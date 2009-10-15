Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E89926B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 18:23:26 -0400 (EDT)
Date: Thu, 15 Oct 2009 23:23:24 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 8/9] swap_info: note SWAP_MAP_SHMEM
In-Reply-To: <20091015123219.43cfd7b1.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0910152317290.4447@sister.anvils>
References: <Pine.LNX.4.64.0910150130001.2250@sister.anvils>
 <Pine.LNX.4.64.0910150156060.3291@sister.anvils>
 <20091015123219.43cfd7b1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Oct 2009, KAMEZAWA Hiroyuki wrote:
> On Thu, 15 Oct 2009 01:57:28 +0100 (BST)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> 
> > While we're fiddling with the swap_map values, let's assign a particular
> > value to shmem/tmpfs swap pages: their swap counts are never incremented,
> > and it helps swapoff's try_to_unuse() a little if it can immediately
> > distinguish those pages from process pages.
> > 
> > Since we've no use for SWAP_MAP_BAD | COUNT_CONTINUED,
> > we might as well use that 0xbf value for SWAP_MAP_SHMEM.
> > 
> > Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> 
> I welcome this!

Ah, I did wonder whether you might find some memcg use for it too:
I'm guessing your welcome means that you do have some such in mind.

(By the way, there's no particular need to use that 0xbf value:
during most of my testing I was using SWAP_MAP_SHMEM 0x3e and
SWAP_MAP_MAX 0x3d; but then noticed that 0xbf just happened to be
free, and also happened to sail through the tests in the right way.
But if it ever becomes a nuisance there, no problem to move it.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
