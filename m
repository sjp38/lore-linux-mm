Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C1FD88D003F
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 11:16:05 -0400 (EDT)
Date: Thu, 17 Mar 2011 10:16:01 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/4] slub,rcu: don't assume the size of struct rcu_head
In-Reply-To: <AANLkTikk02f6kLiPFqqAGroJErQkHbJFfHzpHy4Y5P8Y@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1103171006270.12540@router.home>
References: <4D6CA852.3060303@cn.fujitsu.com> <AANLkTimXy2Yaj+NTDMNTWuLqHHfKZJhVDpeXj3CfMvBf@mail.gmail.com> <alpine.DEB.2.00.1103010909320.6253@router.home> <AANLkTim0Zjc7c9-7LCnEaYpV5PVN=5fNQpjMYqtZe-fk@mail.gmail.com> <alpine.DEB.2.00.1103020625290.10180@router.home>
 <AANLkTikk02f6kLiPFqqAGroJErQkHbJFfHzpHy4Y5P8Y@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

On Sun, 6 Mar 2011, Hugh Dickins wrote:

> >> That was so for a long time, but I stopped it just over a year ago
> >> with commit a70caa8ba48f21f46d3b4e71b6b8d14080bbd57a, stop ptlock
> >> enlarging struct page.
> >
> > Strange. I just played around with in in January and the page struct size
> > changes when I build kernels with full debugging. I have some
> > cmpxchg_double patches here that depend on certain alignment in the page
> > struct. Debugging causes all that stuff to get out of whack so that I had
> > to do some special patches to make sure fields following the spinlock are
> > properly aligned when the sizes change.
>
> That puzzles me, it's not my experience and I don't have an
> explanation: do you have time to investigate?
>
> Uh oh, you're going to tell me you're working on an out-of-tree
> architecture with a million cpus ;)  In that case, yes, I'm afraid
> I'll have to update the SPLIT_PTLOCK_CPUS defaulting (for a million -
> 1 even).

No I am not working on any out of tree structure. Just regular dual socket
server boxes with 24 processors (which is a normal business machine
configuration these days).

But then there is also CONFIG_GENERIC_LOCKBREAK. That does not affect
things?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
