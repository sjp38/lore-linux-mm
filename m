Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 605F06B02E1
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 10:37:44 -0500 (EST)
Received: by obcwo8 with SMTP id wo8so78194obc.14
        for <linux-mm@kvack.org>; Wed, 14 Dec 2011 07:37:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111214122041.GF3487@suse.de>
References: <1323798271-1452-1-git-send-email-mikew@google.com>
 <1323829490.22361.395.camel@sli10-conroe> <CAGTjWtDvmLnNqUoddUCmLVSDN0HcOjtsuFbAs+MFy24JFX-P3g@mail.gmail.com>
 <20111214122041.GF3487@suse.de>
From: Mike Waychison <mikew@google.com>
Date: Wed, 14 Dec 2011 07:37:22 -0800
Message-ID: <CAGTjWtByuv2Z+7rydJzdydrQmxiE5ErHH8OaX6fhOg5eS6X9OQ@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix kswapd livelock on single core, no preempt kernel
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickens <hughd@google.com>, Greg Thelen <gthelen@google.com>

On Wed, Dec 14, 2011 at 4:20 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Tue, Dec 13, 2011 at 08:36:43PM -0800, Mike Waychison wrote:
>> FYI, this was seen with a 2.6.39-based kernel with no-numa, no-memcg
>> and swap-enabled.
>>
>
> If this is 2.6.39, can you try applying the commit
> [f06590bd: mm: vmscan: correctly check if reclaimer should schedule during shrink_slab]
>
> There have been a few fixes around kswapd hogging the CPU since 2.6.39.

In this particular case, I didn't see any problem acquiring
shrinker_rwsem (the shrinkers should up in the cpu profile I
gathered).  I think this patch would fix my issue though as it happens
to drop in a cond_resched() into the path.  It isn't obvious that this
cond_resched() really belongs in shrink_slab() though.  Thanks :)

>
> --
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
