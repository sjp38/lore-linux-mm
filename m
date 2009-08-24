Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BC2F76B0128
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 01:03:22 -0400 (EDT)
Received: by pzk36 with SMTP id 36so2092401pzk.12
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 22:03:22 -0700 (PDT)
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
Subject: [PATCH 4/4] compcache: documentation
Date: Mon, 24 Aug 2009 10:08:02 +0530
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200908241008.02184.ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

Short guide on how to setup and use ramzswap.

Signed-off-by: Nitin Gupta <ngupta@vflare.org>
---

 Documentation/blockdev/00-INDEX     |    2 +
 Documentation/blockdev/ramzswap.txt |   52 +++++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/Documentation/blockdev/00-INDEX b/Documentation/blockdev/00-INDEX
index c08df56..c1cb074 100644
--- a/Documentation/blockdev/00-INDEX
+++ b/Documentation/blockdev/00-INDEX
@@ -16,3 +16,5 @@ paride.txt
 	- information about the parallel port IDE subsystem.
 ramdisk.txt
 	- short guide on how to set up and use the RAM disk.
+ramzswap.txt
+	- short guide on how to setup compressed in-memory swap device.
diff --git a/Documentation/blockdev/ramzswap.txt b/Documentation/blockdev/ramzswap.txt
new file mode 100644
index 0000000..463dd2d
--- /dev/null
+++ b/Documentation/blockdev/ramzswap.txt
@@ -0,0 +1,52 @@
+ramzswap: Compressed RAM based swap device
+-------------------------------------------
+
+Project home: http://compcache.googlecode.com/
+
+* Introduction
+
+It creates RAM based block devices which can be used (only) as swap disks.
+Pages swapped to these devices are compressed and stored in memory itself.
+See project home for use cases, performance numbers and a lot more.
+
+It consists of three modules:
+ - xvmalloc.ko: memory allocator
+ - ramzswap.ko: virtual block device driver
+ - rzscontrol userspace utility: to control individual ramzswap devices
+
+* Usage
+
+Following shows a typical sequence of steps for using ramzswap.
+
+1) Load Modules:
+	modprobe ramzswap NUM_DEVICES=4
+	This creates 4 (uninitialized) devices: /dev/ramzswap{0,1,2,3}
+	(NUM_DEVICES parameter is optional. Default: 1)
+
+2) Initialize:
+	Use rzscontrol utility to configure and initialize individual
+	ramzswap devices. Example:
+	rzscontrol /dev/ramzswap2 --init # uses default value of disksize_kb
+
+	*See rzscontrol manpage for more details and examples*
+
+3) Activate:
+	swapon /dev/ramzswap2 # or any other initialized ramzswap device
+
+4) Stats:
+	rzscontrol /dev/ramzswap2 --stats
+
+5) Deactivate:
+	swapoff /dev/ramzswap2
+
+6) Reset:
+	rzscontrol /dev/ramzswap2 --reset
+	(This frees all the memory allocated for this device).
+
+
+Please report any problems at:
+ - Mailing list: linux-mm-cc at laptop dot org
+ - Issue tracker: http://code.google.com/p/compcache/issues/list
+
+Nitin Gupta
+ngupta@vflare.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
