Date: Sun, 18 Jun 2000 09:57:13 +0200 (CEST)
From: Mike Galbraith <mikeg@weiden.de>
Subject: Re: PATCH: Improvements in shrink_mmap and kswapd
In-Reply-To: <ytt3dmcyli7.fsf@serpe.mitica>
Message-ID: <Pine.Linu.4.10.10006180925380.529-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, lkml <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, linux-fsdevel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On 18 Jun 2000, Juan J. Quintela wrote:

> Hi
>         this patch makes kswapd use less resources.  It should solve
> the kswapd eats xx% of my CPU problems.  It appears that it improves
> IO a bit here.  Could people having problems with IO told me if this
> patch improves things, I am interested in knowing that it don't makes
> things worst never.  This patch is stable here.  I am finishing the
> deferred mmaped pages form file writing patch, that should solve
> several other problems.
> 
> Reports of success/failure are welcome.  Comments are also welcome.

Hi Juan,

I added this patch to ac20 + Roger Larsonn fix and gave it a quick burn.
I saw a slight performance drop in both make -j30 build times and streaming
IO (iozone).  I didn't do sustained pounding though (consistancy), so...

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
