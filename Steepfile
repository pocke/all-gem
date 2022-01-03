D = Steep::Diagnostic

target :lib do
  signature "sig"
  signature "sig_internal"

  check "lib"                       # Directory name

  library 'rubygems'
  library 'optparse'

  configure_code_diagnostics(D::Ruby.default)
end
