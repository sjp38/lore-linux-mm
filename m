Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id VAA25273
	for <linux-mm@kvack.org>; Wed, 23 Oct 2002 21:28:37 -0700 (PDT)
Message-ID: <3DB776F5.C5AA1922@digeo.com>
Date: Wed, 23 Oct 2002 21:28:37 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: 2.5.44-mm4
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

url: http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.44/2.5.44-mm4/

Having a few stability problems so most of the new things have been
removed.  Once this thing is working properly we can start moving
forward again.

If the people who had problem with -mm4 could please retest?  If
problems remain, please try popping off shpte-ng.patch.

Also be suspicious of CONFIG_PREEMPT=y.  For me, with preempt, smp
and spinlock debugging the kernel dies immediately doing an unlock
of already-unlocked kernel_flag when bringing up the first migration
thread.  That's on base 2.5.44.  May not be a preempt problem; could
be that preempt is simply exposing it.

+read-barrier-depends.patch

 RCU fix

+deferred-lru-add-fix.patch

 lru_cache_add fix

-for-each-cpu.patch

 Dropped.  Rusty has a different cpu iterator patch

-task-unmapped-base-fix.patch

 Folded into ingo-mmap-speedup

-larger-cpu-masks.patch
-adam-loop.patch
-rcu-stats.patch
-generic-nonlinear-mappings-D0.patch

 Over in experimental/

+md-01-driverfs-core.patch
+md-02-driverfs-topology.patch
+md-03-numa-meminfo.patch
+md-04-memblk_online_map.patch
+md-05-node_online_map.patch

 The NUMA driverfs interfaces from Matt Dobson.  Queued up in
 experimental/ too.  It all adds only a few hundred bytes to a
 non-NUMA build.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
