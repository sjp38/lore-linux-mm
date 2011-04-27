Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 028916B0012
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:45:47 -0400 (EDT)
Received: by wwi36 with SMTP id 36so2115300wwi.26
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:45:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110427171157.3751528f.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<bb2acc3882594cf54689d9e29c61077ff581c533.1303833417.git.minchan.kim@gmail.com>
	<20110427171157.3751528f.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 28 Apr 2011 08:20:32 +0900
Message-ID: <BANLkTik2FTKgSSYkyP4XT4pkhOYvpjgSTA@mail.gmail.com>
Subject: Re: [RFC 4/8] Make clear description of putback_lru_page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Apr 27, 2011 at 5:11 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 27 Apr 2011 01:25:21 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Commonly, putback_lru_page is used with isolated_lru_page.
>> The isolated_lru_page picks the page in middle of LRU and
>> putback_lru_page insert the lru in head of LRU.
>> It means it could make LRU churning so we have to be very careful.
>> Let's clear description of putback_lru_page.
>>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
> seems good...
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> But is there consensus which side of LRU is tail? head?

I don't know. I used to think it's head.
If other guys raise a concern as well, let's talk about it. :)
Thanks

> I always need to revisit codes when I see a word head/tail....
>
>
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
