# InSpec GCP Helpers Resource Pack

Resource pack containing helper functions and classes for Inspec-gcp profiles.

## Required Disclaimer

This is not an officially supported Google product. This code is intended to help users assess their security posture on the Google Cloud against the CIS Benchmark. This code is not certified by CIS.

### Create a profile 

For example, using InSpec e.g.

```
inspec init profile myprofile --platform gcp
```

### Update the inspec.yml file

This should be updated to point here instead of directly to the InSpec GCP resource pack:

```
depends:
- name: inspec-gcp-helpers
  url: https://github.com/GoogleCloudPlatform/inspec-gcp-helpers/archive/master.tar.gz
```

### Use the helper functions

Now we could edit the controls to include lines such as:

```
gcp_project_id = attribute('gcp_project_id')

gke_cache = GKECache(project: gcp_project_id, gke_locations: ['us-central1-a'])
p gke_cache.gke_clusters_cache

gce_cache = GCECache(project: gcp_project_id, gce_zones: ['us-central1-a'])
p gce_cache.gce_instances_cache
```

and directly use these methods in downstream profiles. 

### Other notes

This approach and much of the code in the helper resource originated because of the PR here: https://github.com/inspec/inspec-gcp/pull/245/files and the issue of helper modules with InSpec discussed https://github.com/inspec/inspec/issues/4948.  
