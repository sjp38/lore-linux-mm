Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id UAA23450
	for <linux-mm@kvack.org>; Fri, 18 Oct 2002 20:40:13 -0700 (PDT)
Received: from schumi.digeo.com ([192.168.1.205])
 by digeo-nav01.digeo.com (NAVGW 2.5.2.12) with SMTP id M2002101820413216718
 for <linux-mm@kvack.org>; Fri, 18 Oct 2002 20:41:32 -0700
Message-ID: <3DB0D41D.329F1E51@digeo.com>
Date: Fri, 18 Oct 2002 20:40:13 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: 2.5.43-mm3
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

url: http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.43/2.5.43-mm3/

Basically everything is broken.  My attempt to merge two large,
conflicting patches from Bill and Dave was, er, approximate.

Bill, please go through what's there and fix up the hugetlb
rework.

Dave, the shared pagetable patch in broken-out/shpte-ng.patch
fails with X applications.  Probably something trivial.  It fails
whether or not shared pagetables are enabled.  An incremental patch
against that would be appreciated.

Please, no more monsters.  It makes a big mess.  I'm carrying
95 patches now and 2.5.44 is about to hit.  Probably will start
tossing things soon.


+dio-submit-fix.patch

 Tries to fix direct-io but doesn't.

+unbloat-pid.patch
+per-cpu-ratelimits.patch
+for-each-cpu.patch
+per-cpu-01-core.patch
+per-cpu-02-rcu.patch
+per-cpu-02-rcu-fix.patch
+per-cpu-03-timer.patch
+per-cpu-04-tasklet.patch
+per-cpu-05-bh.patch

 Lots of kernel-shrinking work.

+shmem_getpage-unlock_page.patch
+shmem_getpage-beyond-eof.patch
+shmem_getpage-reading-holes.patch
+shmem-fs-cleanup.patch
+shmem_file_sendfile.patch
+shmem_file_write-update.patch
+shmem_getpage-flush_dcache.patch
+loopable-tmpfs.patch

 Hugh.  Haven't even looked at this yet.

+htlb-update.patch

 Some stuff I pulled out of Bill's update

+hugetlbfs-update.patch

 Some more stuff

+htlb-shm-update.patch

 Even more stuff

+acl-xattr-on.patch

 Make extended attributes and acls "on" in config

+shmem_populate.patch

 Hugh's delta to Ingo's mpopulate code.

+shpte-ng.patch

 Not in the rollup.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
