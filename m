Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id BC3F26B0035
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 17:15:33 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id rr13so1816701pbb.15
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 14:15:33 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yd10si16940557pab.412.2014.04.18.14.15.32
        for <linux-mm@kvack.org>;
        Fri, 18 Apr 2014 14:15:32 -0700 (PDT)
Message-ID: <535195F3.8040009@intel.com>
Date: Fri, 18 Apr 2014 14:15:31 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/16] mm: Disable zone_reclaim_mode by default
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>	<1397832643-14275-2-git-send-email-mgorman@suse.de> <87tx9q35x7.fsf@tassilo.jf.intel.com>
In-Reply-To: <87tx9q35x7.fsf@tassilo.jf.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On 04/18/2014 10:26 AM, Andi Kleen wrote:
> Mel Gorman <mgorman@suse.de> writes:
>> Favour the common case and disable it by default. Users that are
>> sophisticated enough to know they need zone_reclaim_mode will detect it.
> 
> While I'm not totally against this change, it will destroy many
> carefully tuned configurations as the default NUMA behavior may be completely
> different now. So it seems like a big hammer, and it's not even clear
> what problem you're exactly solving here.

I'm not 100% sure what the common case _is_.  Folks who want good NUMA
affinity are happy now and are happy by default.  Folks who want to fill
memory with page cache are mad and mad by default, and they're the ones
complaining.  It's hard to count the happy ones. :)

But, on the other hand, the current situation is easy to debug.  Someone
complains that they have too much free memory, and it ends up being
pretty easy to solve just looking at statistics, and things go horribly
wrong quickly.  If we apply this patch, it's much less obvious when
things are going wrong, and we have no statistics to help.  We'll need
to get folks running more things like numatop:

	https://01.org/numatop

That said, as a recipient of angry calls from customers who don't like
zone_reclaim_mode, I _do_ think this is the path we should take at the
moment.  Maybe we'll be reverting it in a few years once all of our
customers are angry about lack of NUMA locality.

Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
