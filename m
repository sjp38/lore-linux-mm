Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7C3F98D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 23:45:41 -0500 (EST)
Subject: Re: [PATCH 1/2 v3]mm: simplify code of swap.c
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <AANLkTikkCj+fokR4x-xS5v8pxRkJfGHPYprNfWwdQyT6@mail.gmail.com>
References: <1299486977.2337.28.camel@sli10-conroe>
	 <AANLkTikkCj+fokR4x-xS5v8pxRkJfGHPYprNfWwdQyT6@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 08 Mar 2011 12:44:39 +0800
Message-ID: <1299559479.2337.31.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 2011-03-07 at 23:33 +0800, Minchan Kim wrote:
> On Mon, Mar 7, 2011 at 5:36 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> > Clean up code and remove duplicate code. Next patch will use
> > pagevec_lru_move_fn introduced here too.
> >
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> 
> Could you take care of recent mm-deactivate-invalidated-pages.patch on mmotm?
> I think you could unify it, too.
ok, I'll check that too

Thanks,
Shaohua


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
