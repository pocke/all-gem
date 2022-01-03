D = Steep::Diagnostic

target :lib do
  signature "sig"
  signature "sig_internal"

  check "lib"                       # Directory name

  library 'rubygems'

  configure_code_diagnostics(D::Ruby.default)
end
