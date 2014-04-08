Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id A630E6B0087
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 04:23:08 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so365671eek.38
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 01:23:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m49si1695502eeo.161.2014.04.08.01.23.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 01:23:04 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/2] Disable zone_reclaim_mode by default v2
Date: Tue,  8 Apr 2014 09:22:58 +0100
Message-Id: <1396945380-18592-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Christoph Lameter <cl@linux.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Changelog since v1
 o topology comment updates

When it was introduced, zone_reclaim_mode made sense as NUMA distances
punished and workloads were generally partitioned to fit into a NUMA
node. NUMA machines are now common but few of the workloads are NUMA-aware
and it's routine to see major performance due to zone_reclaim_mode being
enabled but relatively few can identify the problem.

Those that require zone_reclaim_mode are likely to be able to detect when
it needs to be enabled and tune appropriately so lets have a sensible
default for the bulk of users.

 Documentation/sysctl/vm.txt         | 17 +++++++++--------
 arch/ia64/include/asm/topology.h    |  3 ++-
 arch/powerpc/include/asm/topology.h |  8 ++------
 include/linux/mmzone.h              |  1 -
 include/linux/topology.h            |  3 ++-
 mm/page_alloc.c                     | 17 +----------------
 6 files changed, 16 insertions(+), 33 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
