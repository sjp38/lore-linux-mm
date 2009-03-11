Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6804F6B0047
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 18:35:33 -0400 (EDT)
Date: Wed, 11 Mar 2009 15:32:38 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <alpine.DEB.1.10.0903111515320.12933@makko.or.mcafeemobile.com>
Message-ID: <alpine.LFD.2.00.0903111531220.32478@localhost.localdomain>
References: <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain> <20090311183748.GK27823@random.random> <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain> <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain>
 <20090311195935.GO27823@random.random> <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain> <alpine.LFD.2.00.0903111328180.32478@localhost.localdomain> <20090311205529.GR27823@random.random> <alpine.LFD.2.00.0903111417230.32478@localhost.localdomain>
 <20090311215721.GS27823@random.random> <alpine.LFD.2.00.0903111502350.32478@localhost.localdomain> <alpine.DEB.1.10.0903111515320.12933@makko.or.mcafeemobile.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Davide Libenzi <davidel@xmailserver.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Wed, 11 Mar 2009, Davide Libenzi wrote:
> 
> Didn't follow the lengthy thread, but if we make fork+exec to fail inside 
> a threaded program, we might end up making a lot of people unhappy.

Yeah, no, we don't want to fail it, but we could do a one-time warning or 
something, to at least see who does it and perhaps see if some of them 
might realize the problems.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
