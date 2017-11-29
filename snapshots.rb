#!/usr/bin/env ruby

# By Orlando de Frias - realmadrid2727@gmail.com

require 'rubygems'
require 'aws-sdk' # sudo gem install aws-sdk

# Used for state checking
COMPLETED = "completed"
# Number of backups to keep around at any given time
MAX_KEEP = 3
# AWS configuration
AWS_KEY = ""
AWS_SECRET = ""

Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(AWS_KEY, AWS_SECRET)
})

# Runs the backup creation and cleanup
def process(_type = :daily) # Accepts :daily, :weekly, :monthly
  client = Aws::EC2::Client.new
  
  delete_snapshots!(client)
  create_snapshots!(client, _type)
end

# Gets available auto snapshots
def snapshots
  client = Aws::EC2::Client.new
  client.describe_snapshots({
    filters: [{
      name: "tag:type",
      values: ["auto"]
    }]
  }).snapshots
end

# Get a list of valid volumes to back up
def volumes
  client = Aws::EC2::Client.new
  client.describe_volumes({
    filters: [{
      name: "tag:backup",
      values: ["true"]
    }]
  }).volumes
end

# Creates the snapshot
def create_snapshots!(client, _type)
  # Back up all volumes that require it
  volumes.each do |volume|
    response = client.create_snapshot({
      volume_id: volume.volume_id,
      description: "Automatic #{_type.to_s} backup #{Time.now.utc.strftime("%A, %d %b %Y %l:%M %p")}",
    })
    
    # Add the tag
    client.create_tags({
      resources: [response.snapshot_id],
      tags: [
        {
          key: "type",
          value: "auto",
        },
      ],
    })
  end
end

# Delete snapshots
def delete_snapshots!(client)
  # Remove older backups
  delete_snapshots = []
  
  if snapshots.count >= MAX_KEEP
    delete_snapshots = snapshots.sort_by(&:start_time)[0..snapshots.length-MAX_KEEP].map {|snapshot| snapshot.snapshot_id}
    delete_snapshots.each do |snapshot_id|
      client.delete_snapshot({
        snapshot_id: snapshot_id
      })
    end
  end
end


# Run the snapshots
process
