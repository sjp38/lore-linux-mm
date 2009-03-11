Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D580D6B0047
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 18:22:27 -0400 (EDT)
Received: from makko.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.26 ESMTP Server]
	id <S2D75FE> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Wed, 11 Mar 2009 18:22:24 -0400
Date: Wed, 11 Mar 2009 15:22:39 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <alpine.LFD.2.00.0903111502350.32478@localhost.localdomain>
Message-ID: <alpine.DEB.1.10.0903111515320.12933@makko.or.mcafeemobile.com>
References: <20090311174103.GA11979@elte.hu> <alpine.LFD.2.00.0903111053080.32478@localhost.localdomain> <20090311183748.GK27823@random.random> <alpine.LFD.2.00.0903111143150.32478@localhost.localdomain> <alpine.LFD.2.00.0903111150120.32478@localhost.localdomain>
 <20090311195935.GO27823@random.random> <alpine.LFD.2.00.0903111306080.32478@localhost.localdomain> <alpine.LFD.2.00.0903111328180.32478@localhost.localdomain> <20090311205529.GR27823@random.random> <alpine.LFD.2.00.0903111417230.32478@localhost.localdomain>
 <20090311215721.GS27823@random.random> <alpine.LFD.2.00.0903111502350.32478@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Mar 2009, Linus Torvalds wrote:

> In particular, "fork()" in a threaded program is almost always wrong. If 
> you want to exec another program from a threaded one, you should either 
> just do execve() (which kills all threads) or you should do vfork+execve 
> (which has none of the COW issues).

Didn't follow the lengthy thread, but if we make fork+exec to fail inside 
a threaded program, we might end up making a lot of people unhappy.


- Davide


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
