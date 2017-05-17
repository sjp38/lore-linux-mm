Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id ABC4F6B02EE
	for <linux-mm@kvack.org>; Wed, 17 May 2017 10:12:35 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t126so10572926pgc.9
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:12:35 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id g15si2186791pgp.346.2017.05.17.07.12.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 07:12:34 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id u187so1991332pgb.1
        for <linux-mm@kvack.org>; Wed, 17 May 2017 07:12:34 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 0/6] refine and rename slub sysfs
Date: Wed, 17 May 2017 22:11:40 +0800
Message-Id: <20170517141146.11063-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

This patch serial could be divided into two parts.

First three patches refine and adds slab sysfs.
Second three patches rename slab sysfs.

1. Refine slab sysfs

There are four level slabs:

    CPU
    CPU_PARTIAL
    PARTIAL
    FULL

And in sysfs, it use show_slab_objects() and cpu_partial_slabs_show() to
reflect the statistics.

In patch 2, it splits some function in show_slab_objects() which makes sure
only cpu_partial_slabs_show() covers statistics for CPU_PARTIAL slabs.

After doing so, it would be more clear that show_slab_objects() has totally 9
statistic combinations for three level of slabs. Each slab has three cases
statistic.

    slabs
    objects
    total_objects

And when we look at current implementation, some of them are missing. So patch
2 & 3 add them up.

2. Rename sysfs

The slab statistics in sysfs are

    slabs
    objects
    total_objects
    cpu_slabs
    partial
    partial_objects
    cpu_partial_slabs

which is a little bit hard for users to understand. The second three patches
rename sysfs file in this pattern.

    xxx_slabs[[_total]_objects]

Finally it looks Like

    slabs
    slabs_objects
    slabs_total_objects
    cpu_slabs
    cpu_slabs_objects
    cpu_slabs_total_objects
    partial_slabs
    partial_slabs_objects
    partial_slabs_total_objects
    cpu_partial_slabs

Wei Yang (6):
  mm/slub: add total_objects_partial sysfs
  mm/slub: not include cpu_partial data in cpu_slabs sysfs
  mm/slub: add cpu_slabs_[total_]objects sysfs
  mm/slub: rename ALL slabs sysfs
  mm/slub: rename partial_slabs sysfs
  mm/slub: rename cpu_partial_slab sysfs

 mm/slub.c | 64 +++++++++++++++++++++++++++++++++++----------------------------
 1 file changed, 36 insertions(+), 28 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
