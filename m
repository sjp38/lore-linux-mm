Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9H1ooJD017611
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 17 Oct 2008 10:50:50 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 81DB853C124
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 10:50:50 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AA7C24005B
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 10:50:50 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 464CA1DB803E
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 10:50:50 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id F22C21DB8042
	for <linux-mm@kvack.org>; Fri, 17 Oct 2008 10:50:49 +0900 (JST)
Date: Fri, 17 Oct 2008 10:50:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mmotm][PATCH] memcg-allocate-all-page_cgroup-at-boot-fix.patch
Message-Id: <20081017105028.fac894c0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081017093046.80ae7d14.kamezawa.hiroyu@jp.fujitsu.com>
References: <200810160758.m9G7wZmt018529@imap1.linux-foundation.org>
	<Pine.LNX.4.64.0810161400230.14604@shark.he.net>
	<20081017093046.80ae7d14.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "Randy.Dunlap" <rdunlap@xenotime.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Oct 2008 09:30:46 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Hmm....it seems
> 
> memcg-allocate-all-page_cgroup-at-boot.patch doesn't includes changes to Makefile...
> 
> Thank you for report. I'll send a fix soon.
> 
This is a fix. for this.

Confirmed vmlinux can be compiled with the config.
(but need to turn off CONFIG_HID_SUPPORT..and found small troube in /samples
 directory's Makefile.

-Kame
==

compile fix to memcg-allocate-all-page_cgroup-at-boot.patch


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/Makefile |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.27/mm/Makefile
===================================================================
--- linux-2.6.27.orig/mm/Makefile
+++ linux-2.6.27/mm/Makefile
@@ -33,5 +33,5 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
-obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
 obj-$(CONFIG_CGROUP_MEMRLIMIT_CTLR) += memrlimitcgroup.o


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
