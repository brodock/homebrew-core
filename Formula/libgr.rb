class Libgr < Formula
  desc "GR framework: a graphics library for visualisation applications"
  homepage "https://gr-framework.org/"
  url "https://github.com/sciapp/gr/archive/v0.44.1.tar.gz"
  sha256 "43979bee9f9bffd145e9e076d1ee24e6ecf3866eb6c0e34631da922bfb4dc0b5"

  depends_on :xcode => :build
  depends_on "ffmpeg" => :build
  depends_on "pkg-config" => :build
  depends_on :x11

  def install
    inreplace "3rdparty/Makefile", "EXTRAS = tiff ogg theora vpx openh264 ffmpeg glfw zeromq pixman cairo", "EXTRAS = tiff glfw pixman zeromq cairo"
    system "make", "self", "GRDIR=#{prefix}"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <gr.h>

      int main(void) {
          gr_opengks();
          gr_openws(1, "test.png", 140);
          double x[] = {0, 0.2, 0.4, 0.6, 0.8, 1.0};
          double y[] = {0.3, 0.5, 0.4, 0.2, 0.6, 0.7};
          gr_polyline(6, x, y);
          gr_axes(gr_tick(0, 1), gr_tick(0, 1), 0, 0, 1, 1, -0.01);
          gr_updatews();
          gr_emergencyclosegks();
          return 0;
      }
    EOS

    system ENV.cc, "test.c", "-o", "test", "-I#{include}", "-L#{lib}", "-lGR"
    system "./test"

    assert_predicate testpath/"test.png", :exist?
  end
end
