Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3D40C6B0078
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 09:20:12 -0500 (EST)
Received: by yxe6 with SMTP id 6so4505298yxe.11
        for <linux-mm@kvack.org>; Mon, 22 Feb 2010 06:20:10 -0800 (PST)
Date: Mon, 22 Feb 2010 22:19:44 +0800
From: Dave Young <hidave.darkstar@gmail.com>
Subject: [PATCH 04/06] kernel.h intr_sqrt cleanup
Message-ID: <20100222141944.GA9031@darkstar>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Mauro Carvalho Chehab <mchehab@infradead.org>, HIRANO Takahito <hiranotaka@zng.info>, Hans Verkuil <hverkuil@xs4all.nl>, Miroslav Sustek <sustmidown@centrum.cz>, Marton Balint <cus@fazekas.hu>, Stefano Brivio <stefano.brivio@polimi.it>, "John W. Linville" <linville@tuxdriver.com>, netrolller.3d@gmail.com, Greg Kroah-Hartman <gregkh@suse.de>, Bruce Jones <brucej@linux.com>, Manuel Gebele <forensixs@gmx.de>, Mithlesh Thukral <mithlesh@linsyssoft.com>, Krzysztof Oledzki <olel@ans.pl>, Ian Lance Taylor <iant@google.com>, Troy Moure <twmoure@szypr.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Benny Halevy <bhalevy@panasas.com>, Andy Adamson <andros@netapp.com>, Jens Axboe <jens.axboe@oracle.com>, Dean Hildebrand <dhildeb@us.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, pekkas@netcore.fi, James Morris <jmorris@namei.org>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Patrick McHardy <kaber@trash.net>, Eric Dumazet <eric.dumazet@gmail.com>, Neil Horman <nhorman@tuxdriver.com>, Ingo Molnar <mingo@elte.hu>, Alexey Dobriyan <adobriyan@gmail.com>, linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org, netdev@vger.kernel.org, devel@driverdev.osuosl.org, linux-fbdev@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

int_sqrt in kernel.h should be put into a standalone head file

cleanup int_sqrt declarations in kernel.h, put them into int_sqrt.h
include int_sqrt.h in every file which need it

Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
---
 drivers/media/dvb/pt1/va1j5jf8007s.c     |    1 +
 drivers/media/video/cx88/cx88-dsp.c      |    1 +
 drivers/net/wireless/b43/phy_lp.c        |    1 +
 drivers/staging/comedi/drivers/vmk80xx.c |    1 +
 drivers/video/fbmon.c                    |    1 +
 fs/nfs/write.c                           |    1 +
 include/linux/int_sqrt.h                 |    6 ++++++
 lib/int_sqrt.c                           |    1 +
 mm/memcontrol.c                          |    1 +
 mm/oom_kill.c                            |    1 +
 mm/page_alloc.c                          |    1 +
 net/ipv4/route.c                         |    1 +
 12 files changed, 17 insertions(+)

--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/int_sqrt.h	2010-02-16 17:39:26.000000000 +0800
@@ -0,0 +1,6 @@
+#ifndef _INT_SQRT_H
+#define _INT_SQRT_H
+
+extern unsigned long int_sqrt(unsigned long);
+
+#endif
--- linux-2.6.orig/drivers/media/dvb/pt1/va1j5jf8007s.c	2010-02-16 17:11:37.000000000 +0800
+++ linux-2.6/drivers/media/dvb/pt1/va1j5jf8007s.c	2010-02-16 17:39:26.000000000 +0800
@@ -25,6 +25,7 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/i2c.h>
+#include <linux/int_sqrt.h>
 #include "dvb_frontend.h"
 #include "va1j5jf8007s.h"
 
--- linux-2.6.orig/drivers/media/video/cx88/cx88-dsp.c	2010-02-16 17:11:37.000000000 +0800
+++ linux-2.6/drivers/media/video/cx88/cx88-dsp.c	2010-02-16 17:39:26.000000000 +0800
@@ -22,6 +22,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/jiffies.h>
+#include <linux/int_sqrt.h>
 #include <asm/div64.h>
 
 #include "cx88.h"
