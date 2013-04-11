Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 743DA6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 10:19:47 -0400 (EDT)
Date: Thu, 11 Apr 2013 15:19:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Print the correct method to disable automatic numa
 migration
Message-ID: <20130411141942.GL3710@suse.de>
References: <1365622514-26614-1-git-send-email-andi@firstfloor.org>
 <20130411124803.GK3710@suse.de>
 <20130411140425.GJ16732@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130411140425.GJ16732@two.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

On Thu, Apr 11, 2013 at 04:04:25PM +0200, Andi Kleen wrote:
> > As David pointed out, CONFIG_NUMA_BALANCING_DEFAULT_ENABLED only comes
> > into play when CONFIG_NUMA_BALANCING is set and CONFIG_NUMA_BALANCING
> > will default to N for make oldconfig. I think it's sensible to enable it
> > by default if it's configured in.
> 
> I've got reports from users who got it unexpected and it messed 
> everything up for them.
> 

They enabled the option to have the feature and were then surprised it
was enabled? That surprises me.

> > 
> > David has also already pointed out the problems with NO_NUMA vs -NUMA and
> > the fact that the option only exists if CONFIG_SCHED_DEBUG which I agree
> > is unfortunate. Ends up with this sort of mess
> 
> We just need the sysctl. Are you adding one or should I send
> another patch with it?
> 

I hadn't planned on it in the short term at least. Originally there was
a sysctl to control the NUMA auto balancing behaviour but it was one of
the points of contention that got dropped along the way. As SCHED_DEBUG
is enabled in some distribution configs at least, it was expected the
option would generally be available even though the documentation for
/sys/kernel/debug/sched_features is non-existent. I had hoped to have
revisited NUMA balancing a long time ago but too many bugs have been
getting in the way.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
