Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 43B446B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 06:17:08 -0400 (EDT)
Date: Mon, 29 Jun 2009 13:19:17 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemleak hexdump proposal
Message-ID: <20090629101917.GA3093@localdomain.by>
References: <20090628173632.GA3890@localdomain.by>
 <84144f020906290243u7a362465p6b1f566257fa3239@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020906290243u7a362465p6b1f566257fa3239@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Catalin Marinas <catalin.marinas@arm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (06/29/09 12:43), Pekka Enberg wrote:
> Hi Sergey,
> 
> On Sun, Jun 28, 2009 at 8:36 PM, Sergey
> Senozhatsky<sergey.senozhatsky@mail.by> wrote:
> > What do you think about ability to 'watch' leaked region? (hex + ascii).
> > (done via lib/hexdump.c)
> 
> What's your use case for this? I'm usually more interested in the
> stack trace when there's a memory leak.
> 
>                         Pekka
> 

Hello Pekka,
Well, it's not easy to come up with something strong. 
I agree, that stack gives you almost all you need.

HEX dump can give you a _tip_ in case you're not sure. 

for example:
unreferenced object 0xf6aac7f8 (size 32):
  comm "swapper", pid 1, jiffies 4294877610
HEX dump:
70 6e 70 20 30 30 3a 30 61 00 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a a5  pnp 00:0a.ZZZZZZZZZZZZZZZZZZZZZ.

  backtrace:
    [<c10e92eb>] kmemleak_alloc+0x11b/0x2b0
    [<c10e4b91>] kmem_cache_alloc+0x111/0x1c0
    [<c12c424e>] reserve_range+0x3e/0x1b0
    [<c12c4454>] system_pnp_probe+0x94/0x140
    [<c12baf84>] pnp_device_probe+0x84/0x100
    [<c12f1919>] driver_probe_device+0x89/0x170
    [<c12f1a99>] __driver_attach+0x99/0xa0
    [<c12f1028>] bus_for_each_dev+0x58/0x90
    [<c12f1764>] driver_attach+0x24/0x40
    [<c12f0804>] bus_add_driver+0xc4/0x290
    [<c12f1e10>] driver_register+0x70/0x130
    [<c12bacd6>] pnp_register_driver+0x26/0x40
    [<c15d4620>] pnp_system_init+0x1b/0x2e
    [<c100115f>] do_one_initcall+0x3f/0x1a0
    [<c15aa4af>] kernel_init+0x13e/0x1a6
    [<c1003e07>] kernel_thread_helper+0x7/0x10

- Ah, pnp 00:0a. Got it.
or
- Ah, pnp 00:0a. No.. It's false. (EXAMPLE)

Or something like that :-)

	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
