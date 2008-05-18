Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m4I7xpCc019364
	for <linux-mm@kvack.org>; Sun, 18 May 2008 17:59:51 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4I84OiM141772
	for <linux-mm@kvack.org>; Sun, 18 May 2008 18:04:24 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4I80HfV000521
	for <linux-mm@kvack.org>; Sun, 18 May 2008 18:00:18 +1000
Date: Sun, 18 May 2008 13:30:13 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: [BUG] 2.6.26-rc2-mm1 - kernel bug while bootup at __alloc_pages_internal () on x86_64
Message-ID: <20080518080013.GA17458@linux.vnet.ibm.com>
Reply-To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
References: <20080514010129.4f672378.akpm@linux-foundation.org> <482ACBFE.9010606@linux.vnet.ibm.com> <20080514103601.32d20889.akpm@linux-foundation.org> <482B2DB0.9030102@linux.vnet.ibm.com> <20080514124455.cf7c3097.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080514124455.cf7c3097.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, apw@shadowen.org, balbir@linux.vnet.ibm.com, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Wed, May 14, 2008 at 12:44:55PM -0700, Andrew Morton wrote:
> On Wed, 14 May 2008 23:51:36 +0530
> Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
> 
> > Andrew Morton wrote:
> > > On Wed, 14 May 2008 16:54:46 +0530 Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
> > > 
> > >> Hi Andrew,
> > >>
> > >> The 2.6.26-rc2-mm1 kernel panic's while bootup on the x86_64 machine.
> > >>
> > >>
> > >> BUG: unable to handle kernel paging request at 0000000000001e08
> > >> IP: [<ffffffff8026ac60>] __alloc_pages_internal+0x80/0x470
> > >> PGD 0 
> > >> Oops: 0000 [1] SMP 
> > >> last sysfs file: 
> > >> CPU 31 
> > >> Modules linked in:
> > >> Pid: 1, comm: swapper Not tainted 2.6.26-rc2-mm1-autotest #1
> > >> RIP: 0010:[<ffffffff8026ac60>]  [<ffffffff8026ac60>] __alloc_pages_internal+0x80/0x470
> > >> RSP: 0018:ffff810bf9dbdbc0  EFLAGS: 00010202
> > >> RAX: 0000000000000002 RBX: ffff810bef4786c0 RCX: 0000000000000001
> > >> RDX: 0000000000001e00 RSI: 0000000000000001 RDI: 0000000000001020
> > >> RBP: ffff810bf9dbb6d0 R08: 0000000000001020 R09: 0000000000000000
> > >> R10: 0000000000000008 R11: ffffffff8046d130 R12: 0000000000001020
> > >> R13: 0000000000000001 R14: 0000000000001e00 R15: ffff810bf8d29878
> > >> FS:  0000000000000000(0000) GS:ffff810bf916dec0(0000) knlGS:0000000000000000
> > >> CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> > >> CR2: 0000000000001e08 CR3: 0000000000201000 CR4: 00000000000006e0
> > >> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > >> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > >> Process swapper (pid: 1, threadinfo ffff810bf9dbc000, task ffff810bf9dbb6d0)
> > >> Stack:  0002102000000000 0000000000000002 0000000000000000 0000000200000000
> > >>  0000000000000000 0000000000000000 0000000000000000 0000000000000000
> > >>  0000000000000000 ffff810bef4786c0 0000000000001020 ffffffffffffffff
> > >> Call Trace:
> > >>  [<ffffffff802112e9>] dma_alloc_coherent+0xa9/0x280
> > >>  [<ffffffff804e8c9e>] tg3_init_one+0xa3e/0x15e0
> > >>  [<ffffffff8028d0e4>] alternate_node_alloc+0x84/0xd0
> > >>  [<ffffffff802286fc>] task_rq_lock+0x4c/0x90
> > >>  [<ffffffff8022de62>] set_cpus_allowed_ptr+0x72/0xf0
> > >>  [<ffffffff802e12fb>] sysfs_addrm_finish+0x1b/0x210
> > >>  [<ffffffff802e0f99>] sysfs_find_dirent+0x29/0x40
> > >>  [<ffffffff8036cc34>] pci_device_probe+0xe4/0x130
> > >>  [<ffffffff803bfc26>] driver_probe_device+0x96/0x1a0
> > >>  [<ffffffff803bfdb9>] __driver_attach+0x89/0x90
> > >>  [<ffffffff803bfd30>] __driver_attach+0x0/0x90
> > >>  [<ffffffff803bf29d>] bus_for_each_dev+0x4d/0x80
> > >>  [<ffffffff8028d676>] kmem_cache_alloc+0x116/0x130
> > >>  [<ffffffff803bf78e>] bus_add_driver+0xae/0x220
> > >>  [<ffffffff803c0046>] driver_register+0x56/0x130
> > >>  [<ffffffff8036cee8>] __pci_register_driver+0x68/0xb0
> > >>  [<ffffffff80708a29>] kernel_init+0x139/0x390
> > >>  [<ffffffff8020c358>] child_rip+0xa/0x12
> > >>  [<ffffffff807088f0>] kernel_init+0x0/0x390
> > >>  [<ffffffff8020c34e>] child_rip+0x0/0x12
> > >>
> > >>
> > >> Code: c9 00 00 02 00 25 00 08 00 00 89 4c 24 04 89 04 24 44 89 e9 b8 01 00 00 00 d3 e0 48 98 48 89 44 24 08 65 48 8b 2c 25 00 00 00 00 <49> 83 7e 08 00 0f 84 9a 03 00 00 44 8b 44 24 1c 48 8b 74 24 10 
> > >> RIP  [<ffffffff8026ac60>] __alloc_pages_internal+0x80/0x470
> > >>  RSP <ffff810bf9dbdbc0>
> > >> CR2: 0000000000001e08
> > >> ---[ end trace 111493bba2b1f3db ]---
> > > 
> > > grumble.  why.  There are lots of patches already which changed the
> > > page allocator.
> > > 
> > > config, please?
> > I have attached the .config file.
> 
> I cannot reproduce it with your config on my non-numa box.
> 
> > > Is it NUMA?
> > It is a NUMA box, with 4 nodes.
> 
> Can you bisect it please?
> 
> Wrecking the page allocator is a fairly unusual thing to do.  I'd start
> out by looking at *bootmem*.patch and perhaps
> acpi-acpi_numa_init-build-fix.patch.

