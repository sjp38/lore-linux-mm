Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 09C4E8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 10:33:55 -0500 (EST)
Received: by iwl42 with SMTP id 42so5417182iwl.14
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 07:33:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299486977.2337.28.camel@sli10-conroe>
References: <1299486977.2337.28.camel@sli10-conroe>
Date: Tue, 8 Mar 2011 00:33:52 +0900
Message-ID: <AANLkTikkCj+fokR4x-xS5v8pxRkJfGHPYprNfWwdQyT6@mail.gmail.com>
Subject: Re: [PATCH 1/2 v3]mm: simplify code of swap.c
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Mar 7, 2011 at 5:36 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> Clean up code and remove duplicate code. Next patch will use
> pagevec_lru_move_fn introduced here too.
>
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

Could you take care of recent mm-deactivate-invalidated-pages.patch on mmotm?
I think you could unify it, too.

Thanks.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
