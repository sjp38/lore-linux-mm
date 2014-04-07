Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 355B56B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 18:34:33 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id x13so95523wgg.33
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 15:34:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w48si108584eel.326.2014.04.07.15.34.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 15:34:31 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/2] Disable zone_reclaim_mode by default
Date: Mon,  7 Apr 2014 23:34:26 +0100
Message-Id: <1396910068-11637-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Christoph Lameter <cl@linux.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

When it was introduced, zone_reclaim_mode made sense as NUMA distances
punished and workloads were generally partitioned to fit into a NUMA
node. NUMA machines are now common but few of the workloads are NUMA-aware
and it's routine to see major performance due to zone_reclaim_mode being
disabled but relatively few can identify the problem.

Those that require zone_reclaim_mode are likely to be able to detect when
it needs to be enabled and tune appropriately so lets have a sensible
default for the bulk of users.

 Documentation/sysctl/vm.txt | 17 +++++++++--------
 include/linux/mmzone.h      |  1 -
 mm/page_alloc.c             | 17 +----------------
 3 files changed, 10 insertions(+), 25 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
