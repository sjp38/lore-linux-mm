Date: Wed, 21 Jun 2000 15:37:27 -0500
From: Timur Tabi <ttabi@interactivesi.com>
In-Reply-To: <Pine.LNX.4.10.10006211622270.10983-100000@binx.mbhs.edu>
References: <20000621200418Z131176-21004+46@kanga.kvack.org>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Message-Id: <20000621204403Z131176-21002+38@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

** Reply to message from Puppetmaster <akhripin@mbhs.edu> on Wed, 21 Jun 2000
16:23:30 -0400 (EDT)


> > >Be aware 
> > > of any cache footprint issues though.
> > 
> > Ok, you just lost me.  What's a "cache footprint"?
> Cache footprint refers to the amount of space code/data take up in the
> cache. This is important for code that is frequently executed, as it is
> very good performance-wise to have the nescessary data and code entirely
> in the L1 cache.

So what does that have to do with NR_GFPINDEX?



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
