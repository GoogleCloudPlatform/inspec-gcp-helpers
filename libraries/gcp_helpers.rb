# frozen_string_literal: true
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Base Class for GCP Cache Classes
#
class GCPBaseCache < Inspec.resource(1)
  name 'GCPBaseCache'
  desc 'The GCP Base cache resource is inherited by more specific cache
       classes (e.g. GCE, GKE). The cache is consumed by the CIS and PCI
       Google Inspec profiles:
       https://github.com/GoogleCloudPlatform/inspec-gcp-cis-benchmark'
  attr_reader :gke_locations

  def initialize(project: '')
    @gcp_project_id = project
    @gke_locations = []
  end

  protected

  def all_gcp_locations
    locations = inspec.google_compute_zones(project: @gcp_project_id).zone_names
    locations += inspec.google_compute_regions(project: @gcp_project_id)
                       .region_names
    locations
  end
end

# Cache for GKE cluster list.
#
class GKECache < GCPBaseCache
  name 'GKECache'
  desc 'The GKE cache resource contains functions consumed by the CIS/PCI
       Google profiles:
       https://github.com/GoogleCloudPlatform/inspec-gcp-cis-benchmark'
  attr_reader :gke_locations

  @@cached_gke_clusters = []
  @@gke_clusters_cached = false

  def initialize(project: '', gke_locations: [])
    @gcp_project_id = project
    @gke_locations = if gke_locations.join.empty?
                       all_gcp_locations
                     else
                       gke_locations
                     end
  end

  def gke_clusters_cache
    set_gke_clusters_cache unless gke_cached?
    @@cached_gke_clusters
  end

  def gke_cached?
    @@gke_clusters_cached
  end

  def set_gke_clusters_cache
    @@cached_gke_clusters = []
    collect_gke_clusters_by_location(@gke_locations)
    @@gke_clusters_cached = true
  end

  private

  def collect_gke_clusters_by_location(gke_locations)
    gke_locations.each do |gke_location|
      inspec.google_container_clusters(project: @gcp_project_id,
                                       location: gke_location).cluster_names
            .each do |gke_cluster|
        @@cached_gke_clusters.push({ cluster_name: gke_cluster,
                                     location: gke_location })
      end
    end
  end
end

# Cache for GCE instances
#
class GCECache < GCPBaseCache
  name 'GCECache'
  desc 'The GCE cache resource contains functions consumed by the CIS/PCI
       Google profiles:
       https://github.com/GoogleCloudPlatform/inspec-gcp-cis-benchmark'
  attr_reader :gce_zones

  @@cached_gce_instances = []
  @@gce_instances_cached = false

  def initialize(project: '', gce_zones: [])
    @gcp_project_id = project
    @gce_zones = if gce_zones.join.empty?
                   inspec.google_compute_zones(project: @gcp_project_id)
                         .zone_names
                 else
                   gce_zones
                 end
  end

  def gce_instances_cache
    set_gce_instances_cache unless gce_cached?
    @@cached_gce_instances
  end

  def gce_cached?
    @@gce_instances_cached
  end

  def set_gce_instances_cache
    @@cached_gce_instances = []
    # Loop/fetch/cache the names and locations of GKE clusters
    @gce_zones.each do |gce_zone|
      inspec.google_compute_instances(project: @gcp_project_id, zone: gce_zone)
            .instance_names.each do |instance|
        @@cached_gce_instances.push({ name: instance, zone: gce_zone })
      end
    end
    # Mark the cache as full
    @@gce_instances_cached = true
    @@cached_gce_instances
  end
end
