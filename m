Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id CB7026B0062
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 01:34:21 -0500 (EST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 6 Dec 2012 12:04:08 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 63F08E0023
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 12:03:49 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB66YBIx37683454
	for <linux-mm@kvack.org>; Thu, 6 Dec 2012 12:04:12 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB66Y85b027877
	for <linux-mm@kvack.org>; Thu, 6 Dec 2012 17:34:12 +1100
Message-ID: <50C03C0E.5080202@linux.vnet.ibm.com>
Date: Thu, 06 Dec 2012 12:02:46 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/8][Sorted-buddy] mm: Linux VM Infrastructure to
 support Memory Power Management
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <50BDD5AB.9070706@gmail.com>
In-Reply-To: <50BDD5AB.9070706@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wujianguo <wujianguo106@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Jianguo,

On 12/04/2012 04:21 PM, wujianguo wrote:
> Hi Srivatsa,
> 
> I applied this patchset, and run genload(from LTP) test: numactl --membind=1 ./genload -m 100,
> then got a "general protection fault", and system was going to reboot.
> 
> If I revert [RFC PATCH 7/8], and run this test again, genload will be killed due to OOM,
> but the system is OK, no coredump.
> 

Sorry for the delay in replying. Thanks a lot for testing and for the bug-report!
I could recreate the issue in one of my machines using the LTP test you mentioned.
I'll try to dig and find out what is going wrong.

Regards,
Srivatsa S. Bhat

