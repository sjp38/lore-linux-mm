Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2685E6B004D
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 05:50:15 -0400 (EDT)
Date: Thu, 1 Oct 2009 11:24:58 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] filemap : fix the wrong offset
In-Reply-To: <4AC2CF46.5070600@gmail.com>
Message-ID: <Pine.LNX.4.64.0910011111590.7682@sister.anvils>
References: <1254215185-29841-1-git-send-email-shijie8@gmail.com>
 <Pine.LNX.4.64.0909291129430.19216@sister.anvils> <4AC2CF46.5070600@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Sep 2009, Huang Shijie wrote:
> 
> But the filemap_fault()  looks  strange. Some functions such as
> do_sync_mmap_readahead() treat offset
> in the PAGE_CAHE_SHIFT unit,though offset is actually in the PAGE_SHIFT unit.

If this one stands out to you as a puzzling place where it's important
to acknowledge the possibility of the difference, please don't take what
I said too seriously: go ahead and send Andrew the patch again, perhaps
adding a comment that this wouldn't be the only place that's wrong.

Or do you think this is the only place?  I'd be surprised, but
haven't checked: perhaps we have cleaned others up down the years.

I just don't want a long trickle of such patches here and there.
And there's not a lot of point in getting everywhere fixed up,
because people are sure to add patches later which get it wrong again.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
