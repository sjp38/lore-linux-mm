Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 82C166B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 10:04:27 -0400 (EDT)
Date: Thu, 11 Apr 2013 16:04:25 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm: Print the correct method to disable automatic numa
 migration
Message-ID: <20130411140425.GJ16732@two.firstfloor.org>
References: <1365622514-26614-1-git-send-email-andi@firstfloor.org>
 <20130411124803.GK3710@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130411124803.GK3710@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

> As David pointed out, CONFIG_NUMA_BALANCING_DEFAULT_ENABLED only comes
> into play when CONFIG_NUMA_BALANCING is set and CONFIG_NUMA_BALANCING
> will default to N for make oldconfig. I think it's sensible to enable it
> by default if it's configured in.

I've got reports from users who got it unexpected and it messed 
everything up for them.

> 
> David has also already pointed out the problems with NO_NUMA vs -NUMA and
> the fact that the option only exists if CONFIG_SCHED_DEBUG which I agree
> is unfortunate. Ends up with this sort of mess

We just need the sysctl. Are you adding one or should I send
another patch with it?

BTW all the knobs are undocumented in Documentation/* too.
Please document any sysctl you submit.

Undocumented = may as well no exist.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
