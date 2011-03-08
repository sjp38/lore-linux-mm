Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DE31F8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 00:18:12 -0500 (EST)
Received: by iyf13 with SMTP id 13so6118340iyf.14
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 21:18:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299559479.2337.31.camel@sli10-conroe>
References: <1299486977.2337.28.camel@sli10-conroe>
	<AANLkTikkCj+fokR4x-xS5v8pxRkJfGHPYprNfWwdQyT6@mail.gmail.com>
	<1299559479.2337.31.camel@sli10-conroe>
Date: Tue, 8 Mar 2011 14:18:11 +0900
Message-ID: <AANLkTi=9LZOBSeOaa5FA+KVJ5iGzZ4CWip29ahHDWLsQ@mail.gmail.com>
Subject: Re: [PATCH 1/2 v3]mm: simplify code of swap.c
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Mar 8, 2011 at 1:44 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> On Mon, 2011-03-07 at 23:33 +0800, Minchan Kim wrote:
>> On Mon, Mar 7, 2011 at 5:36 PM, Shaohua Li <shaohua.li@intel.com> wrote:
>> > Clean up code and remove duplicate code. Next patch will use
>> > pagevec_lru_move_fn introduced here too.
>> >
>> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
>>
>> Could you take care of recent mm-deactivate-invalidated-pages.patch on mmotm?
>> I think you could unify it, too.
> ok, I'll check that too

Thanks!
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
