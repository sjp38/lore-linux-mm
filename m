Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E331D60044A
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 14:43:47 -0500 (EST)
Date: Mon, 21 Dec 2009 19:43:37 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm : kill combined_idx
Message-ID: <20091221194337.GA23345@csn.ul.ie>
References: <1261366347-19232-1-git-send-email-shijie8@gmail.com> <20091221143139.7088a8d3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091221143139.7088a8d3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 21, 2009 at 02:31:39PM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 21 Dec 2009 11:32:27 +0800
> Huang Shijie <shijie8@gmail.com> wrote:
> 
> > In more then half of all the cases, `page' is head of the buddy pair
> > {page, buddy} in __free_one_page. That is because the allocation logic
> > always picks the head of a chunk, and puts the rest back to the buddy system.
> > 
> > So calculating the combined page is not needed but waste some cycles in
> > more then half of all the cases.Just do the calculation when `page' is
> > bigger then the `buddy'.
> > 
> > Signed-off-by: Huang Shijie <shijie8@gmail.com>
> 
> Hmm...As far as I remember, this code design was for avoiding "if".
> Is this compare+jump is better than add+xor ?
> 

Agreed. It's not clear that a compare+jump is cheaper than the add+xor.
How often it's the case that the page is the higher or lower half of the
buddy would depend heavily on the allocation/free pattern making it
hard, if not possible, to predict which is the more common case.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
