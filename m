Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 452546B003D
	for <linux-mm@kvack.org>; Sat, 14 Mar 2009 01:07:49 -0400 (EDT)
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LFD.2.00.0903111328180.32478@localhost.localdomain>
References: <20090311170611.GA2079@elte.hu>
	 <alpine.LFD.2.00.0903111024320.32478@localhost.localdomain>
	 <20090311174103.GA11979@elte.hu>
	 <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain>
	 <20090311183748.GK27823@random.random>
	 <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain>
	 <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain>
	 <20090311195935.GO27823@random.random>
	 <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain>
	 <alpine.LFD.2.00.0903111328180.32478@localhost.localdomain>
Content-Type: text/plain
Date: Sat, 14 Mar 2009 16:07:21 +1100
Message-Id: <1237007241.25062.92.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2009-03-11 at 13:33 -0700, Linus Torvalds wrote:
>  - Just make the rule be that people who use get_user_pages() always 
>    have to have the read-lock on mmap_sem until they've used the
> pages.
> 

That's not going to work with IB and friends who gup() whole bunches of
user memory forever...

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
