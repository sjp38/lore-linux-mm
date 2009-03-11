Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A9B476B0047
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 18:10:41 -0400 (EDT)
Date: Wed, 11 Mar 2009 15:07:48 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <alpine.LFD.2.00.0903111502350.32478@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.0903111506380.32478@localhost.localdomain>
References: <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain> <20090311183748.GK27823@random.random> <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain> <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain>
 <20090311195935.GO27823@random.random> <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain> <alpine.LFD.2.00.0903111328180.32478@localhost.localdomain> <20090311205529.GR27823@random.random> <alpine.LFD.2.00.0903111417230.32478@localhost.localdomain>
 <20090311215721.GS27823@random.random> <alpine.LFD.2.00.0903111502350.32478@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Wed, 11 Mar 2009, Linus Torvalds wrote:
> 
> An we could add a warning for it. Something like "if this is a threaded 
> program, and it has ever used get_user_pages(), and it does a fork(), warn 
> about it once". Maybe people would realize what a stupid thing they are 
> doing, and that there is a simple fix (vfork).

Ehh. vfork is only simple if you literally are going to execve. If you are 
using a fork as some kind of odd way to snapshot, I don't know what you 
should do. You can't sanely snapshot a threaded app with fork, but I bet 
some people try.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
