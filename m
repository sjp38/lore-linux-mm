Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id WAA28675
	for <linux-mm@kvack.org>; Sun, 10 Nov 2002 22:29:43 -0800 (PST)
Message-ID: <3DCF4E57.AA92B134@digeo.com>
Date: Sun, 10 Nov 2002 22:29:43 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: 2.5.47-mm1
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.47/2.5.47-mm1/

Nothing much new here, except for the rbtree-based IO scheduler.
This needs a lot of benching please.

And reiserfs doesn't immediately oops this time.



Since 2.5.46-mm2:

-genksyms-hurts.patch

 Wrong, dropped.

-misc.patch
-writev-bad-seg-fix.patch
-wli-01-iowait.patch
-wli-02-zap_hugetlb_resources.patch
-wli-03-remove-unlink_vma.patch
-wli-04-internalize-hugetlb-init.patch
-wli-05-sysctl-cleanup.patch
-wli-06-cleanup-proc.patch
-wli-07-hugetlb-static.patch
-msec-fix.patch
-touch_buffer-fix.patch
-pgalloc-accounting-fix.patch
-nuke-disk-stats.patch

 Merged

+genksyms-fix.patch

 Really fix the exporting of per-cpu data to modules with modversioning.

+buffer-debug.patch

 Add some printk's to catch what appears to be a blockdev pagecache invalidation
 problem.

+mbcache-cleanup.patch

 Some fs/mbcache work from Andreas, in for some testing.

+ip6-mcast-timer.patch

 Init a timer in ipv6

+reiserfs-readpages-fix.patch

 Fix reiserfs3

+swapcache-throttle.patch

 Random change to VM throttling which doesn't do much.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
