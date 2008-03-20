Received: by hs-out-0708.google.com with SMTP id j58so798698hsj.6
        for <linux-mm@kvack.org>; Thu, 20 Mar 2008 13:17:25 -0700 (PDT)
From: Nitin Gupta <nitingupta910@gmail.com>
Reply-To: nitingupta910@gmail.com
Subject: [RFC][PATCH 6/6] compcache: Documentation
Date: Fri, 21 Mar 2008 01:42:45 +0530
References: <200803210129.59299.nitingupta910@gmail.com>
In-Reply-To: <200803210129.59299.nitingupta910@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200803210142.45812.nitingupta910@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

compcache usage documentation.

Signed-off-by: Nitin Gupta <nitingupta910 at gmail dot com>
---
 Documentation/compcache.txt |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/Documentation/compcache.txt b/Documentation/compcache.txt
new file mode 100644
index 0000000..9ece295
--- /dev/null
+++ b/Documentation/compcache.txt
@@ -0,0 +1,24 @@
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
+* Usage
+ - modprobe compcache compcache_size_kbytes=<size>
+   (If no size is specified, default size of 25% of RAM is taken).
+ - swapon /dev/ramzswap0
+
+* Notes
+ - Allocator and compcache statistics are exported via /proc interface:
+   - /proc/tlsfinfo
+   - /proc/compcache
+
+
+Nitin Gupta
+(nitingupta910 at gmail dot com)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