--- linux-2.6.orig/drivers/net/wireless/b43/phy_lp.c	2010-02-16 17:11:37.000000000 +0800
+++ linux-2.6/drivers/net/wireless/b43/phy_lp.c	2010-02-16 17:39:26.000000000 +0800
@@ -23,6 +23,7 @@
 
 */
 
+#include <linux/int_sqrt.h>
 #include "b43.h"
 #include "main.h"
 #include "phy_lp.h"
--- linux-2.6.orig/drivers/staging/comedi/drivers/vmk80xx.c	2010-02-16 17:11:37.000000000 +0800
+++ linux-2.6/drivers/staging/comedi/drivers/vmk80xx.c	2010-02-16 17:39:26.000000000 +0800
@@ -61,6 +61,7 @@ Changelog:
 #include <linux/poll.h>
 #include <linux/usb.h>
 #include <linux/uaccess.h>
+#include <linux/int_sqrt.h>
 
 #include "../comedidev.h"
 
--- linux-2.6.orig/drivers/video/fbmon.c	2010-02-16 17:11:37.000000000 +0800
+++ linux-2.6/drivers/video/fbmon.c	2010-02-16 17:39:26.000000000 +0800
@@ -29,6 +29,7 @@
 #include <linux/fb.h>
 #include <linux/module.h>
 #include <linux/pci.h>
+#include <linux/int_sqrt.h>
 #include <video/edid.h>
 #ifdef CONFIG_PPC_OF
 #include <asm/prom.h>
--- linux-2.6.orig/fs/nfs/write.c	2010-02-16 17:11:37.000000000 +0800
+++ linux-2.6/fs/nfs/write.c	2010-02-16 17:39:26.000000000 +0800
@@ -20,6 +20,7 @@
 #include <linux/nfs_mount.h>
 #include <linux/nfs_page.h>
 #include <linux/backing-dev.h>
+#include <linux/int_sqrt.h>
 
 #include <asm/uaccess.h>
 
--- linux-2.6.orig/lib/int_sqrt.c	2010-02-16 17:11:37.000000000 +0800
+++ linux-2.6/lib/int_sqrt.c	2010-02-16 17:39:26.000000000 +0800
@@ -1,6 +1,7 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/int_sqrt.h>
 
 /**
  * int_sqrt - rough approximation to sqrt
--- linux-2.6.orig/mm/memcontrol.c	2010-02-16 17:11:37.000000000 +0800
+++ linux-2.6/mm/memcontrol.c	2010-02-16 17:39:26.000000000 +0800
@@ -39,6 +39,7 @@
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
+#include <linux/int_sqrt.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
--- linux-2.6.orig/mm/oom_kill.c	2010-02-16 17:11:37.000000000 +0800
+++ linux-2.6/mm/oom_kill.c	2010-02-16 17:39:26.000000000 +0800
@@ -27,6 +27,7 @@
 #include <linux/notifier.h>
 #include <linux/memcontrol.h>
 #include <linux/security.h>
+#include <linux/int_sqrt.h>
 
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
--- linux-2.6.orig/mm/page_alloc.c	2010-02-16 17:11:37.000000000 +0800
+++ linux-2.6/mm/page_alloc.c	2010-02-16 17:39:26.000000000 +0800
@@ -49,6 +49,7 @@
 #include <linux/debugobjects.h>
 #include <linux/kmemleak.h>
 #include <linux/memory.h>
+#include <linux/int_sqrt.h>
 #include <trace/events/kmem.h>
 
 #include <asm/tlbflush.h>
--- linux-2.6.orig/net/ipv4/route.c	2010-02-16 17:11:37.000000000 +0800
+++ linux-2.6/net/ipv4/route.c	2010-02-16 17:39:26.000000000 +0800
@@ -104,6 +104,7 @@
 #include <net/xfrm.h>
 #include <net/netevent.h>
 #include <net/rtnetlink.h>
+#include <linux/int_sqrt.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
