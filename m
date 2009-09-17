Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AFF5A6B0093
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 18:44:51 -0400 (EDT)
Received: by ywh28 with SMTP id 28so633690ywh.11
        for <linux-mm@kvack.org>; Thu, 17 Sep 2009 15:44:55 -0700 (PDT)
From: Nitin Gupta <ngupta@vflare.org>
Subject: [PATCH 4/4] documentation
Date: Fri, 18 Sep 2009 04:13:32 +0530
Message-Id: <1253227412-24342-5-git-send-email-ngupta@vflare.org>
In-Reply-To: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>
List-ID: <linux-mm.kvack.org>

Short guide on how to setup and use ramzswap.

Signed-off-by: Nitin Gupta <ngupta@vflare.org>

---
 drivers/staging/ramzswap/ramzswap.txt |   51 +++++++++++++++++++++++++++++++++
 1 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/ramzswap/ramzswap.txt b/drivers/staging/ramzswap/ramzswap.txt
new file mode 100644
index 0000000..e9f1619
--- /dev/null
+++ b/drivers/staging/ramzswap/ramzswap.txt
@@ -0,0 +1,51 @@
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
+Individual ramzswap devices are configured and initialized using rzscontrol
+userspace utility as shown in examples below. See rzscontrol man page for more
+details.
+
+* Usage
+
+Following shows a typical sequence of steps for using ramzswap.
+
+1) Load Modules:
+	modprobe ramzswap num_devices=4
+	This creates 4 (uninitialized) devices: /dev/ramzswap{0,1,2,3}
+	(num_devices parameter is optional. Default: 1)
+
+2) Initialize:
+	Use rzscontrol utility to configure and initialize individual
+	ramzswap devices. Example:
+	rzscontrol /dev/ramzswap2 --init # uses default value of disksize_kb
+
+	*See rzscontrol man page for more details and examples*
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
