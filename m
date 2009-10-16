Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 71B4E6B005A
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 20:28:28 -0400 (EDT)
Date: Fri, 16 Oct 2009 01:28:19 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 1/9] swap_info: private to swapfile.c
In-Reply-To: <4AD7ABE7.40105@crca.org.au>
Message-ID: <Pine.LNX.4.64.0910160121240.14004@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
 <Pine.LNX.4.64.0910150144310.3291@sister.anvils> <4AD7ABE7.40105@crca.org.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 16 Oct 2009, Nigel Cunningham wrote:
> Hugh Dickins wrote:
> > The swap_info_struct is mostly private to mm/swapfile.c, with only
> > one other in-tree user: get_swap_bio().  Adjust its interface to
> > map_swap_page(), so that we can then remove get_swap_info_struct().
> > 
> > But there is a popular user out-of-tree, TuxOnIce: so leave the
> > declaration of swap_info_struct in linux/swap.h.
> 
> Sorry for the delay in replying.

Delay?  Not at all!  Just leave the delays to me ;)

> 
> I don't mind if you don't leave swap_info_struct in
> include/linux/swap.h.

Okay, thanks for the info, that's good.  I won't take it out of swap.h
at this point, I'm finished in that area for now; but it's useful to
know that later on we can do so.

> I'm currently reworking my swap support anyway,

There should be better ways to interface to it than get_swap_info_struct().

> adding support for honouring the priority field. I've also recently
> learned that under some circumstances, allocating all available swap can
> take quite a while (I have a user who is hibernating with 32GB of RAM!),
> so I've been thinking about what I can do to optimise that.

Have fun!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
