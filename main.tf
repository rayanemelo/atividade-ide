terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = ">= 5.0.0"
    }
  }
}

provider "keycloak" {
  url       = "http://keycloak:8080"
  realm     = "master"
  client_id = "admin-cli"
  username  = "admin"
  password  = var.kc_admin_password
}


variable "kc_admin_password" { type = string } 
variable "kc_secret_key" { type = string } 

variable "google_client_id"      { type = string }
variable "google_client_secret" {
  type      = string
  sensitive = true
}

variable "github_client_id"      { type = string }
variable "github_client_secret" {
  type      = string
  sensitive = true
}


resource "keycloak_realm" "realm" {
  realm             = "IDP"
  enabled           = true
  display_name      = "IDP" 
  registration_allowed = true

  otp_policy {
    type               = "totp"        # "totp" ou "hotp"
    algorithm          = "HmacSHA1"    # HmacSHA1, HmacSHA256, HmacSHA512
    digits             = 6
    period             = 30            # segundos
    look_ahead_window  = 1
    initial_counter    = 0             # relevante só para HOTP
  }
}


resource "keycloak_openid_client" "openid_client" {
  realm_id                     = keycloak_realm.realm.id
  client_id                    = "SP"
  name                         = "SP"
  enabled                      = true

  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true        
  implicit_flow_enabled        = false
  direct_access_grants_enabled = false
  service_accounts_enabled     = false        

  valid_redirect_uris          = [
    "*"  
  ]
  web_origins                  = ["+"]      
  login_theme                  = "keycloak"
  client_secret                = var.kc_secret_key
}


resource "keycloak_required_action" "require_totp" {
  realm_id       = keycloak_realm.realm.id
  alias          = "CONFIGURE_TOTP"  # built-in
  name           = "Configure OTP"
  enabled        = true
  default_action = true
  priority       = 50
}


resource "keycloak_user" "ray" {
  realm_id        = keycloak_realm.realm.id
  username        = "ray"
  email           = "ray@email.com"
  email_verified  = true
  enabled         = true

  required_actions = ["CONFIGURE_TOTP"] 

  initial_password {
    value     = "ray123"
    temporary = true
  }
}


resource "keycloak_oidc_google_identity_provider" "google" {
  realm         = keycloak_realm.realm.id
  client_id     = var.google_client_id
  client_secret = var.google_client_secret
  trust_email   = true 
  hosted_domain = "*"
  sync_mode     = "IMPORT"
}


resource "keycloak_oidc_identity_provider" "github" {
  realm                                = keycloak_realm.realm.id
  alias                                = "github"
  display_name                         = "GitHub"
  enabled                              = true 
  trust_email                          = true 

  authorization_url                    = "https://github.com/login/oauth/authorize"
  token_url                            = "https://github.com/login/oauth/access_token"
  user_info_url                        = "https://api.github.com/user"

  client_id                            = var.github_client_id
  client_secret                        = var.github_client_secret 
}
