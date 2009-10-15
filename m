Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 83ACB6B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 18:08:21 -0400 (EDT)
Date: Thu, 15 Oct 2009 23:08:19 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 5/9] swap_info: SWAP_HAS_CACHE cleanups
In-Reply-To: <20091015113736.d46a6a8a.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0910152301550.4447@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
 <Pine.LNX.4.64.0910150150570.3291@sister.anvils>
 <20091015113736.d46a6a8a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Oct 2009, KAMEZAWA Hiroyuki wrote:
> On Thu, 15 Oct 2009 01:52:27 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> 
> > Though swap_count() is useful, I'm finding that swap_has_cache() and
> > encode_swapmap() obscure what happens in the swap_map entry, just at
> > those points where I need to understand it.  Remove them, and pass
> > more usable "usage" values to scan_swap_map(), swap_entry_free() and
> > __swap_duplicate(), instead of the SWAP_MAP and SWAP_CACHE enum.
> > 
> > Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> 
> I have no objectios to above.

Phew!  Thanks.  I particularly had this one in mind when I Cc'ed you
on them all, because we do have a clash of styles or habits there.

My view is, the next time you or someone else is at work in there,
okay to reintroduce such things if they make it easier for you to
work on the code; but for me they made it harder.

> I'll test, later. maybe no troubles.

Thanks, yes, testing is the most important.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
