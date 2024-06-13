// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "custom/menu"
import "custom/image_upload"
//import "../../assets/stylesheets/micropost_dialog.css" // 2024.06.11 add modal dialog

import jquery from "jquery"
window.$ = jquery // TODO:micropost/xxxをリロードすると、ReferenceError: $ is not defined が発生するのが課題