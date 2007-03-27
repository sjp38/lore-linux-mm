In-reply-to: <20070327001834.04dc375e.akpm@linux-foundation.org> (message from
	Andrew Morton on Tue, 27 Mar 2007 00:18:34 -0800)
Subject: Re: [patch resend v4] update ctime and mtime for mmaped write
References: <E1HVZyn-0008T8-00@dorka.pomaz.szeredi.hu>
	<20070326140036.f3352f81.akpm@linux-foundation.org>
	<E1HVwy4-0002UD-00@dorka.pomaz.szeredi.hu>
	<20070326153153.817b6a82.akpm@linux-foundation.org>
	<E1HW5am-0003Mc-00@dorka.pomaz.szeredi.hu>
	<20070326232214.ee92d8c4.akpm@linux-foundation.org>
	<E1HW6Ec-0003Tv-00@dorka.pomaz.szeredi.hu>
	<20070326234957.6b287dda.akpm@linux-foundation.org>
	<E1HW6eb-0003WX-00@dorka.pomaz.szeredi.hu> <20070327001834.04dc375e.akpm@linux-foundation.org>
Message-Id: <E1HW72O-0003ZB-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 27 Mar 2007 10:28:16 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > But Peter Staubach says a RH custumer has files written thorugh mmap,
> > which are not being backed up.
> 
> Yes, I expect the backup problem is the major real-world hurt arising from
> this bug.
> 
> But I expect we could adequately plug that problem at munmap()-time.  Or,
> better, do_wp_page().  As I said - half-assed.
> 
> It's a question if whether the backup problem is the only thing which is hurting
> in the real-world, or if people have other problems.
> 
> (In fact, what's wrong with doing it in do_wp_page()?

It's rather more expensive, than just toggling a bit.

Let me work on it a bit more.  I think I can make the current patch
more palatable.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
