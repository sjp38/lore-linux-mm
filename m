Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id DBAF06B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:25:13 -0400 (EDT)
Date: Thu, 11 Apr 2013 18:25:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Print the correct method to disable automatic numa
 migration
Message-ID: <20130411172508.GC11656@suse.de>
References: <1365622514-26614-1-git-send-email-andi@firstfloor.org>
 <20130411124803.GK3710@suse.de>
 <20130411140425.GJ16732@two.firstfloor.org>
 <20130411141942.GL3710@suse.de>
 <20130411155304.GK22166@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130411155304.GK22166@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, Apr 11, 2013 at 08:53:04AM -0700, Andi Kleen wrote:
> > > > David has also already pointed out the problems with NO_NUMA vs -NUMA and
> > > > the fact that the option only exists if CONFIG_SCHED_DEBUG which I agree
> > > > is unfortunate. Ends up with this sort of mess
> > > 
> > > We just need the sysctl. Are you adding one or should I send
> > > another patch with it?
> > > 
> > 
> > I hadn't planned on it in the short term at least. Originally there was
> 
> I'll send a patch.
> 

Ok.

> But are you taking care of the documentation of all the existing knobs?
> 

Which knobs? The sched_features knobs? No, I was not planning on
documenting them. Some of them are already partially documented in
kernel/sched/features.h but the consequences of tuning them is heavily
workload dependant. While this is unsatisfactory, the interface is only
intended for debugging. For NUMA balancing, the tuning knob is a kernel
parameter and it is already documented in Documentation/kernel-parameters.txt

> I think if you had done that earlier you would have noticed
> that the current situation is not very satisfying.
> 
> Writing documentation is one of the best ways we have
> to sanitize user interfaces.
> 
> > revisited NUMA balancing a long time ago but too many bugs have been
> > getting in the way.
> 
> That will likely make everything even worse.
> 

With one exception, the bugs I've been working on are not related to
automatic NUMA balancing.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
