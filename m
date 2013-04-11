Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id C5E706B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 08:48:09 -0400 (EDT)
Date: Thu, 11 Apr 2013 13:48:03 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Print the correct method to disable automatic numa
 migration
Message-ID: <20130411124803.GK3710@suse.de>
References: <1365622514-26614-1-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1365622514-26614-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

On Wed, Apr 10, 2013 at 12:35:14PM -0700, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
> 
> When the "default y" CONFIG_NUMA_BALANCING_DEFAULT_ENABLED is enabled,
> the message it prints refers to a sysctl to disable it again.
> But that sysctl doesn't exist.
> 

True.

> Document the correct (highly obscure method) through debugfs.
> 
> This should be also in Documentation/* but isn't.
> 
> Also fix the checkpatch problems.
> 
> BTW I think the "default y" is highly dubious for such a
> experimential feature.
> 

As David pointed out, CONFIG_NUMA_BALANCING_DEFAULT_ENABLED only comes
into play when CONFIG_NUMA_BALANCING is set and CONFIG_NUMA_BALANCING
will default to N for make oldconfig. I think it's sensible to enable it
by default if it's configured in.

David has also already pointed out the problems with NO_NUMA vs -NUMA and
the fact that the option only exists if CONFIG_SCHED_DEBUG which I agree
is unfortunate. Ends up with this sort of mess

printk(KERN_INFO "Enabling automatic NUMA balancing. "
	"Configure with numa_balancing="
#ifdef CONFIG_SCHED_DEBUG
	" or echo [NO_]NUMA > /sys/kernel/debug/sched_features"
#endif
	".\n");

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
