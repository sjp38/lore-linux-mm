Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 17F756B003D
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 10:47:43 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so770999eek.15
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 07:47:41 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u5si3065707een.263.2014.04.08.07.47.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 07:47:40 -0700 (PDT)
Date: Tue, 8 Apr 2014 15:47:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: Disable zone_reclaim_mode by default
Message-ID: <20140408144735.GK7292@suse.de>
References: <1396910068-11637-1-git-send-email-mgorman@suse.de>
 <1396910068-11637-2-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.10.1404080910040.8782@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1404080910040.8782@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: sivanich@sgi.com, Andrew Morton <akpm@linux-foundation.org>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>, Andres Freund <andres@2ndquadrant.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 08, 2014 at 09:14:05AM -0500, Christoph Lameter wrote:
> On Mon, 7 Apr 2014, Mel Gorman wrote:
> 
> > zone_reclaim_mode causes processes to prefer reclaiming memory from local
> > node instead of spilling over to other nodes. This made sense initially when
> > NUMA machines were almost exclusively HPC and the workload was partitioned
> > into nodes. The NUMA penalties were sufficiently high to justify reclaiming
> > the memory. On current machines and workloads it is often the case that
> > zone_reclaim_mode destroys performance but not all users know how to detect
> > this. Favour the common case and disable it by default. Users that are
> > sophisticated enough to know they need zone_reclaim_mode will detect it.
> 
> Ok that is going to require SGI machines to deal with zone_reclaim
> configurations on bootup. Dimitri? Any comments?
> 

The SGI machines are also likely to be managed by system administrators
who are both aware of zone_reclaim_mode and know how to evaluate if it
should be enabled or not. The pair of patches is really aimmed at the
common case of 2-8 socket machines running workloads that are not NUMA
aware.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
