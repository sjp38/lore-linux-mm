Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 43F476B004F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:17:24 -0400 (EDT)
Received: by yxe35 with SMTP id 35so227790yxe.12
        for <linux-mm@kvack.org>; Thu, 16 Jul 2009 07:17:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090716133454.GA20550@localhost>
References: <20090716133454.GA20550@localhost>
Date: Thu, 16 Jul 2009 23:17:28 +0900
Message-ID: <28c262360907160717p5cb3f3d8y5b3ced96e3824ef8@mail.gmail.com>
Subject: Re: [PATCH] mm: count only reclaimable lru pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

Hi, Wu.
I already agreed this concept.
Wow, It looks better than old. :)

On Thu, Jul 16, 2009 at 10:34 PM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> global_lru_pages() / zone_lru_pages() can be used in two ways:
> - to estimate max reclaimable pages in determine_dirtyable_memory()
> - to calculate the slab scan ratio
>
> When swap is full or not present, the anon lru lists are not reclaimable
> and thus won't be scanned. So the anon pages shall not be counted. Also
> rename the function names to reflect the new meaning.
>
> It can greatly (and correctly) increase the slab scan rate under high memory
> pressure (when most file pages have been reclaimed and swap is full/absent),
> thus avoid possible false OOM kills.
>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
