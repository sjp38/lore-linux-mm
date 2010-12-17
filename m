Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C62CF6B00A2
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 21:10:15 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id oBH2ADDc014629
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 18:10:14 -0800
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by wpaz13.hot.corp.google.com with ESMTP id oBH2AA3U019652
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 18:10:12 -0800
Received: by pzk30 with SMTP id 30so32681pzk.36
        for <linux-mm@kvack.org>; Thu, 16 Dec 2010 18:10:10 -0800 (PST)
Date: Thu, 16 Dec 2010 18:10:02 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: add replace_page_cache_page() function
In-Reply-To: <AANLkTinhkZKWkthN1R39+6nDbN0xZq-g7jP5-LVLxZ3E@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1012161804280.4484@tigran.mtv.corp.google.com>
References: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu> <AANLkTikXQmsgZ8Ea-GoQ4k2St6yCJj8Z3XthuBQ9u+EV@mail.gmail.com> <E1PTCV4-0007sR-SO@pomaz-ex.szeredi.hu> <20101216220457.GA3450@barrios-desktop> <alpine.LSU.2.00.1012161708260.3351@tigran.mtv.corp.google.com>
 <AANLkTinhkZKWkthN1R39+6nDbN0xZq-g7jP5-LVLxZ3E@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Dec 2010, Minchan Kim wrote:
> On Fri, Dec 17, 2010 at 10:21 AM, Hugh Dickins <hughd@google.com> wrote:
> >
> > I disagree with you there: I like the way Miklos made it symmetric,
> > I like the way delete_from_swap_cache drops the swap cache reference,
> > I dislike the way remove_from_page_cache does not - I did once try to
> > change that, but did a bad job, messed up reiserfs or reiser4 I forget
> > which, retreated in shame.
> 
> I agree symmetric is good. I just said current fact which is that
> remove_from_page_cache doesn't release ref.
> So I thought we have to match current semantic to protect confusing.
> Okay. I will not oppose current semantics.
> Instead of it, please add it (ex, caller should hold the page
> reference) in function description.
> 
> I am happy to hear that you tried it.
> Although it is hard, I think it's very valuable thing.
> Could you give me hint to googling your effort and why it is failed?

http://lkml.org/lkml/2004/10/24/140

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
