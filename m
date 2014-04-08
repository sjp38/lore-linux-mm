Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 654C16B0073
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 03:14:55 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so295759eek.7
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 00:14:53 -0700 (PDT)
Received: from moutng.kundenserver.de (moutng.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id z2si1452784eeo.124.2014.04.08.00.14.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Apr 2014 00:14:52 -0700 (PDT)
Date: Tue, 8 Apr 2014 09:14:43 +0200
From: Andres Freund <andres@2ndquadrant.com>
Subject: Re: [PATCH 1/2] mm: Disable zone_reclaim_mode by default
Message-ID: <20140408071443.GQ4161@awork2.anarazel.de>
References: <1396910068-11637-1-git-send-email-mgorman@suse.de>
 <1396910068-11637-2-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1396910068-11637-2-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>, Christoph Lameter <cl@linux.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi,

On 2014-04-07 23:34:27 +0100, Mel Gorman wrote:
> zone_reclaim_mode causes processes to prefer reclaiming memory from local
> node instead of spilling over to other nodes. This made sense initially when
> NUMA machines were almost exclusively HPC and the workload was partitioned
> into nodes. The NUMA penalties were sufficiently high to justify reclaiming
> the memory. On current machines and workloads it is often the case that
> zone_reclaim_mode destroys performance but not all users know how to detect
> this. Favour the common case and disable it by default. Users that are
> sophisticated enough to know they need zone_reclaim_mode will detect it.

Unsurprisingly I am in favor of this.

>  Documentation/sysctl/vm.txt | 17 +++++++++--------
>  mm/page_alloc.c             |  2 --
>  2 files changed, 9 insertions(+), 10 deletions(-)

But I think linux/topology.h's comment about RECLAIM_DISTANCE should be
adapted as well.

Thanks,

Andres

-- 
 Andres Freund	                   http://www.2ndQuadrant.com/
 PostgreSQL Development, 24x7 Support, Training & Services

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
