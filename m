Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id EEA0F6B004A
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 19:11:24 -0400 (EDT)
Date: Wed, 13 Jul 2011 16:11:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/12] mm: let swap use exceptional entries
Message-Id: <20110713161121.17fd98a4.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1107121501100.2112@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
	<alpine.LSU.2.00.1106140342330.29206@sister.anvils>
	<20110618145254.1b333344.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1107121501100.2112@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 12 Jul 2011 15:08:58 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> > All the crap^Wnice changes made to filemap.c really need some comments,
> > please.  Particularly when they're keyed off the bland-sounding
> > "radix_tree_exception()".  Apparently they have something to do with
> > swap, but how is the poor reader to know this?
> 
> The naming was intentionally bland, because other filesystems might
> in future have other uses for such exceptional entries.
> 
> (I think the field size would generally defeat it, but you can,
> for example, imagine a small filesystem wanting to save sector number
> there when a page is evicted.)
> 
> But let's go bland when it's more familiar, and such uses materialize -
> particularly since I only placed those checks in places where they're
> needed now for shmem/tmpfs/swap.
> 
> I'll keep the bland naming, if that's okay, but send a patch adding
> a line of comment in such places.  Mentioning shmem, tmpfs, swap.

A better fix would be to create a nicely-documented filemap-specific
function with a non-bland name which simply wraps
radix_tree_exception().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
