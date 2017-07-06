Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id C159F6B0292
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 12:12:49 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id 191so2018506vko.1
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 09:12:49 -0700 (PDT)
Received: from mail-vk0-x241.google.com (mail-vk0-x241.google.com. [2607:f8b0:400c:c05::241])
        by mx.google.com with ESMTPS id x15si285207uae.134.2017.07.06.09.12.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 09:12:48 -0700 (PDT)
Received: by mail-vk0-x241.google.com with SMTP id y70so483914vky.3
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 09:12:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170706155123.cyyjpvraifu5ptmr@techsingularity.net>
References: <1499346271-15653-1-git-send-email-guro@fb.com>
 <20170706131941.omod4zl4cyuscmjo@techsingularity.net> <CAATkVEyuqQhiL1G=UyOqwABbUGJn2XNvnYpiOp-F3Zb659uOdQ@mail.gmail.com>
 <20170706155123.cyyjpvraifu5ptmr@techsingularity.net>
From: Debabrata Banerjee <dbavatar@gmail.com>
Date: Thu, 6 Jul 2017 12:12:47 -0400
Message-ID: <CAATkVEzuFq5UWasE87Eo_F4aQxkuYWqSGJh5bBnieC=686NyqA@mail.gmail.com>
Subject: Re: [PATCH] mm: make allocation counters per-order
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jul 6, 2017 at 11:51 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
>
> These counters do not actually help you solve that particular problem.
> Knowing how many allocations happened since the system booted doesn't tell
> you much about how many failed or why they failed. You don't even know
> what frequency they occured at unless you monitor it constantly so you're
> back to square one whether this information is available from proc or not.
> There even is a tracepoint that can be used to track information related
> to events that degrade fragmentation (trace_mm_page_alloc_extfrag) although
> the primary thing it tells you is that "the probability that an allocation
> will fail due to fragmentation in the future is potentially higher".

I agree these counters don't have enough information, but there a
start to a first order approximation of the current state of memory.
buddyinfo and pagetypeinfo basically show no information now, because
they only involve the small amount of free memory under the watermark
and all our machines are in this state. As second order approximation,
it would be nice to be able to get answers like: "There are
reclaimable high order allocations of at least this order" and "None
of this order allocation can become available due to unmovable and
unreclaimable allocations"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
