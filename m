Date: Mon, 25 Jun 2001 20:34:00 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: 2.4.6pre3: kswapd dominating CPU
Message-ID: <20010625203400.D3327@suse.de>
References: <F341E03C8ED6D311805E00902761278C07EFA675@xfc04.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F341E03C8ED6D311805E00902761278C07EFA675@xfc04.fc.hp.com>; from matt_zinkevicius@hp.com on Mon, Jun 18, 2001 at 05:12:44PM -0700
Resent-To: matt_zinkevicius@hp.com, linux-mm@kvack.org
Resent-Message-Id: <E15Ec4O-0001B7-00@burns.home.kernel.dk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "ZINKEVICIUS,MATT (HP-Loveland,ex1)" <matt_zinkevicius@hp.com>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 18 2001, ZINKEVICIUS,MATT (HP-Loveland,ex1) wrote:
> [...] This seems related
> to whether we enable highmem in the kernel, as this problem only appears
> when highmem is set to 4GB or 64GB. Any hints?
> 
> Server specs:
> HP LT6000r server
> 4 x 700Mhz P3Xeons
> 4GB RAM
> 1GB swap partition
> 2.4.6pre3 kernel

WIth a machine spec'ed like that, you might want to try with the
zero-bounce patches for highmem machines. Running out of memory and
still requiring low mem bounce buffers can get ugly -- the patches won't
solve any vm issues, but they should solve the problem for you (and
boost your specsfs performance a good deal).

Haven't had time to update to 2.4.6-pre3 yet, if these don't apply let
me know:

*.kernel.org/pub/linux/kernel/people/axboe/patches/2.4.5/block-highmem-all-4.bz2

Dunno what I/O controller you used...

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
