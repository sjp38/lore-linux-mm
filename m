Date: Tue, 26 Jun 2001 00:05:07 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: 2.4.6pre3: kswapd dominating CPU
Message-ID: <20010626000507.J4132@suse.de>
References: <F341E03C8ED6D311805E00902761278C07EFA68B@xfc04.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F341E03C8ED6D311805E00902761278C07EFA68B@xfc04.fc.hp.com>; from matt_zinkevicius@hp.com on Mon, Jun 25, 2001 at 03:02:02PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "ZINKEVICIUS,MATT (HP-Loveland,ex1)" <matt_zinkevicius@hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 25 2001, ZINKEVICIUS,MATT (HP-Loveland,ex1) wrote:
> > WIth a machine spec'ed like that, you might want to try with the
> > zero-bounce patches for highmem machines. Running out of memory and
> > still requiring low mem bounce buffers can get ugly -- the 
> > patches won't
> > solve any vm issues, but they should solve the problem for you (and
> > boost your specsfs performance a good deal).
> > 
> > Haven't had time to update to 2.4.6-pre3 yet, if these don't apply let
> > me know:
> > 
> > *.kernel.org/pub/linux/kernel/people/axboe/patches/2.4.5/block
> > -highmem-all-4.bz2
> 
> We tried your block-highmem patch for 2.4.6pre1 (the 2.4.5 one you suggested
> didn't patch cleanly). Sadly the kernel is unbootable (stops at
> "uncompressing kernel..."). If you give as an updated patch for 2.4.6pre3 we
> will be happy to try it!

I'll be updating it tomorrow anyway, it's probably the zone issue again.
At least I'll be able to verify if it is tomorrow, I'll post an update
later.

> > Dunno what I/O controller you used...
> 
> Qlogic fibre channel card (kernel's qlogicfc driver)

Ok good

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
