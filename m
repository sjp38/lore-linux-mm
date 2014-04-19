Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4E70F6B0031
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 07:16:28 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id d49so2337931eek.27
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 04:16:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q2si44489625eep.42.2014.04.19.04.16.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 04:16:26 -0700 (PDT)
Date: Sat, 19 Apr 2014 12:15:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re:  [PATCH 01/16] mm: Disablezone_eclaim_mode by default
Message-ID: <20140419111515.GA4225@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, Apr 18, 2014 at 10:26:28AM -0700, Andi Kleen wrote:
> Mel Gorman <mgorman@suse.de> writes:
> 
> > zone_reclaim_mode causes processes to prefer reclaiming memory from local
> > node instead of spilling over to other nodes. This made sense initially when
> > NUMA machines were almost exclusively HPC and the workload was partitioned
> > into nodes. The NUMA penalties were sufficiently high to justify reclaiming
> > the memory. On current machines and workloads it is often the case that
> > zone_reclaim_mode destroys performance but not all users know how to detect
> > this. 
> 
> Non local memory also often destroys performance.
> 

True, but if they are sophisticated enough to detect it, they should
also know about the tunable.

> > Favour the common case and disable it by default. Users that are
> > sophisticated enough to know they need zone_reclaim_mode will detect it.
> 
> While I'm not totally against this change, it will destroy many
> carefully tuned configurations as the default NUMA behavior may be completely
> different now. So it seems like a big hammer, and it's not even clear
> what problem you're exactly solving here.
> 

It's a sysctl entry for them to add.

The problem is that many users do not know or cannot detect why page
reclaim is happening early. They do not have the people on staff to
detect it where as the NUMA people appear to generally do. I see bugs
semi-regularly on the problem albeit generally against the distribution
rather than upstream.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
