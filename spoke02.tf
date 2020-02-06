resource "oci_core_vcn" "spoke02" {
  cidr_block     = "10.20.0.0/16"
  dns_label      = "spoke02"
  compartment_id = var.compartment_ocid
  display_name   = "spoke02"
}

#LPG Spoke-HUB
resource "oci_core_local_peering_gateway" "spoke02_hub_local_peering_gateway" {
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.spoke02.id
    display_name = "spoke02_hub_lpg"
}

resource "oci_core_subnet" "spoke02_subnet_pub01" {
    cidr_block = "10.20.10.0/24"
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.spoke02.id
    display_name = "spoke2_subnet_pub01"
}

output "vcn_id_spoke02" {
  value = oci_core_vcn.spoke02.id
}

output "vcn_spoke02_lpg"{
  value = oci_core_local_peering_gateway.spoke02_hub_local_peering_gateway.id
} 

resource "oci_core_instance" "spoke02_test_instance" {
  # count = var.NumInstances
  availability_domain = data.oci_identity_availability_domain.default_AD.name
  compartment_id = var.compartment_ocid
  display_name = "spoke02_test_instance"
  shape = var.InstanceShape

  create_vnic_details {
    subnet_id = oci_core_subnet.spoke02_subnet_pub01.id
    display_name = "primaryvnic"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id = var.InstanceImageOCID[var.region]

  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  
  }
  # timeouts {
  #   create = "60m"
  # }
}