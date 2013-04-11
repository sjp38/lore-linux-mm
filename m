Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id AF5CC6B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:48:22 -0400 (EDT)
Date: Thu, 11 Apr 2013 18:48:17 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Print the correct method to disable automatic numa
 migration
Message-ID: <20130411174817.GD11656@suse.de>
References: <1365622514-26614-1-git-send-email-andi@firstfloor.org>
 <20130411124803.GK3710@suse.de>
 <20130411140425.GJ16732@two.firstfloor.org>
 <20130411141942.GL3710@suse.de>
 <20130411155304.GK22166@tassilo.jf.intel.com>
 <20130411172508.GC11656@suse.de>
 <20130411173902.GM22166@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130411173902.GM22166@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, Apr 11, 2013 at 10:39:02AM -0700, Andi Kleen wrote:
> > > But are you taking care of the documentation of all the existing knobs?
> > > 
> > 
> > Which knobs? The sched_features knobs? No, I was not planning on
> 
> The sysctls that got added
> 
>                 .procname       = "numa_balancing_scan_delay_ms",
>                 .procname       = "numa_balancing_scan_period_min_ms",
>                 .procname       = "numa_balancing_scan_period_reset",
>                 .procname       = "numa_balancing_scan_period_max_ms",
>                 .procname       = "numa_balancing_scan_size_mb",
> 

Yes, I will document them. I've taken a TODO item to do it but it'll be
after LSF/MM before I get around to it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
