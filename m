Date: Thu, 17 Jun 1999 09:20:57 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: kmem_cache_init() question
In-Reply-To: <14184.50648.347245.288706@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.990617091928.312A-100000@mole.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: cprash@wipinfo.soft.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jun 1999, Stephen C. Tweedie wrote:

> The great thing about having all the source code is that if you can't
> instantly find the answer to such a question just by searching code, it
> takes no time at all to add a 
> 
> 	printk ("num_physpages is now %lu\n", num_physpages);
> 
> to init.c to find out for yourself. :)
> 
> And if this turns out to be a real bug, do let us know...

It is a real bug, but it's one we probably don't want to fix in 2.2 unless
we want to deal with the fragmentation beast rearing its ugly head once
again. 

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
