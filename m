Message-ID: <F341E03C8ED6D311805E00902761278C07EFA68B@xfc04.fc.hp.com>
From: "ZINKEVICIUS,MATT (HP-Loveland,ex1)" <matt_zinkevicius@hp.com>
Subject: RE: 2.4.6pre3: kswapd dominating CPU
Date: Mon, 25 Jun 2001 15:02:02 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Jens Axboe' <axboe@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> WIth a machine spec'ed like that, you might want to try with the
> zero-bounce patches for highmem machines. Running out of memory and
> still requiring low mem bounce buffers can get ugly -- the 
> patches won't
> solve any vm issues, but they should solve the problem for you (and
> boost your specsfs performance a good deal).
> 
> Haven't had time to update to 2.4.6-pre3 yet, if these don't apply let
> me know:
> 
> *.kernel.org/pub/linux/kernel/people/axboe/patches/2.4.5/block
> -highmem-all-4.bz2

We tried your block-highmem patch for 2.4.6pre1 (the 2.4.5 one you suggested
didn't patch cleanly). Sadly the kernel is unbootable (stops at
"uncompressing kernel..."). If you give as an updated patch for 2.4.6pre3 we
will be happy to try it!

> Dunno what I/O controller you used...

Qlogic fibre channel card (kernel's qlogicfc driver)

--Matt

PS: We also have tried Andrea's 2.4.6pre3aa2 patch. kswapd/kupdated still
runs but at much less CPU utilization (30%-70%) but for much longer periods
having an overall worsening effect. It also breaks fsync which in turn
breaks lots of things (lilo, etc).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
