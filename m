Date: Thu, 17 Apr 2008 23:56:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.25-mm1: not looking good
Message-Id: <20080417235637.68eb090b.akpm@linux-foundation.org>
In-Reply-To: <84144f020804172340l79f9c815u42e4dad69dada299@mail.gmail.com>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
	<84144f020804172340l79f9c815u42e4dad69dada299@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morris <jmorris@namei.org>, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Apr 2008 09:40:07 +0300 "Pekka Enberg" <penberg@cs.helsinki.fi> wrote:

> On Fri, Apr 18, 2008 at 2:03 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> >  After 10 or fifteen minutes uptime, slab declared game over:
> >
> >  kernel BUG at mm/slab.c:590!
> >  invalid opcode: 0000 [1] SMP
> >  last sysfs file: /sys/devices/pci0000:00/0000:00:02.0/0000:01:00.0/0000:02:02.0/0000:05:00.1/irq
> >  CPU 5
> >  Modules linked in: nfsd auth_rpcgss exportfs lockd nfs_acl autofs4 hidp rfcomm l2cap bluetooth sunrpc ipv6 dm_mirror dm_log dm_multipath dm_mod sbs sbshc battery ac parport_pc lp parport sg floppy snd_hda_intel snd_seq_dummy ide_cd_mod cdrom snd_seq_oss snd_seq_midi_event snd_seq serio_raw snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer i2c_i801 snd button soundcore i2c_core snd_page_alloc shpchp pcspkr ehci_hcd ohci_hcd uhci_hcd
> >  Pid: 0, comm: swapper Tainted: G        W 2.6.25-mm1 #4
> >  RIP: 0010:[<ffffffff8028fea8>]  [<ffffffff8028fea8>] page_get_cache+0x19/0x24
> >  RSP: 0018:ffff81025f22fe88  EFLAGS: 00010046
> >  RAX: 0000000000000000 RBX: ffffe20000028440 RCX: 0000000000000007
> >  RDX: 0000000000000000 RSI: ffffe20000028440 RDI: 0000000000000040
> >  RBP: ffff81025f22fe90 R08: 0000000000000006 R09: ffff810001080fe8
> >  R10: ffff8100010b7a40 R11: ffff8100010b7a28 R12: 0000000000000282
> >  R13: 0000000000000001 R14: 0000000000000001 R15: 0000000000000000
> >  FS:  0000000000000000(0000) GS:ffff81025f1616c0(0000) knlGS:0000000000000000
> >  CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> >  CR2: 0000003e5f0948f0 CR3: 000000024a01e000 CR4: 00000000000006e0
> >  DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> >  DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> >  Process swapper (pid: 0, threadinfo ffff81025f22a000, task ffff81025f2294a0)
> >  Stack:  ffffffff80a11690 ffff81025f22fea0 ffffffff8028fec4 ffff81025f22fec0
> >   ffffffff802909af 0000000000000000 ffff8100010b4820 ffff81025f22fed0
> >   ffffffff80327789 ffff81025f22ff00 ffffffff80268932 0000000000000001
> >  Call Trace:
> >   <IRQ>  [<ffffffff8028fec4>] virt_to_cache+0x11/0x13
> >   [<ffffffff802909af>] kfree+0x20/0x38
> >   [<ffffffff80327789>] sel_netnode_free+0xd/0xf
> >   [<ffffffff80268932>] __rcu_process_callbacks+0x147/0x1b6
> >   [<ffffffff802689c4>] rcu_process_callbacks+0x23/0x44
> >   [<ffffffff8023cc04>] __do_softirq+0x58/0xae
> >   [<ffffffff8020d1cc>] call_softirq+0x1c/0x28
> >   [<ffffffff8020ed5c>] do_softirq+0x2f/0x6f
> >   [<ffffffff8023c72e>] irq_exit+0x36/0x38
> >   [<ffffffff8021dedc>] smp_apic_timer_interrupt+0x74/0x81
> >   [<ffffffff8020cc76>] apic_timer_interrupt+0x66/0x70
> >   <EOI>  [<ffffffff8020a2e1>] ? mwait_idle+0x38/0x42
> >   [<ffffffff8020a2a9>] ? mwait_idle+0x0/0x42
> >   [<ffffffff8020b2ff>] ? cpu_idle+0xcb/0xe0
> >   [<ffffffff804eaefe>] ? start_secondary+0xb2/0xb4
> >
> >
> >  Code: 3a 48 69 c0 80 0e 00 00 48 03 04 d5 00 35 92 80 c9 c3 55 48 89 e5 53 e8 87 ff ff ff 48 89 c7 48 89 c3 e8 69 ff ff ff 85 c0 75 04 <0f> 0b eb fe 48 8b 43 30 5b c9 c3 55 48 89 e5 e8 87 ff ff ff 48
> >  RIP  [<ffffffff8028fea8>] page_get_cache+0x19/0x24
> >   RSP <ffff81025f22fe88>
> >
> >  security/selinux/netnode.c looks to be doing simple old kzalloc/kfree, so
> >  I'd be suspecting slab.  But there are significant changes netnode.c in
> >  git-selinux.
> 
> Andrew, you don't seem to have slab debugging enabled:
> 
> # CONFIG_DEBUG_SLAB is not set
> 
> And quite frankly, the oops looks unlikely to be a slab bug but rather
> a plain old slab corruption cause by the callers...
> 

Yes, I'd agree.  All has been peachy since I dropped git-selinux.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
