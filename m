Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 984196B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 16:31:36 -0400 (EDT)
Date: Wed, 28 Oct 2009 20:31:28 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] try_to_unuse : remove redundant swap_count()
In-Reply-To: <dc46d49c0910201825g1b3b3987w8f9002761a64166f@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0910282017410.19885@sister.anvils>
References: <COL115-W535064AC2F576372C1BB1B9FC00@phx.gbl>
 <0f7b4023bee9b7ccc47998cd517d193c.squirrel@webmail-b.css.fujitsu.com>
 <dc46d49c0910201825g1b3b3987w8f9002761a64166f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <yjfpb04@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bo Liu <bo-liu@hotmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Oct 2009, Bob Liu wrote:
> >>
> >> While comparing with swcount,it's no need to
> >> call swap_count(). Just as int set_start_mm =
> >> (*swap_map>= swcount) is ok.
> >>
> > Hmm ?
> > *swap_map = (SWAP_HAS_CACHE) | count. What this change means ?
> >
> 
> Sorry for the wrong format, I changed to gmail.
> Because swcount is assigned value *swap_map not swap_count(*swap_map).
> So I think here should compare with *swap_map not swap_count(*swap_map).
> 
> And refer to variable set_start_mm, it is inited also by comparing
> *swap_map and swcount not swap_count(*swap_map) and swcount.
> So I submited this patch.

Thanks a lot for the fuller description: I mistakenly dismissed
your patch the first time, misunderstanding what you had found.

As I remarked in private mail (being smtp-challenged last week),
what you found was worse than a redundant use of swap_count(): it
was a wrong use of swap_count(), and caused an (easily overlooked)
regression in swapoff's (never wonderful) performance.

> 
> > Anyway, swap_count() macro is removed by Hugh's patch (queued in -mm)

Actually no: I removed some of the other wrappers, which were obscuring
things for me; but swap_count() still seemed useful, so I left it.

> >
> I am sorry for not notice that. So just forget about this patch.

No, let's not forget it at all, it was a good find, thank you.
Updated version of the patch comes in following mail.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