> ps: node1 has 8G memory.
> 
> [ 3647.020666] general protection fault: 0000 [#1] SMP
> [ 3647.026232] Modules linked in: edd cpufreq_conservative cpufreq_userspace cpu
> freq_powersave acpi_cpufreq mperf fuse vfat fat loop dm_mod coretemp kvm crc32c_
> intel ixgbe ipv6 i7core_edac igb iTCO_wdt i2c_i801 iTCO_vendor_support ioatdma e
> dac_core tpm_tis joydev lpc_ich i2c_core microcode mfd_core rtc_cmos pcspkr sr_m
> od tpm sg dca hid_generic mdio tpm_bios cdrom button ext3 jbd mbcache usbhid hid
>  uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif processor thermal_sys hw
> mon scsi_dh_alua scsi_dh_hp_sw scsi_dh_rdac scsi_dh_emc scsi_dh ata_generic ata_
> piix libata megaraid_sas scsi_mod
> [ 3647.084565] CPU 19
> [ 3647.086709] Pid: 33708, comm: genload Not tainted 3.7.0-rc7-mem-region+ #11 Q
> CI QSSC-S4R/QSSC-S4R
> [ 3647.096799] RIP: 0010:[<ffffffff8110979c>]  [<ffffffff8110979c>] add_to_freel
> ist+0x8c/0x100
> [ 3647.106125] RSP: 0000:ffff880a7f6c3e58  EFLAGS: 00010086
> [ 3647.112042] RAX: dead000000200200 RBX: 0000000000000001 RCX: 0000000000000000
> 
> [ 3647.119990] RDX: ffffea001211a3a0 RSI: ffffea001211ffa0 RDI: 0000000000000001
> 
> [ 3647.127936] RBP: ffff880a7f6c3e58 R08: ffff88067ff6d240 R09: ffff88067ff6b180
> 
> [ 3647.135884] R10: 0000000000000002 R11: 0000000000000001 R12: 00000000000007fe
> 
> [ 3647.143831] R13: 0000000000000001 R14: 0000000000000001 R15: ffffea001211ff80
> 
> [ 3647.151778] FS:  00007f0b2a674700(0000) GS:ffff880a7f6c0000(0000) knlGS:00000
> 00000000000
> [ 3647.160790] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 3647.167188] CR2: 00007f0b1a000000 CR3: 0000000484723000 CR4: 00000000000007e0
> 
> [ 3647.175136] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> 
> [ 3647.183083] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> 
> [ 3647.191030] Process genload (pid: 33708, threadinfo ffff8806852bc000, task ff
> ff880688288000)
> [ 3647.200428] Stack:
> [ 3647.202667]  ffff880a7f6c3f08 ffffffff8110e9c0 ffff88067ff66100 0000000000000
> 7fe
> [ 3647.210954]  ffff880a7f6d5bb0 0000000000000030 0000000000002030 ffff88067ff66
> 168
> [ 3647.219244]  0000000000000002 ffff880a7f6d5b78 0000000e88288000 ffff88067ff66
> 100
> [ 3647.227530] Call Trace:
> [ 3647.230252]  <IRQ>
> [ 3647.232394]  [<ffffffff8110e9c0>] free_pcppages_bulk+0x350/0x450
> [ 3647.239297]  [<ffffffff8110f0d0>] ? drain_pages+0xd0/0xd0
> [ 3647.245313]  [<ffffffff8110f0c3>] drain_pages+0xc3/0xd0
> [ 3647.251135]  [<ffffffff8110f0e6>] drain_local_pages+0x16/0x20
> [ 3647.257540]  [<ffffffff810a3bce>] generic_smp_call_function_interrupt+0xae/0x
> 260
> [ 3647.265783]  [<ffffffff810282c7>] smp_call_function_interrupt+0x27/0x40
> [ 3647.273156]  [<ffffffff8147f272>] call_function_interrupt+0x72/0x80
> [ 3647.280136]  <EOI>
> [ 3647.282278]  [<ffffffff81077936>] ? mutex_spin_on_owner+0x76/0xa0
> [ 3647.289292]  [<ffffffff81473116>] __mutex_lock_slowpath+0x66/0x180
> [ 3647.296181]  [<ffffffff8113afe7>] ? try_to_unmap_one+0x277/0x440
> [ 3647.302872]  [<ffffffff81472b93>] mutex_lock+0x23/0x40
> [ 3647.308595]  [<ffffffff8113b657>] rmap_walk+0x137/0x240
> [ 3647.314417]  [<ffffffff8115c230>] ? get_page+0x40/0x40
> [ 3647.320133]  [<ffffffff8115d036>] move_to_new_page+0xb6/0x110
> [ 3647.326526]  [<ffffffff8115d452>] __unmap_and_move+0x192/0x230
> [ 3647.333023]  [<ffffffff8115d612>] unmap_and_move+0x122/0x140
> [ 3647.339328]  [<ffffffff8115d6c9>] migrate_pages+0x99/0x150
> [ 3647.345433]  [<ffffffff81129f10>] ? isolate_freepages+0x220/0x220
> [ 3647.352220]  [<ffffffff8112ace2>] compact_zone+0x2f2/0x5d0
> [ 3647.358332]  [<ffffffff8112b4a0>] try_to_compact_pages+0x180/0x240
> [ 3647.365218]  [<ffffffff8110f1e7>] __alloc_pages_direct_compact+0x97/0x200
> [ 3647.372780]  [<ffffffff810a45a3>] ? on_each_cpu_mask+0x63/0xb0
> [ 3647.379279]  [<ffffffff8110f84f>] __alloc_pages_slowpath+0x4ff/0x780
> [ 3647.386349]  [<ffffffff8110fbf1>] __alloc_pages_nodemask+0x121/0x180
> [ 3647.393430]  [<ffffffff811500d6>] alloc_pages_vma+0xd6/0x170
> [ 3647.399737]  [<ffffffff81162198>] do_huge_pmd_anonymous_page+0x148/0x210
> [ 3647.407203]  [<ffffffff81132f6b>] handle_mm_fault+0x33b/0x340
> [ 3647.413609]  [<ffffffff814799d3>] __do_page_fault+0x2a3/0x4e0
> [ 3647.420017]  [<ffffffff8126316a>] ? trace_hardirqs_off_thunk+0x3a/0x6c
> [ 3647.427290]  [<ffffffff81479c1e>] do_page_fault+0xe/0x10
> [ 3647.433208]  [<ffffffff81475f68>] page_fault+0x28/0x30
> [ 3647.438921] Code: 8d 78 01 48 89 f8 48 c1 e0 04 49 8d 04 00 48 8b 50 08 48 83
>  40 10 01 48 85 d2 74 1b 48 8b 42 08 48 89 72 08 48 89 16 48 89 46 08 <48> 89 30
>  c9 c3 0f 1f 80 00 00 00 00 4d 3b 00 74 4b 83 e9 01 79
> [ 3647.460607] RIP  [<ffffffff8110979c>] add_to_freelist+0x8c/0x100
> [ 3647.467308]  RSP <ffff880a7f6c3e58>
> [    0.000000] Linux version 3.7.0-rc7-mem-region+ (root@linux-intel) (gcc versi
> on 4.3.4 [gcc-4_3-branch revision 152973] (SUSE Linux) ) #11 SMP Tue Dec 4 15:23
> :15 CST 2012
> .
> 
> Thanks,
> Jianguo Wu
> 
> On 2012-11-7 3:52, Srivatsa S. Bhat wrote:
>> Hi,
>>
>> This is an alternative design for Memory Power Management, developed based on
>> some of the suggestions[1] received during the review of the earlier patchset
>> ("Hierarchy" design) on Memory Power Management[2]. This alters the buddy-lists
>> to keep them region-sorted, and is hence identified as the "Sorted-buddy" design.
>>
>> One of the key aspects of this design is that it avoids the zone-fragmentation
>> problem that was present in the earlier design[3].
>>
>>
>> Quick overview of Memory Power Management and Memory Regions:
>> ------------------------------------------------------------
>>
>> Today memory subsystems are offer a wide range of capabilities for managing
>> memory power consumption. As a quick example, if a block of memory is not
>> referenced for a threshold amount of time, the memory controller can decide to
>> put that chunk into a low-power content-preserving state. And the next
>> reference to that memory chunk would bring it back to full power for read/write.
>> With this capability in place, it becomes important for the OS to understand
>> the boundaries of such power-manageable chunks of memory and to ensure that
>> references are consolidated to a minimum number of such memory power management
>> domains.
>>
>> ACPI 5.0 has introduced MPST tables (Memory Power State Tables) [5] so that
>> the firmware can expose information regarding the boundaries of such memory
>> power management domains to the OS in a standard way.
>>
>> How can Linux VM help memory power savings?
>>
>> o Consolidate memory allocations and/or references such that they are
>> not spread across the entire memory address space.  Basically area of memory
>> that is not being referenced, can reside in low power state.
>>
>> o Support targeted memory reclaim, where certain areas of memory that can be
>> easily freed can be offlined, allowing those areas of memory to be put into
>> lower power states.
>>
>> Memory Regions:
>> ---------------
>>
>> "Memory Regions" is a way of capturing the boundaries of power-managable
>> chunks of memory, within the MM subsystem.
>>
>>
>> Short description of the "Sorted-buddy" design:
>> -----------------------------------------------
>>
>> In this design, the memory region boundaries are captured in a parallel
>> data-structure instead of fitting regions between nodes and zones in the
>> hierarchy. Further, the buddy allocator is altered, such that we maintain the
>> zones' freelists in region-sorted-order and thus do page allocation in the
>> order of increasing memory regions. (The freelists need not be fully
>> address-sorted, they just need to be region-sorted. Patch 6 explains this
>> in more detail).
>>
>> The idea is to do page allocation in increasing order of memory regions
>> (within a zone) and perform page reclaim in the reverse order, as illustrated
>> below.
>>
>> ---------------------------- Increasing region number---------------------->
>>
>> Direction of allocation--->                         <---Direction of reclaim
>>
>>
>> The sorting logic (to maintain freelist pageblocks in region-sorted-order)
>> lies in the page-free path and not the page-allocation path and hence the
>> critical page allocation paths remain fast. Moreover, the heart of the page
>> allocation algorithm itself remains largely unchanged, and the region-related
>> data-structures are optimized to avoid unnecessary updates during the
>> page-allocator's runtime.
>>
>> Advantages of this design:
>> --------------------------
>> 1. No zone-fragmentation (IOW, we don't create more zones than necessary) and
>>    hence we avoid its associated problems (like too many zones, extra page
>>    reclaim threads, question of choosing watermarks etc).
>>    [This is an advantage over the "Hierarchy" design]
>>
>> 2. Performance overhead is expected to be low: Since we retain the simplicity
>>    of the algorithm in the page allocation path, page allocation can
>>    potentially remain as fast as it would be without memory regions. The
>>    overhead is pushed to the page-freeing paths which are not that critical.
>>
>>
>> Results:
>> =======
>>
>> Test setup:
>> -----------
>> This patchset applies cleanly on top of 3.7-rc3.
>>
>> x86 dual-socket quad core HT-enabled machine booted with mem=8G
>> Memory region size = 512 MB
>>
>> Functional testing:
>> -------------------
>>
>> Ran pagetest, a simple C program that allocates and touches a required number
>> of pages.
>>
>> Below is the statistics from the regions within ZONE_NORMAL, at various sizes
>> of allocations from pagetest.
>>
>> 	     Present pages   |	Free pages at various allocations        |
>> 			     |  start	|  512 MB  |  1024 MB | 2048 MB  |
>>   Region 0      16	     |   0      |    0     |     0    |    0     |
>>   Region 1      131072       |  87219   |  8066    |   7892   |  7387    |
>>   Region 2      131072       | 131072   |  79036   |     0    |    0     |
>>   Region 3      131072       | 131072   | 131072   |   79061  |    0     |
>>   Region 4      131072       | 131072   | 131072   |  131072  |    0     |
>>   Region 5      131072       | 131072   | 131072   |  131072  |  79051   |
>>   Region 6      131072       | 131072   | 131072   |  131072  |  131072  |
>>   Region 7      131072       | 131072   | 131072   |  131072  |  131072  |
>>   Region 8      131056       | 105475   | 105472   |  105472  |  105472  |
>>
>> This shows that page allocation occurs in the order of increasing region
>> numbers, as intended in this design.
>>
>> Performance impact:
>> -------------------
>>
>> Kernbench results didn't show much of a difference between the performance
>> of vanilla 3.7-rc3 and this patchset.
>>
>>
>> Todos:
>> =====
>>
>> 1. Memory-region aware page-reclamation:
>> ----------------------------------------
>>
>> We would like to do page reclaim in the reverse order of page allocation
>> within a zone, ie., in the order of decreasing region numbers.
>> To achieve that, while scanning lru pages to reclaim, we could potentially
>> look for pages belonging to higher regions (considering region boundaries)
>> or perhaps simply prefer pages of higher pfns (and skip lower pfns) as
>> reclaim candidates.
>>
>> 2. Compile-time exclusion of Memory Power Management, and extending the
>> support to also work with other features such as Mem cgroups, kexec etc.
>>
>> References:
>> ----------
>>
>> [1]. Review comments suggesting modifying the buddy allocator to be aware of
>>      memory regions:
>>      http://article.gmane.org/gmane.linux.power-management.general/24862
>>      http://article.gmane.org/gmane.linux.power-management.general/25061
>>      http://article.gmane.org/gmane.linux.kernel.mm/64689
>>
>> [2]. Patch series that implemented the node-region-zone hierarchy design:
>>      http://lwn.net/Articles/445045/
>>      http://thread.gmane.org/gmane.linux.kernel.mm/63840
>>
>>      Summary of the discussion on that patchset:
>>      http://article.gmane.org/gmane.linux.power-management.general/25061
>>
>>      Forward-port of that patchset to 3.7-rc3 (minimal x86 config)
>>      http://thread.gmane.org/gmane.linux.kernel.mm/89202
>>
>> [3]. Disadvantages of having memory regions in the hierarchy between nodes and
>>      zones:
>>      http://article.gmane.org/gmane.linux.kernel.mm/63849
>>
>> [4]. Estimate of potential power savings on Samsung exynos board
>>      http://article.gmane.org/gmane.linux.kernel.mm/65935
>>
>> [5]. ACPI 5.0 and MPST support
>>      http://www.acpi.info/spec.htm
>>      Section 5.2.21 Memory Power State Table (MPST)
>>
>>  Srivatsa S. Bhat (8):
>>       mm: Introduce memory regions data-structure to capture region boundaries within node
>>       mm: Initialize node memory regions during boot
>>       mm: Introduce and initialize zone memory regions
>>       mm: Add helpers to retrieve node region and zone region for a given page
>>       mm: Add data-structures to describe memory regions within the zones' freelists
>>       mm: Demarcate and maintain pageblocks in region-order in the zones' freelists
>>       mm: Add an optimized version of del_from_freelist to keep page allocation fast
>>       mm: Print memory region statistics to understand the buddy allocator behavior
>>
>>
>>   include/linux/mm.h     |   38 +++++++
>>  include/linux/mmzone.h |   52 +++++++++
>>  mm/compaction.c        |    8 +
>>  mm/page_alloc.c        |  263 ++++++++++++++++++++++++++++++++++++++++++++----
>>  mm/vmstat.c            |   59 ++++++++++-
>>  5 files changed, 390 insertions(+), 30 deletions(-)
>>
>>
>> Thanks,
>> Srivatsa S. Bhat
>> IBM Linux Technology Center
>>
>> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
