From: Paul Moore <paul.moore@hp.com>
Subject: Re: 2.6.25-mm1: not looking good
Date: Thu, 17 Apr 2008 19:55:46 -0400
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
In-Reply-To: <20080417160331.b4729f0c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200804171955.46600.paul.moore@hp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morris <jmorris@namei.org>, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

On Thursday 17 April 2008 7:03:31 pm Andrew Morton wrote:
> I repulled all the trees an hour or two ago, installed everything on
> an 8-way x86_64 box and:

...

> ffffffff80268932 0000000000000001 Call Trace:
>  <IRQ>  [<ffffffff8028fec4>] virt_to_cache+0x11/0x13
>  [<ffffffff802909af>] kfree+0x20/0x38
>  [<ffffffff80327789>] sel_netnode_free+0xd/0xf
>  [<ffffffff80268932>] __rcu_process_callbacks+0x147/0x1b6
>  [<ffffffff802689c4>] rcu_process_callbacks+0x23/0x44
>  [<ffffffff8023cc04>] __do_softirq+0x58/0xae
>  [<ffffffff8020d1cc>] call_softirq+0x1c/0x28
>  [<ffffffff8020ed5c>] do_softirq+0x2f/0x6f
>  [<ffffffff8023c72e>] irq_exit+0x36/0x38
>  [<ffffffff8021dedc>] smp_apic_timer_interrupt+0x74/0x81
>  [<ffffffff8020cc76>] apic_timer_interrupt+0x66/0x70
>  <EOI>  [<ffffffff8020a2e1>] ? mwait_idle+0x38/0x42
>  [<ffffffff8020a2a9>] ? mwait_idle+0x0/0x42
>  [<ffffffff8020b2ff>] ? cpu_idle+0xcb/0xe0
>  [<ffffffff804eaefe>] ? start_secondary+0xb2/0xb4
>
>
> Code: 3a 48 69 c0 80 0e 00 00 48 03 04 d5 00 35 92 80 c9 c3 55 48 89
> e5 53 e8 87 ff ff ff 48 89 c7 48 89 c3 e8 69 ff ff ff 85 c0 75 04
> <0f> 0b eb fe 48 8b 43 30 5b c9 c3 55 48 89 e5 e8 87 ff ff ff 48 RIP 
> [<ffffffff8028fea8>] page_get_cache+0x19/0x24
>  RSP <ffff81025f22fe88>
>
> security/selinux/netnode.c looks to be doing simple old
> kzalloc/kfree, so I'd be suspecting slab.  But there are significant
> changes netnode.c in git-selinux.
>
> I have maybe two hours in which to weed out whatever
> very-recently-added dud patches are causing this.  Any suggestions
> are welcome.

For what it's worth I just looked over the changes in netnode.c and 
nothing is jumping out at me.  The changes ran fine for me when tested 
on the later 2.6.25-rcX kernels but I suppose that doesn't mean a whole 
lot.

I've got a 4-way x86_64 box but it needs to be installed (which means 
I'm not going to be able to do anything useful with it until tomorrow 
at the earliest).  I'll try it out and see if I can recreate the 
problem.

-- 
paul moore
linux @ hp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
