Date: Mon, 9 Jun 2008 14:48:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.26-rc5-mm1
Message-Id: <20080609144834.c6fcb625.akpm@linux-foundation.org>
In-Reply-To: <200806092114.54467.m.kozlowski@tuxland.pl>
References: <20080609053908.8021a635.akpm@linux-foundation.org>
	<484D67EF.5090203@linux.vnet.ibm.com>
	<200806092114.54467.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Cc: balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Jun 2008 21:14:54 +0200
Mariusz Kozlowski <m.kozlowski@tuxland.pl> wrote:

> Hello Balbir,
> 
> > Andrew Morton wrote:
> > > Temporarily at
> > > 
> > >   http://userweb.kernel.org/~akpm/2.6.26-rc5-mm1/
> > > 
> > 
> > I've hit a segfault, the last few lines on my console are
> > 
> > 
> > Testing -fstack-protector-all feature
> > registered taskstats version 1
> > debug: unmapping init memory ffffffff80c03000..ffffffff80dd8000
> > init[1]: segfault at 7fff701fe880 ip 7fff701fee5e sp 7fff7006e6d0 error 7
> > 
> > With absolutely no stack trace. I'll dig deeper.
> 
> Hey, I see something similar and I actually have a stack trace. Here it goes:
> 
> bash[498] segfault at ffffffff80868b58 ip ffffffffff600412 sp 7fffa3d010f0 error 7
> init[1] segfault at ffffffff80868b58 ip ffffffffff600412 sp 7fff9e97f640 error 7
> init[1] segfault at ffffffff80868b58 ip ffffffffff600412 sp 7fff9e97eed0 error 7
> Kernel panic - not syncing: Attemted to kill init!
> Pid 1, comm: init Not tainted 2.6.26-rc5-mm1 #1
> 
> Call Trace:
> [<ffffffff80254632>] panic+0xe2/0x260
> [<ffffffff802fa8ba>] ? __slab_free+0x10a/0x630
> [<ffffffff80265a8e>] ? __sigqueue_free+0x5e/0x70
> [<ffffffff802851eb>] ? trace_hardirqs_off+0x1b/0x30
> [<ffffffff802851eb>] ? trace_hardirqs_off+0x1b/0x30
> [<ffffffff80259b54>] do_exit+0xb84/0xc30
> [<ffffffff80259c5a>] do_group_exit+0x5a/0x110
> [<ffffffff8026a3b5>] get_signal_to_deliver+0x2c5/0x620
> [<ffffffff8020bb3b>] do_notify_resume+0x11b/0xd10
> [<ffffffff8028da5b>] ? trace_hardirqs_on+0x1b/0x30
> [<ffffffff805cd0f3>] ? _spin_unlock_irqrestore+0x93/0x130
> [<ffffffff8026865c>] ? force_sig_info+0x10c/0x130
> [<ffffffff8022fb9c>] ? force_sig_info_fault+0x2c/0x40
> [<ffffffff802dd7dd>] ? print_vma_addr+0x10d/0x1d0
> [<ffffffff805cbb67>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [<ffffffff8028d8da>] ? trace_hardirqs_on_caller+0x15a/0x2c0
> [<ffffffff8020d4c9>] retint_signal+0x46/0x8d
> 
> This was copied manually so typos are possible.
> 

Thanks.  Could someone send a config please?  Or a bisection result ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
