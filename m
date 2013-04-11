Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id B3DD76B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 11:53:05 -0400 (EDT)
Date: Thu, 11 Apr 2013 08:53:04 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] mm: Print the correct method to disable automatic numa
 migration
Message-ID: <20130411155304.GK22166@tassilo.jf.intel.com>
References: <1365622514-26614-1-git-send-email-andi@firstfloor.org>
 <20130411124803.GK3710@suse.de>
 <20130411140425.GJ16732@two.firstfloor.org>
 <20130411141942.GL3710@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130411141942.GL3710@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org

> > > David has also already pointed out the problems with NO_NUMA vs -NUMA and
> > > the fact that the option only exists if CONFIG_SCHED_DEBUG which I agree
> > > is unfortunate. Ends up with this sort of mess
> > 
> > We just need the sysctl. Are you adding one or should I send
> > another patch with it?
> > 
> 
> I hadn't planned on it in the short term at least. Originally there was

I'll send a patch.

But are you taking care of the documentation of all the existing knobs?

I think if you had done that earlier you would have noticed
that the current situation is not very satisfying.

Writing documentation is one of the best ways we have
to sanitize user interfaces.

> revisited NUMA balancing a long time ago but too many bugs have been
> getting in the way.

That will likely make everything even worse.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