After bisecting, the acpi-acpi_numa_init-build-fix.patch patch seems
to be causing the kernel panic during the bootup. Reverting the patch helps
in booting up the machine without the panic.

commit 5dc90c0b2d4bd0127624bab67cec159b2c6c4daf
Author: Ingo Molnar <mingo@elte.hu>
Date:   Thu May 1 09:51:47 2008 +0000

    acpi-acpi_numa_init-build-fix
    
    x86.git testing found the following build error on latest -git:
    
     drivers/acpi/numa.c: In function 'acpi_numa_init':
     drivers/acpi/numa.c:226: error: 'NR_NODE_MEMBLKS' undeclared (first use in this function)
     drivers/acpi/numa.c:226: error: (Each undeclared identifier is reported only once
     drivers/acpi/numa.c:226: error: for each function it appears in.)
    
    with this config:
    
     http://redhat.com/~mingo/misc/config-Wed_Apr_30_22_42_42_CEST_2008.bad
    
    i suspect we dont want SRAT parsing when CONFIG_HAVE_ARCH_PARSE_SRAT
    is unset - but the fix looks a bit ugly. Perhaps we should define
    NR_NODE_MEMBLKS even in this case and just let the code fall back
    to some sane behavior?
    
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 5d59cb3..8cab8c5 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -176,6 +176,7 @@ acpi_parse_processor_affinity(struct acpi_subtable_header * header,
 	return 0;
 }
 
+#ifdef CONFIG_HAVE_ARCH_PARSE_SRAT
 static int __init
 acpi_parse_memory_affinity(struct acpi_subtable_header * header,
 			   const unsigned long end)
@@ -193,6 +194,7 @@ acpi_parse_memory_affinity(struct acpi_subtable_header * header,
 
 	return 0;
 }
+#endif
 
 static int __init acpi_parse_srat(struct acpi_table_header *table)
 {
@@ -221,9 +223,11 @@ int __init acpi_numa_init(void)
 	if (!acpi_table_parse(ACPI_SIG_SRAT, acpi_parse_srat)) {
 		acpi_table_parse_srat(ACPI_SRAT_TYPE_CPU_AFFINITY,
 				      acpi_parse_processor_affinity, NR_CPUS);
+#ifdef CONFIG_HAVE_ARCH_PARSE_SRAT
 		acpi_table_parse_srat(ACPI_SRAT_TYPE_MEMORY_AFFINITY,
 				      acpi_parse_memory_affinity,
 				      NR_NODE_MEMBLKS);
+#endif
 	}
 
 	/* SLIT: System Locality Information Table */
-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
