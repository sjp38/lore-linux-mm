Date: Wed, 14 May 2008 12:44:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] 2.6.26-rc2-mm1 - kernel bug while bootup at
 __alloc_pages_internal () on x86_64
Message-Id: <20080514124455.cf7c3097.akpm@linux-foundation.org>
In-Reply-To: <482B2DB0.9030102@linux.vnet.ibm.com>
References: <20080514010129.4f672378.akpm@linux-foundation.org>
	<482ACBFE.9010606@linux.vnet.ibm.com>
	<20080514103601.32d20889.akpm@linux-foundation.org>
	<482B2DB0.9030102@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, apw@shadowen.org, balbir@linux.vnet.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 May 2008 23:51:36 +0530
Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:

> Andrew Morton wrote:
> > On Wed, 14 May 2008 16:54:46 +0530 Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
> > 
> >> Hi Andrew,
> >>
> >> The 2.6.26-rc2-mm1 kernel panic's while bootup on the x86_64 machine.
> >>
> >>
> >> BUG: unable to handle kernel paging request at 0000000000001e08
> >> IP: [<ffffffff8026ac60>] __alloc_pages_internal+0x80/0x470
> >> PGD 0 
> >> Oops: 0000 [1] SMP 
> >> last sysfs file: 
> >> CPU 31 
> >> Modules linked in:
> >> Pid: 1, comm: swapper Not tainted 2.6.26-rc2-mm1-autotest #1
> >> RIP: 0010:[<ffffffff8026ac60>]  [<ffffffff8026ac60>] __alloc_pages_internal+0x80/0x470
> >> RSP: 0018:ffff810bf9dbdbc0  EFLAGS: 00010202
> >> RAX: 0000000000000002 RBX: ffff810bef4786c0 RCX: 0000000000000001
> >> RDX: 0000000000001e00 RSI: 0000000000000001 RDI: 0000000000001020
> >> RBP: ffff810bf9dbb6d0 R08: 0000000000001020 R09: 0000000000000000
> >> R10: 0000000000000008 R11: ffffffff8046d130 R12: 0000000000001020
> >> R13: 0000000000000001 R14: 0000000000001e00 R15: ffff810bf8d29878
> >> FS:  0000000000000000(0000) GS:ffff810bf916dec0(0000) knlGS:0000000000000000
> >> CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> >> CR2: 0000000000001e08 CR3: 0000000000201000 CR4: 00000000000006e0
> >> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> >> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> >> Process swapper (pid: 1, threadinfo ffff810bf9dbc000, task ffff810bf9dbb6d0)
> >> Stack:  0002102000000000 0000000000000002 0000000000000000 0000000200000000
> >>  0000000000000000 0000000000000000 0000000000000000 0000000000000000
> >>  0000000000000000 ffff810bef4786c0 0000000000001020 ffffffffffffffff
> >> Call Trace:
> >>  [<ffffffff802112e9>] dma_alloc_coherent+0xa9/0x280
> >>  [<ffffffff804e8c9e>] tg3_init_one+0xa3e/0x15e0
> >>  [<ffffffff8028d0e4>] alternate_node_alloc+0x84/0xd0
> >>  [<ffffffff802286fc>] task_rq_lock+0x4c/0x90
> >>  [<ffffffff8022de62>] set_cpus_allowed_ptr+0x72/0xf0
> >>  [<ffffffff802e12fb>] sysfs_addrm_finish+0x1b/0x210
> >>  [<ffffffff802e0f99>] sysfs_find_dirent+0x29/0x40
> >>  [<ffffffff8036cc34>] pci_device_probe+0xe4/0x130
> >>  [<ffffffff803bfc26>] driver_probe_device+0x96/0x1a0
> >>  [<ffffffff803bfdb9>] __driver_attach+0x89/0x90
> >>  [<ffffffff803bfd30>] __driver_attach+0x0/0x90
> >>  [<ffffffff803bf29d>] bus_for_each_dev+0x4d/0x80
> >>  [<ffffffff8028d676>] kmem_cache_alloc+0x116/0x130
> >>  [<ffffffff803bf78e>] bus_add_driver+0xae/0x220
> >>  [<ffffffff803c0046>] driver_register+0x56/0x130
> >>  [<ffffffff8036cee8>] __pci_register_driver+0x68/0xb0
> >>  [<ffffffff80708a29>] kernel_init+0x139/0x390
> >>  [<ffffffff8020c358>] child_rip+0xa/0x12
> >>  [<ffffffff807088f0>] kernel_init+0x0/0x390
> >>  [<ffffffff8020c34e>] child_rip+0x0/0x12
> >>
> >>
> >> Code: c9 00 00 02 00 25 00 08 00 00 89 4c 24 04 89 04 24 44 89 e9 b8 01 00 00 00 d3 e0 48 98 48 89 44 24 08 65 48 8b 2c 25 00 00 00 00 <49> 83 7e 08 00 0f 84 9a 03 00 00 44 8b 44 24 1c 48 8b 74 24 10 
> >> RIP  [<ffffffff8026ac60>] __alloc_pages_internal+0x80/0x470
> >>  RSP <ffff810bf9dbdbc0>
> >> CR2: 0000000000001e08
> >> ---[ end trace 111493bba2b1f3db ]---
> > 
> > grumble.  why.  There are lots of patches already which changed the
> > page allocator.
> > 
> > config, please?
> I have attached the .config file.

I cannot reproduce it with your config on my non-numa box.

> > Is it NUMA?
> It is a NUMA box, with 4 nodes.

Can you bisect it please?

Wrecking the page allocator is a fairly unusual thing to do.  I'd start
out by looking at *bootmem*.patch and perhaps
acpi-acpi_numa_init-build-fix.patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
