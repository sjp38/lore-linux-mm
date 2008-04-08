From: Nitin Gupta <nitingupta910@gmail.com>
Subject: [PATCH 3/3] compcache: documentation
Date: Tue, 8 Apr 2008 15:06:49 +0530
Message-ID: <200804081506.49931.nitingupta910@gmail.com>
References: <200804081459.27382.nitingupta910@gmail.com>
Reply-To: nitingupta910@gmail.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754019AbYDHJtU@vger.kernel.org>
In-Reply-To: <200804081459.27382.nitingupta910@gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-Id: linux-mm.kvack.org

compcache usage documentation.

Signed-off-by: Nitin Gupta <nitingupta910 at gmail dot com>
---
 Documentation/compcache.txt |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/Documentation/compcache.txt b/Documentation/compcache.txt
new file mode 100644
index 0000000..2500da6
--- /dev/null
+++ b/Documentation/compcache.txt
@@ -0,0 +1,29 @@
+
+compcache: Compressed RAM based swap device
+-------------------------------------------
+
+Project home: http://code.google.com/p/compcache
+
+* Introduction
+This is a RAM based block device which acts as swap disk.
+Pages swapped to this device are compressed and stored in
+memory itself.
+
+It uses these components:
+ - TLSF: memory allocator
+ - LZO: de/compressor
+
+* Usage
+ - modprobe compcache compcache_size_kbytes=<size>
+   (If no size is specified, default size of 25% of RAM is taken).
+ - swapon /dev/ramzswap0
+
+* Notes
+ - Allocator and compcache statistics are exported via /proc interface:
+   (if stats are enabled for corresponding modules)
+   - /proc/tlsfinfo (from tlsf.ko)
+   - /proc/compcache (from compcache.ko)
+
+
+Nitin Gupta
+(nitingupta910@gmail.com)
