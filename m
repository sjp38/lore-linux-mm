Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C7F336B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 20:34:26 -0500 (EST)
Received: by iwn1 with SMTP id 1so2723227iwn.37
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 17:29:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
Date: Thu, 9 Dec 2010 10:29:48 +0900
Message-ID: <AANLkTik19QQpZJYiAP0=S6jSjVJdU+Z-8B0vpUBSoz80@mail.gmail.com>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 9, 2010 at 12:16 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Kswapd tries to rebalance zones persistently until their high
> watermarks are restored.
>
> If the amount of unreclaimable pages in a zone makes this impossible
> for reclaim, though, kswapd will end up in a busy loop without a
> chance of reaching its goal.
>
> This behaviour was observed on a virtual machine with a tiny
> Normal-zone that filled up with unreclaimable slab objects.
>
> This patch makes kswapd skip rebalancing on such 'hopeless' zones and
> leaves them to direct reclaim.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I like this. It makes code more readable as well as solving the problem.

Just nitpick/off-topic.

Doesn't we really consider NR_SLAB_RECLAIMABLE in zone_reclaimable_pages?
We already consider it when we calculate size of free pages in some
places(__vm_enough_memory,  minimum_image_size) but it is hard to make
sure we can really reclaim. But I it would be mitigated by Nick's
per-zone slab shrinker.

Maybe be another patch.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
