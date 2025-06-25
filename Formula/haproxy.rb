class Haproxy < Formula
  desc "Reliable, high performance TCP/HTTP load balancer"
  homepage "https://www.haproxy.org/"
  url "https://www.haproxy.org/download/3.2/src/haproxy-3.2.1.tar.gz"
  sha256 "bb3f967a797c8851d08683ec43dfafe4ad7bf5ad86fa6b0721cad033ea9e5ae5"
  license "GPL-2.0-or-later" => { with: "openvpn-openssl-exception" }

  livecheck do
    url :homepage
    regex(/href=.*?haproxy[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "openssl@3"
  depends_on "pcre2"
  depends_on "lua"

  uses_from_macos "libxcrypt"
  uses_from_macos "zlib"

  def install
    lua = Formula["lua"]
    target = if OS.mac?
      "osx"
    else
      "linux-glibc"
    end

    args = %W[
      TARGET=#{target}
      USE_KQUEUE=1
      USE_POLL=1
      USE_PCRE2=1
      USE_PCRE2_JIT=1
      USE_OPENSSL=1
      USE_THREAD=1
      USE_ZLIB=1
      ADDLIB=-lcrypto
      USE_LUA=1
      LUA_LIB=#{lua.opt_lib}
      LUA_INC=#{lua.opt_include}/lua
      LUA_LD_FLAGS=-L#{lua.opt_lib}
    ]

    # We build generic since the Makefile.osx doesn't appear to work
    system "make", "CC=#{ENV.cc}", "CFLAGS=#{ENV.cflags}", "LDFLAGS=#{ENV.ldflags}", *args
    man1.install "doc/haproxy.1"
    bin.install "haproxy"
  end

  service do
    run [opt_bin/"haproxy", "-f", etc/"haproxy.cfg"]
    keep_alive true
    log_path var/"log/haproxy.log"
    error_log_path var/"log/haproxy.log"
  end

  test do
    system bin/"haproxy", "-v"
  end
end
