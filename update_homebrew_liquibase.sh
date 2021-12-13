#!/bin/bash
VERSION="${1:-"$(curl -s https://github.com/liquibase/liquibase/releases/latest | grep -o "v.*" | sed s/'>.*'//g |  sed s/'v'//g | sed 's/"//g')"}"
curl -L https://github.com/liquibase/liquibase/releases/download/v${VERSION}/liquibase-${VERSION}.tar.gz --output liquibase-${VERSION}.tar.gz
NEW_CHECKSUM=$(sha256sum liquibase-${VERSION}.tar.gz | awk '{print $1}')

echo "class Liquibase < Formula
  desc \"Library for database change tracking\"
  homepage \"https://www.liquibase.org/\"
  url \"https://github.com/liquibase/liquibase/releases/download/v${VERSION}/liquibase-${VERSION}.tar.gz\"
  sha256 \"${NEW_CHECKSUM}\"
  license \"Apache-2.0\"
  bottle do
    sha256 cellar: :any_skip_relocation, all: \"99370e7302eb02c7927604b7c3a8e0f69a2d335715e57e691e3c8c88acbbbb94\"
  end
  depends_on \"openjdk\"
  def install
    rm_f Dir[\"*.bat\"]
    chmod 0755, \"liquibase\"
    prefix.install_metafiles
    libexec.install Dir[\"*\"]
    (bin/\"liquibase\").write_env_script libexec/\"liquibase\", JAVA_HOME: Formula[\"openjdk\"].opt_prefix
    (libexec/\"lib\").install_symlink Dir[\"\#{libexec}/sdk/lib-sdk/slf4j*\"]
  end
  def caveats
    <<~EOS
      You should set the environment variable LIQUIBASE_HOME to
        #{opt_libexec}
    EOS
  end
  test do
    system \"\#{bin}/liquibase\", \"--version\"
  end
end" > liquibase.rb

# git clone https://github.com/Homebrew/homebrew-core
git clone https://github.com/szandany/update_homebrew_liquibase_formulae
cd update_homebrew_liquibase_formulae
ls
git config --global user.email szandany@liquibase.com; git config --global user.name Tsvi; git config pull.rebase false
git checkout -b update_lb_${VERSION}
# cp -rf liquibase.rb homebrew-core/liquibase.rb
cp -rf ../liquibase.rb homebrew-core/liquibase.rb
git add .
git commit -m "liquibase: update $VERSION bottle."
git commit --amend
git push --force
cat homebrew-core/liquibase.rb
