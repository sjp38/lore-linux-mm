Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id E873F6B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 01:44:01 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id y19so36778459wgg.11
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 22:44:01 -0800 (PST)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id v7si21529660wix.66.2015.02.01.22.43.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Feb 2015 22:43:58 -0800 (PST)
Received: by mail-wi0-f175.google.com with SMTP id fb4so14318121wid.2
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 22:43:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54cf0703.gCv3qNhGJngLODLV%user@localhost>
References: <54cf0703.gCv3qNhGJngLODLV%user@localhost>
Date: Mon, 2 Feb 2015 10:43:57 +0400
Message-ID: <CADivJMo17V97JrC2FSOOU-ODp3X5K9bAOymNj6WFfmNYnzJt4w@mail.gmail.com>
Subject: Fwd: [abrt] full crash report
From: =?UTF-8?B?0JjQs9C+0YDRjCDQqNC10LLRh9C10L3QutC+?= <valens254@gmail.com>
Content-Type: multipart/alternative; boundary=047d7bfcf662596bda050e1547c4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--047d7bfcf662596bda050e1547c4
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Forwarded conversation
Subject: [abrt] full crash report
------------------------

From:  <user@localhost.centos>
Date: 2015-02-02 0:33 GMT+03:00
To: root@localhost.centos


abrt_version:   2.1.11
cmdline:        BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el7.x86_64
root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro rd.lvm.lv=3Dcentos_ro=
uter/swap
vconsole.font=3Dlatarcyrheb-sun16 rd.lvm.lv=3Dcentos_router/root
crashkernel=3Dauto vconsole.keymap=3Dus rhgb quiet LANG=3Den_US.UTF-8
hostname:       router.centos
kernel:         3.10.0-123.el7.x86_64
last_occurrence: 1422826385
pkg_arch:       x86_64
pkg_epoch:      0
pkg_name:       kernel
pkg_release:    123.el7
pkg_version:    3.10.0
runlevel:       N 3
time:           Fri 12 Dec 2014 10:06:55 AM MSK

sosreport.tar.xz: Binary file, 6994408 bytes

backtrace:
:WARNING: at net/sched/sch_generic.c:259 dev_watchdog+0x270/0x280()
:NETDEV WATCHDOG: enp4s0 (r8169): transmit queue 0 timed out
:Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast xt_nat
xt_mark ipt_MASQUERADE ip6t_rpfilter ip6table_nat nf_nat_ipv6
ip6table_mangle ip6table_security ip6table_raw ip6t_REJECT
nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables iptable_nat
nf_nat_ipv4 nf_nat iptable_mangle iptable_security iptable_raw ipt_REJECT
nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_filter
ip_tables tcp_diag inet_diag bsd_comp ppp_synctty ppp_async crc_ccitt
ppp_generic slhc bridge stp llc sg coretemp kvm serio_raw crct10dif_pclmul
iTCO_wdt iTCO_vendor_support ppdev crc32_pclmul pcspkr i2c_i801
crc32c_intel snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic
snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device
ghash_clmulni_intel snd_pcm snd_page_alloc
:snd_timer snd soundcore mei_me mei cryptd r8169 mii lpc_ich mfd_core
shpchp parport_pc parport mperf xfs libcrc32c sd_mod crc_t10dif
crct10dif_common ata_generic pata_acpi ahci pata_jmicron i915 libahci
libata i2c_algo_bit drm_kms_helper drm i2c_core video dm_mirror
dm_region_hash dm_log dm_mod [last unloaded: ip_tables]
:CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.10.0-123.el7.x86_64 #1
:Hardware name: Gigabyte Technology Co., Ltd. To be filled by O.E.M./C847N,
BIOS F2 11/09/2012
:ffff88021f303d90 eeb6307312c80fd5 ffff88021f303d48 ffffffff815e19ba
:ffff88021f303d80 ffffffff8105dee1 0000000000000000 ffff880212550000
:ffff88021139f280 0000000000000001 0000000000000001 ffff88021f303de8
:Call Trace:
:<IRQ>  [<ffffffff815e19ba>] dump_stack+0x19/0x1b
:[<ffffffff8105dee1>] warn_slowpath_common+0x61/0x80
:[<ffffffff8105df5c>] warn_slowpath_fmt+0x5c/0x80
:[<ffffffff81088671>] ? run_posix_cpu_timers+0x51/0x840
:[<ffffffff814f0ab0>] dev_watchdog+0x270/0x280
:[<ffffffff814f0840>] ? dev_graft_qdisc+0x80/0x80
:[<ffffffff8106d236>] call_timer_fn+0x36/0x110
:[<ffffffff814f0840>] ? dev_graft_qdisc+0x80/0x80
:[<ffffffff8106f2ff>] run_timer_softirq+0x21f/0x320
:[<ffffffff81067047>] __do_softirq+0xf7/0x290
:[<ffffffff815f3a5c>] call_softirq+0x1c/0x30
:[<ffffffff81014d25>] do_softirq+0x55/0x90
:[<ffffffff810673e5>] irq_exit+0x115/0x120
:[<ffffffff815f4435>] smp_apic_timer_interrupt+0x45/0x60
:[<ffffffff815f2d9d>] apic_timer_interrupt+0x6d/0x80
:<EOI>  [<ffffffff814834df>] ? cpuidle_enter_state+0x4f/0xc0
:[<ffffffff81483615>] cpuidle_idle_call+0xc5/0x200
:[<ffffffff8101bc7e>] arch_cpu_idle+0xe/0x30
:[<ffffffff810b4725>] cpu_startup_entry+0xf5/0x290
:[<ffffffff815cfee1>] start_secondary+0x265/0x27b

dmesg:
:[    0.000000] CPU0 microcode updated early to revision 0x29, date =3D
2013-06-12
:[    0.000000] Initializing cgroup subsys cpuset
:[    0.000000] Initializing cgroup subsys cpu
:[    0.000000] Initializing cgroup subsys cpuacct
:[    0.000000] Linux version 3.10.0-123.el7.x86_64 (
builder@kbuilder.dev.centos.org) (gcc version 4.8.2 20140120 (Red Hat
4.8.2-16) (GCC) ) #1 SMP Mon Jun 30 12:09:22 UTC 2014
:[    0.000000] Command line: BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el7.x86_64
root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro rd.lvm.lv=3Dcentos_ro=
uter/swap
vconsole.font=3Dlatarcyrheb-sun16 rd.lvm.lv=3Dcentos_router/root
crashkernel=3Dauto vconsole.keymap=3Dus rhgb quiet LANG=3Den_US.UTF-8
:[    0.000000] e820: BIOS-provided physical RAM map:
:[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009d7ff]
usable
:[    0.000000] BIOS-e820: [mem 0x000000000009d800-0x000000000009ffff]
reserved
:[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff]
reserved
:[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffffff]
usable
:[    0.000000] BIOS-e820: [mem 0x0000000020000000-0x00000000201fffff]
reserved
:[    0.000000] BIOS-e820: [mem 0x0000000020200000-0x000000003fffffff]
usable
:[    0.000000] BIOS-e820: [mem 0x0000000040000000-0x00000000401fffff]
reserved
:[    0.000000] BIOS-e820: [mem 0x0000000040200000-0x00000000d94d1fff]
usable
:[    0.000000] BIOS-e820: [mem 0x00000000d94d2000-0x00000000d9a94fff]
reserved
:[    0.000000] BIOS-e820: [mem 0x00000000d9a95000-0x00000000d9a95fff] ACPI
data
:[    0.000000] BIOS-e820: [mem 0x00000000d9a96000-0x00000000d9bbafff] ACPI
NVS
:[    0.000000] BIOS-e820: [mem 0x00000000d9bbb000-0x00000000da6b8fff]
reserved
:[    0.000000] BIOS-e820: [mem 0x00000000da6b9000-0x00000000da6b9fff]
usable
:[    0.000000] BIOS-e820: [mem 0x00000000da6ba000-0x00000000da6fcfff] ACPI
NVS
:[    0.000000] BIOS-e820: [mem 0x00000000da6fd000-0x00000000dadeefff]
usable
:[    0.000000] BIOS-e820: [mem 0x00000000dadef000-0x00000000dafe0fff]
reserved
:[    0.000000] BIOS-e820: [mem 0x00000000dafe1000-0x00000000daffffff]
usable
:[    0.000000] BIOS-e820: [mem 0x00000000db800000-0x00000000df9fffff]
reserved
:[    0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbffffff]
reserved
:[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff]
reserved
:[    0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed03fff]
reserved
:[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff]
reserved
:[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff]
reserved
:[    0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff]
reserved
:[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000021f5fffff]
usable
:[    0.000000] NX (Execute Disable) protection: active
:[    0.000000] SMBIOS 2.7 present.
:[    0.000000] DMI: Gigabyte Technology Co., Ltd. To be filled by
O.E.M./C847N, BIOS F2 11/09/2012
:[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> res=
erved
:[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
:[    0.000000] No AGP bridge found
:[    0.000000] e820: last_pfn =3D 0x21f600 max_arch_pfn =3D 0x400000000
:[    0.000000] MTRR default type: uncachable
:[    0.000000] MTRR fixed ranges enabled:
:[    0.000000]   00000-9FFFF write-back
:[    0.000000]   A0000-BFFFF uncachable
:[    0.000000]   C0000-CFFFF write-protect
:[    0.000000]   D0000-E7FFF uncachable
:[    0.000000]   E8000-FFFFF write-protect
:[    0.000000] MTRR variable ranges enabled:
:[    0.000000]   0 base 000000000 mask E00000000 write-back
:[    0.000000]   1 base 200000000 mask FE0000000 write-back
:[    0.000000]   2 base 0E0000000 mask FE0000000 uncachable
:[    0.000000]   3 base 0DC000000 mask FFC000000 uncachable
:[    0.000000]   4 base 0DB800000 mask FFF800000 uncachable
:[    0.000000]   5 base 21F800000 mask FFF800000 uncachable
:[    0.000000]   6 base 21F600000 mask FFFE00000 uncachable
:[    0.000000]   7 disabled
:[    0.000000]   8 disabled
:[    0.000000]   9 disabled
:[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new
0x7010600070106
:[    0.000000] original variable MTRRs
:[    0.000000] reg 0, base: 0GB, range: 8GB, type WB
:[    0.000000] reg 1, base: 8GB, range: 512MB, type WB
:[    0.000000] reg 2, base: 3584MB, range: 512MB, type UC
:[    0.000000] reg 3, base: 3520MB, range: 64MB, type UC
:[    0.000000] reg 4, base: 3512MB, range: 8MB, type UC
:[    0.000000] reg 5, base: 8696MB, range: 8MB, type UC
:[    0.000000] reg 6, base: 8694MB, range: 2MB, type UC
:[    0.000000] total RAM covered: 8110M
:[    0.000000] Found optimal setting for mtrr clean up
:[    0.000000]  gran_size: 64K         chunk_size: 128M        num_reg: 9
    lose cover RAM: 0G
:[    0.000000] New variable MTRRs
:[    0.000000] reg 0, base: 0GB, range: 2GB, type WB
:[    0.000000] reg 1, base: 2GB, range: 1GB, type WB
:[    0.000000] reg 2, base: 3GB, range: 512MB, type WB
:[    0.000000] reg 3, base: 3512MB, range: 8MB, type UC
:[    0.000000] reg 4, base: 3520MB, range: 64MB, type UC
:[    0.000000] reg 5, base: 4GB, range: 4GB, type WB
:[    0.000000] reg 6, base: 8GB, range: 512MB, type WB
:[    0.000000] reg 7, base: 8694MB, range: 2MB, type UC
:[    0.000000] reg 8, base: 8696MB, range: 8MB, type UC
:[    0.000000] e820: update [mem 0xdb800000-0xffffffff] usable =3D=3D> res=
erved
:[    0.000000] e820: last_pfn =3D 0xdb000 max_arch_pfn =3D 0x400000000
:[    0.000000] found SMP MP-table at [mem 0x000fd760-0x000fd76f] mapped at
[ffff8800000fd760]
:[    0.000000] Base memory trampoline at [ffff880000097000] 97000 size
24576
:[    0.000000] reserving inaccessible SNB gfx pages
:[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
:[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
:[    0.000000] BRK [0x01e1d000, 0x01e1dfff] PGTABLE
:[    0.000000] BRK [0x01e1e000, 0x01e1efff] PGTABLE
:[    0.000000] BRK [0x01e1f000, 0x01e1ffff] PGTABLE
:[    0.000000] init_memory_mapping: [mem 0x21f400000-0x21f5fffff]
:[    0.000000]  [mem 0x21f400000-0x21f5fffff] page 2M
:[    0.000000] BRK [0x01e20000, 0x01e20fff] PGTABLE
:[    0.000000] init_memory_mapping: [mem 0x21c000000-0x21f3fffff]
:[    0.000000]  [mem 0x21c000000-0x21f3fffff] page 2M
:[    0.000000] init_memory_mapping: [mem 0x200000000-0x21bffffff]
:[    0.000000]  [mem 0x200000000-0x21bffffff] page 2M
:[    0.000000] init_memory_mapping: [mem 0x00100000-0x1fffffff]
:[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
:[    0.000000]  [mem 0x00200000-0x1fffffff] page 2M
:[    0.000000] init_memory_mapping: [mem 0x20200000-0x3fffffff]
:[    0.000000]  [mem 0x20200000-0x3fffffff] page 2M
:[    0.000000] init_memory_mapping: [mem 0x40200000-0xd94d1fff]
:[    0.000000]  [mem 0x40200000-0xd93fffff] page 2M
:[    0.000000]  [mem 0xd9400000-0xd94d1fff] page 4k
:[    0.000000] BRK [0x01e21000, 0x01e21fff] PGTABLE
:[    0.000000] BRK [0x01e22000, 0x01e22fff] PGTABLE
:[    0.000000] init_memory_mapping: [mem 0xda6b9000-0xda6b9fff]
:[    0.000000]  [mem 0xda6b9000-0xda6b9fff] page 4k
:[    0.000000] init_memory_mapping: [mem 0xda6fd000-0xdadeefff]
:[    0.000000]  [mem 0xda6fd000-0xda7fffff] page 4k
:[    0.000000]  [mem 0xda800000-0xdabfffff] page 2M
:[    0.000000]  [mem 0xdac00000-0xdadeefff] page 4k
:[    0.000000] init_memory_mapping: [mem 0xdafe1000-0xdaffffff]
:[    0.000000]  [mem 0xdafe1000-0xdaffffff] page 4k
:[    0.000000] init_memory_mapping: [mem 0x100000000-0x1ffffffff]
:[    0.000000]  [mem 0x100000000-0x1ffffffff] page 2M
:[    0.000000] RAMDISK: [mem 0x369a0000-0x374c7fff]
:[    0.000000] Reserving 161MB of memory at 704MB for crashkernel (System
RAM: 8077MB)
:[    0.000000] ACPI: RSDP 00000000000f0490 00024 (v02 ALASKA)
:[    0.000000] ACPI: XSDT 00000000d9b9c070 00064 (v01 ALASKA    A M I
01072009 AMI  00010013)
:[    0.000000] ACPI: FACP 00000000d9ba6610 000F4 (v04 ALASKA    A M I
01072009 AMI  00010013)
:[    0.000000] ACPI: DSDT 00000000d9b9c170 0A49C (v02 ALASKA    A M I
00000012 INTL 20051117)
:[    0.000000] ACPI: FACS 00000000d9bb9f80 00040
:[    0.000000] ACPI: APIC 00000000d9ba6708 00062 (v03 ALASKA    A M I
01072009 AMI  00010013)
:[    0.000000] ACPI: MCFG 00000000d9ba6770 0003C (v01
 01072009 MSFT 00000097)
:[    0.000000] ACPI: HPET 00000000d9ba67b0 00038 (v01 ALASKA    A M I
01072009 AMI. 00000005)
:[    0.000000] ACPI: SSDT 00000000d9ba67e8 0036D (v01 SataRe SataTabl
00001000 INTL 20091112)
:[    0.000000] ACPI: SSDT 00000000d9ba6b58 00692 (v01  PmRef  Cpu0Ist
00003000 INTL 20051117)
:[    0.000000] ACPI: SSDT 00000000d9ba71f0 00A92 (v01  PmRef    CpuPm
00003000 INTL 20051117)
:[    0.000000] ACPI: BGRT 00000000d9ba7c88 00038 (v00 ALASKA    A M I
01072009 AMI  00010013)
:[    0.000000] ACPI: Local APIC address 0xfee00000
:[    0.000000] No NUMA configuration found
:[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000021f5fffff=
]
:[    0.000000] Initmem setup node 0 [mem 0x00000000-0x21f5fffff]
:[    0.000000]   NODE_DATA [mem 0x21f5d0000-0x21f5f6fff]
:[    0.000000]  [ffffea0000000000-ffffea00087fffff] PMD ->
[ffff880216c00000-ffff88021ebfffff] on node 0
:[    0.000000] Zone ranges:
:[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
:[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
:[    0.000000]   Normal   [mem 0x100000000-0x21f5fffff]
:[    0.000000] Movable zone start for each node
:[    0.000000] Early memory node ranges
:[    0.000000]   node   0: [mem 0x00001000-0x0009cfff]
:[    0.000000]   node   0: [mem 0x00100000-0x1fffffff]
:[    0.000000]   node   0: [mem 0x20200000-0x3fffffff]
:[    0.000000]   node   0: [mem 0x40200000-0xd94d1fff]
:[    0.000000]   node   0: [mem 0xda6b9000-0xda6b9fff]
:[    0.000000]   node   0: [mem 0xda6fd000-0xdadeefff]
:[    0.000000]   node   0: [mem 0xdafe1000-0xdaffffff]
:[    0.000000]   node   0: [mem 0x100000000-0x21f5fffff]
:[    0.000000] On node 0 totalpages: 2067840
:[    0.000000]   DMA zone: 64 pages used for memmap
:[    0.000000]   DMA zone: 156 pages reserved
:[    0.000000]   DMA zone: 3996 pages, LIFO batch:0
:[    0.000000]   DMA32 zone: 13856 pages used for memmap
:[    0.000000]   DMA32 zone: 886756 pages, LIFO batch:31
:[    0.000000]   Normal zone: 18392 pages used for memmap
:[    0.000000]   Normal zone: 1177088 pages, LIFO batch:31
:[    0.000000] ACPI: PM-Timer IO Port: 0x408
:[    0.000000] ACPI: Local APIC address 0xfee00000
:[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
:[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
:[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
:[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
:[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI
0-23
:[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
:[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
:[    0.000000] ACPI: IRQ0 used by override.
:[    0.000000] ACPI: IRQ2 used by override.
:[    0.000000] ACPI: IRQ9 used by override.
:[    0.000000] Using ACPI (MADT) for SMP configuration information
:[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
:[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
:[    0.000000] nr_irqs_gsi: 40
:[    0.000000] PM: Registered nosave memory: [mem 0x0009d000-0x0009dfff]
:[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009ffff]
:[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
:[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
:[    0.000000] PM: Registered nosave memory: [mem 0x20000000-0x201fffff]
:[    0.000000] PM: Registered nosave memory: [mem 0x40000000-0x401fffff]
:[    0.000000] PM: Registered nosave memory: [mem 0xd94d2000-0xd9a94fff]
:[    0.000000] PM: Registered nosave memory: [mem 0xd9a95000-0xd9a95fff]
:[    0.000000] PM: Registered nosave memory: [mem 0xd9a96000-0xd9bbafff]
:[    0.000000] PM: Registered nosave memory: [mem 0xd9bbb000-0xda6b8fff]
:[    0.000000] PM: Registered nosave memory: [mem 0xda6ba000-0xda6fcfff]
:[    0.000000] PM: Registered nosave memory: [mem 0xdadef000-0xdafe0fff]
:[    0.000000] PM: Registered nosave memory: [mem 0xdb000000-0xdb7fffff]
:[    0.000000] PM: Registered nosave memory: [mem 0xdb800000-0xdf9fffff]
:[    0.000000] PM: Registered nosave memory: [mem 0xdfa00000-0xf7ffffff]
:[    0.000000] PM: Registered nosave memory: [mem 0xf8000000-0xfbffffff]
:[    0.000000] PM: Registered nosave memory: [mem 0xfc000000-0xfebfffff]
:[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfec00fff]
:[    0.000000] PM: Registered nosave memory: [mem 0xfec01000-0xfecfffff]
:[    0.000000] PM: Registered nosave memory: [mem 0xfed00000-0xfed03fff]
:[    0.000000] PM: Registered nosave memory: [mem 0xfed04000-0xfed1bfff]
:[    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
:[    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xfedfffff]
:[    0.000000] PM: Registered nosave memory: [mem 0xfee00000-0xfee00fff]
:[    0.000000] PM: Registered nosave memory: [mem 0xfee01000-0xfeffffff]
:[    0.000000] PM: Registered nosave memory: [mem 0xff000000-0xffffffff]
:[    0.000000] e820: [mem 0xdfa00000-0xf7ffffff] available for PCI devices
:[    0.000000] Booting paravirtualized kernel on bare hardware
:[    0.000000] setup_percpu: NR_CPUS:5120 nr_cpumask_bits:2 nr_cpu_ids:2
nr_node_ids:1
:[    0.000000] PERCPU: Embedded 29 pages/cpu @ffff88021f200000 s86592
r8192 d24000 u1048576
:[    0.000000] pcpu-alloc: s86592 r8192 d24000 u1048576 alloc=3D1*2097152
:[    0.000000] pcpu-alloc: [0] 0 1
:[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.
Total pages: 2035372
:[    0.000000] Policy zone: Normal
:[    0.000000] Kernel command line:
BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el7.x86_64
root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro rd.lvm.lv=3Dcentos_ro=
uter/swap
vconsole.font=3Dlatarcyrheb-sun16 rd.lvm.lv=3Dcentos_router/root
crashkernel=3Dauto vconsole.keymap=3Dus rhgb quiet LANG=3Den_US.UTF-8
:[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
:[    0.000000] xsave: enabled xstate_bv 0x3, cntxt size 0x240
:[    0.000000] Checking aperture...
:[    0.000000] No AGP bridge found
:[    0.000000] Memory: 7882168k/8902656k available (6105k kernel code,
631296k absent, 389192k reserved, 4065k data, 1584k init)
:[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D2, =
Nodes=3D1
:[    0.000000] Hierarchical RCU implementation.
:[    0.000000]         RCU restricting CPUs from NR_CPUS=3D5120 to
nr_cpu_ids=3D2.
:[    0.000000]         Experimental no-CBs for all CPUs
:[    0.000000]         Experimental no-CBs CPUs: 0-1.
:[    0.000000] NR_IRQS:327936 nr_irqs:512 16
:[    0.000000] Console: colour VGA+ 80x25
:[    0.000000] console [tty0] enabled
:[    0.000000] allocated 33554432 bytes of page_cgroup
:[    0.000000] please try 'cgroup_disable=3Dmemory' option if you don't wa=
nt
memory cgroups
:[    0.000000] hpet clockevent registered
:[    0.000000] tsc: Fast TSC calibration using PIT
:[    0.002000] tsc: Detected 1097.537 MHz processor
:[    0.000004] Calibrating delay loop (skipped), value calculated using
timer frequency.. 2195.07 BogoMIPS (lpj=3D1097537)
:[    0.000009] pid_max: default: 32768 minimum: 301
:[    0.000048] Security Framework initialized
:[    0.000059] SELinux:  Initializing.
:[    0.000073] SELinux:  Starting in permissive mode
:[    0.001469] Dentry cache hash table entries: 1048576 (order: 11,
8388608 bytes)
:[    0.005221] Inode-cache hash table entries: 524288 (order: 10, 4194304
bytes)
:[    0.006767] Mount-cache hash table entries: 4096
:[    0.007121] Initializing cgroup subsys memory
:[    0.007135] Initializing cgroup subsys devices
:[    0.007139] Initializing cgroup subsys freezer
:[    0.007141] Initializing cgroup subsys net_cls
:[    0.007144] Initializing cgroup subsys blkio
:[    0.007146] Initializing cgroup subsys perf_event
:[    0.007150] Initializing cgroup subsys hugetlb
:[    0.007194] CPU: Physical Processor ID: 0
:[    0.007197] CPU: Processor Core ID: 0
:[    0.007205] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
:ENERGY_PERF_BIAS: View and update with x86_energy_perf_policy(8)
:[    0.007211] mce: CPU supports 7 MCE banks
:[    0.007232] CPU0: Thermal monitoring enabled (TM1)
:[    0.007248] Last level iTLB entries: 4KB 512, 2MB 0, 4MB 0
:Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32
:tlb_flushall_shift: 6
:[    0.007425] Freeing SMP alternatives: 24k freed
:[    0.010435] ACPI: Core revision 20130517
:[    0.022190] ACPI: All ACPI Tables successfully acquired
:[    0.022419] ftrace: allocating 23383 entries in 92 pages
:[    0.047596] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=
=3D-1
:[    0.057604] smpboot: CPU0: Intel(R) Celeron(R) CPU 847 @ 1.10GHz (fam:
06, model: 2a, stepping: 07)
:[    0.057618] TSC deadline timer enabled
:[    0.057636] Performance Events: PEBS fmt1+, 16-deep LBR, SandyBridge
events, full-width counters, Intel PMU driver.
:[    0.057651] ... version:                3
:[    0.057654] ... bit width:              48
:[    0.057656] ... generic registers:      8
:[    0.057658] ... value mask:             0000ffffffffffff
:[    0.057661] ... max period:             0000ffffffffffff
:[    0.057663] ... fixed-purpose events:   3
:[    0.057665] ... event mask:             00000007000000ff
:[    0.060083] smpboot: Booting Node   0, Processors  #1 OK
:[    0.071147] CPU1 microcode updated early to revision 0x29, date =3D
2013-06-12
:[    0.073360] Brought up 2 CPUs
:[    0.073367] smpboot: Total of 2 processors activated (4390.14 BogoMIPS)
:[    0.073465] NMI watchdog: enabled on all CPUs, permanently consumes one
hw-PMU counter.
:[    0.075983] devtmpfs: initialized
:[    0.078123] EVM: security.selinux
:[    0.078126] EVM: security.ima
:[    0.078129] EVM: security.capability
:[    0.078258] PM: Registering ACPI NVS region [mem 0xd9a96000-0xd9bbafff]
(1200128 bytes)
:[    0.078297] PM: Registering ACPI NVS region [mem 0xda6ba000-0xda6fcfff]
(274432 bytes)
:[    0.079950] atomic64 test passed for x86-64 platform with CX8 and with
SSE
:[    0.080031] NET: Registered protocol family 16
:[    0.080296] ACPI: bus type PCI registered
:[    0.080301] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
:[    0.080383] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem
0xf8000000-0xfbffffff] (base 0xf8000000)
:[    0.080388] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in
E820
:[    0.095808] PCI: Using configuration type 1 for base access
:[    0.097442] bio: create slab <bio-0> at 0
:[    0.097607] ACPI: Added _OSI(Module Device)
:[    0.097611] ACPI: Added _OSI(Processor Device)
:[    0.097614] ACPI: Added _OSI(3.0 _SCP Extensions)
:[    0.097617] ACPI: Added _OSI(Processor Aggregator Device)
:[    0.100564] ACPI: EC: Look up EC in DSDT
:[    0.104172] ACPI: Executed 1 blocks of module-level executable AML code
:[    0.111498] ACPI: SSDT 00000000d9a37018 0083B (v01  PmRef  Cpu0Cst
00003001 INTL 20051117)
:[    0.112265] ACPI: Dynamic OEM Table Load:
:[    0.112270] ACPI: SSDT           (null) 0083B (v01  PmRef  Cpu0Cst
00003001 INTL 20051117)
:[    0.114181] ACPI: SSDT 00000000d9a38a98 00303 (v01  PmRef    ApIst
00003000 INTL 20051117)
:[    0.115009] ACPI: Dynamic OEM Table Load:
:[    0.115014] ACPI: SSDT           (null) 00303 (v01  PmRef    ApIst
00003000 INTL 20051117)
:[    0.116869] ACPI: SSDT 00000000d9a44c18 00119 (v01  PmRef    ApCst
00003000 INTL 20051117)
:[    0.117606] ACPI: Dynamic OEM Table Load:
:[    0.117610] ACPI: SSDT           (null) 00119 (v01  PmRef    ApCst
00003000 INTL 20051117)
:[    0.119503] ACPI: Interpreter enabled
:[    0.119516] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State
[\_S1_] (20130517/hwxface-571)
:[    0.119525] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State
[\_S2_] (20130517/hwxface-571)
:[    0.119553] ACPI: (supports S0 S3 S4 S5)
:[    0.119556] ACPI: Using IOAPIC for interrupt routing
:[    0.119611] PCI: Using host bridge windows from ACPI; if necessary, use
"pci=3Dnocrs" and report a bug
:[    0.119893] ACPI: No dock devices found.
:[    0.135655] ACPI: Power Resource [FN00] (off)
:[    0.135820] ACPI: Power Resource [FN01] (off)
:[    0.135978] ACPI: Power Resource [FN02] (off)
:[    0.136127] ACPI: Power Resource [FN03] (off)
:[    0.136279] ACPI: Power Resource [FN04] (off)
:[    0.137476] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
:[    0.137487] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM
ClockPM Segments MSI]
:[    0.137926] acpi PNP0A08:00: _OSC: platform does not support
[PCIeHotplug PME]
:[    0.138200] acpi PNP0A08:00: _OSC: OS now controls [AER PCIeCapability]
:[    0.139322] PCI host bridge to bus 0000:00
:[    0.139328] pci_bus 0000:00: root bus resource [bus 00-3e]
:[    0.139333] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
:[    0.139337] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
:[    0.139340] pci_bus 0000:00: root bus resource [mem
0x000a0000-0x000bffff]
:[    0.139344] pci_bus 0000:00: root bus resource [mem
0x000d0000-0x000d3fff]
:[    0.139347] pci_bus 0000:00: root bus resource [mem
0x000d4000-0x000d7fff]
:[    0.139351] pci_bus 0000:00: root bus resource [mem
0x000d8000-0x000dbfff]
:[    0.139359] pci_bus 0000:00: root bus resource [mem
0x000dc000-0x000dffff]
:[    0.139363] pci_bus 0000:00: root bus resource [mem
0x000e0000-0x000e3fff]
:[    0.139366] pci_bus 0000:00: root bus resource [mem
0x000e4000-0x000e7fff]
:[    0.139370] pci_bus 0000:00: root bus resource [mem
0xdfa00000-0xfeafffff]
:[    0.139387] pci 0000:00:00.0: [8086:0104] type 00 class 0x060000
:[    0.139570] pci 0000:00:02.0: [8086:0106] type 00 class 0x030000
:[    0.139592] pci 0000:00:02.0: reg 0x10: [mem 0xf7800000-0xf7bfffff
64bit]
:[    0.139605] pci 0000:00:02.0: reg 0x18: [mem 0xe0000000-0xefffffff
64bit pref]
:[    0.139614] pci 0000:00:02.0: reg 0x20: [io  0xf000-0xf03f]
:[    0.139824] pci 0000:00:16.0: [8086:1e3a] type 00 class 0x078000
:[    0.139857] pci 0000:00:16.0: reg 0x10: [mem 0xf7f0a000-0xf7f0a00f
64bit]
:[    0.139961] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
:[    0.140131] pci 0000:00:1a.0: [8086:1e2d] type 00 class 0x0c0320
:[    0.140161] pci 0000:00:1a.0: reg 0x10: [mem 0xf7f08000-0xf7f083ff]
:[    0.140285] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
:[    0.140414] pci 0000:00:1a.0: System wakeup disabled by ACPI
:[    0.140475] pci 0000:00:1b.0: [8086:1e20] type 00 class 0x040300
:[    0.140498] pci 0000:00:1b.0: reg 0x10: [mem 0xf7f00000-0xf7f03fff
64bit]
:[    0.140605] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
:[    0.140710] pci 0000:00:1b.0: System wakeup disabled by ACPI
:[    0.140764] pci 0000:00:1c.0: [8086:1e10] type 01 class 0x060400
:[    0.140884] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
:[    0.140992] pci 0000:00:1c.0: System wakeup disabled by ACPI
:[    0.141043] pci 0000:00:1c.1: [8086:1e12] type 01 class 0x060400
:[    0.141155] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
:[    0.141261] pci 0000:00:1c.1: System wakeup disabled by ACPI
:[    0.141313] pci 0000:00:1c.2: [8086:2448] type 01 class 0x060401
:[    0.141425] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
:[    0.141534] pci 0000:00:1c.2: System wakeup disabled by ACPI
:[    0.141585] pci 0000:00:1c.3: [8086:1e16] type 01 class 0x060400
:[    0.141697] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
:[    0.141803] pci 0000:00:1c.3: System wakeup disabled by ACPI
:[    0.141870] pci 0000:00:1d.0: [8086:1e26] type 00 class 0x0c0320
:[    0.141900] pci 0000:00:1d.0: reg 0x10: [mem 0xf7f07000-0xf7f073ff]
:[    0.142024] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
:[    0.142150] pci 0000:00:1d.0: System wakeup disabled by ACPI
:[    0.142205] pci 0000:00:1f.0: [8086:1e5f] type 00 class 0x060100
:[    0.142478] pci 0000:00:1f.2: [8086:1e03] type 00 class 0x010601
:[    0.142507] pci 0000:00:1f.2: reg 0x10: [io  0xf0b0-0xf0b7]
:[    0.142519] pci 0000:00:1f.2: reg 0x14: [io  0xf0a0-0xf0a3]
:[    0.142531] pci 0000:00:1f.2: reg 0x18: [io  0xf090-0xf097]
:[    0.142543] pci 0000:00:1f.2: reg 0x1c: [io  0xf080-0xf083]
:[    0.142556] pci 0000:00:1f.2: reg 0x20: [io  0xf060-0xf07f]
:[    0.142568] pci 0000:00:1f.2: reg 0x24: [mem 0xf7f06000-0xf7f067ff]
:[    0.142637] pci 0000:00:1f.2: PME# supported from D3hot
:[    0.142777] pci 0000:00:1f.3: [8086:1e22] type 00 class 0x0c0500
:[    0.142800] pci 0000:00:1f.3: reg 0x10: [mem 0xf7f05000-0xf7f050ff
64bit]
:[    0.142836] pci 0000:00:1f.3: reg 0x20: [io  0xf040-0xf05f]
:[    0.143098] pci 0000:01:00.0: [10ec:8168] type 00 class 0x020000
:[    0.143124] pci 0000:01:00.0: reg 0x10: [io  0xe000-0xe0ff]
:[    0.143168] pci 0000:01:00.0: reg 0x18: [mem 0xf7e00000-0xf7e00fff
64bit]
:[    0.143196] pci 0000:01:00.0: reg 0x20: [mem 0xf0100000-0xf0103fff
64bit pref]
:[    0.143332] pci 0000:01:00.0: supports D1 D2
:[    0.143336] pci 0000:01:00.0: PME# supported from D0 D1 D2 D3hot D3cold
:[    0.143388] pci 0000:01:00.0: System wakeup disabled by ACPI
:[    0.144857] pci 0000:00:1c.0: PCI bridge to [bus 01]
:[    0.144866] pci 0000:00:1c.0:   bridge window [io  0xe000-0xefff]
:[    0.144874] pci 0000:00:1c.0:   bridge window [mem
0xf7e00000-0xf7efffff]
:[    0.144886] pci 0000:00:1c.0:   bridge window [mem
0xf0100000-0xf01fffff 64bit pref]
:[    0.145020] pci 0000:02:00.0: [10ec:8168] type 00 class 0x020000
:[    0.145046] pci 0000:02:00.0: reg 0x10: [io  0xd000-0xd0ff]
:[    0.145089] pci 0000:02:00.0: reg 0x18: [mem 0xf0004000-0xf0004fff
64bit pref]
:[    0.145116] pci 0000:02:00.0: reg 0x20: [mem 0xf0000000-0xf0003fff
64bit pref]
:[    0.145251] pci 0000:02:00.0: supports D1 D2
:[    0.145254] pci 0000:02:00.0: PME# supported from D0 D1 D2 D3hot D3cold
:[    0.145306] pci 0000:02:00.0: System wakeup disabled by ACPI
:[    0.146858] pci 0000:00:1c.1: PCI bridge to [bus 02]
:[    0.146867] pci 0000:00:1c.1:   bridge window [io  0xd000-0xdfff]
:[    0.146882] pci 0000:00:1c.1:   bridge window [mem
0xf0000000-0xf00fffff 64bit pref]
:[    0.147011] pci 0000:03:00.0: [8086:244e] type 01 class 0x060401
:[    0.147194] pci 0000:03:00.0: supports D1 D2
:[    0.147197] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
:[    0.147236] pci 0000:03:00.0: System wakeup disabled by ACPI
:[    0.147280] pci 0000:00:1c.2: PCI bridge to [bus 03-04] (subtractive
decode)
:[    0.147286] pci 0000:00:1c.2:   bridge window [io  0xc000-0xcfff]
:[    0.147292] pci 0000:00:1c.2:   bridge window [mem
0xf7d00000-0xf7dfffff]
:[    0.147302] pci 0000:00:1c.2:   bridge window [io  0x0000-0x0cf7]
(subtractive decode)
:[    0.147306] pci 0000:00:1c.2:   bridge window [io  0x0d00-0xffff]
(subtractive decode)
:[    0.147310] pci 0000:00:1c.2:   bridge window [mem
0x000a0000-0x000bffff] (subtractive decode)
:[    0.147313] pci 0000:00:1c.2:   bridge window [mem
0x000d0000-0x000d3fff] (subtractive decode)
:[    0.147317] pci 0000:00:1c.2:   bridge window [mem
0x000d4000-0x000d7fff] (subtractive decode)
:[    0.147320] pci 0000:00:1c.2:   bridge window [mem
0x000d8000-0x000dbfff] (subtractive decode)
:[    0.147324] pci 0000:00:1c.2:   bridge window [mem
0x000dc000-0x000dffff] (subtractive decode)
:[    0.147328] pci 0000:00:1c.2:   bridge window [mem
0x000e0000-0x000e3fff] (subtractive decode)
:[    0.147331] pci 0000:00:1c.2:   bridge window [mem
0x000e4000-0x000e7fff] (subtractive decode)
:[    0.147335] pci 0000:00:1c.2:   bridge window [mem
0xdfa00000-0xfeafffff] (subtractive decode)
:[    0.147442] pci 0000:04:00.0: [1186:4300] type 00 class 0x020000
:[    0.147485] pci 0000:04:00.0: reg 0x10: [io  0xc000-0xc0ff]
:[    0.147510] pci 0000:04:00.0: reg 0x14: [mem 0xf7d20000-0xf7d200ff]
:[    0.147618] pci 0000:04:00.0: reg 0x30: [mem 0xf7d00000-0xf7d1ffff pref=
]
:[    0.147690] pci 0000:04:00.0: supports D1 D2
:[    0.147693] pci 0000:04:00.0: PME# supported from D1 D2 D3hot D3cold
:[    0.147851] pci 0000:03:00.0: PCI bridge to [bus 04] (subtractive
decode)
:[    0.147866] pci 0000:03:00.0:   bridge window [io  0xc000-0xcfff]
:[    0.147876] pci 0000:03:00.0:   bridge window [mem
0xf7d00000-0xf7dfffff]
:[    0.147890] pci 0000:03:00.0:   bridge window [io  0xc000-0xcfff]
(subtractive decode)
:[    0.147894] pci 0000:03:00.0:   bridge window [mem
0xf7d00000-0xf7dfffff] (subtractive decode)
:[    0.147897] pci 0000:03:00.0:   bridge window [??? 0x00000000 flags
0x0] (subtractive decode)
:[    0.147901] pci 0000:03:00.0:   bridge window [??? 0x00000000 flags
0x0] (subtractive decode)
:[    0.147905] pci 0000:03:00.0:   bridge window [io  0x0000-0x0cf7]
(subtractive decode)
:[    0.147908] pci 0000:03:00.0:   bridge window [io  0x0d00-0xffff]
(subtractive decode)
:[    0.147912] pci 0000:03:00.0:   bridge window [mem
0x000a0000-0x000bffff] (subtractive decode)
:[    0.147915] pci 0000:03:00.0:   bridge window [mem
0x000d0000-0x000d3fff] (subtractive decode)
:[    0.147919] pci 0000:03:00.0:   bridge window [mem
0x000d4000-0x000d7fff] (subtractive decode)
:[    0.147922] pci 0000:03:00.0:   bridge window [mem
0x000d8000-0x000dbfff] (subtractive decode)
:[    0.147926] pci 0000:03:00.0:   bridge window [mem
0x000dc000-0x000dffff] (subtractive decode)
:[    0.147929] pci 0000:03:00.0:   bridge window [mem
0x000e0000-0x000e3fff] (subtractive decode)
:[    0.147933] pci 0000:03:00.0:   bridge window [mem
0x000e4000-0x000e7fff] (subtractive decode)
:[    0.147936] pci 0000:03:00.0:   bridge window [mem
0xdfa00000-0xfeafffff] (subtractive decode)
:[    0.148062] pci 0000:05:00.0: [197b:2368] type 00 class 0x010185
:[    0.148106] pci 0000:05:00.0: reg 0x10: [io  0xb040-0xb047]
:[    0.148126] pci 0000:05:00.0: reg 0x14: [io  0xb030-0xb033]
:[    0.148147] pci 0000:05:00.0: reg 0x18: [io  0xb020-0xb027]
:[    0.148168] pci 0000:05:00.0: reg 0x1c: [io  0xb010-0xb013]
:[    0.148189] pci 0000:05:00.0: reg 0x20: [io  0xb000-0xb00f]
:[    0.148227] pci 0000:05:00.0: reg 0x30: [mem 0xf7c00000-0xf7c0ffff pref=
]
:[    0.148366] pci 0000:05:00.0: System wakeup disabled by ACPI
:[    0.148407] pci 0000:05:00.0: disabling ASPM on pre-1.1 PCIe device.
You can enable it with 'pcie_aspm=3Dforce'
:[    0.148422] pci 0000:00:1c.3: PCI bridge to [bus 05]
:[    0.148429] pci 0000:00:1c.3:   bridge window [io  0xb000-0xbfff]
:[    0.148435] pci 0000:00:1c.3:   bridge window [mem
0xf7c00000-0xf7cfffff]
:[    0.149939] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 *11 12 14
15)
:[    0.150042] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 *10 11 12 14
15)
:[    0.150140] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 *11 12 14
15)
:[    0.150238] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10 11 12 14
15)
:[    0.150340] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 10 11 12 14
15) *0, disabled.
:[    0.150441] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 11 12 14
15) *0, disabled.
:[    0.150538] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 10 *11 12 14
15)
:[    0.150634] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *10 11 12 14
15)
:[    0.151075] ACPI: Enabled 5 GPEs in block 00 to 3F
:[    0.151090] ACPI: \_SB_.PCI0: notify handler is installed
:[    0.151214] Found 1 acpi root devices
:[    0.151369] vgaarb: device added:
PCI:0000:00:02.0,decodes=3Dio+mem,owns=3Dio+mem,locks=3Dnone
:[    0.151376] vgaarb: loaded
:[    0.151379] vgaarb: bridge control possible 0000:00:02.0
:[    0.151491] SCSI subsystem initialized
:[    0.151523] ACPI: bus type USB registered
:[    0.151560] usbcore: registered new interface driver usbfs
:[    0.151573] usbcore: registered new interface driver hub
:[    0.151633] usbcore: registered new device driver usb
:[    0.151757] PCI: Using ACPI for IRQ routing
:[    0.153871] PCI: pci_cache_line_size set to 64 bytes
:[    0.153958] e820: reserve RAM buffer [mem 0x0009d800-0x0009ffff]
:[    0.153962] e820: reserve RAM buffer [mem 0xd94d2000-0xdbffffff]
:[    0.153967] e820: reserve RAM buffer [mem 0xda6ba000-0xdbffffff]
:[    0.153970] e820: reserve RAM buffer [mem 0xdadef000-0xdbffffff]
:[    0.153973] e820: reserve RAM buffer [mem 0xdb000000-0xdbffffff]
:[    0.153977] e820: reserve RAM buffer [mem 0x21f600000-0x21fffffff]
:[    0.154122] NetLabel: Initializing
:[    0.154125] NetLabel:  domain hash size =3D 128
:[    0.154127] NetLabel:  protocols =3D UNLABELED CIPSOv4
:[    0.154150] NetLabel:  unlabeled traffic allowed by default
:[    0.154226] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
:[    0.154236] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
:[    0.156260] Switching to clocksource hpet
:[    0.165255] pnp: PnP ACPI init
:[    0.165287] ACPI: bus type PNP registered
:[    0.165448] system 00:00: [mem 0xfed40000-0xfed44fff] has been reserved
:[    0.165456] system 00:00: Plug and Play ACPI device, IDs PNP0c01
(active)
:[    0.165479] pnp 00:01: [dma 4]
:[    0.165502] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
:[    0.165535] pnp 00:02: Plug and Play ACPI device, IDs INT0800 (active)
:[    0.165696] pnp 00:03: Plug and Play ACPI device, IDs PNP0103 (active)
:[    0.165775] system 00:04: [io  0x0680-0x069f] has been reserved
:[    0.165780] system 00:04: [io  0x0200-0x020f] has been reserved
:[    0.165784] system 00:04: [io  0xffff] has been reserved
:[    0.165788] system 00:04: [io  0xffff] has been reserved
:[    0.165793] system 00:04: [io  0x0400-0x0453] could not be reserved
:[    0.165797] system 00:04: [io  0x0458-0x047f] has been reserved
:[    0.165801] system 00:04: [io  0x0500-0x057f] has been reserved
:[    0.165806] system 00:04: Plug and Play ACPI device, IDs PNP0c02
(active)
:[    0.165856] pnp 00:05: Plug and Play ACPI device, IDs PNP0b00 (active)
:[    0.165946] system 00:06: [io  0x0454-0x0457] has been reserved
:[    0.165952] system 00:06: Plug and Play ACPI device, IDs INT3f0d
PNP0c02 (active)
:[    0.166187] system 00:07: [io  0x0a00-0x0a0f] has been reserved
:[    0.166192] system 00:07: [io  0x0a30-0x0a3f] has been reserved
:[    0.166195] system 00:07: [io  0x0a20-0x0a2f] has been reserved
:[    0.166200] system 00:07: Plug and Play ACPI device, IDs PNP0c02
(active)
:[    0.166634] pnp 00:08: [dma 0 disabled]
:[    0.166721] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
:[    0.167080] pnp 00:09: [dma 0 disabled]
:[    0.167162] pnp 00:09: Plug and Play ACPI device, IDs PNP0501 (active)
:[    0.167631] pnp 00:0a: [dma 0 disabled]
:[    0.167824] pnp 00:0a: Plug and Play ACPI device, IDs PNP0400 (active)
:[    0.167915] system 00:0b: [io  0x04d0-0x04d1] has been reserved
:[    0.167921] system 00:0b: Plug and Play ACPI device, IDs PNP0c02
(active)
:[    0.167965] pnp 00:0c: Plug and Play ACPI device, IDs PNP0c04 (active)
:[    0.168450] system 00:0d: [mem 0xfed1c000-0xfed1ffff] has been reserved
:[    0.168455] system 00:0d: [mem 0xfed10000-0xfed17fff] has been reserved
:[    0.168459] system 00:0d: [mem 0xfed18000-0xfed18fff] has been reserved
:[    0.168463] system 00:0d: [mem 0xfed19000-0xfed19fff] has been reserved
:[    0.168468] system 00:0d: [mem 0xf8000000-0xfbffffff] has been reserved
:[    0.168472] system 00:0d: [mem 0xfed20000-0xfed3ffff] has been reserved
:[    0.168475] system 00:0d: [mem 0xfed90000-0xfed93fff] has been reserved
:[    0.168479] system 00:0d: [mem 0xfed45000-0xfed8ffff] has been reserved
:[    0.168489] system 00:0d: [mem 0xff000000-0xffffffff] has been reserved
:[    0.168494] system 00:0d: [mem 0xfee00000-0xfeefffff] could not be
reserved
:[    0.168498] system 00:0d: [mem 0xdfa00000-0xdfa00fff] has been reserved
:[    0.168503] system 00:0d: Plug and Play ACPI device, IDs PNP0c02
(active)
:[    0.168793] system 00:0e: [mem 0x20000000-0x201fffff] has been reserved
:[    0.168797] system 00:0e: [mem 0x40000000-0x401fffff] has been reserved
:[    0.168802] system 00:0e: Plug and Play ACPI device, IDs PNP0c01
(active)
:[    0.168843] pnp: PnP ACPI: found 15 devices
:[    0.168845] ACPI: bus type PNP unregistered
:[    0.176267] pci 0000:00:1c.0: PCI bridge to [bus 01]
:[    0.176280] pci 0000:00:1c.0:   bridge window [io  0xe000-0xefff]
:[    0.176289] pci 0000:00:1c.0:   bridge window [mem
0xf7e00000-0xf7efffff]
:[    0.176296] pci 0000:00:1c.0:   bridge window [mem
0xf0100000-0xf01fffff 64bit pref]
:[    0.176305] pci 0000:00:1c.1: PCI bridge to [bus 02]
:[    0.176310] pci 0000:00:1c.1:   bridge window [io  0xd000-0xdfff]
:[    0.176321] pci 0000:00:1c.1:   bridge window [mem
0xf0000000-0xf00fffff 64bit pref]
:[    0.176331] pci 0000:03:00.0: PCI bridge to [bus 04]
:[    0.176337] pci 0000:03:00.0:   bridge window [io  0xc000-0xcfff]
:[    0.176349] pci 0000:03:00.0:   bridge window [mem
0xf7d00000-0xf7dfffff]
:[    0.176369] pci 0000:00:1c.2: PCI bridge to [bus 03-04]
:[    0.176374] pci 0000:00:1c.2:   bridge window [io  0xc000-0xcfff]
:[    0.176382] pci 0000:00:1c.2:   bridge window [mem
0xf7d00000-0xf7dfffff]
:[    0.176394] pci 0000:00:1c.3: PCI bridge to [bus 05]
:[    0.176399] pci 0000:00:1c.3:   bridge window [io  0xb000-0xbfff]
:[    0.176407] pci 0000:00:1c.3:   bridge window [mem
0xf7c00000-0xf7cfffff]
:[    0.176420] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
:[    0.176424] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
:[    0.176428] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
:[    0.176432] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000d3fff]
:[    0.176435] pci_bus 0000:00: resource 8 [mem 0x000d4000-0x000d7fff]
:[    0.176439] pci_bus 0000:00: resource 9 [mem 0x000d8000-0x000dbfff]
:[    0.176442] pci_bus 0000:00: resource 10 [mem 0x000dc000-0x000dffff]
:[    0.176446] pci_bus 0000:00: resource 11 [mem 0x000e0000-0x000e3fff]
:[    0.176449] pci_bus 0000:00: resource 12 [mem 0x000e4000-0x000e7fff]
:[    0.176453] pci_bus 0000:00: resource 13 [mem 0xdfa00000-0xfeafffff]
:[    0.176457] pci_bus 0000:01: resource 0 [io  0xe000-0xefff]
:[    0.176460] pci_bus 0000:01: resource 1 [mem 0xf7e00000-0xf7efffff]
:[    0.176464] pci_bus 0000:01: resource 2 [mem 0xf0100000-0xf01fffff
64bit pref]
:[    0.176468] pci_bus 0000:02: resource 0 [io  0xd000-0xdfff]
:[    0.176471] pci_bus 0000:02: resource 2 [mem 0xf0000000-0xf00fffff
64bit pref]
:[    0.176475] pci_bus 0000:03: resource 0 [io  0xc000-0xcfff]
:[    0.176478] pci_bus 0000:03: resource 1 [mem 0xf7d00000-0xf7dfffff]
:[    0.176482] pci_bus 0000:03: resource 4 [io  0x0000-0x0cf7]
:[    0.176486] pci_bus 0000:03: resource 5 [io  0x0d00-0xffff]
:[    0.176489] pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000bffff]
:[    0.176493] pci_bus 0000:03: resource 7 [mem 0x000d0000-0x000d3fff]
:[    0.176496] pci_bus 0000:03: resource 8 [mem 0x000d4000-0x000d7fff]
:[    0.176500] pci_bus 0000:03: resource 9 [mem 0x000d8000-0x000dbfff]
:[    0.176503] pci_bus 0000:03: resource 10 [mem 0x000dc000-0x000dffff]
:[    0.176507] pci_bus 0000:03: resource 11 [mem 0x000e0000-0x000e3fff]
:[    0.176510] pci_bus 0000:03: resource 12 [mem 0x000e4000-0x000e7fff]
:[    0.176514] pci_bus 0000:03: resource 13 [mem 0xdfa00000-0xfeafffff]
:[    0.176517] pci_bus 0000:04: resource 0 [io  0xc000-0xcfff]
:[    0.176521] pci_bus 0000:04: resource 1 [mem 0xf7d00000-0xf7dfffff]
:[    0.176524] pci_bus 0000:04: resource 4 [io  0xc000-0xcfff]
:[    0.176528] pci_bus 0000:04: resource 5 [mem 0xf7d00000-0xf7dfffff]
:[    0.176531] pci_bus 0000:04: resource 8 [io  0x0000-0x0cf7]
:[    0.176535] pci_bus 0000:04: resource 9 [io  0x0d00-0xffff]
:[    0.176538] pci_bus 0000:04: resource 10 [mem 0x000a0000-0x000bffff]
:[    0.176542] pci_bus 0000:04: resource 11 [mem 0x000d0000-0x000d3fff]
:[    0.176545] pci_bus 0000:04: resource 12 [mem 0x000d4000-0x000d7fff]
:[    0.176549] pci_bus 0000:04: resource 13 [mem 0x000d8000-0x000dbfff]
:[    0.176552] pci_bus 0000:04: resource 14 [mem 0x000dc000-0x000dffff]
:[    0.176555] pci_bus 0000:04: resource 15 [mem 0x000e0000-0x000e3fff]
:[    0.176559] pci_bus 0000:04: resource 16 [mem 0x000e4000-0x000e7fff]
:[    0.176562] pci_bus 0000:04: resource 17 [mem 0xdfa00000-0xfeafffff]
:[    0.176566] pci_bus 0000:05: resource 0 [io  0xb000-0xbfff]
:[    0.176569] pci_bus 0000:05: resource 1 [mem 0xf7c00000-0xf7cfffff]
:[    0.176614] NET: Registered protocol family 2
:[    0.176925] TCP established hash table entries: 65536 (order: 7, 524288
bytes)
:[    0.177300] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes=
)
:[    0.177567] TCP: Hash tables configured (established 65536 bind 65536)
:[    0.177611] TCP: reno registered
:[    0.177641] UDP hash table entries: 4096 (order: 5, 131072 bytes)
:[    0.177709] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
:[    0.177841] NET: Registered protocol family 1
:[    0.177865] pci 0000:00:02.0: Boot video device
:[    0.209495] PCI: CLS 64 bytes, default 64
:[    0.209584] Unpacking initramfs...
:[    0.604426] Freeing initrd memory: 11424k freed
:[    0.607345] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
:[    0.607354] software IO TLB [mem 0xd54d2000-0xd94d2000] (64MB) mapped
at [ffff8800d54d2000-ffff8800d94d1fff]
:[    0.607865] microcode: CPU0 sig=3D0x206a7, pf=3D0x10, revision=3D0x29
:[    0.607876] microcode: CPU1 sig=3D0x206a7, pf=3D0x10, revision=3D0x29
:[    0.607919] microcode: Microcode Update Driver: v2.00 <
tigran@aivazian.fsnet.co.uk>, Peter Oruba
:[    0.608188] futex hash table entries: 512 (order: 3, 32768 bytes)
:[    0.608203] Initialise system trusted keyring
:[    0.608291] audit: initializing netlink socket (disabled)
:[    0.608311] type=3D2000 audit(1418209464.594:1): initialized
:[    0.655256] HugeTLB registered 2 MB page size, pre-allocated 0 pages
:[    0.657177] zbud: loaded
:[    0.657464] VFS: Disk quotas dquot_6.5.2
:[    0.657528] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
:[    0.657784] msgmni has been set to 15417
:[    0.657867] Key type big_key registered
:[    0.657870] SELinux:  Registering netfilter hooks
:[    0.658770] alg: No test for stdrng (krng)
:[    0.658782] NET: Registered protocol family 38
:[    0.658786] Key type asymmetric registered
:[    0.658789] Asymmetric key parser 'x509' registered
:[    0.658852] Block layer SCSI generic (bsg) driver version 0.4 loaded
(major 252)
:[    0.658898] io scheduler noop registered
:[    0.658901] io scheduler deadline registered (default)
:[    0.658941] io scheduler cfq registered
:[    0.659785] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
:[    0.659810] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
:[    0.659911] intel_idle: MWAIT substates: 0x21120
:[    0.659914] intel_idle: v0.4 model 0x2A
:[    0.659917] intel_idle: lapic_timer_reliable_states 0xffffffff
:[    0.660050] input: Power Button as
/devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
:[    0.660057] ACPI: Power Button [PWRB]
:[    0.660112] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
:[    0.660116] ACPI: Power Button [PWRF]
:[    0.660204] ACPI: Fan [FAN0] (off)
:[    0.660252] ACPI: Fan [FAN1] (off)
:[    0.660306] ACPI: Fan [FAN2] (off)
:[    0.660349] ACPI: Fan [FAN3] (off)
:[    0.660388] ACPI: Fan [FAN4] (off)
:[    0.660472] ACPI: Requesting acpi_cpufreq
:[    0.669091] thermal LNXTHERM:00: registered as thermal_zone0
:[    0.669097] ACPI: Thermal Zone [TZ00] (28 C)
:[    0.669534] thermal LNXTHERM:01: registered as thermal_zone1
:[    0.669538] ACPI: Thermal Zone [TZ01] (30 C)
:[    0.669621] GHES: HEST is not enabled!
:[    0.669716] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
:[    0.690414] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
:[    0.711102] 00:09: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A
:[    0.711789] Non-volatile memory driver v1.3
:[    0.711793] Linux agpgart interface v0.103
:[    0.711922] crash memory driver: version 1.1
:[    0.711947] rdac: device handler registered
:[    0.711996] hp_sw: device handler registered
:[    0.711999] emc: device handler registered
:[    0.712002] alua: device handler registered
:[    0.712051] libphy: Fixed MDIO Bus: probed
:[    0.712112] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
:[    0.712118] ehci-pci: EHCI PCI platform driver
:[    0.712329] ehci-pci 0000:00:1a.0: EHCI Host Controller
:[    0.712391] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus
number 1
:[    0.712410] ehci-pci 0000:00:1a.0: debug port 2
:[    0.716318] ehci-pci 0000:00:1a.0: cache line size of 64 is not
supported
:[    0.716347] ehci-pci 0000:00:1a.0: irq 16, io mem 0xf7f08000
:[    0.722278] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
:[    0.722360] usb usb1: New USB device found, idVendor=3D1d6b,
idProduct=3D0002
:[    0.722364] usb usb1: New USB device strings: Mfr=3D3, Product=3D2,
SerialNumber=3D1
:[    0.722368] usb usb1: Product: EHCI Host Controller
:[    0.722371] usb usb1: Manufacturer: Linux 3.10.0-123.el7.x86_64 ehci_hc=
d
:[    0.722374] usb usb1: SerialNumber: 0000:00:1a.0
:[    0.722537] hub 1-0:1.0: USB hub found
:[    0.722551] hub 1-0:1.0: 2 ports detected
:[    0.722918] ehci-pci 0000:00:1d.0: EHCI Host Controller
:[    0.722988] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus
number 2
:[    0.723006] ehci-pci 0000:00:1d.0: debug port 2
:[    0.726907] ehci-pci 0000:00:1d.0: cache line size of 64 is not
supported
:[    0.726932] ehci-pci 0000:00:1d.0: irq 23, io mem 0xf7f07000
:[    0.732277] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
:[    0.732341] usb usb2: New USB device found, idVendor=3D1d6b,
idProduct=3D0002
:[    0.732346] usb usb2: New USB device strings: Mfr=3D3, Product=3D2,
SerialNumber=3D1
:[    0.732349] usb usb2: Product: EHCI Host Controller
:[    0.732353] usb usb2: Manufacturer: Linux 3.10.0-123.el7.x86_64 ehci_hc=
d
:[    0.732356] usb usb2: SerialNumber: 0000:00:1d.0
:[    0.732506] hub 2-0:1.0: USB hub found
:[    0.732517] hub 2-0:1.0: 2 ports detected
:[    0.732691] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
:[    0.732694] ohci-pci: OHCI PCI platform driver
:[    0.732711] uhci_hcd: USB Universal Host Controller Interface driver
:[    0.732789] usbcore: registered new interface driver usbserial
:[    0.732803] usbcore: registered new interface driver usbserial_generic
:[    0.732813] usbserial: USB Serial support registered for generic
:[    0.732872] i8042: PNP: No PS/2 controller found. Probing ports
directly.
:[    0.733300] serio: i8042 KBD port at 0x60,0x64 irq 1
:[    0.733309] serio: i8042 AUX port at 0x60,0x64 irq 12
:[    0.733440] mousedev: PS/2 mouse device common for all mice
:[    0.733655] rtc_cmos 00:05: RTC can wake from S4
:[    0.733830] rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
:[    0.733866] rtc_cmos 00:05: alarms up to one month, y3k, 242 bytes
nvram, hpet irqs
:[    0.733883] Intel P-state driver initializing.
:[    0.733899] Intel pstate controlling: cpu 0
:[    0.733925] Intel pstate controlling: cpu 1
:[    0.734037] cpuidle: using governor menu
:[    0.734480] hidraw: raw HID events driver (C) Jiri Kosina
:[    0.734610] usbcore: registered new interface driver usbhid
:[    0.734612] usbhid: USB HID core driver
:[    0.734670] drop_monitor: Initializing network drop monitor service
:[    0.734797] TCP: cubic registered
:[    0.734801] Initializing XFRM netlink socket
:[    0.734942] NET: Registered protocol family 10
:[    0.735187] NET: Registered protocol family 17
:[    0.735533] Loading compiled-in X.509 certificates
:[    0.735583] Loaded X.509 cert 'CentOS Linux kpatch signing key:
ea0413152cde1d98ebdca3fe6f0230904c9ef717'
:[    0.735621] Loaded X.509 cert 'CentOS Linux Driver update signing key:
7f421ee0ab69461574bb358861dbe77762a4201b'
:[    0.736851] Loaded X.509 cert 'CentOS Linux kernel signing key:
bc83d0fe70c62fab1c58b4ebaa95e3936128fcf4'
:[    0.736869] registered taskstats version 1
:[    0.740369] Key type trusted registered
:[    0.743683] Key type encrypted registered
:[    0.746760] IMA: No TPM chip found, activating TPM-bypass!
:[    0.747332] rtc_cmos 00:05: setting system clock to 2014-12-10 11:04:25
UTC (1418209465)
:[    0.748784] Freeing unused kernel memory: 1584k freed
:[    0.755639] systemd[1]: systemd 208 running in system mode. (+PAM
+LIBWRAP +AUDIT +SELINUX +IMA +SYSVINIT +LIBCRYPTSETUP +GCRYPT +ACL +XZ)
:[    0.755935] systemd[1]: Running in initial RAM disk.
:[    0.756038] systemd[1]: Set hostname to <router.centos>.
:[    0.806660] systemd[1]: Expecting device
dev-disk-by\x2duuid-328b16e8\x2d5f97\x2d4c97\x2d80c2\x2d1269e2157281.device=
...
:[    0.806689] systemd[1]: Starting -.slice.
:[    0.806966] systemd[1]: Created slice -.slice.
:[    0.807056] systemd[1]: Starting System Slice.
:[    0.807185] systemd[1]: Created slice System Slice.
:[    0.807255] systemd[1]: Starting Slices.
:[    0.807289] systemd[1]: Reached target Slices.
:[    0.807350] systemd[1]: Starting Timers.
:[    0.807370] systemd[1]: Reached target Timers.
:[    0.807434] systemd[1]: Starting Journal Socket.
:[    0.807541] systemd[1]: Listening on Journal Socket.
:[    0.807883] systemd[1]: Starting dracut cmdline hook...
:[    0.808728] systemd[1]: Started Load Kernel Modules.
:[    0.808765] systemd[1]: Starting Setup Virtual Console...
:[    0.809325] systemd[1]: Starting Journal Service...
:[    0.809926] systemd[1]: Started Journal Service.
:[    0.831115] systemd-journald[90]: Vacuuming done, freed 0 bytes
:[    1.024326] usb 1-1: new high-speed USB device number 2 using ehci-pci
:[    1.047379] device-mapper: uevent: version 1.0.3
:[    1.047490] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30)
initialised: dm-devel@redhat.com
:[    1.097510] systemd-udevd[214]: starting version 208
:[    1.142672] usb 1-1: New USB device found, idVendor=3D8087, idProduct=
=3D0024
:[    1.142681] usb 1-1: New USB device strings: Mfr=3D0, Product=3D0,
SerialNumber=3D0
:[    1.142930] hub 1-1:1.0: USB hub found
:[    1.143002] hub 1-1:1.0: 4 ports detected
:[    1.206054] [drm] Initialized drm 1.1.0 20060810
:[    1.226469] ACPI: bus type ATA registered
:[    1.244192] libata version 3.00 loaded.
:[    1.247288] usb 2-1: new high-speed USB device number 2 using ehci-pci
:[    1.270906] scsi0 : pata_jmicron
:[    1.271240] scsi1 : pata_jmicron
:[    1.271331] ata1: PATA max UDMA/100 cmd 0xb040 ctl 0xb030 bmdma 0xb000
irq 19
:[    1.271336] ata2: PATA max UDMA/100 cmd 0xb020 ctl 0xb010 bmdma 0xb008
irq 19
:[    1.273633] [drm] Memory usable by graphics device =3D 2048M
:[    1.345663] i915 0000:00:02.0: irq 40 for MSI/MSI-X
:[    1.345681] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
:[    1.345684] [drm] Driver supports precise vblank timestamp query.
:[    1.345773] vgaarb: device changed decodes:
PCI:0000:00:02.0,olddecodes=3Dio+mem,decodes=3Dio+mem:owns=3Dio+mem
:[    1.360450] [drm] Wrong MCH_SSKPD value: 0x16040307
:[    1.360456] [drm] This can cause pipe underruns and display issues.
:[    1.360459] [drm] Please upgrade your BIOS to fix this.
:[    1.361628] usb 2-1: New USB device found, idVendor=3D8087, idProduct=
=3D0024
:[    1.361635] usb 2-1: New USB device strings: Mfr=3D0, Product=3D0,
SerialNumber=3D0
:[    1.361923] hub 2-1:1.0: USB hub found
:[    1.361996] hub 2-1:1.0: 4 ports detected
:[    1.371176] i915 0000:00:02.0: No connectors reported connected with
modes
:[    1.371191] [drm] Cannot find any crtc or sizes - going 1024x768
:[    1.373057] fbcon: inteldrmfb (fb0) is primary device
:[    1.399213] Console: switching to colour frame buffer device 128x48
:[    1.404226] i915 0000:00:02.0: fb0: inteldrmfb frame buffer device
:[    1.404231] i915 0000:00:02.0: registered panic notifier
:[    1.409678] acpi device:59: registered as cooling_device7
:[    1.409978] ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post:
no)
:[    1.410057] input: Video Bus as
/devices/LNXSYSTM:00/device:00/PNP0A08:00/LNXVIDEO:00/input/input2
:[    1.410178] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on
minor 0
:[    1.410466] ahci 0000:00:1f.2: version 3.0
:[    1.410718] ahci 0000:00:1f.2: irq 41 for MSI/MSI-X
:[    1.410791] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 4 ports 6 Gbps
0x1 impl SATA mode
:[    1.410798] ahci 0000:00:1f.2: flags: 64bit ncq led clo pio slum part
ems apst
:[    1.415503] scsi2 : ahci
:[    1.415706] scsi3 : ahci
:[    1.416022] scsi4 : ahci
:[    1.416153] scsi5 : ahci
:[    1.416320] ata3: SATA max UDMA/133 abar m2048@0xf7f06000 port
0xf7f06100 irq 41
:[    1.416326] ata4: DUMMY
:[    1.416329] ata5: DUMMY
:[    1.416331] ata6: DUMMY
:[    1.608361] tsc: Refined TSC clocksource calibration: 1097.506 MHz
:[    1.608373] Switching to clocksource tsc
:[    1.721408] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
:[    1.724848] ACPI Error: [DSSP] Namespace lookup failure, AE_NOT_FOUND
(20130517/psargs-359)
:[    1.724867] ACPI Error: Method parse/execution failed
[\_SB_.PCI0.SAT0.SPT0._GTF] (Node ffff8802138b5c30), AE_NOT_FOUND
(20130517/psparse-536)
:[    1.725058] ata3.00: ATA-7: SAMSUNG SP2004C, VM100-33, max UDMA7
:[    1.725067] ata3.00: 390721968 sectors, multi 16: LBA48 NCQ (depth
31/32), AA
:[    1.728549] ACPI Error: [DSSP] Namespace lookup failure, AE_NOT_FOUND
(20130517/psargs-359)
:[    1.728566] ACPI Error: Method parse/execution failed
[\_SB_.PCI0.SAT0.SPT0._GTF] (Node ffff8802138b5c30), AE_NOT_FOUND
(20130517/psparse-536)
:[    1.728756] ata3.00: configured for UDMA/133
:[    1.729110] scsi 2:0:0:0: Direct-Access     ATA      SAMSUNG SP2004C
VM10 PQ: 0 ANSI: 5
:[    1.748009] sd 2:0:0:0: [sda] 390721968 512-byte logical blocks: (200
GB/186 GiB)
:[    1.748219] sd 2:0:0:0: [sda] Write Protect is off
:[    1.748227] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
:[    1.748302] sd 2:0:0:0: [sda] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
:[    1.753738]  sda: sda1 sda2
:[    1.754356] sd 2:0:0:0: [sda] Attached SCSI disk
:[    2.081247] bio: create slab <bio-1> at 1
:[    2.426495] SGI XFS with ACLs, security attributes, large block/inode
numbers, no debug enabled
:[    2.428871] XFS (dm-1): Mounting Filesystem
:[    2.575266] XFS (dm-1): Ending clean mount
:[    2.716589] [drm] Enabling RC6 states: RC6 on, RC6p off, RC6pp off
:[    2.847140] systemd-journald[90]: Received SIGTERM
:[    3.407186] type=3D1404 audit(1418209468.158:2): enforcing=3D1
old_enforcing=3D0 auid=3D4294967295 ses=3D4294967295
:[    3.713525] SELinux: 2048 avtab hash slots, 106409 rules.
:[    3.750012] SELinux: 2048 avtab hash slots, 106409 rules.
:[    3.806480] SELinux:  8 users, 86 roles, 4801 types, 280 bools, 1 sens,
1024 cats
:[    3.806487] SELinux:  83 classes, 106409 rules
:[    3.817820] SELinux:  Completing initialization.
:[    3.817826] SELinux:  Setting up existing superblocks.
:[    3.817839] SELinux: initialized (dev sysfs, type sysfs), uses
genfs_contexts
:[    3.817848] SELinux: initialized (dev rootfs, type rootfs), uses
genfs_contexts
:[    3.817861] SELinux: initialized (dev bdev, type bdev), uses
genfs_contexts
:[    3.817869] SELinux: initialized (dev proc, type proc), uses
genfs_contexts
:[    3.817937] SELinux: initialized (dev tmpfs, type tmpfs), uses
transition SIDs
:[    3.818001] SELinux: initialized (dev devtmpfs, type devtmpfs), uses
transition SIDs
:[    3.819365] SELinux: initialized (dev sockfs, type sockfs), uses task
SIDs
:[    3.819373] SELinux: initialized (dev debugfs, type debugfs), uses
genfs_contexts
:[    3.820926] SELinux: initialized (dev pipefs, type pipefs), uses task
SIDs
:[    3.820937] SELinux: initialized (dev anon_inodefs, type anon_inodefs),
uses genfs_contexts
:[    3.820942] SELinux: initialized (dev aio, type aio), not configured
for labeling
:[    3.820947] SELinux: initialized (dev devpts, type devpts), uses
transition SIDs
:[    3.820979] SELinux: initialized (dev hugetlbfs, type hugetlbfs), uses
transition SIDs
:[    3.820991] SELinux: initialized (dev mqueue, type mqueue), uses
transition SIDs
:[    3.821004] SELinux: initialized (dev selinuxfs, type selinuxfs), uses
genfs_contexts
:[    3.821022] SELinux: initialized (dev securityfs, type securityfs),
uses genfs_contexts
:[    3.821028] SELinux: initialized (dev sysfs, type sysfs), uses
genfs_contexts
:[    3.821552] SELinux: initialized (dev tmpfs, type tmpfs), uses
transition SIDs
:[    3.821570] SELinux: initialized (dev tmpfs, type tmpfs), uses
transition SIDs
:[    3.821762] SELinux: initialized (dev tmpfs, type tmpfs), uses
transition SIDs
:[    3.821828] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.821841] SELinux: initialized (dev pstore, type pstore), uses
genfs_contexts
:[    3.821845] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.821853] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.821861] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.821873] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.821879] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.821884] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.821890] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.821903] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.821908] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.821917] SELinux: initialized (dev configfs, type configfs), uses
genfs_contexts
:[    3.821926] SELinux: initialized (dev dm-1, type xfs), uses xattr
:[    3.834171] type=3D1403 audit(1418209468.585:3): policy loaded
auid=3D4294967295 ses=3D4294967295
:[    3.843703] systemd[1]: Successfully loaded SELinux policy in 460.952ms=
.
:[    3.977338] systemd[1]: RTC configured in localtime, applying delta of
240 minutes to system time.
:[    4.062264] systemd[1]: Relabelled /dev and /run in 40.475ms.
:[    5.634361] SELinux: initialized (dev autofs, type autofs), uses
genfs_contexts
:[    6.091269] systemd-journald[447]: Vacuuming done, freed 0 bytes
:[    6.703510] SELinux: initialized (dev hugetlbfs, type hugetlbfs), uses
transition SIDs
:[    7.523322] systemd-udevd[478]: starting version 208
:[    7.775839] parport_pc 00:0a: reported by Plug and Play ACPI
:[    7.775899] parport0: PC-style at 0x378, irq 5 [PCSPP,TRISTATE]
:[    7.821634] shpchp: Standard Hot Plug PCI Controller Driver version: 0.=
4
:[    7.831041] ACPI Warning: SystemIO range
0x0000000000000428-0x000000000000042f conflicts with OpRegion
0x0000000000000400-0x000000000000047f (\PMIO) (20130517/utaddress-254)
:[    7.831055] ACPI: If an ACPI driver is available for this device, you
should use it instead of the native driver
:[    7.831061] ACPI Warning: SystemIO range
0x0000000000000530-0x000000000000053f conflicts with OpRegion
0x0000000000000500-0x0000000000000563 (\GPIO) (20130517/utaddress-254)
:[    7.831068] ACPI: If an ACPI driver is available for this device, you
should use it instead of the native driver
:[    7.831071] ACPI Warning: SystemIO range
0x0000000000000500-0x000000000000052f conflicts with OpRegion
0x0000000000000500-0x000000000000051f (\LED_) (20130517/utaddress-254)
:[    7.831102] ACPI Warning: SystemIO range
0x0000000000000500-0x000000000000052f conflicts with OpRegion
0x0000000000000500-0x0000000000000563 (\GPIO) (20130517/utaddress-254)
:[    7.831109] ACPI: If an ACPI driver is available for this device, you
should use it instead of the native driver
:[    7.831111] lpc_ich: Resource conflict(s) found affecting gpio_ich
:[    7.869355] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
:[    7.869691] r8169 0000:01:00.0: irq 42 for MSI/MSI-X
:[    7.870007] r8169 0000:01:00.0 eth0: RTL8168evl/8111evl at
0xffffc90004e26000, 90:2b:34:db:46:be, XID 0c900800 IRQ 42
:[    7.870013] r8169 0000:01:00.0 eth0: jumbo features [frames: 9200
bytes, tx checksumming: ko]
:[    7.874289] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
:[    7.874616] r8169 0000:02:00.0: irq 43 for MSI/MSI-X
:[    7.874908] r8169 0000:02:00.0 eth1: RTL8168evl/8111evl at
0xffffc90004e28000, 90:2b:34:db:46:ff, XID 0c900800 IRQ 43
:[    7.874913] r8169 0000:02:00.0 eth1: jumbo features [frames: 9200
bytes, tx checksumming: ko]
:[    7.875974] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
:[    7.876406] r8169 0000:04:00.0 (unregistered net_device): not PCI
Express
:[    7.876771] r8169 0000:04:00.0 eth2: RTL8169sb/8110sb at
0xffffc90004e2a000, f0:7d:68:c1:fd:3f, XID 10000000 IRQ 18
:[    7.876776] r8169 0000:04:00.0 eth2: jumbo features [frames: 7152
bytes, tx checksumming: ok]
:[    7.887265] mei_me 0000:00:16.0: irq 44 for MSI/MSI-X
:[    8.123488] snd_hda_intel 0000:00:1b.0: irq 45 for MSI/MSI-X
:[    8.229173] input: HDA Intel PCH HDMI/DP,pcm=3D3 as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input3
:[    8.230015] input: HDA Intel PCH Front Headphone as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input4
:[    8.230275] input: HDA Intel PCH Line Out as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input5
:[    8.231702] input: HDA Intel PCH Line as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input6
:[    8.232200] input: HDA Intel PCH Front Mic as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input7
:[    8.233240] input: HDA Intel PCH Rear Mic as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input8
:[    8.278698] ACPI Warning: SystemIO range
0x000000000000f040-0x000000000000f05f conflicts with OpRegion
0x000000000000f040-0x000000000000f04f (\_SB_.PCI0.SBUS.SMBI)
(20130517/utaddress-254)
:[    8.278713] ACPI: If an ACPI driver is available for this device, you
should use it instead of the native driver
:[    8.315455] input: PC Speaker as /devices/platform/pcspkr/input/input9
:[    8.366818] alg: No test for crc32 (crc32-pclmul)
:[    8.429970] ppdev: user-space parallel port driver
:[    8.431927] iTCO_vendor_support: vendor-support=3D0
:[    8.433957] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
:[    8.434000] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled
by hardware/BIOS
:[    8.712032] kvm: disabled by bios
:[    8.714295] systemd-udevd[484]: renamed network interface eth2 to enp4s=
0
:[    8.725329] kvm: disabled by bios
:[    8.725395] systemd-udevd[495]: renamed network interface eth1 to enp2s=
0
:[    8.821234] systemd-udevd[486]: renamed network interface eth0 to enp1s=
0
:[    9.930365] Adding 8142844k swap on /dev/mapper/centos_router-swap.
Priority:-1 extents:1 across:8142844k FS
:[   11.116207] XFS (sda1): Mounting Filesystem
:[   11.184980] XFS (dm-2): Mounting Filesystem
:[   12.095239] XFS (dm-2): Ending clean mount
:[   12.095274] SELinux: initialized (dev dm-2, type xfs), uses xattr
:[   16.109342] XFS (sda1): Ending clean mount
:[   16.109383] SELinux: initialized (dev sda1, type xfs), uses xattr
:[   16.133176] systemd-journald[447]: Received request to flush runtime
journal from PID 1
:[   16.175544] type=3D1305 audit(1418195080.927:4): audit_pid=3D634 old=3D=
0
auid=3D4294967295 ses=3D4294967295 subj=3Dsystem_u:system_r:auditd_t:s0 res=
=3D1
:[   16.872748] sd 2:0:0:0: Attached scsi generic sg0 type 0
:[   17.157388] ip_tables: (C) 2000-2006 Netfilter Core Team
:[   17.327288] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
:[   17.418998] ip6_tables: (C) 2000-2006 Netfilter Core Team
:[   17.561155] Ebtables v2.0 registered
:[   17.587651] Bridge firewalling registered
:[   18.266198] r8169 0000:01:00.0 enp1s0: link down
:[   18.266220] r8169 0000:01:00.0 enp1s0: link down
:[   18.266460] IPv6: ADDRCONF(NETDEV_UP): enp1s0: link is not ready
:[   18.396477] r8169 0000:02:00.0 enp2s0: link down
:[   18.396733] IPv6: ADDRCONF(NETDEV_UP): enp2s0: link is not ready
:[   18.441873] r8169 0000:04:00.0 enp4s0: link down
:[   18.441923] r8169 0000:04:00.0 enp4s0: link down
:[   18.442011] IPv6: ADDRCONF(NETDEV_UP): enp4s0: link is not ready
:[   19.937537] r8169 0000:01:00.0 enp1s0: link up
:[   19.937554] IPv6: ADDRCONF(NETDEV_CHANGE): enp1s0: link becomes ready
:[   20.099898] PPP generic driver version 2.4.2
:[   21.582535] PPP BSD Compression module registered
:[   46.441170] r8169 0000:04:00.0 enp4s0: link up
:[   46.441190] IPv6: ADDRCONF(NETDEV_CHANGE): enp4s0: link becomes ready
:[ 3693.587715] perf samples too long (2515 > 2500), lowering
kernel.perf_event_max_sample_rate to 50000
:[12382.969343] perf samples too long (5002 > 5000), lowering
kernel.perf_event_max_sample_rate to 25000
:[18808.075550] Ebtables v2.0 unregistered
:[18808.405133] ip_tables: (C) 2000-2006 Netfilter Core Team
:[18808.435406] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
:[18808.758001] ip6_tables: (C) 2000-2006 Netfilter Core Team
:[28503.378469] ip_tables: (C) 2000-2006 Netfilter Core Team
:[28503.409093] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
:[28503.731692] ip6_tables: (C) 2000-2006 Netfilter Core Team
:[29409.061343] ip_tables: (C) 2000-2006 Netfilter Core Team
:[29409.090714] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
:[29409.410958] ip6_tables: (C) 2000-2006 Netfilter Core Team
:[105103.876746] ip_tables: (C) 2000-2006 Netfilter Core Team
:[105103.908118] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
:[105104.231344] ip6_tables: (C) 2000-2006 Netfilter Core Team
:[129620.535874] systemd-journald[447]: Vacuuming done, freed 0 bytes
:[172946.916946] ------------[ cut here ]------------
:[172946.916978] WARNING: at net/sched/sch_generic.c:259
dev_watchdog+0x270/0x280()
:[172946.916985] NETDEV WATCHDOG: enp4s0 (r8169): transmit queue 0 timed ou=
t
:[172946.916990] Modules linked in: nf_conntrack_netbios_ns
nf_conntrack_broadcast xt_nat xt_mark ipt_MASQUERADE ip6t_rpfilter
ip6table_nat nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw
ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables
iptable_nat nf_nat_ipv4 nf_nat iptable_mangle iptable_security iptable_raw
ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack
iptable_filter ip_tables tcp_diag inet_diag bsd_comp ppp_synctty ppp_async
crc_ccitt ppp_generic slhc bridge stp llc sg coretemp kvm serio_raw
crct10dif_pclmul iTCO_wdt iTCO_vendor_support ppdev crc32_pclmul pcspkr
i2c_i801 crc32c_intel snd_hda_codec_hdmi snd_hda_codec_realtek
snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hwdep snd_seq
snd_seq_device ghash_clmulni_intel snd_pcm snd_page_alloc
:[172946.917077]  snd_timer snd soundcore mei_me mei cryptd r8169 mii
lpc_ich mfd_core shpchp parport_pc parport mperf xfs libcrc32c sd_mod
crc_t10dif crct10dif_common ata_generic pata_acpi ahci pata_jmicron i915
libahci libata i2c_algo_bit drm_kms_helper drm i2c_core video dm_mirror
dm_region_hash dm_log dm_mod [last unloaded: ip_tables]
:[172946.917122] CPU: 1 PID: 0 Comm: swapper/1 Not tainted
3.10.0-123.el7.x86_64 #1
:[172946.917127] Hardware name: Gigabyte Technology Co., Ltd. To be filled
by O.E.M./C847N, BIOS F2 11/09/2012
:[172946.917132]  ffff88021f303d90 eeb6307312c80fd5 ffff88021f303d48
ffffffff815e19ba
:[172946.917140]  ffff88021f303d80 ffffffff8105dee1 0000000000000000
ffff880212550000
:[172946.917147]  ffff88021139f280 0000000000000001 0000000000000001
ffff88021f303de8
:[172946.917154] Call Trace:
:[172946.917159]  <IRQ>  [<ffffffff815e19ba>] dump_stack+0x19/0x1b
:[172946.917178]  [<ffffffff8105dee1>] warn_slowpath_common+0x61/0x80
:[172946.917187]  [<ffffffff8105df5c>] warn_slowpath_fmt+0x5c/0x80
:[172946.917196]  [<ffffffff81088671>] ? run_posix_cpu_timers+0x51/0x840
:[172946.917207]  [<ffffffff814f0ab0>] dev_watchdog+0x270/0x280
:[172946.917213]  [<ffffffff814f0840>] ? dev_graft_qdisc+0x80/0x80
:[172946.917222]  [<ffffffff8106d236>] call_timer_fn+0x36/0x110
:[172946.917228]  [<ffffffff814f0840>] ? dev_graft_qdisc+0x80/0x80
:[172946.917236]  [<ffffffff8106f2ff>] run_timer_softirq+0x21f/0x320
:[172946.917244]  [<ffffffff81067047>] __do_softirq+0xf7/0x290
:[172946.917253]  [<ffffffff815f3a5c>] call_softirq+0x1c/0x30
:[172946.917264]  [<ffffffff81014d25>] do_softirq+0x55/0x90
:[172946.917271]  [<ffffffff810673e5>] irq_exit+0x115/0x120
:[172946.917279]  [<ffffffff815f4435>] smp_apic_timer_interrupt+0x45/0x60
:[172946.917285]  [<ffffffff815f2d9d>] apic_timer_interrupt+0x6d/0x80
:[172946.917289]  <EOI>  [<ffffffff814834df>] ?
cpuidle_enter_state+0x4f/0xc0
:[172946.917306]  [<ffffffff81483615>] cpuidle_idle_call+0xc5/0x200
:[172946.917314]  [<ffffffff8101bc7e>] arch_cpu_idle+0xe/0x30
:[172946.917324]  [<ffffffff810b4725>] cpu_startup_entry+0xf5/0x290
:[172946.917333]  [<ffffffff815cfee1>] start_secondary+0x265/0x27b
:[172946.917339] ---[ end trace 87a83aa998315558 ]---
:[172946.927322] r8169 0000:04:00.0 enp4s0: link up
:[172954.291571] SELinux: initialized (dev binfmt_misc, type binfmt_misc),
uses genfs_contexts
:[172958.827459] xor: measuring software checksum speed
:[172958.836820]    prefetch64-sse:  5904.000 MB/sec
:[172958.846817]    generic_sse:  5500.000 MB/sec
:[172958.846821] xor: using function: prefetch64-sse (5904.000 MB/sec)
:[172958.880819] raid6: sse2x1    2792 MB/s
:[172958.897820] raid6: sse2x2    3628 MB/s
:[172958.914820] raid6: sse2x4    4207 MB/s
:[172958.914824] raid6: using algorithm sse2x4 (4207 MB/s)
:[172958.914827] raid6: using ssse3x2 recovery algorithm
:[172959.007487] bio: create slab <bio-2> at 2
:[172959.009677] Btrfs loaded
:[172959.034533] fuse init (API version 7.22)
:[172959.056836] SELinux: initialized (dev fusectl, type fusectl), uses
genfs_contexts
:[172961.172566] nr_pdflush_threads exported in /proc is scheduled for
removal
:[172961.173004] sysctl: The scan_unevictable_pages sysctl/node-interface
has been disabled for lack of a legitimate use case.  If you have one,
please send an email to linux-mm@kvack.org.

os_info:
:NAME=3D"CentOS Linux"
:VERSION=3D"7 (Core)"
:ID=3D"centos"
:ID_LIKE=3D"rhel fedora"
:VERSION_ID=3D"7"
:PRETTY_NAME=3D"CentOS Linux 7 (Core)"
:ANSI_COLOR=3D"0;31"
:CPE_NAME=3D"cpe:/o:centos:centos:7"
:HOME_URL=3D"https://www.centos.org/"
:BUG_REPORT_URL=3D"https://bugs.centos.org/"
:

proc_modules:
:nf_conntrack_netbios_ns 12665 0 - Live 0xffffffffa0585000
:nf_conntrack_broadcast 12589 1 nf_conntrack_netbios_ns, Live
0xffffffffa0580000
:xt_nat 12681 21 - Live 0xffffffffa057b000
:xt_mark 12563 63 - Live 0xffffffffa0576000
:ipt_MASQUERADE 12880 1 - Live 0xffffffffa0571000
:ip6t_rpfilter 12546 1 - Live 0xffffffffa056c000
:ip6table_nat 13015 1 - Live 0xffffffffa0567000
:nf_nat_ipv6 13279 1 ip6table_nat, Live 0xffffffffa0538000
:ip6table_mangle 12700 1 - Live 0xffffffffa0533000
:ip6table_security 12710 1 - Live 0xffffffffa052e000
:ip6table_raw 12683 1 - Live 0xffffffffa0529000
:ip6t_REJECT 12939 2 - Live 0xffffffffa0524000
:nf_conntrack_ipv6 18738 11 - Live 0xffffffffa051a000
:nf_defrag_ipv6 34651 1 nf_conntrack_ipv6, Live 0xffffffffa050c000
:ip6table_filter 12815 1 - Live 0xffffffffa0507000
:ip6_tables 27025 5
ip6table_nat,ip6table_mangle,ip6table_security,ip6table_raw,ip6table_filter=
,
Live 0xffffffffa04fb000
:iptable_nat 13011 1 - Live 0xffffffffa04f1000
:nf_nat_ipv4 13263 1 iptable_nat, Live 0xffffffffa04f6000
:nf_nat 21798 6
xt_nat,ipt_MASQUERADE,ip6table_nat,nf_nat_ipv6,iptable_nat,nf_nat_ipv4,
Live 0xffffffffa04ea000
:iptable_mangle 12695 1 - Live 0xffffffffa04e5000
:iptable_security 12705 1 - Live 0xffffffffa04e0000
:iptable_raw 12678 1 - Live 0xffffffffa04db000
:ipt_REJECT 12541 2 - Live 0xffffffffa04d6000
:nf_conntrack_ipv4 14862 31 - Live 0xffffffffa04cd000
:nf_defrag_ipv4 12729 1 nf_conntrack_ipv4, Live 0xffffffffa04a3000
:xt_conntrack 12760 40 - Live 0xffffffffa0493000
:nf_conntrack 101024 11
nf_conntrack_netbios_ns,nf_conntrack_broadcast,ipt_MASQUERADE,ip6table_nat,=
nf_nat_ipv6,nf_conntrack_ipv6,iptable_nat,nf_nat_ipv4,nf_nat,nf_conntrack_i=
pv4,xt_conntrack,
Live 0xffffffffa04b3000
:iptable_filter 12810 1 - Live 0xffffffffa0421000
:ip_tables 27239 5
iptable_nat,iptable_mangle,iptable_security,iptable_raw,iptable_filter,
Live 0xffffffffa04ab000
:tcp_diag 12591 0 - Live 0xffffffffa05b3000
:inet_diag 18543 1 tcp_diag, Live 0xffffffffa058a000
:bsd_comp 12921 0 - Live 0xffffffffa05bd000
:ppp_synctty 13237 0 - Live 0xffffffffa05a3000
:ppp_async 17413 1 - Live 0xffffffffa05ad000
:crc_ccitt 12707 1 ppp_async, Live 0xffffffffa05a8000
:ppp_generic 33037 7 bsd_comp,ppp_synctty,ppp_async, Live 0xffffffffa059900=
0
:slhc 13450 1 ppp_generic, Live 0xffffffffa0594000
:bridge 110196 0 - Live 0xffffffffa054b000
:stp 12976 1 bridge, Live 0xffffffffa0546000
:llc 14552 2 bridge,stp, Live 0xffffffffa053d000
:sg 36533 0 - Live 0xffffffffa0499000
:coretemp 13435 0 - Live 0xffffffffa041c000
:kvm 441119 0 - Live 0xffffffffa0426000
:serio_raw 13462 0 - Live 0xffffffffa0417000
:crct10dif_pclmul 14289 0 - Live 0xffffffffa0412000
:iTCO_wdt 13480 0 - Live 0xffffffffa040d000
:iTCO_vendor_support 13718 1 iTCO_wdt, Live 0xffffffffa0402000
:ppdev 17671 0 - Live 0xffffffffa0407000
:crc32_pclmul 13113 0 - Live 0xffffffffa03f6000
:pcspkr 12718 0 - Live 0xffffffffa03f1000
:i2c_i801 18135 0 - Live 0xffffffffa03fc000
:crc32c_intel 22079 0 - Live 0xffffffffa0385000
:snd_hda_codec_hdmi 46433 1 - Live 0xffffffffa03b3000
:snd_hda_codec_realtek 57226 1 - Live 0xffffffffa03e2000
:snd_hda_codec_generic 68082 1 snd_hda_codec_realtek, Live
0xffffffffa03d0000
:snd_hda_intel 48259 0 - Live 0xffffffffa03c3000
:snd_hda_codec 137343 4
snd_hda_codec_hdmi,snd_hda_codec_realtek,snd_hda_codec_generic,snd_hda_inte=
l,
Live 0xffffffffa0390000
:snd_hwdep 13602 1 snd_hda_codec, Live 0xffffffffa0369000
:snd_seq 61519 0 - Live 0xffffffffa0374000
:snd_seq_device 14497 1 snd_seq, Live 0xffffffffa0364000
:ghash_clmulni_intel 13259 0 - Live 0xffffffffa036f000
:snd_pcm 97511 3 snd_hda_codec_hdmi,snd_hda_intel,snd_hda_codec, Live
0xffffffffa034b000
:snd_page_alloc 18710 2 snd_hda_intel,snd_pcm, Live 0xffffffffa0338000
:snd_timer 29482 2 snd_seq,snd_pcm, Live 0xffffffffa0342000
:snd 74645 10
snd_hda_codec_hdmi,snd_hda_codec_realtek,snd_hda_codec_generic,snd_hda_inte=
l,snd_hda_codec,snd_hwdep,snd_seq,snd_seq_device,snd_pcm,snd_timer,
Live 0xffffffffa0324000
:soundcore 15047 1 snd, Live 0xffffffffa02e8000
:mei_me 18568 0 - Live 0xffffffffa0305000
:mei 77872 1 mei_me, Live 0xffffffffa030b000
:cryptd 20359 1 ghash_clmulni_intel, Live 0xffffffffa013a000
:r8169 71677 0 - Live 0xffffffffa02f2000
:mii 13934 1 r8169, Live 0xffffffffa02ed000
:lpc_ich 16977 0 - Live 0xffffffffa0134000
:mfd_core 13435 1 lpc_ich, Live 0xffffffffa011b000
:shpchp 37032 0 - Live 0xffffffffa0140000
:parport_pc 28165 0 - Live 0xffffffffa0120000
:parport 42348 2 ppdev,parport_pc, Live 0xffffffffa0128000
:mperf 12667 0 - Live 0xffffffffa0111000
:xfs 914152 3 - Live 0xffffffffa0207000
:libcrc32c 12644 1 xfs, Live 0xffffffffa0116000
:sd_mod 45373 3 - Live 0xffffffffa0104000
:crc_t10dif 12714 1 sd_mod, Live 0xffffffffa00b5000
:crct10dif_common 12595 2 crct10dif_pclmul,crc_t10dif, Live
0xffffffffa00b0000
:ata_generic 12910 0 - Live 0xffffffffa00a8000
:pata_acpi 13038 0 - Live 0xffffffffa003e000
:ahci 25819 2 - Live 0xffffffffa00a0000
:pata_jmicron 12758 0 - Live 0xffffffffa004f000
:i915 710975 1 - Live 0xffffffffa0158000
:libahci 32009 1 ahci, Live 0xffffffffa014f000
:libata 219478 5 ata_generic,pata_acpi,ahci,pata_jmicron,libahci, Live
0xffffffffa00ca000
:i2c_algo_bit 13413 1 i915, Live 0xffffffffa0022000
:drm_kms_helper 52758 1 i915, Live 0xffffffffa00bc000
:drm 297829 2 i915,drm_kms_helper, Live 0xffffffffa0056000
:i2c_core 40325 5 i2c_i801,i915,i2c_algo_bit,drm_kms_helper,drm, Live
0xffffffffa0044000
:video 19267 1 i915, Live 0xffffffffa0038000
:dm_mirror 22135 0 - Live 0xffffffffa002d000
:dm_region_hash 20862 1 dm_mirror, Live 0xffffffffa001b000
:dm_log 18411 2 dm_mirror,dm_region_hash, Live 0xffffffffa0027000
:dm_mod 102999 11 dm_mirror,dm_log, Live 0xffffffffa0000000

suspend_stats:
:success: 0
:fail: 0
:failed_freeze: 0
:failed_prepare: 0
:failed_suspend: 0
:failed_suspend_late: 0
:failed_suspend_noirq: 0
:failed_resume: 0
:failed_resume_early: 0
:failed_resume_noirq: 0
:failures:
:  last_failed_dev:
:
:  last_failed_errno:   0
:                       0
:  last_failed_step:
:

----------
From:  <user@localhost.centos>
Date: 2015-02-02 2:12 GMT+03:00
To: root@localhost.centos


abrt_version:   2.1.11
cmdline:        BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el7.x86_64
root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro rd.lvm.lv=3Dcentos_ro=
uter/swap
vconsole.font=3Dlatarcyrheb-sun16 rd.lvm.lv=3Dcentos_router/root
crashkernel=3Dauto vconsole.keymap=3Dus rhgb quiet LANG=3Den_US.UTF-8
hostname:       router.centos
kernel:         3.10.0-123.el7.x86_64
last_occurrence: 1422832344
pkg_arch:       x86_64
pkg_epoch:      0
pkg_name:       kernel
pkg_release:    123.el7
pkg_version:    3.10.0
runlevel:       N 3
time:           Fri 23 Jan 2015 04:15:18 PM MSK

backtrace:
:BUG: soft lockup - CPU#0 stuck for 21s! [rcuos/0:12]
:Modules linked in: bsd_comp nf_conntrack_netbios_ns nf_conntrack_broadcast
ppp_synctty ppp_async crc_ccitt ppp_generic slhc xt_nat xt_mark
ipt_MASQUERADE ip6t_rpfilter ip6t_REJECT ipt_REJECT xt_conntrack
ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables
ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle
ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
iptable_mangle iptable_security iptable_raw iptable_filter ip_tables sg
coretemp kvm crct10dif_pclmul crc32_pclmul snd_hda_codec_hdmi
snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel snd_hda_codec
serio_raw crc32c_intel snd_hwdep snd_seq snd_seq_device snd_pcm ppdev
iTCO_wdt iTCO_vendor_support i2c_i801 pcspkr
:ghash_clmulni_intel snd_page_alloc cryptd mei_me mei snd_timer snd
soundcore r8169 mii parport_pc parport lpc_ich mfd_core shpchp mperf xfs
libcrc32c sd_mod crc_t10dif crct10dif_common ata_generic pata_acpi i915
ahci i2c_algo_bit pata_jmicron libahci drm_kms_helper libata drm i2c_core
video dm_mirror dm_region_hash dm_log dm_mod
:CPU: 0 PID: 12 Comm: rcuos/0 Not tainted 3.10.0-123.el7.x86_64 #1
:Hardware name: Gigabyte Technology Co., Ltd. To be filled by O.E.M./C847N,
BIOS F2 11/09/2012
:task: ffff880213970000 ti: ffff88021396e000 task.ti: ffff88021396e000
:RIP: 0010:[<ffffffffa04addf1>]  [<ffffffffa04addf1>]
nf_conntrack_tuple_taken+0x91/0x1a0 [nf_conntrack]
:RSP: 0018:ffff88021f203838  EFLAGS: 00000246
:RAX: ffff8801fc8753e8 RBX: ffff88021f2037b8 RCX: 0000000000000000
:RDX: 0000000000000001 RSI: 00000000a7cd4ec5 RDI: ffff8800ca2e7000
:RBP: ffff88021f203860 R08: 000000009b52ef62 R09: 00000000ae0c5d8d
:R10: ffff88021f203888 R11: ffff880212522000 R12: ffff88021f2037a8
:R13: ffffffff815f2d9d R14: ffff88021f203860 R15: ffff88021f203870
:FS:  0000000000000000(0000) GS:ffff88021f200000(0000)
knlGS:0000000000000000
:CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
:CR2: 00007f0e9ceed000 CR3: 00000002116ad000 CR4: 00000000000407f0
:DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
:DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
:Stack:
:ffff8800cc67e9c0 ffff88021f2039e0 ffff88021f203a70 000000000000c16d
:000000000000c2c1 ffff88021f2038a8 ffffffffa04d4198 000000000601a8c0
:0000000000000000 0101a8c00002d59d 0000000000000000 0106c1c600000000
:Call Trace:
:[    0.002000] tsc: Detected 1097.502 MHz processor
:[    0.000004] Calibrating delay loop (skipped), value calculated using
timer frequency.. 2195.00 BogoMIPS (lpj=3D1097502)
:[    0.000009] pid_max: default: 32768 minimum: 301
:[    0.000048] Security Framework initialized
:[    0.000060] SELinux:  Initializing.
:[    0.000074] SELinux:  Starting in permissive mode
:[    0.001472] Dentry cache hash table entries: 1048576 (order: 11,
8388608 bytes)
:[    0.005228] Inode-cache hash table entries: 524288 (order: 10, 4194304
bytes)
:[    0.006776] Mount-cache hash table entries: 4096
:[    0.007130] Initializing cgroup subsys memory
:[    0.007144] Initializing cgroup subsys devices
:[    0.007147] Initializing cgroup subsys freezer
:[    0.007150] Initializing cgroup subsys net_cls
:[    0.007153] Initializing cgroup subsys blkio
:[    0.007155] Initializing cgroup subsys perf_event
:[    0.007158] Initializing cgroup subsys hugetlb
:[    0.007203] CPU: Physical Processor ID: 0
:[    0.007205] CPU: Processor Core ID: 0
:[    0.007214] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
:ENERGY_PERF_BIAS: View and update with x86_energy_perf_policy(8)
:[    0.007219] mce: CPU supports 7 MCE banks
:[    0.007241] CPU0: Thermal monitoring enabled (TM1)
:[    0.007257] Last level iTLB entries: 4KB 512, 2MB 0, 4MB 0
:Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32
:tlb_flushall_shift: 6
:[    0.007433] Freeing SMP alternatives: 24k freed
:[    0.010436] ACPI: Core revision 20130517
:[    0.022201] ACPI: All ACPI Tables successfully acquired
:[    0.022430] ftrace: allocating 23383 entries in 92 pages
:[    0.047587] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=
=3D-1
:[    0.057594] smpboot: CPU0: Intel(R) Celeron(R) CPU 847 @ 1.10GHz (fam:
06, model: 2a, stepping: 07)
:[    0.057609] TSC deadline timer enabled
:[    0.057626] Performance Events: PEBS fmt1+, 16-deep LBR, SandyBridge
events, full-width counters, Intel PMU driver.
:[    0.057642] ... version:                3
:[    0.057644] ... bit width:              48
:[    0.057646] ... generic registers:      8
:[    0.057648] ... value mask:             0000ffffffffffff
:[    0.057651] ... max period:             0000ffffffffffff
:[    0.057653] ... fixed-purpose events:   3
:[    0.057655] ... event mask:             00000007000000ff
:[    0.060063] smpboot: Booting Node   0, Processors  #1 OK
:[    0.071128] CPU1 microcode updated early to revision 0x29, date =3D
2013-06-12
:[    0.073340] Brought up 2 CPUs
:[    0.073347] smpboot: Total of 2 processors activated (4390.00 BogoMIPS)
:[    0.073445] NMI watchdog: enabled on all CPUs, permanently consumes one
hw-PMU counter.
:[    0.075964] devtmpfs: initialized
:[    0.078104] EVM: security.selinux
:[    0.078108] EVM: security.ima
:[    0.078110] EVM: security.capability
:[    0.078237] PM: Registering ACPI NVS region [mem 0xd9a96000-0xd9bbafff]
(1200128 bytes)
:[    0.078277] PM: Registering ACPI NVS region [mem 0xda6ba000-0xda6fcfff]
(274432 bytes)
:[    0.079934] atomic64 test passed for x86-64 platform with CX8 and with
SSE
:[    0.080014] NET: Registered protocol family 16
:[    0.080281] ACPI: bus type PCI registered
:[    0.080285] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
:[    0.080369] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem
0xf8000000-0xfbffffff] (base 0xf8000000)
:[    0.080374] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in
E820
:[    0.095794] PCI: Using configuration type 1 for base access
:[    0.097436] bio: create slab <bio-0> at 0
:[    0.097584] ACPI: Added _OSI(Module Device)
:[    0.097588] ACPI: Added _OSI(Processor Device)
:[    0.097591] ACPI: Added _OSI(3.0 _SCP Extensions)
:[    0.097594] ACPI: Added _OSI(Processor Aggregator Device)
:[    0.100539] ACPI: EC: Look up EC in DSDT
:[    0.104150] ACPI: Executed 1 blocks of module-level executable AML code
:[    0.111476] ACPI: SSDT 00000000d9a37018 0083B (v01  PmRef  Cpu0Cst
00003001 INTL 20051117)
:[    0.112239] ACPI: Dynamic OEM Table Load:
:[    0.112244] ACPI: SSDT           (null) 0083B (v01  PmRef  Cpu0Cst
00003001 INTL 20051117)
:[    0.114159] ACPI: SSDT 00000000d9a38a98 00303 (v01  PmRef    ApIst
00003000 INTL 20051117)
:[    0.114984] ACPI: Dynamic OEM Table Load:
:[    0.114989] ACPI: SSDT           (null) 00303 (v01  PmRef    ApIst
00003000 INTL 20051117)
:[    0.116849] ACPI: SSDT 00000000d9a44c18 00119 (v01  PmRef    ApCst
00003000 INTL 20051117)
:[    0.117583] ACPI: Dynamic OEM Table Load:
:[    0.117587] ACPI: SSDT           (null) 00119 (v01  PmRef    ApCst
00003000 INTL 20051117)
:[    0.119484] ACPI: Interpreter enabled
:[    0.119497] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State
[\_S1_] (20130517/hwxface-571)
:[    0.119506] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State
[\_S2_] (20130517/hwxface-571)
:[    0.119533] ACPI: (supports S0 S3 S4 S5)
:[    0.119536] ACPI: Using IOAPIC for interrupt routing
:[    0.119590] PCI: Using host bridge windows from ACPI; if necessary, use
"pci=3Dnocrs" and report a bug
:[    0.119875] ACPI: No dock devices found.
:[    0.135632] ACPI: Power Resource [FN00] (off)
:[    0.135797] ACPI: Power Resource [FN01] (off)
:[    0.135955] ACPI: Power Resource [FN02] (off)
:[    0.136104] ACPI: Power Resource [FN03] (off)
:[    0.136256] ACPI: Power Resource [FN04] (off)
:[    0.137451] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
:[    0.137462] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM
ClockPM Segments MSI]
:[    0.137902] acpi PNP0A08:00: _OSC: platform does not support
[PCIeHotplug PME]
:[    0.138174] acpi PNP0A08:00: _OSC: OS now controls [AER PCIeCapability]
:[    0.139307] PCI host bridge to bus 0000:00
:[    0.139314] pci_bus 0000:00: root bus resource [bus 00-3e]
:[    0.139318] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
:[    0.139322] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
:[    0.139326] pci_bus 0000:00: root bus resource [mem
0x000a0000-0x000bffff]
:[    0.139329] pci_bus 0000:00: root bus resource [mem
0x000d0000-0x000d3fff]
:[    0.139333] pci_bus 0000:00: root bus resource [mem
0x000d4000-0x000d7fff]
:[    0.139337] pci_bus 0000:00: root bus resource [mem
0x000d8000-0x000dbfff]
:[    0.139340] pci_bus 0000:00: root bus resource [mem
0x000dc000-0x000dffff]
:[    0.139344] pci_bus 0000:00: root bus resource [mem
0x000e0000-0x000e3fff]
:[    0.139347] pci_bus 0000:00: root bus resource [mem
0x000e4000-0x000e7fff]
:[    0.139351] pci_bus 0000:00: root bus resource [mem
0xdfa00000-0xfeafffff]
:[    0.139367] pci 0000:00:00.0: [8086:0104] type 00 class 0x060000
:[    0.139550] pci 0000:00:02.0: [8086:0106] type 00 class 0x030000
:[    0.139573] pci 0000:00:02.0: reg 0x10: [mem 0xf7800000-0xf7bfffff
64bit]
:[    0.139585] pci 0000:00:02.0: reg 0x18: [mem 0xe0000000-0xefffffff
64bit pref]
:[    0.139594] pci 0000:00:02.0: reg 0x20: [io  0xf000-0xf03f]
:[    0.139805] pci 0000:00:16.0: [8086:1e3a] type 00 class 0x078000
:[    0.139838] pci 0000:00:16.0: reg 0x10: [mem 0xf7f0a000-0xf7f0a00f
64bit]
:[    0.139943] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
:[    0.140116] pci 0000:00:1a.0: [8086:1e2d] type 00 class 0x0c0320
:[    0.140146] pci 0000:00:1a.0: reg 0x10: [mem 0xf7f08000-0xf7f083ff]
:[    0.140269] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
:[    0.140398] pci 0000:00:1a.0: System wakeup disabled by ACPI
:[    0.140459] pci 0000:00:1b.0: [8086:1e20] type 00 class 0x040300
:[    0.140482] pci 0000:00:1b.0: reg 0x10: [mem 0xf7f00000-0xf7f03fff
64bit]
:[    0.140590] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
:[    0.140695] pci 0000:00:1b.0: System wakeup disabled by ACPI
:[    0.140747] pci 0000:00:1c.0: [8086:1e10] type 01 class 0x060400
:[    0.140866] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
:[    0.140973] pci 0000:00:1c.0: System wakeup disabled by ACPI
:[    0.141025] pci 0000:00:1c.1: [8086:1e12] type 01 class 0x060400
:[    0.141138] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
:[    0.141244] pci 0000:00:1c.1: System wakeup disabled by ACPI
:[    0.141295] pci 0000:00:1c.2: [8086:2448] type 01 class 0x060401
:[    0.141407] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
:[    0.141517] pci 0000:00:1c.2: System wakeup disabled by ACPI
:[    0.141567] pci 0000:00:1c.3: [8086:1e16] type 01 class 0x060400
:[    0.141680] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
:[    0.141790] pci 0000:00:1c.3: System wakeup disabled by ACPI
:[    0.141854] pci 0000:00:1d.0: [8086:1e26] type 00 class 0x0c0320
:[    0.141884] pci 0000:00:1d.0: reg 0x10: [mem 0xf7f07000-0xf7f073ff]
:[    0.142007] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
:[    0.142132] pci 0000:00:1d.0: System wakeup disabled by ACPI
:[    0.142188] pci 0000:00:1f.0: [8086:1e5f] type 00 class 0x060100
:[    0.142464] pci 0000:00:1f.2: [8086:1e03] type 00 class 0x010601
:[    0.142492] pci 0000:00:1f.2: reg 0x10: [io  0xf0b0-0xf0b7]
:[    0.142505] pci 0000:00:1f.2: reg 0x14: [io  0xf0a0-0xf0a3]
:[    0.142517] pci 0000:00:1f.2: reg 0x18: [io  0xf090-0xf097]
:[    0.142529] pci 0000:00:1f.2: reg 0x1c: [io  0xf080-0xf083]
:[    0.142542] pci 0000:00:1f.2: reg 0x20: [io  0xf060-0xf07f]
:[    0.142554] pci 0000:00:1f.2: reg 0x24: [mem 0xf7f06000-0xf7f067ff]
:[    0.142623] pci 0000:00:1f.2: PME# supported from D3hot
:[    0.142763] pci 0000:00:1f.3: [8086:1e22] type 00 class 0x0c0500
:[    0.142786] pci 0000:00:1f.3: reg 0x10: [mem 0xf7f05000-0xf7f050ff
64bit]
:[    0.142822] pci 0000:00:1f.3: reg 0x20: [io  0xf040-0xf05f]
:[    0.143081] pci 0000:01:00.0: [10ec:8168] type 00 class 0x020000
:[    0.143108] pci 0000:01:00.0: reg 0x10: [io  0xe000-0xe0ff]
:[    0.143151] pci 0000:01:00.0: reg 0x18: [mem 0xf7e00000-0xf7e00fff
64bit]
:[    0.143179] pci 0000:01:00.0: reg 0x20: [mem 0xf0100000-0xf0103fff
64bit pref]
:[    0.143316] pci 0000:01:00.0: supports D1 D2
:[    0.143319] pci 0000:01:00.0: PME# supported from D0 D1 D2 D3hot D3cold
:[    0.143371] pci 0000:01:00.0: System wakeup disabled by ACPI
:[    0.144835] pci 0000:00:1c.0: PCI bridge to [bus 01]
:[    0.144844] pci 0000:00:1c.0:   bridge window [io  0xe000-0xefff]
:[    0.144853] pci 0000:00:1c.0:   bridge window [mem
0xf7e00000-0xf7efffff]
:[    0.144864] pci 0000:00:1c.0:   bridge window [mem
0xf0100000-0xf01fffff 64bit pref]
:[    0.144998] pci 0000:02:00.0: [10ec:8168] type 00 class 0x020000
:[    0.145025] pci 0000:02:00.0: reg 0x10: [io  0xd000-0xd0ff]
:[    0.145068] pci 0000:02:00.0: reg 0x18: [mem 0xf0004000-0xf0004fff
64bit pref]
:[    0.145096] pci 0000:02:00.0: reg 0x20: [mem 0xf0000000-0xf0003fff
64bit pref]
:[    0.145232] pci 0000:02:00.0: supports D1 D2
:[    0.145236] pci 0000:02:00.0: PME# supported from D0 D1 D2 D3hot D3cold
:[    0.145295] pci 0000:02:00.0: System wakeup disabled by ACPI
:[    0.146837] pci 0000:00:1c.1: PCI bridge to [bus 02]
:[    0.146846] pci 0000:00:1c.1:   bridge window [io  0xd000-0xdfff]
:[    0.146860] pci 0000:00:1c.1:   bridge window [mem
0xf0000000-0xf00fffff 64bit pref]
:[    0.146990] pci 0000:03:00.0: [8086:244e] type 01 class 0x060401
:[    0.147172] pci 0000:03:00.0: supports D1 D2
:[    0.147175] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
:[    0.147214] pci 0000:03:00.0: System wakeup disabled by ACPI
:[    0.147257] pci 0000:00:1c.2: PCI bridge to [bus 03-04] (subtractive
decode)
:[    0.147264] pci 0000:00:1c.2:   bridge window [io  0xc000-0xcfff]
:[    0.147270] pci 0000:00:1c.2:   bridge window [mem
0xf7d00000-0xf7dfffff]
:[    0.147279] pci 0000:00:1c.2:   bridge window [io  0x0000-0x0cf7]
(subtractive decode)
:[    0.147283] pci 0000:00:1c.2:   bridge window [io  0x0d00-0xffff]
(subtractive decode)
:[    0.147287] pci 0000:00:1c.2:   bridge window [mem
0x000a0000-0x000bffff] (subtractive decode)
:[    0.147291] pci 0000:00:1c.2:   bridge window [mem
0x000d0000-0x000d3fff] (subtractive decode)
:[    0.147294] pci 0000:00:1c.2:   bridge window [mem
0x000d4000-0x000d7fff] (subtractive decode)
:[    0.147298] pci 0000:00:1c.2:   bridge window [mem
0x000d8000-0x000dbfff] (subtractive decode)
:[    0.147301] pci 0000:00:1c.2:   bridge window [mem
0x000dc000-0x000dffff] (subtractive decode)
:[    0.147305] pci 0000:00:1c.2:   bridge window [mem
0x000e0000-0x000e3fff] (subtractive decode)
:[    0.147308] pci 0000:00:1c.2:   bridge window [mem
0x000e4000-0x000e7fff] (subtractive decode)
:[    0.147312] pci 0000:00:1c.2:   bridge window [mem
0xdfa00000-0xfeafffff] (subtractive decode)
:[    0.147419] pci 0000:04:00.0: [1186:4300] type 00 class 0x020000
:[    0.147462] pci 0000:04:00.0: reg 0x10: [io  0xc000-0xc0ff]
:[    0.147487] pci 0000:04:00.0: reg 0x14: [mem 0xf7d20000-0xf7d200ff]
:[    0.147594] pci 0000:04:00.0: reg 0x30: [mem 0xf7d00000-0xf7d1ffff pref=
]
:[    0.147666] pci 0000:04:00.0: supports D1 D2
:[    0.147669] pci 0000:04:00.0: PME# supported from D1 D2 D3hot D3cold
:[    0.147827] pci 0000:03:00.0: PCI bridge to [bus 04] (subtractive
decode)
:[    0.147842] pci 0000:03:00.0:   bridge window [io  0xc000-0xcfff]
:[    0.147851] pci 0000:03:00.0:   bridge window [mem
0xf7d00000-0xf7dfffff]
:[    0.147865] pci 0000:03:00.0:   bridge window [io  0xc000-0xcfff]
(subtractive decode)
:[    0.147869] pci 0000:03:00.0:   bridge window [mem
0xf7d00000-0xf7dfffff] (subtractive decode)
:[    0.147873] pci 0000:03:00.0:   bridge window [??? 0x00000000 flags
0x0] (subtractive decode)
:[    0.147877] pci 0000:03:00.0:   bridge window [??? 0x00000000 flags
0x0] (subtractive decode)
:[    0.147880] pci 0000:03:00.0:   bridge window [io  0x0000-0x0cf7]
(subtractive decode)
:[    0.147884] pci 0000:03:00.0:   bridge window [io  0x0d00-0xffff]
(subtractive decode)
:[    0.147887] pci 0000:03:00.0:   bridge window [mem
0x000a0000-0x000bffff] (subtractive decode)
:[    0.147891] pci 0000:03:00.0:   bridge window [mem
0x000d0000-0x000d3fff] (subtractive decode)
:[    0.147894] pci 0000:03:00.0:   bridge window [mem
0x000d4000-0x000d7fff] (subtractive decode)
:[    0.147898] pci 0000:03:00.0:   bridge window [mem
0x000d8000-0x000dbfff] (subtractive decode)
:[    0.147901] pci 0000:03:00.0:   bridge window [mem
0x000dc000-0x000dffff] (subtractive decode)
:[    0.147905] pci 0000:03:00.0:   bridge window [mem
0x000e0000-0x000e3fff] (subtractive decode)
:[    0.147908] pci 0000:03:00.0:   bridge window [mem
0x000e4000-0x000e7fff] (subtractive decode)
:[    0.147912] pci 0000:03:00.0:   bridge window [mem
0xdfa00000-0xfeafffff] (subtractive decode)
:[    0.148039] pci 0000:05:00.0: [197b:2368] type 00 class 0x010185
:[    0.148083] pci 0000:05:00.0: reg 0x10: [io  0xb040-0xb047]
:[    0.148104] pci 0000:05:00.0: reg 0x14: [io  0xb030-0xb033]
:[    0.148124] pci 0000:05:00.0: reg 0x18: [io  0xb020-0xb027]
:[    0.148145] pci 0000:05:00.0: reg 0x1c: [io  0xb010-0xb013]
:[    0.148165] pci 0000:05:00.0: reg 0x20: [io  0xb000-0xb00f]
:[    0.148204] pci 0000:05:00.0: reg 0x30: [mem 0xf7c00000-0xf7c0ffff pref=
]
:[    0.148342] pci 0000:05:00.0: System wakeup disabled by ACPI
:[    0.148383] pci 0000:05:00.0: disabling ASPM on pre-1.1 PCIe device.
You can enable it with 'pcie_aspm=3Dforce'
:[    0.148398] pci 0000:00:1c.3: PCI bridge to [bus 05]
:[    0.148404] pci 0000:00:1c.3:   bridge window [io  0xb000-0xbfff]
:[    0.148411] pci 0000:00:1c.3:   bridge window [mem
0xf7c00000-0xf7cfffff]
:[    0.149911] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 *11 12 14
15)
:[    0.150014] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 *10 11 12 14
15)
:[    0.150112] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 *11 12 14
15)
:[    0.150210] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10 11 12 14
15)
:[    0.150312] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 10 11 12 14
15) *0, disabled.
:[    0.150413] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 11 12 14
15) *0, disabled.
:[    0.150510] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 10 *11 12 14
15)
:[    0.150606] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *10 11 12 14
15)
:[    0.151045] ACPI: Enabled 5 GPEs in block 00 to 3F
:[    0.151060] ACPI: \_SB_.PCI0: notify handler is installed
:[    0.151184] Found 1 acpi root devices
:[    0.151342] vgaarb: device added:
PCI:0000:00:02.0,decodes=3Dio+mem,owns=3Dio+mem,locks=3Dnone
:[    0.151349] vgaarb: loaded
:[    0.151351] vgaarb: bridge control possible 0000:00:02.0
:[    0.151467] SCSI subsystem initialized
:[    0.151499] ACPI: bus type USB registered
:[    0.151536] usbcore: registered new interface driver usbfs
:[    0.151550] usbcore: registered new interface driver hub
:[    0.151610] usbcore: registered new device driver usb
:[    0.151734] PCI: Using ACPI for IRQ routing
:[    0.153848] PCI: pci_cache_line_size set to 64 bytes
:[    0.153935] e820: reserve RAM buffer [mem 0x0009d800-0x0009ffff]
:[    0.153939] e820: reserve RAM buffer [mem 0xd94d2000-0xdbffffff]
:[    0.153943] e820: reserve RAM buffer [mem 0xda6ba000-0xdbffffff]
:[    0.153947] e820: reserve RAM buffer [mem 0xdadef000-0xdbffffff]
:[    0.153950] e820: reserve RAM buffer [mem 0xdb000000-0xdbffffff]
:[    0.153953] e820: reserve RAM buffer [mem 0x21f600000-0x21fffffff]
:[    0.154096] NetLabel: Initializing
:[    0.154099] NetLabel:  domain hash size =3D 128
:[    0.154101] NetLabel:  protocols =3D UNLABELED CIPSOv4
:[    0.154122] NetLabel:  unlabeled traffic allowed by default
:[    0.154199] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
:[    0.154210] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
:[    0.156234] Switching to clocksource hpet
:[    0.165233] pnp: PnP ACPI init
:[    0.165264] ACPI: bus type PNP registered
:[    0.165425] system 00:00: [mem 0xfed40000-0xfed44fff] has been reserved
:[    0.165432] system 00:00: Plug and Play ACPI device, IDs PNP0c01
(active)
:[    0.165456] pnp 00:01: [dma 4]
:[    0.165480] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
:[    0.165513] pnp 00:02: Plug and Play ACPI device, IDs INT0800 (active)
:[    0.165674] pnp 00:03: Plug and Play ACPI device, IDs PNP0103 (active)
:[    0.165755] system 00:04: [io  0x0680-0x069f] has been reserved
:[    0.165760] system 00:04: [io  0x0200-0x020f] has been reserved
:[    0.165764] system 00:04: [io  0xffff] has been reserved
:[    0.165768] system 00:04: [io  0xffff] has been reserved
:[    0.165773] system 00:04: [io  0x0400-0x0453] could not be reserved
:[    0.165777] system 00:04: [io  0x0458-0x047f] has been reserved
:[    0.165780] system 00:04: [io  0x0500-0x057f] has been reserved
:[    0.165786] system 00:04: Plug and Play ACPI device, IDs PNP0c02
(active)
:[    0.165837] pnp 00:05: Plug and Play ACPI device, IDs PNP0b00 (active)
:[    0.165925] system 00:06: [io  0x0454-0x0457] has been reserved
:[    0.165931] system 00:06: Plug and Play ACPI device, IDs INT3f0d
PNP0c02 (active)
:[    0.166167] system 00:07: [io  0x0a00-0x0a0f] has been reserved
:[    0.166171] system 00:07: [io  0x0a30-0x0a3f] has been reserved
:[    0.166175] system 00:07: [io  0x0a20-0x0a2f] has been reserved
:[    0.166180] system 00:07: Plug and Play ACPI device, IDs PNP0c02
(active)
:[    0.166614] pnp 00:08: [dma 0 disabled]
:[    0.166701] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
:[    0.167061] pnp 00:09: [dma 0 disabled]
:[    0.167146] pnp 00:09: Plug and Play ACPI device, IDs PNP0501 (active)
:[    0.167617] pnp 00:0a: [dma 0 disabled]
:[    0.167807] pnp 00:0a: Plug and Play ACPI device, IDs PNP0400 (active)
:[    0.167900] system 00:0b: [io  0x04d0-0x04d1] has been reserved
:[    0.167905] system 00:0b: Plug and Play ACPI device, IDs PNP0c02
(active)
:[    0.167949] pnp 00:0c: Plug and Play ACPI device, IDs PNP0c04 (active)
:[    0.168435] system 00:0d: [mem 0xfed1c000-0xfed1ffff] has been reserved
:[    0.168440] system 00:0d: [mem 0xfed10000-0xfed17fff] has been reserved
:[    0.168444] system 00:0d: [mem 0xfed18000-0xfed18fff] has been reserved
:[    0.168448] system 00:0d: [mem 0xfed19000-0xfed19fff] has been reserved
:[    0.168452] system 00:0d: [mem 0xf8000000-0xfbffffff] has been reserved
:[    0.168456] system 00:0d: [mem 0xfed20000-0xfed3ffff] has been reserved
:[    0.168465] system 00:0d: [mem 0xfed90000-0xfed93fff] has been reserved
:[    0.168469] system 00:0d: [mem 0xfed45000-0xfed8ffff] has been reserved
:[    0.168473] system 00:0d: [mem 0xff000000-0xffffffff] has been reserved
:[    0.168478] system 00:0d: [mem 0xfee00000-0xfeefffff] could not be
reserved
:[    0.168482] system 00:0d: [mem 0xdfa00000-0xdfa00fff] has been reserved
:[    0.168487] system 00:0d: Plug and Play ACPI device, IDs PNP0c02
(active)
:[    0.168775] system 00:0e: [mem 0x20000000-0x201fffff] has been reserved
:[    0.168779] system 00:0e: [mem 0x40000000-0x401fffff] has been reserved
:[    0.168784] system 00:0e: Plug and Play ACPI device, IDs PNP0c01
(active)
:[    0.168825] pnp: PnP ACPI: found 15 devices
:[    0.168827] ACPI: bus type PNP unregistered
:[    0.176239] pci 0000:00:1c.0: PCI bridge to [bus 01]
:[    0.176247] pci 0000:00:1c.0:   bridge window [io  0xe000-0xefff]
:[    0.176262] pci 0000:00:1c.0:   bridge window [mem
0xf7e00000-0xf7efffff]
:[    0.176269] pci 0000:00:1c.0:   bridge window [mem
0xf0100000-0xf01fffff 64bit pref]
:[    0.176278] pci 0000:00:1c.1: PCI bridge to [bus 02]
:[    0.176283] pci 0000:00:1c.1:   bridge window [io  0xd000-0xdfff]
:[    0.176294] pci 0000:00:1c.1:   bridge window [mem
0xf0000000-0xf00fffff 64bit pref]
:[    0.176304] pci 0000:03:00.0: PCI bridge to [bus 04]
:[    0.176310] pci 0000:03:00.0:   bridge window [io  0xc000-0xcfff]
:[    0.176322] pci 0000:03:00.0:   bridge window [mem
0xf7d00000-0xf7dfffff]
:[    0.176342] pci 0000:00:1c.2: PCI bridge to [bus 03-04]
:[    0.176347] pci 0000:00:1c.2:   bridge window [io  0xc000-0xcfff]
:[    0.176355] pci 0000:00:1c.2:   bridge window [mem
0xf7d00000-0xf7dfffff]
:[    0.176367] pci 0000:00:1c.3: PCI bridge to [bus 05]
:[    0.176372] pci 0000:00:1c.3:   bridge window [io  0xb000-0xbfff]
:[    0.176379] pci 0000:00:1c.3:   bridge window [mem
0xf7c00000-0xf7cfffff]
:[    0.176393] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
:[    0.176397] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
:[    0.176401] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
:[    0.176404] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000d3fff]
:[    0.176408] pci_bus 0000:00: resource 8 [mem 0x000d4000-0x000d7fff]
:[    0.176411] pci_bus 0000:00: resource 9 [mem 0x000d8000-0x000dbfff]
:[    0.176415] pci_bus 0000:00: resource 10 [mem 0x000dc000-0x000dffff]
:[    0.176418] pci_bus 0000:00: resource 11 [mem 0x000e0000-0x000e3fff]
:[    0.176422] pci_bus 0000:00: resource 12 [mem 0x000e4000-0x000e7fff]
:[    0.176425] pci_bus 0000:00: resource 13 [mem 0xdfa00000-0xfeafffff]
:[    0.176429] pci_bus 0000:01: resource 0 [io  0xe000-0xefff]
:[    0.176433] pci_bus 0000:01: resource 1 [mem 0xf7e00000-0xf7efffff]
:[    0.176437] pci_bus 0000:01: resource 2 [mem 0xf0100000-0xf01fffff
64bit pref]
:[    0.176440] pci_bus 0000:02: resource 0 [io  0xd000-0xdfff]
:[    0.176444] pci_bus 0000:02: resource 2 [mem 0xf0000000-0xf00fffff
64bit pref]
:[    0.176448] pci_bus 0000:03: resource 0 [io  0xc000-0xcfff]
:[    0.176451] pci_bus 0000:03: resource 1 [mem 0xf7d00000-0xf7dfffff]
:[    0.176455] pci_bus 0000:03: resource 4 [io  0x0000-0x0cf7]
:[    0.176458] pci_bus 0000:03: resource 5 [io  0x0d00-0xffff]
:[    0.176462] pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000bffff]
:[    0.176465] pci_bus 0000:03: resource 7 [mem 0x000d0000-0x000d3fff]
:[    0.176469] pci_bus 0000:03: resource 8 [mem 0x000d4000-0x000d7fff]
:[    0.176472] pci_bus 0000:03: resource 9 [mem 0x000d8000-0x000dbfff]
:[    0.176476] pci_bus 0000:03: resource 10 [mem 0x000dc000-0x000dffff]
:[    0.176479] pci_bus 0000:03: resource 11 [mem 0x000e0000-0x000e3fff]
:[    0.176483] pci_bus 0000:03: resource 12 [mem 0x000e4000-0x000e7fff]
:[    0.176486] pci_bus 0000:03: resource 13 [mem 0xdfa00000-0xfeafffff]
:[    0.176490] pci_bus 0000:04: resource 0 [io  0xc000-0xcfff]
:[    0.176493] pci_bus 0000:04: resource 1 [mem 0xf7d00000-0xf7dfffff]
:[    0.176497] pci_bus 0000:04: resource 4 [io  0xc000-0xcfff]
:[    0.176500] pci_bus 0000:04: resource 5 [mem 0xf7d00000-0xf7dfffff]
:[    0.176504] pci_bus 0000:04: resource 8 [io  0x0000-0x0cf7]
:[    0.176507] pci_bus 0000:04: resource 9 [io  0x0d00-0xffff]
:[    0.176511] pci_bus 0000:04: resource 10 [mem 0x000a0000-0x000bffff]
:[    0.176514] pci_bus 0000:04: resource 11 [mem 0x000d0000-0x000d3fff]
:[    0.176518] pci_bus 0000:04: resource 12 [mem 0x000d4000-0x000d7fff]
:[    0.176521] pci_bus 0000:04: resource 13 [mem 0x000d8000-0x000dbfff]
:[    0.176524] pci_bus 0000:04: resource 14 [mem 0x000dc000-0x000dffff]
:[    0.176528] pci_bus 0000:04: resource 15 [mem 0x000e0000-0x000e3fff]
:[    0.176531] pci_bus 0000:04: resource 16 [mem 0x000e4000-0x000e7fff]
:[    0.176535] pci_bus 0000:04: resource 17 [mem 0xdfa00000-0xfeafffff]
:[    0.176538] pci_bus 0000:05: resource 0 [io  0xb000-0xbfff]
:[    0.176542] pci_bus 0000:05: resource 1 [mem 0xf7c00000-0xf7cfffff]
:[    0.176590] NET: Registered protocol family 2
:[    0.176898] TCP established hash table entries: 65536 (order: 7, 524288
bytes)
:[    0.177272] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes=
)
:[    0.177542] TCP: Hash tables configured (established 65536 bind 65536)
:[    0.177585] TCP: reno registered
:[    0.177614] UDP hash table entries: 4096 (order: 5, 131072 bytes)
:[    0.177683] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
:[    0.177816] NET: Registered protocol family 1
:[    0.177840] pci 0000:00:02.0: Boot video device
:[    0.209469] PCI: CLS 64 bytes, default 64
:[    0.209560] Unpacking initramfs...
:[    0.604457] Freeing initrd memory: 11424k freed
:[    0.607382] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
:[    0.607391] software IO TLB [mem 0xd54d2000-0xd94d2000] (64MB) mapped
at [ffff8800d54d2000-ffff8800d94d1fff]
:[    0.607905] microcode: CPU0 sig=3D0x206a7, pf=3D0x10, revision=3D0x29
:[    0.607917] microcode: CPU1 sig=3D0x206a7, pf=3D0x10, revision=3D0x29
:[    0.607960] microcode: Microcode Update Driver: v2.00 <
tigran@aivazian.fsnet.co.uk>, Peter Oruba
:[    0.608228] futex hash table entries: 512 (order: 3, 32768 bytes)
:[    0.608259] Initialise system trusted keyring
:[    0.608337] audit: initializing netlink socket (disabled)
:[    0.608357] type=3D2000 audit(1419859884.594:1): initialized
:[    0.655088] HugeTLB registered 2 MB page size, pre-allocated 0 pages
:[    0.657011] zbud: loaded
:[    0.657296] VFS: Disk quotas dquot_6.5.2
:[    0.657361] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
:[    0.657619] msgmni has been set to 15417
:[    0.657703] Key type big_key registered
:[    0.657706] SELinux:  Registering netfilter hooks
:[    0.658582] alg: No test for stdrng (krng)
:[    0.658595] NET: Registered protocol family 38
:[    0.658600] Key type asymmetric registered
:[    0.658602] Asymmetric key parser 'x509' registered
:[    0.658655] Block layer SCSI generic (bsg) driver version 0.4 loaded
(major 252)
:[    0.658698] io scheduler noop registered
:[    0.658701] io scheduler deadline registered (default)
:[    0.658740] io scheduler cfq registered
:[    0.659561] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
:[    0.659587] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
:[    0.659689] intel_idle: MWAIT substates: 0x21120
:[    0.659692] intel_idle: v0.4 model 0x2A
:[    0.659695] intel_idle: lapic_timer_reliable_states 0xffffffff
:[    0.659840] input: Power Button as
/devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
:[    0.659848] ACPI: Power Button [PWRB]
:[    0.659904] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
:[    0.659908] ACPI: Power Button [PWRF]
:[    0.660001] ACPI: Fan [FAN0] (off)
:[    0.660043] ACPI: Fan [FAN1] (off)
:[    0.660089] ACPI: Fan [FAN2] (off)
:[    0.660128] ACPI: Fan [FAN3] (off)
:[    0.660171] ACPI: Fan [FAN4] (off)
:[    0.660270] ACPI: Requesting acpi_cpufreq
:[    0.668020] thermal LNXTHERM:00: registered as thermal_zone0
:[    0.668025] ACPI: Thermal Zone [TZ00] (28 C)
:[    0.668442] thermal LNXTHERM:01: registered as thermal_zone1
:[    0.668445] ACPI: Thermal Zone [TZ01] (30 C)
:[    0.668534] GHES: HEST is not enabled!
:[    0.668627] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
:[    0.689327] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
:[    0.710011] 00:09: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A
:[    0.710707] Non-volatile memory driver v1.3
:[    0.710711] Linux agpgart interface v0.103
:[    0.710840] crash memory driver: version 1.1
:[    0.710865] rdac: device handler registered
:[    0.710920] hp_sw: device handler registered
:[    0.710924] emc: device handler registered
:[    0.710927] alua: device handler registered
:[    0.710980] libphy: Fixed MDIO Bus: probed
:[    0.711055] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
:[    0.711060] ehci-pci: EHCI PCI platform driver
:[    0.711280] ehci-pci 0000:00:1a.0: EHCI Host Controller
:[    0.711346] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus
number 1
:[    0.711365] ehci-pci 0000:00:1a.0: debug port 2
:[    0.715281] ehci-pci 0000:00:1a.0: cache line size of 64 is not
supported
:[    0.715310] ehci-pci 0000:00:1a.0: irq 16, io mem 0xf7f08000
:[    0.721251] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
:[    0.721328] usb usb1: New USB device found, idVendor=3D1d6b,
idProduct=3D0002
:[    0.721332] usb usb1: New USB device strings: Mfr=3D3, Product=3D2,
SerialNumber=3D1
:[    0.721335] usb usb1: Product: EHCI Host Controller
:[    0.721339] usb usb1: Manufacturer: Linux 3.10.0-123.el7.x86_64 ehci_hc=
d
:[    0.721343] usb usb1: SerialNumber: 0000:00:1a.0
:[    0.721508] hub 1-0:1.0: USB hub found
:[    0.721520] hub 1-0:1.0: 2 ports detected
:[    0.721883] ehci-pci 0000:00:1d.0: EHCI Host Controller
:[    0.721948] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus
number 2
:[    0.721965] ehci-pci 0000:00:1d.0: debug port 2
:[    0.725869] ehci-pci 0000:00:1d.0: cache line size of 64 is not
supported
:[    0.725892] ehci-pci 0000:00:1d.0: irq 23, io mem 0xf7f07000
:[    0.731251] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
:[    0.731306] usb usb2: New USB device found, idVendor=3D1d6b,
idProduct=3D0002
:[    0.731310] usb usb2: New USB device strings: Mfr=3D3, Product=3D2,
SerialNumber=3D1
:[    0.731314] usb usb2: Product: EHCI Host Controller
:[    0.731317] usb usb2: Manufacturer: Linux 3.10.0-123.el7.x86_64 ehci_hc=
d
:[    0.731321] usb usb2: SerialNumber: 0000:00:1d.0
:[    0.731469] hub 2-0:1.0: USB hub found
:[    0.731480] hub 2-0:1.0: 2 ports detected
:[    0.731663] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
:[    0.731666] ohci-pci: OHCI PCI platform driver
:[    0.731680] uhci_hcd: USB Universal Host Controller Interface driver
:[    0.731757] usbcore: registered new interface driver usbserial
:[    0.731768] usbcore: registered new interface driver usbserial_generic
:[    0.731781] usbserial: USB Serial support registered for generic
:[    0.731839] i8042: PNP: No PS/2 controller found. Probing ports
directly.
:[    0.732271] serio: i8042 KBD port at 0x60,0x64 irq 1
:[    0.732281] serio: i8042 AUX port at 0x60,0x64 irq 12
:[    0.732423] mousedev: PS/2 mouse device common for all mice
:[    0.732651] rtc_cmos 00:05: RTC can wake from S4
:[    0.732824] rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
:[    0.732860] rtc_cmos 00:05: alarms up to one month, y3k, 242 bytes
nvram, hpet irqs
:[    0.732878] Intel P-state driver initializing.
:[    0.732894] Intel pstate controlling: cpu 0
:[    0.732920] Intel pstate controlling: cpu 1
:[    0.733031] cpuidle: using governor menu
:[    0.733472] hidraw: raw HID events driver (C) Jiri Kosina
:[    0.733605] usbcore: registered new interface driver usbhid
:[    0.733607] usbhid: USB HID core driver
:[    0.733664] drop_monitor: Initializing network drop monitor service
:[    0.733792] TCP: cubic registered
:[    0.733795] Initializing XFRM netlink socket
:[    0.733944] NET: Registered protocol family 10
:[    0.734184] NET: Registered protocol family 17
:[    0.734533] Loading compiled-in X.509 certificates
:[    0.734580] Loaded X.509 cert 'CentOS Linux kpatch signing key:
ea0413152cde1d98ebdca3fe6f0230904c9ef717'
:[    0.734617] Loaded X.509 cert 'CentOS Linux Driver update signing key:
7f421ee0ab69461574bb358861dbe77762a4201b'
:[    0.735856] Loaded X.509 cert 'CentOS Linux kernel signing key:
bc83d0fe70c62fab1c58b4ebaa95e3936128fcf4'
:[    0.735874] registered taskstats version 1
:[    0.739363] Key type trusted registered
:[    0.742673] Key type encrypted registered
:[    0.745824] IMA: No TPM chip found, activating TPM-bypass!
:[    0.746475] rtc_cmos 00:05: setting system clock to 2014-12-29 13:31:25
UTC (1419859885)
:[    0.748508] Freeing unused kernel memory: 1584k freed
:[    0.754405] systemd[1]: systemd 208 running in system mode. (+PAM
+LIBWRAP +AUDIT +SELINUX +IMA +SYSVINIT +LIBCRYPTSETUP +GCRYPT +ACL +XZ)
:[    0.754703] systemd[1]: Running in initial RAM disk.
:[    0.754802] systemd[1]: Set hostname to <router.centos>.
:[    0.805134] systemd[1]: Expecting device
dev-disk-by\x2duuid-328b16e8\x2d5f97\x2d4c97\x2d80c2\x2d1269e2157281.device=
...
:[    0.805164] systemd[1]: Starting -.slice.
:[    0.805446] systemd[1]: Created slice -.slice.
:[    0.805547] systemd[1]: Starting System Slice.
:[    0.805688] systemd[1]: Created slice System Slice.
:[    0.805757] systemd[1]: Starting Slices.
:[    0.805778] systemd[1]: Reached target Slices.
:[    0.805836] systemd[1]: Starting Timers.
:[    0.805856] systemd[1]: Reached target Timers.
:[    0.805914] systemd[1]: Starting Journal Socket.
:[    0.806019] systemd[1]: Listening on Journal Socket.
:[    0.806375] systemd[1]: Starting dracut cmdline hook...
:[    0.807179] systemd[1]: Started Load Kernel Modules.
:[    0.807212] systemd[1]: Starting Setup Virtual Console...
:[    0.807844] systemd[1]: Starting Journal Service...
:[    0.808460] systemd[1]: Started Journal Service.
:[    0.824104] systemd-journald[90]: Vacuuming done, freed 0 bytes
:[    1.024292] usb 1-1: new high-speed USB device number 2 using ehci-pci
:[    1.043450] device-mapper: uevent: version 1.0.3
:[    1.043582] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30)
initialised: dm-devel@redhat.com
:[    1.095150] systemd-udevd[214]: starting version 208
:[    1.138603] usb 1-1: New USB device found, idVendor=3D8087, idProduct=
=3D0024
:[    1.138611] usb 1-1: New USB device strings: Mfr=3D0, Product=3D0,
SerialNumber=3D0
:[    1.138887] hub 1-1:1.0: USB hub found
:[    1.138965] hub 1-1:1.0: 4 ports detected
:[    1.214959] [drm] Initialized drm 1.1.0 20060810
:[    1.231450] ACPI: bus type ATA registered
:[    1.237330] libata version 3.00 loaded.
:[    1.243256] usb 2-1: new high-speed USB device number 2 using ehci-pci
:[    1.245014] ahci 0000:00:1f.2: version 3.0
:[    1.245320] ahci 0000:00:1f.2: irq 40 for MSI/MSI-X
:[    1.245399] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 4 ports 6 Gbps
0x1 impl SATA mode
:[    1.245406] ahci 0000:00:1f.2: flags: 64bit ncq led clo pio slum part
ems apst
:[    1.279383] scsi0 : pata_jmicron
:[    1.281670] scsi1 : ahci
:[    1.291657] scsi3 : ahci
:[    1.294823] scsi2 : pata_jmicron
:[    1.294910] ata1: PATA max UDMA/100 cmd 0xb040 ctl 0xb030 bmdma 0xb000
irq 19
:[    1.294914] ata2: PATA max UDMA/100 cmd 0xb020 ctl 0xb010 bmdma 0xb008
irq 19
:[    1.308040] scsi4 : ahci
:[    1.320404] scsi5 : ahci
:[    1.320583] ata3: SATA max UDMA/133 abar m2048@0xf7f06000 port
0xf7f06100 irq 40
:[    1.320587] ata4: DUMMY
:[    1.320590] ata5: DUMMY
:[    1.320592] ata6: DUMMY
:[    1.322898] [drm] Memory usable by graphics device =3D 2048M
:[    1.358589] usb 2-1: New USB device found, idVendor=3D8087, idProduct=
=3D0024
:[    1.358598] usb 2-1: New USB device strings: Mfr=3D0, Product=3D0,
SerialNumber=3D0
:[    1.358875] hub 2-1:1.0: USB hub found
:[    1.358956] hub 2-1:1.0: 4 ports detected
:[    1.395684] i915 0000:00:02.0: irq 41 for MSI/MSI-X
:[    1.395709] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
:[    1.395711] [drm] Driver supports precise vblank timestamp query.
:[    1.395804] vgaarb: device changed decodes:
PCI:0000:00:02.0,olddecodes=3Dio+mem,decodes=3Dio+mem:owns=3Dio+mem
:[    1.415744] [drm] Wrong MCH_SSKPD value: 0x16040307
:[    1.415749] [drm] This can cause pipe underruns and display issues.
:[    1.415751] [drm] Please upgrade your BIOS to fix this.
:[    1.425898] i915 0000:00:02.0: No connectors reported connected with
modes
:[    1.425905] [drm] Cannot find any crtc or sizes - going 1024x768
:[    1.427730] fbcon: inteldrmfb (fb0) is primary device
:[    1.455620] Console: switching to colour frame buffer device 128x48
:[    1.459524] i915 0000:00:02.0: fb0: inteldrmfb frame buffer device
:[    1.459527] i915 0000:00:02.0: registered panic notifier
:[    1.471043] acpi device:59: registered as cooling_device7
:[    1.471345] ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post:
no)
:[    1.471417] input: Video Bus as
/devices/LNXSYSTM:00/device:00/PNP0A08:00/LNXVIDEO:00/input/input2
:[    1.472093] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on
minor 0
:[    1.608229] tsc: Refined TSC clocksource calibration: 1097.506 MHz
:[    1.608237] Switching to clocksource tsc
:[    1.625263] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
:[    1.628527] ACPI Error: [DSSP] Namespace lookup failure, AE_NOT_FOUND
(20130517/psargs-359)
:[    1.628540] ACPI Error: Method parse/execution failed
[\_SB_.PCI0.SAT0.SPT0._GTF] (Node ffff8802138b5c30), AE_NOT_FOUND
(20130517/psparse-536)
:[    1.628708] ata3.00: ATA-7: SAMSUNG SP2004C, VM100-33, max UDMA7
:[    1.628713] ata3.00: 390721968 sectors, multi 16: LBA48 NCQ (depth
31/32), AA
:[    1.631993] ACPI Error: [DSSP] Namespace lookup failure, AE_NOT_FOUND
(20130517/psargs-359)
:[    1.632006] ACPI Error: Method parse/execution failed
[\_SB_.PCI0.SAT0.SPT0._GTF] (Node ffff8802138b5c30), AE_NOT_FOUND
(20130517/psparse-536)
:[    1.632138] ata3.00: configured for UDMA/133
:[    1.632317] scsi 1:0:0:0: Direct-Access     ATA      SAMSUNG SP2004C
VM10 PQ: 0 ANSI: 5
:[    1.649161] sd 1:0:0:0: [sda] 390721968 512-byte logical blocks: (200
GB/186 GiB)
:[    1.649491] sd 1:0:0:0: [sda] Write Protect is off
:[    1.649498] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00
:[    1.649532] sd 1:0:0:0: [sda] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
:[    1.655470]  sda: sda1 sda2
:[    1.655883] sd 1:0:0:0: [sda] Attached SCSI disk
:[    2.061962] bio: create slab <bio-1> at 1
:[    2.379041] SGI XFS with ACLs, security attributes, large block/inode
numbers, no debug enabled
:[    2.381018] XFS (dm-1): Mounting Filesystem
:[    2.537380] XFS (dm-1): Ending clean mount
:[    2.720554] [drm] Enabling RC6 states: RC6 on, RC6p off, RC6pp off
:[    2.787861] systemd-journald[90]: Received SIGTERM
:[    3.350603] type=3D1404 audit(1419859888.103:2): enforcing=3D1
old_enforcing=3D0 auid=3D4294967295 ses=3D4294967295
:[    3.657353] SELinux: 2048 avtab hash slots, 106409 rules.
:[    3.693846] SELinux: 2048 avtab hash slots, 106409 rules.
:[    3.751099] SELinux:  8 users, 86 roles, 4801 types, 280 bools, 1 sens,
1024 cats
:[    3.751107] SELinux:  83 classes, 106409 rules
:[    3.762442] SELinux:  Completing initialization.
:[    3.762449] SELinux:  Setting up existing superblocks.
:[    3.762461] SELinux: initialized (dev sysfs, type sysfs), uses
genfs_contexts
:[    3.762469] SELinux: initialized (dev rootfs, type rootfs), uses
genfs_contexts
:[    3.762483] SELinux: initialized (dev bdev, type bdev), uses
genfs_contexts
:[    3.762492] SELinux: initialized (dev proc, type proc), uses
genfs_contexts
:[    3.762552] SELinux: initialized (dev tmpfs, type tmpfs), uses
transition SIDs
:[    3.762616] SELinux: initialized (dev devtmpfs, type devtmpfs), uses
transition SIDs
:[    3.763983] SELinux: initialized (dev sockfs, type sockfs), uses task
SIDs
:[    3.763990] SELinux: initialized (dev debugfs, type debugfs), uses
genfs_contexts
:[    3.765541] SELinux: initialized (dev pipefs, type pipefs), uses task
SIDs
:[    3.765554] SELinux: initialized (dev anon_inodefs, type anon_inodefs),
uses genfs_contexts
:[    3.765558] SELinux: initialized (dev aio, type aio), not configured
for labeling
:[    3.765563] SELinux: initialized (dev devpts, type devpts), uses
transition SIDs
:[    3.765598] SELinux: initialized (dev hugetlbfs, type hugetlbfs), uses
transition SIDs
:[    3.765609] SELinux: initialized (dev mqueue, type mqueue), uses
transition SIDs
:[    3.765622] SELinux: initialized (dev selinuxfs, type selinuxfs), uses
genfs_contexts
:[    3.765640] SELinux: initialized (dev securityfs, type securityfs),
uses genfs_contexts
:[    3.765647] SELinux: initialized (dev sysfs, type sysfs), uses
genfs_contexts
:[    3.766188] SELinux: initialized (dev tmpfs, type tmpfs), uses
transition SIDs
:[    3.766206] SELinux: initialized (dev tmpfs, type tmpfs), uses
transition SIDs
:[    3.766397] SELinux: initialized (dev tmpfs, type tmpfs), uses
transition SIDs
:[    3.766463] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.766476] SELinux: initialized (dev pstore, type pstore), uses
genfs_contexts
:[    3.766480] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.766488] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.766496] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.766508] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.766514] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.766520] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.766526] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.766537] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.766543] SELinux: initialized (dev cgroup, type cgroup), uses
genfs_contexts
:[    3.766552] SELinux: initialized (dev configfs, type configfs), uses
genfs_contexts
:[    3.766561] SELinux: initialized (dev dm-1, type xfs), uses xattr
:[    3.778243] type=3D1403 audit(1419859888.530:3): policy loaded
auid=3D4294967295 ses=3D4294967295
:[    3.787849] systemd[1]: Successfully loaded SELinux policy in 462.134ms=
.
:[    3.920876] systemd[1]: RTC configured in localtime, applying delta of
240 minutes to system time.
:[    4.005427] systemd[1]: Relabelled /dev and /run in 39.980ms.
:[    5.710538] SELinux: initialized (dev autofs, type autofs), uses
genfs_contexts
:[    6.307749] systemd-journald[455]: Vacuuming done, freed 0 bytes
:[    7.178649] SELinux: initialized (dev hugetlbfs, type hugetlbfs), uses
transition SIDs
:[    7.351328] systemd-udevd[477]: starting version 208
:[    7.665816] shpchp: Standard Hot Plug PCI Controller Driver version: 0.=
4
:[    7.693874] ACPI Warning: SystemIO range
0x0000000000000428-0x000000000000042f conflicts with OpRegion
0x0000000000000400-0x000000000000047f (\PMIO) (20130517/utaddress-254)
:[    7.693888] ACPI: If an ACPI driver is available for this device, you
should use it instead of the native driver
:[    7.693894] ACPI Warning: SystemIO range
0x0000000000000530-0x000000000000053f conflicts with OpRegion
0x0000000000000500-0x0000000000000563 (\GPIO) (20130517/utaddress-254)
:[    7.693901] ACPI: If an ACPI driver is available for this device, you
should use it instead of the native driver
:[    7.693904] ACPI Warning: SystemIO range
0x0000000000000500-0x000000000000052f conflicts with OpRegion
0x0000000000000500-0x000000000000051f (\LED_) (20130517/utaddress-254)
:[    7.693910] ACPI Warning: SystemIO range
0x0000000000000500-0x000000000000052f conflicts with OpRegion
0x0000000000000500-0x0000000000000563 (\GPIO) (20130517/utaddress-254)
:[    7.693916] ACPI: If an ACPI driver is available for this device, you
should use it instead of the native driver
:[    7.693918] lpc_ich: Resource conflict(s) found affecting gpio_ich
:[    7.704394] parport_pc 00:0a: reported by Plug and Play ACPI
:[    7.704454] parport0: PC-style at 0x378, irq 5 [PCSPP,TRISTATE]
:[    7.750623] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
:[    7.750946] r8169 0000:01:00.0: irq 42 for MSI/MSI-X
:[    7.752251] r8169 0000:01:00.0 eth0: RTL8168evl/8111evl at
0xffffc90000c20000, 90:2b:34:db:46:be, XID 0c900800 IRQ 42
:[    7.752258] r8169 0000:01:00.0 eth0: jumbo features [frames: 9200
bytes, tx checksumming: ko]
:[    7.752290] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
:[    7.752609] r8169 0000:02:00.0: irq 43 for MSI/MSI-X
:[    7.752838] r8169 0000:02:00.0 eth1: RTL8168evl/8111evl at
0xffffc90000c2a000, 90:2b:34:db:46:ff, XID 0c900800 IRQ 43
:[    7.752843] r8169 0000:02:00.0 eth1: jumbo features [frames: 9200
bytes, tx checksumming: ko]
:[    7.752861] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
:[    7.753197] r8169 0000:04:00.0 (unregistered net_device): not PCI
Express
:[    7.753527] r8169 0000:04:00.0 eth2: RTL8169sb/8110sb at
0xffffc90004e34000, f0:7d:68:c1:fd:3f, XID 10000000 IRQ 18
:[    7.753532] r8169 0000:04:00.0 eth2: jumbo features [frames: 7152
bytes, tx checksumming: ok]
:[    7.954829] mei_me 0000:00:16.0: irq 44 for MSI/MSI-X
:[    8.350294] input: PC Speaker as /devices/platform/pcspkr/input/input3
:[    8.354836] ACPI Warning: SystemIO range
0x000000000000f040-0x000000000000f05f conflicts with OpRegion
0x000000000000f040-0x000000000000f04f (\_SB_.PCI0.SBUS.SMBI)
(20130517/utaddress-254)
:[    8.354850] ACPI: If an ACPI driver is available for this device, you
should use it instead of the native driver
:[    8.357773] iTCO_vendor_support: vendor-support=3D0
:[    8.359958] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
:[    8.360003] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled
by hardware/BIOS
:[    8.363647] ppdev: user-space parallel port driver
:[    8.494188] snd_hda_intel 0000:00:1b.0: irq 45 for MSI/MSI-X
:[    8.533553] input: HDA Intel PCH HDMI/DP,pcm=3D3 as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input4
:[    8.534515] input: HDA Intel PCH Front Headphone as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input5
:[    8.534898] input: HDA Intel PCH Line Out as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input6
:[    8.535066] input: HDA Intel PCH Line as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input7
:[    8.535258] input: HDA Intel PCH Front Mic as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input8
:[    8.535423] input: HDA Intel PCH Rear Mic as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input9
:[    8.848016] alg: No test for crc32 (crc32-pclmul)
:[    8.877913] kvm: disabled by bios
:[    8.885824] kvm: disabled by bios
:[    9.158360] systemd-udevd[493]: renamed network interface eth1 to enp2s=
0
:[    9.236390] systemd-udevd[485]: renamed network interface eth0 to enp1s=
0
:[    9.332624] systemd-udevd[497]: renamed network interface eth2 to enp4s=
0
:[    9.703544] XFS (sda1): Mounting Filesystem
:[    9.846652] XFS (dm-2): Mounting Filesystem
:[   10.278975] Adding 8142844k swap on /dev/mapper/centos_router-swap.
Priority:-1 extents:1 across:8142844k FS
:[   11.723634] XFS (dm-2): Ending clean mount
:[   11.723664] SELinux: initialized (dev dm-2, type xfs), uses xattr
:[   16.508880] XFS (sda1): Ending clean mount
:[   16.508914] SELinux: initialized (dev sda1, type xfs), uses xattr
:[   16.536304] systemd-journald[455]: Received request to flush runtime
journal from PID 1
:[   16.571284] type=3D1305 audit(1419845501.324:4): audit_pid=3D643 old=3D=
0
auid=3D4294967295 ses=3D4294967295 subj=3Dsystem_u:system_r:auditd_t:s0 res=
=3D1
:[   17.153653] sd 1:0:0:0: Attached scsi generic sg0 type 0
:[   17.507429] ip_tables: (C) 2000-2006 Netfilter Core Team
:[   17.660658] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
:[   17.691649] ip6_tables: (C) 2000-2006 Netfilter Core Team
:[   17.887724] Ebtables v2.0 registered
:[   17.941800] Bridge firewalling registered
:[   18.725996] r8169 0000:01:00.0 enp1s0: link down
:[   18.726023] r8169 0000:01:00.0 enp1s0: link down
:[   18.726063] IPv6: ADDRCONF(NETDEV_UP): enp1s0: link is not ready
:[   18.962890] r8169 0000:02:00.0 enp2s0: link down
:[   18.962907] r8169 0000:02:00.0 enp2s0: link down
:[   18.963901] IPv6: ADDRCONF(NETDEV_UP): enp2s0: link is not ready
:[   19.013741] r8169 0000:04:00.0 enp4s0: link down
:[   19.013767] r8169 0000:04:00.0 enp4s0: link down
:[   19.013807] IPv6: ADDRCONF(NETDEV_UP): enp4s0: link is not ready
:[   20.391340] r8169 0000:01:00.0 enp1s0: link up
:[   20.391356] IPv6: ADDRCONF(NETDEV_CHANGE): enp1s0: link becomes ready
:[   20.743693] PPP generic driver version 2.4.2
:[   21.965632] PPP BSD Compression module registered
:[   23.225499] r8169 0000:02:00.0 enp2s0: link up
:[   23.225520] IPv6: ADDRCONF(NETDEV_CHANGE): enp2s0: link becomes ready
:[   47.001413] r8169 0000:04:00.0 enp4s0: link up
:[   47.001433] IPv6: ADDRCONF(NETDEV_CHANGE): enp4s0: link becomes ready
:[ 5415.638681] perf samples too long (2508 > 2500), lowering
kernel.perf_event_max_sample_rate to 50000
:[11457.169428] perf samples too long (5017 > 5000), lowering
kernel.perf_event_max_sample_rate to 25000
:[191358.932922] systemd-journald[455]: Vacuuming done, freed 0 bytes
:[304423.181608] systemd-journald[455]: Vacuuming done, freed 0 bytes
:[391708.916322] systemd-journald[455]: Vacuuming done, freed 0 bytes
:[479912.211156] systemd-journald[455]: Vacuuming done, freed 0 bytes
:[505860.603691] systemd-journald[455]: Vacuuming done, freed 0 bytes
:[697679.203939] systemd-journald[455]: Vacuuming done, freed 0 bytes
:[743074.307891] systemd-journald[455]: Vacuuming done, freed 0 bytes
:[755870.448830] systemd-journald[455]: Vacuuming done, freed 0 bytes
:[887001.227339] systemd-journald[455]: Vacuuming done, freed 0 bytes
:[948156.740769] systemd-journald[455]: Vacuuming done, freed 0 bytes
:[1009037.886161] systemd-journald[455]: Vacuuming done, freed 41943040
bytes
:[1107167.047526] systemd-journald[455]: Vacuuming done, freed 41943040
bytes
:[1187677.314504] systemd-journald[455]: Vacuuming done, freed 41943040
bytes
:[1221396.417323] systemd-journald[455]: Vacuuming done, freed 33554432
bytes
:[1274328.202842] systemd-journald[455]: Vacuuming done, freed 41943040
bytes
:[1383365.061849] systemd-journald[455]: Vacuuming done, freed 41943040
bytes
:[1458028.242405] systemd-journald[455]: Vacuuming done, freed 33554432
bytes
:[1486997.501736] systemd-journald[455]: Vacuuming done, freed 33554432
bytes
:[1520487.522344] systemd-journald[455]: Vacuuming done, freed 33554432
bytes
:[1603068.878693] systemd-journald[455]: Vacuuming done, freed 33554432
bytes
:[1624069.808694] systemd-journald[455]: Vacuuming done, freed 41943040
bytes
:[1697147.165742] systemd-journald[455]: Vacuuming done, freed 41943040
bytes
:[1764124.987955] systemd-journald[455]: Vacuuming done, freed 41943040
bytes
:[1786445.984889] systemd-journald[455]: Vacuuming done, freed 41943040
bytes
:[1830870.711673] systemd-journald[455]: Vacuuming done, freed 41943040
bytes
:[1907546.639638] systemd-udevd[18049]: starting version 208
:[1907702.391382] SELinux: 2048 avtab hash slots, 100245 rules.
:[1907702.436586] SELinux: 2048 avtab hash slots, 100245 rules.
:[1907702.519654] SELinux:  8 users, 86 roles, 4818 types, 285 bools, 1
sens, 1024 cats
:[1907702.519664] SELinux:  83 classes, 100245 rules
:[1907702.737102] SELinux:  Context
unconfined_u:unconfined_r:sandbox_t:s0-s0:c0.c1023 became invalid
(unmapped).
:[1907703.614224] SELinux:  Context
system_u:unconfined_r:sandbox_t:s0-s0:c0.c1023 became invalid (unmapped).
:[1912396.914381] systemd-journald[455]: Vacuuming done, freed 41943040
bytes
:[2029686.408895] systemd-journald[455]: Vacuuming done, freed 41943040
bytes
:[2098191.398350] systemd-journald[455]: Vacuuming done, freed 33554432
bytes
:[2158269.202916] systemd-journald[455]: Vacuuming done, freed 33554432
bytes
:[2172179.878334] [sched_delayed] sched: RT throttling activated
:[2173411.070531] BUG: soft lockup - CPU#0 stuck for 21s! [rcuos/0:12]
:[2173411.070594] Modules linked in: bsd_comp nf_conntrack_netbios_ns
nf_conntrack_broadcast ppp_synctty ppp_async crc_ccitt ppp_generic slhc
xt_nat xt_mark ipt_MASQUERADE ip6t_rpfilter ip6t_REJECT ipt_REJECT
xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter
ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6
ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables
iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat
nf_conntrack iptable_mangle iptable_security iptable_raw iptable_filter
ip_tables sg coretemp kvm crct10dif_pclmul crc32_pclmul snd_hda_codec_hdmi
snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel snd_hda_codec
serio_raw crc32c_intel snd_hwdep snd_seq snd_seq_device snd_pcm ppdev
iTCO_wdt iTCO_vendor_support i2c_i801 pcspkr
:[2173411.070664]  ghash_clmulni_intel snd_page_alloc cryptd mei_me mei
snd_timer snd soundcore r8169 mii parport_pc parport lpc_ich mfd_core
shpchp mperf xfs libcrc32c sd_mod crc_t10dif crct10dif_common ata_generic
pata_acpi i915 ahci i2c_algo_bit pata_jmicron libahci drm_kms_helper libata
drm i2c_core video dm_mirror dm_region_hash dm_log dm_mod
:[2173411.070706] CPU: 0 PID: 12 Comm: rcuos/0 Not tainted
3.10.0-123.el7.x86_64 #1
:[2173411.070709] Hardware name: Gigabyte Technology Co., Ltd. To be filled
by O.E.M./C847N, BIOS F2 11/09/2012
:[2173411.070714] task: ffff880213970000 ti: ffff88021396e000 task.ti:
ffff88021396e000
:[2173411.070717] RIP: 0010:[<ffffffffa04addf1>]  [<ffffffffa04addf1>]
nf_conntrack_tuple_taken+0x91/0x1a0 [nf_conntrack]
:[2173411.070733] RSP: 0018:ffff88021f203838  EFLAGS: 00000246
:[2173411.070736] RAX: ffff8801fc8753e8 RBX: ffff88021f2037b8 RCX:
0000000000000000
:[2173411.070739] RDX: 0000000000000001 RSI: 00000000a7cd4ec5 RDI:
ffff8800ca2e7000
:[2173411.070742] RBP: ffff88021f203860 R08: 000000009b52ef62 R09:
00000000ae0c5d8d
:[2173411.070745] R10: ffff88021f203888 R11: ffff880212522000 R12:
ffff88021f2037a8
:[2173411.070747] R13: ffffffff815f2d9d R14: ffff88021f203860 R15:
ffff88021f203870
:[2173411.070751] FS:  0000000000000000(0000) GS:ffff88021f200000(0000)
knlGS:0000000000000000
:[2173411.070754] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
:[2173411.070757] CR2: 00007f0e9ceed000 CR3: 00000002116ad000 CR4:
00000000000407f0
:[2173411.070760] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
:[2173411.070763] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
:[2173411.070766] Stack:
:[2173411.070768]  ffff8800cc67e9c0 ffff88021f2039e0 ffff88021f203a70
000000000000c16d
:[2173411.070774]  000000000000c2c1 ffff88021f2038a8 ffffffffa04d4198
000000000601a8c0
:[2173411.070778]  0000000000000000 0101a8c00002d59d 0000000000000000
0106c1c600000000
:[2173411.070783] Call Trace:
:[2173411.070787]  <IRQ>
:
:[2173411.070798]  [<ffffffffa04d4198>] nf_nat_used_tuple+0x38/0x60 [nf_nat=
]
:[2173411.070806]  [<ffffffffa04d55cc>]
nf_nat_l4proto_unique_tuple+0xcc/0x170 [nf_nat]
:[2173411.070816]  [<ffffffffa04d57a5>] tcp_unique_tuple+0x15/0x20 [nf_nat]
:[2173411.070823]  [<ffffffffa04d4aa9>] get_unique_tuple+0x219/0x660
[nf_nat]
:[2173411.070833]  [<ffffffffa04d4f96>] nf_nat_setup_info+0xa6/0x3a0
[nf_nat]
:[2173411.070845]  [<ffffffffa04ad7ac>] ? nf_ct_invert_tuple+0x6c/0x80
[nf_conntrack]
:[2173411.070851]  [<ffffffffa057d1b8>] masquerade_tg+0xf8/0x140
[ipt_MASQUERADE]
:[2173411.070861]  [<ffffffffa04a30b3>] ipt_do_table+0x2d3/0x6d1 [ip_tables=
]
:[2173411.070868]  [<ffffffffa04a3107>] ? ipt_do_table+0x327/0x6d1
[ip_tables]
:[2173411.070877]  [<ffffffffa04e01d7>] nf_nat_ipv4_fn+0x1d7/0x320
[iptable_nat]
:[2173411.070884]  [<ffffffff8150da30>] ? ip_fragment+0x870/0x870
:[2173411.070889]  [<ffffffff8150da30>] ? ip_fragment+0x870/0x870
:[2173411.070896]  [<ffffffffa04e04f8>] nf_nat_ipv4_out+0x48/0xf0
[iptable_nat]
:[2173411.070900]  [<ffffffff8150da30>] ? ip_fragment+0x870/0x870
:[2173411.070906]  [<ffffffff815003ca>] nf_iterate+0xaa/0xc0
:[2173411.070912]  [<ffffffff8150da30>] ? ip_fragment+0x870/0x870
:[2173411.070917]  [<ffffffff81500464>] nf_hook_slow+0x84/0x140
:[2173411.070921]  [<ffffffff8150da30>] ? ip_fragment+0x870/0x870
:[2173411.070927]  [<ffffffff8150f162>] ip_output+0x82/0x90
:[2173411.070932]  [<ffffffff8150b09b>] ip_forward_finish+0x8b/0x170
:[2173411.070936]  [<ffffffff8150b4d5>] ip_forward+0x355/0x400
:[2173411.070941]  [<ffffffff815091fd>] ip_rcv_finish+0x7d/0x350
:[2173411.070945]  [<ffffffff81509ac4>] ip_rcv+0x234/0x380
:[2173411.070952]  [<ffffffff814cfdb6>] __netif_receive_skb_core+0x676/0x87=
0
:[2173411.070957]  [<ffffffff814cffc8>] __netif_receive_skb+0x18/0x60
:[2173411.070962]  [<ffffffff814d0b7e>] process_backlog+0xae/0x180
:[2173411.070967]  [<ffffffff814d041a>] net_rx_action+0x15a/0x250
:[2173411.070974]  [<ffffffff81067047>] __do_softirq+0xf7/0x290
:[2173411.070980]  [<ffffffff815f3a5c>] call_softirq+0x1c/0x30
:[2173411.070982]  <EOI>
:
:[2173411.070990]  [<ffffffff81014d25>] do_softirq+0x55/0x90
:[2173411.070995]  [<ffffffff81066b44>] local_bh_enable+0x94/0xa0
:[2173411.071004]  [<ffffffff810fee05>] rcu_nocb_kthread+0x255/0x370
:[2173411.071010]  [<ffffffff81086ab0>] ? wake_up_bit+0x30/0x30
:[2173411.071017]  [<ffffffff810febb0>] ? rcu_start_gp+0x40/0x40
:[2173411.071022]  [<ffffffff81085aef>] kthread+0xcf/0xe0
:[2173411.071027]  [<ffffffff81085a20>] ? kthread_create_on_node+0x140/0x14=
0
:[2173411.071032]  [<ffffffff815f206c>] ret_from_fork+0x7c/0xb0
:[2173411.071037]  [<ffffffff81085a20>] ? kthread_create_on_node+0x140/0x14=
0
:[2173411.071039] Code: 48 8b 00 a8 01 74 20 e9 ee 00 00 00 66 0f 1f 44 00
00 49 8b 95 28 0a 00 00 65 ff 02 48 8b 00 a8 01 0f 85 d3 00 00 00 0f b6 50
37 <48> 89 c7 48 8d 0c d5 00 00 00 00 48 c1 e2 06 48 29 ca 48 83 c2

os_info:
:NAME=3D"CentOS Linux"
:VERSION=3D"7 (Core)"
:ID=3D"centos"
:ID_LIKE=3D"rhel fedora"
:VERSION_ID=3D"7"
:PRETTY_NAME=3D"CentOS Linux 7 (Core)"
:ANSI_COLOR=3D"0;31"
:CPE_NAME=3D"cpe:/o:centos:centos:7"
:HOME_URL=3D"https://www.centos.org/"
:BUG_REPORT_URL=3D"https://bugs.centos.org/"
:

proc_modules:
:bsd_comp 12921 0 - Live 0xffffffffa05b5000
:nf_conntrack_netbios_ns 12665 0 - Live 0xffffffffa05b0000
:nf_conntrack_broadcast 12589 1 nf_conntrack_netbios_ns, Live
0xffffffffa05ab000
:ppp_synctty 13237 0 - Live 0xffffffffa059b000
:ppp_async 17413 1 - Live 0xffffffffa05a5000
:crc_ccitt 12707 1 ppp_async, Live 0xffffffffa05a0000
:ppp_generic 33037 7 bsd_comp,ppp_synctty,ppp_async, Live 0xffffffffa059100=
0
:slhc 13450 1 ppp_generic, Live 0xffffffffa058c000
:xt_nat 12681 39 - Live 0xffffffffa0587000
:xt_mark 12563 66 - Live 0xffffffffa0582000
:ipt_MASQUERADE 12880 3 - Live 0xffffffffa057d000
:ip6t_rpfilter 12546 1 - Live 0xffffffffa0578000
:ip6t_REJECT 12939 2 - Live 0xffffffffa0573000
:ipt_REJECT 12541 2 - Live 0xffffffffa056e000
:xt_conntrack 12760 41 - Live 0xffffffffa0564000
:ebtable_nat 12807 0 - Live 0xffffffffa055f000
:ebtable_broute 12731 0 - Live 0xffffffffa0569000
:bridge 110196 1 ebtable_broute, Live 0xffffffffa0543000
:stp 12976 1 bridge, Live 0xffffffffa053e000
:llc 14552 2 bridge,stp, Live 0xffffffffa0535000
:ebtable_filter 12827 0 - Live 0xffffffffa0530000
:ebtables 30913 3 ebtable_nat,ebtable_broute,ebtable_filter, Live
0xffffffffa0523000
:ip6table_nat 13015 1 - Live 0xffffffffa051e000
:nf_conntrack_ipv6 18738 11 - Live 0xffffffffa0518000
:nf_defrag_ipv6 34651 1 nf_conntrack_ipv6, Live 0xffffffffa050a000
:nf_nat_ipv6 13279 1 ip6table_nat, Live 0xffffffffa0505000
:ip6table_mangle 12700 1 - Live 0xffffffffa0500000
:ip6table_security 12710 1 - Live 0xffffffffa04fb000
:ip6table_raw 12683 1 - Live 0xffffffffa04f6000
:ip6table_filter 12815 1 - Live 0xffffffffa04f1000
:ip6_tables 27025 5
ip6table_nat,ip6table_mangle,ip6table_security,ip6table_raw,ip6table_filter=
,
Live 0xffffffffa04e5000
:iptable_nat 13011 1 - Live 0xffffffffa04e0000
:nf_conntrack_ipv4 14862 32 - Live 0xffffffffa04db000
:nf_defrag_ipv4 12729 1 nf_conntrack_ipv4, Live 0xffffffffa04cc000
:nf_nat_ipv4 13263 1 iptable_nat, Live 0xffffffffa04c7000
:nf_nat 21798 6
xt_nat,ipt_MASQUERADE,ip6table_nat,nf_nat_ipv6,iptable_nat,nf_nat_ipv4,
Live 0xffffffffa04d4000
:nf_conntrack 101024 11
nf_conntrack_netbios_ns,nf_conntrack_broadcast,ipt_MASQUERADE,xt_conntrack,=
ip6table_nat,nf_conntrack_ipv6,nf_nat_ipv6,iptable_nat,nf_conntrack_ipv4,nf=
_nat_ipv4,nf_nat,
Live 0xffffffffa04ad000
:iptable_mangle 12695 1 - Live 0xffffffffa04a8000
:iptable_security 12705 1 - Live 0xffffffffa049b000
:iptable_raw 12678 1 - Live 0xffffffffa048b000
:iptable_filter 12810 1 - Live 0xffffffffa0419000
:ip_tables 27239 5
iptable_nat,iptable_mangle,iptable_security,iptable_raw,iptable_filter,
Live 0xffffffffa04a0000
:sg 36533 0 - Live 0xffffffffa0491000
:coretemp 13435 0 - Live 0xffffffffa03b0000
:kvm 441119 0 - Live 0xffffffffa041e000
:crct10dif_pclmul 14289 0 - Live 0xffffffffa03f2000
:crc32_pclmul 13113 0 - Live 0xffffffffa03bb000
:snd_hda_codec_hdmi 46433 1 - Live 0xffffffffa040c000
:snd_hda_codec_realtek 57226 1 - Live 0xffffffffa03e3000
:snd_hda_codec_generic 68082 1 snd_hda_codec_realtek, Live
0xffffffffa03fa000
:snd_hda_intel 48259 0 - Live 0xffffffffa03a3000
:snd_hda_codec 137343 4
snd_hda_codec_hdmi,snd_hda_codec_realtek,snd_hda_codec_generic,snd_hda_inte=
l,
Live 0xffffffffa03c0000
:serio_raw 13462 0 - Live 0xffffffffa03b6000
:crc32c_intel 22079 0 - Live 0xffffffffa0397000
:snd_hwdep 13602 1 snd_hda_codec, Live 0xffffffffa039e000
:snd_seq 61519 0 - Live 0xffffffffa0386000
:snd_seq_device 14497 1 snd_seq, Live 0xffffffffa033e000
:snd_pcm 97511 3 snd_hda_codec_hdmi,snd_hda_intel,snd_hda_codec, Live
0xffffffffa036d000
:ppdev 17671 0 - Live 0xffffffffa0367000
:iTCO_wdt 13480 0 - Live 0xffffffffa0362000
:iTCO_vendor_support 13718 1 iTCO_wdt, Live 0xffffffffa035a000
:i2c_i801 18135 0 - Live 0xffffffffa0350000
:pcspkr 12718 0 - Live 0xffffffffa0348000
:ghash_clmulni_intel 13259 0 - Live 0xffffffffa0343000
:snd_page_alloc 18710 2 snd_hda_intel,snd_pcm, Live 0xffffffffa0338000
:cryptd 20359 1 ghash_clmulni_intel, Live 0xffffffffa0332000
:mei_me 18568 0 - Live 0xffffffffa02f0000
:mei 77872 1 mei_me, Live 0xffffffffa031d000
:snd_timer 29482 2 snd_seq,snd_pcm, Live 0xffffffffa0136000
:snd 74645 10
snd_hda_codec_hdmi,snd_hda_codec_realtek,snd_hda_codec_generic,snd_hda_inte=
l,snd_hda_codec,snd_hwdep,snd_seq,snd_seq_device,snd_pcm,snd_timer,
Live 0xffffffffa0309000
:soundcore 15047 1 snd, Live 0xffffffffa0125000
:r8169 71677 0 - Live 0xffffffffa02f6000
:mii 13934 1 r8169, Live 0xffffffffa010a000
:parport_pc 28165 0 - Live 0xffffffffa02e8000
:parport 42348 2 ppdev,parport_pc, Live 0xffffffffa012a000
:lpc_ich 16977 0 - Live 0xffffffffa011f000
:mfd_core 13435 1 lpc_ich, Live 0xffffffffa010f000
:shpchp 37032 0 - Live 0xffffffffa0114000
:mperf 12667 0 - Live 0xffffffffa0100000
:xfs 914152 3 - Live 0xffffffffa0207000
:libcrc32c 12644 1 xfs, Live 0xffffffffa0105000
:sd_mod 45373 3 - Live 0xffffffffa00f3000
:crc_t10dif 12714 1 sd_mod, Live 0xffffffffa00b5000
:crct10dif_common 12595 2 crct10dif_pclmul,crc_t10dif, Live
0xffffffffa00b0000
:ata_generic 12910 0 - Live 0xffffffffa00ab000
:pata_acpi 13038 0 - Live 0xffffffffa004f000
:i915 710975 1 - Live 0xffffffffa0158000
:ahci 25819 2 - Live 0xffffffffa00a0000
:i2c_algo_bit 13413 1 i915, Live 0xffffffffa0022000
:pata_jmicron 12758 0 - Live 0xffffffffa003e000
:libahci 32009 1 ahci, Live 0xffffffffa014f000
:drm_kms_helper 52758 1 i915, Live 0xffffffffa0141000
:libata 219478 5 ata_generic,pata_acpi,ahci,pata_jmicron,libahci, Live
0xffffffffa00bc000

----------
From:  <user@localhost.centos>
Date: 2015-02-02 3:24 GMT+03:00
To: root@localhost.centos


abrt_version:   2.1.11
cmdline:        BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el7.x86_64
root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro rd.lvm.lv=3Dcentos_ro=
uter/swap
vconsole.font=3Dlatarcyrheb-sun16 rd.lvm.lv=3Dcentos_router/root
crashkernel=3Dauto vconsole.keymap=3Dus rhgb quiet LANG=3Den_US.UTF-8
hostname:       router.centos
kernel:         3.10.0-123.el7.x86_64
last_occurrence: 1422836636

----------
From:  <user@localhost.centos>
Date: 2015-02-02 6:05 GMT+03:00
To: root@localhost.centos


abrt_version:   2.1.11
cmdline:        BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el7.x86_64
root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro rd.lvm.lv=3Dcentos_ro=
uter/swap
vconsole.font=3Dlatarcyrheb-sun16 rd.lvm.lv=3Dcentos_router/root
crashkernel=3Dauto vconsole.keymap=3Dus rhgb quiet LANG=3Den_US.UTF-8
hostname:       router.centos
kernel:         3.10.0-123.el7.x86_64
last_occurrence: 1422846288

----------
From:  <user@localhost.centos>
Date: 2015-02-02 7:28 GMT+03:00
To: root@localhost.centos


abrt_version:   2.1.11
cmdline:        BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el7.x86_64
root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro rd.lvm.lv=3Dcentos_ro=
uter/swap
vconsole.font=3Dlatarcyrheb-sun16 rd.lvm.lv=3Dcentos_router/root
crashkernel=3Dauto vconsole.keymap=3Dus rhgb quiet LANG=3Den_US.UTF-8
hostname:       router.centos
kernel:         3.10.0-123.el7.x86_64
last_occurrence: 1422851292

----------
From:  <user@localhost.centos>
Date: 2015-02-02 8:11 GMT+03:00
To: root@localhost.centos


abrt_version:   2.1.11
cmdline:        BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el7.x86_64
root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro rd.lvm.lv=3Dcentos_ro=
uter/swap
vconsole.font=3Dlatarcyrheb-sun16 rd.lvm.lv=3Dcentos_router/root
crashkernel=3Dauto vconsole.keymap=3Dus rhgb quiet LANG=3Den_US.UTF-8
hostname:       router.centos
kernel:         3.10.0-123.el7.x86_64
last_occurrence: 1422853850




--=20
=D0=A1 =D1=83=D0=B2=D0=B0=D0=B6=D0=B5=D0=BD=D0=B8=D0=B5=D0=BC =D0=A8=D0=B5=
=D0=B2=D1=87=D0=B5=D0=BD=D0=BA=D0=BE =D0=98=D0=B3=D0=BE=D1=80=D1=8C.
mailto://valens254@gmail.com

--047d7bfcf662596bda050e1547c4
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_quote"><span style=3D"font-size:la=
rge;font-weight:bold">Forwarded conversation</span><br>Subject: <b class=3D=
"gmail_sendername">[abrt] full crash report</b><br>------------------------=
<br><br><span class=3D"undefined"><font color=3D"#888">From: <b class=3D"un=
defined"></b> <span dir=3D"ltr">&lt;user@localhost.centos&gt;</span><br>Dat=
e: 2015-02-02 0:33 GMT+03:00<br>To: root@localhost.centos<br></font><br></s=
pan><br>abrt_version:=C2=A0 =C2=A02.1.11<br>
cmdline:=C2=A0 =C2=A0 =C2=A0 =C2=A0 BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el7.x8=
6_64 root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro <a href=3D"http:=
//rd.lvm.lv" target=3D"_blank">rd.lvm.lv</a>=3Dcentos_router/swap vconsole.=
font=3Dlatarcyrheb-sun16 <a href=3D"http://rd.lvm.lv" target=3D"_blank">rd.=
lvm.lv</a>=3Dcentos_router/root crashkernel=3Dauto vconsole.keymap=3Dus rhg=
b quiet LANG=3Den_US.UTF-8<br>
hostname:=C2=A0 =C2=A0 =C2=A0 =C2=A0router.centos<br>
kernel:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03.10.0-123.el7.x86_64<br>
last_occurrence: 1422826385<br>
pkg_arch:=C2=A0 =C2=A0 =C2=A0 =C2=A0x86_64<br>
pkg_epoch:=C2=A0 =C2=A0 =C2=A0 0<br>
pkg_name:=C2=A0 =C2=A0 =C2=A0 =C2=A0kernel<br>
pkg_release:=C2=A0 =C2=A0 123.el7<br>
pkg_version:=C2=A0 =C2=A0 3.10.0<br>
runlevel:=C2=A0 =C2=A0 =C2=A0 =C2=A0N 3<br>
time:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Fri 12 Dec 2014 10:06:55 AM M=
SK<br>
<br>
sosreport.tar.xz: Binary file, 6994408 bytes<br>
<br>
backtrace:<br>
:WARNING: at net/sched/sch_generic.c:259 dev_watchdog+0x270/0x280()<br>
:NETDEV WATCHDOG: enp4s0 (r8169): transmit queue 0 timed out<br>
:Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast xt_nat x=
t_mark ipt_MASQUERADE ip6t_rpfilter ip6table_nat nf_nat_ipv6 ip6table_mangl=
e ip6table_security ip6table_raw ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ip=
v6 ip6table_filter ip6_tables iptable_nat nf_nat_ipv4 nf_nat iptable_mangle=
 iptable_security iptable_raw ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 x=
t_conntrack nf_conntrack iptable_filter ip_tables tcp_diag inet_diag bsd_co=
mp ppp_synctty ppp_async crc_ccitt ppp_generic slhc bridge stp llc sg coret=
emp kvm serio_raw crct10dif_pclmul iTCO_wdt iTCO_vendor_support ppdev crc32=
_pclmul pcspkr i2c_i801 crc32c_intel snd_hda_codec_hdmi snd_hda_codec_realt=
ek snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_=
seq_device ghash_clmulni_intel snd_pcm snd_page_alloc<br>
:snd_timer snd soundcore mei_me mei cryptd r8169 mii lpc_ich mfd_core shpch=
p parport_pc parport mperf xfs libcrc32c sd_mod crc_t10dif crct10dif_common=
 ata_generic pata_acpi ahci pata_jmicron i915 libahci libata i2c_algo_bit d=
rm_kms_helper drm i2c_core video dm_mirror dm_region_hash dm_log dm_mod [la=
st unloaded: ip_tables]<br>
:CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.10.0-123.el7.x86_64 #1<br>
:Hardware name: Gigabyte Technology Co., Ltd. To be filled by O.E.M./C847N,=
 BIOS F2 11/09/2012<br>
:ffff88021f303d90 eeb6307312c80fd5 ffff88021f303d48 ffffffff815e19ba<br>
:ffff88021f303d80 ffffffff8105dee1 0000000000000000 ffff880212550000<br>
:ffff88021139f280 0000000000000001 0000000000000001 ffff88021f303de8<br>
:Call Trace:<br>
:&lt;IRQ&gt;=C2=A0 [&lt;ffffffff815e19ba&gt;] dump_stack+0x19/0x1b<br>
:[&lt;ffffffff8105dee1&gt;] warn_slowpath_common+0x61/0x80<br>
:[&lt;ffffffff8105df5c&gt;] warn_slowpath_fmt+0x5c/0x80<br>
:[&lt;ffffffff81088671&gt;] ? run_posix_cpu_timers+0x51/0x840<br>
:[&lt;ffffffff814f0ab0&gt;] dev_watchdog+0x270/0x280<br>
:[&lt;ffffffff814f0840&gt;] ? dev_graft_qdisc+0x80/0x80<br>
:[&lt;ffffffff8106d236&gt;] call_timer_fn+0x36/0x110<br>
:[&lt;ffffffff814f0840&gt;] ? dev_graft_qdisc+0x80/0x80<br>
:[&lt;ffffffff8106f2ff&gt;] run_timer_softirq+0x21f/0x320<br>
:[&lt;ffffffff81067047&gt;] __do_softirq+0xf7/0x290<br>
:[&lt;ffffffff815f3a5c&gt;] call_softirq+0x1c/0x30<br>
:[&lt;ffffffff81014d25&gt;] do_softirq+0x55/0x90<br>
:[&lt;ffffffff810673e5&gt;] irq_exit+0x115/0x120<br>
:[&lt;ffffffff815f4435&gt;] smp_apic_timer_interrupt+0x45/0x60<br>
:[&lt;ffffffff815f2d9d&gt;] apic_timer_interrupt+0x6d/0x80<br>
:&lt;EOI&gt;=C2=A0 [&lt;ffffffff814834df&gt;] ? cpuidle_enter_state+0x4f/0x=
c0<br>
:[&lt;ffffffff81483615&gt;] cpuidle_idle_call+0xc5/0x200<br>
:[&lt;ffffffff8101bc7e&gt;] arch_cpu_idle+0xe/0x30<br>
:[&lt;ffffffff810b4725&gt;] cpu_startup_entry+0xf5/0x290<br>
:[&lt;ffffffff815cfee1&gt;] start_secondary+0x265/0x27b<br>
<br>
dmesg:<br>
:[=C2=A0 =C2=A0 0.000000] CPU0 microcode updated early to revision 0x29, da=
te =3D 2013-06-12<br>
:[=C2=A0 =C2=A0 0.000000] Initializing cgroup subsys cpuset<br>
:[=C2=A0 =C2=A0 0.000000] Initializing cgroup subsys cpu<br>
:[=C2=A0 =C2=A0 0.000000] Initializing cgroup subsys cpuacct<br>
:[=C2=A0 =C2=A0 0.000000] Linux version 3.10.0-123.el7.x86_64 (<a href=3D"m=
ailto:builder@kbuilder.dev.centos.org">builder@kbuilder.dev.centos.org</a>)=
 (gcc version 4.8.2 20140120 (Red Hat 4.8.2-16) (GCC) ) #1 SMP Mon Jun 30 1=
2:09:22 UTC 2014<br>
:[=C2=A0 =C2=A0 0.000000] Command line: BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el=
7.x86_64 root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro <a href=3D"h=
ttp://rd.lvm.lv" target=3D"_blank">rd.lvm.lv</a>=3Dcentos_router/swap vcons=
ole.font=3Dlatarcyrheb-sun16 <a href=3D"http://rd.lvm.lv" target=3D"_blank"=
>rd.lvm.lv</a>=3Dcentos_router/root crashkernel=3Dauto vconsole.keymap=3Dus=
 rhgb quiet LANG=3Den_US.UTF-8<br>
:[=C2=A0 =C2=A0 0.000000] e820: BIOS-provided physical RAM map:<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009=
d7ff] usable<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x000000000009d800-0x000000000009=
ffff] reserved<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000f=
ffff] reserved<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fff=
ffff] usable<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x0000000020000000-0x00000000201f=
ffff] reserved<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x0000000020200000-0x000000003fff=
ffff] usable<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x0000000040000000-0x00000000401f=
ffff] reserved<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x0000000040200000-0x00000000d94d=
1fff] usable<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000d94d2000-0x00000000d9a9=
4fff] reserved<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000d9a95000-0x00000000d9a9=
5fff] ACPI data<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000d9a96000-0x00000000d9bb=
afff] ACPI NVS<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000d9bbb000-0x00000000da6b=
8fff] reserved<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000da6b9000-0x00000000da6b=
9fff] usable<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000da6ba000-0x00000000da6f=
cfff] ACPI NVS<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000da6fd000-0x00000000dade=
efff] usable<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000dadef000-0x00000000dafe=
0fff] reserved<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000dafe1000-0x00000000daff=
ffff] usable<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000db800000-0x00000000df9f=
ffff] reserved<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbff=
ffff] reserved<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec0=
0fff] reserved<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed0=
3fff] reserved<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1=
ffff] reserved<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee0=
0fff] reserved<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffff=
ffff] reserved<br>
:[=C2=A0 =C2=A0 0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000021f5f=
ffff] usable<br>
:[=C2=A0 =C2=A0 0.000000] NX (Execute Disable) protection: active<br>
:[=C2=A0 =C2=A0 0.000000] SMBIOS 2.7 present.<br>
:[=C2=A0 =C2=A0 0.000000] DMI: Gigabyte Technology Co., Ltd. To be filled b=
y O.E.M./C847N, BIOS F2 11/09/2012<br>
:[=C2=A0 =C2=A0 0.000000] e820: update [mem 0x00000000-0x00000fff] usable =
=3D=3D&gt; reserved<br>
:[=C2=A0 =C2=A0 0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable<b=
r>
:[=C2=A0 =C2=A0 0.000000] No AGP bridge found<br>
:[=C2=A0 =C2=A0 0.000000] e820: last_pfn =3D 0x21f600 max_arch_pfn =3D 0x40=
0000000<br>
:[=C2=A0 =C2=A0 0.000000] MTRR default type: uncachable<br>
:[=C2=A0 =C2=A0 0.000000] MTRR fixed ranges enabled:<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A000000-9FFFF write-back<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0A0000-BFFFF uncachable<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0C0000-CFFFF write-protect<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0D0000-E7FFF uncachable<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0E8000-FFFFF write-protect<br>
:[=C2=A0 =C2=A0 0.000000] MTRR variable ranges enabled:<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A00 base 000000000 mask E00000000 write=
-back<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A01 base 200000000 mask FE0000000 write=
-back<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A02 base 0E0000000 mask FE0000000 uncac=
hable<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A03 base 0DC000000 mask FFC000000 uncac=
hable<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A04 base 0DB800000 mask FFF800000 uncac=
hable<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A05 base 21F800000 mask FFF800000 uncac=
hable<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A06 base 21F600000 mask FFFE00000 uncac=
hable<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A07 disabled<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A08 disabled<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A09 disabled<br>
:[=C2=A0 =C2=A0 0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new =
0x7010600070106<br>
:[=C2=A0 =C2=A0 0.000000] original variable MTRRs<br>
:[=C2=A0 =C2=A0 0.000000] reg 0, base: 0GB, range: 8GB, type WB<br>
:[=C2=A0 =C2=A0 0.000000] reg 1, base: 8GB, range: 512MB, type WB<br>
:[=C2=A0 =C2=A0 0.000000] reg 2, base: 3584MB, range: 512MB, type UC<br>
:[=C2=A0 =C2=A0 0.000000] reg 3, base: 3520MB, range: 64MB, type UC<br>
:[=C2=A0 =C2=A0 0.000000] reg 4, base: 3512MB, range: 8MB, type UC<br>
:[=C2=A0 =C2=A0 0.000000] reg 5, base: 8696MB, range: 8MB, type UC<br>
:[=C2=A0 =C2=A0 0.000000] reg 6, base: 8694MB, range: 2MB, type UC<br>
:[=C2=A0 =C2=A0 0.000000] total RAM covered: 8110M<br>
:[=C2=A0 =C2=A0 0.000000] Found optimal setting for mtrr clean up<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 gran_size: 64K=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0chunk_size: 128M=C2=A0 =C2=A0 =C2=A0 =C2=A0 num_reg: 9=C2=A0 =C2=A0 =
=C2=A0 lose cover RAM: 0G<br>
:[=C2=A0 =C2=A0 0.000000] New variable MTRRs<br>
:[=C2=A0 =C2=A0 0.000000] reg 0, base: 0GB, range: 2GB, type WB<br>
:[=C2=A0 =C2=A0 0.000000] reg 1, base: 2GB, range: 1GB, type WB<br>
:[=C2=A0 =C2=A0 0.000000] reg 2, base: 3GB, range: 512MB, type WB<br>
:[=C2=A0 =C2=A0 0.000000] reg 3, base: 3512MB, range: 8MB, type UC<br>
:[=C2=A0 =C2=A0 0.000000] reg 4, base: 3520MB, range: 64MB, type UC<br>
:[=C2=A0 =C2=A0 0.000000] reg 5, base: 4GB, range: 4GB, type WB<br>
:[=C2=A0 =C2=A0 0.000000] reg 6, base: 8GB, range: 512MB, type WB<br>
:[=C2=A0 =C2=A0 0.000000] reg 7, base: 8694MB, range: 2MB, type UC<br>
:[=C2=A0 =C2=A0 0.000000] reg 8, base: 8696MB, range: 8MB, type UC<br>
:[=C2=A0 =C2=A0 0.000000] e820: update [mem 0xdb800000-0xffffffff] usable =
=3D=3D&gt; reserved<br>
:[=C2=A0 =C2=A0 0.000000] e820: last_pfn =3D 0xdb000 max_arch_pfn =3D 0x400=
000000<br>
:[=C2=A0 =C2=A0 0.000000] found SMP MP-table at [mem 0x000fd760-0x000fd76f]=
 mapped at [ffff8800000fd760]<br>
:[=C2=A0 =C2=A0 0.000000] Base memory trampoline at [ffff880000097000] 9700=
0 size 24576<br>
:[=C2=A0 =C2=A0 0.000000] reserving inaccessible SNB gfx pages<br>
:[=C2=A0 =C2=A0 0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]<=
br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0x00000000-0x000fffff] page 4k<br>
:[=C2=A0 =C2=A0 0.000000] BRK [0x01e1d000, 0x01e1dfff] PGTABLE<br>
:[=C2=A0 =C2=A0 0.000000] BRK [0x01e1e000, 0x01e1efff] PGTABLE<br>
:[=C2=A0 =C2=A0 0.000000] BRK [0x01e1f000, 0x01e1ffff] PGTABLE<br>
:[=C2=A0 =C2=A0 0.000000] init_memory_mapping: [mem 0x21f400000-0x21f5fffff=
]<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0x21f400000-0x21f5fffff] page 2M<br>
:[=C2=A0 =C2=A0 0.000000] BRK [0x01e20000, 0x01e20fff] PGTABLE<br>
:[=C2=A0 =C2=A0 0.000000] init_memory_mapping: [mem 0x21c000000-0x21f3fffff=
]<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0x21c000000-0x21f3fffff] page 2M<br>
:[=C2=A0 =C2=A0 0.000000] init_memory_mapping: [mem 0x200000000-0x21bffffff=
]<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0x200000000-0x21bffffff] page 2M<br>
:[=C2=A0 =C2=A0 0.000000] init_memory_mapping: [mem 0x00100000-0x1fffffff]<=
br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0x00100000-0x001fffff] page 4k<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0x00200000-0x1fffffff] page 2M<br>
:[=C2=A0 =C2=A0 0.000000] init_memory_mapping: [mem 0x20200000-0x3fffffff]<=
br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0x20200000-0x3fffffff] page 2M<br>
:[=C2=A0 =C2=A0 0.000000] init_memory_mapping: [mem 0x40200000-0xd94d1fff]<=
br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0x40200000-0xd93fffff] page 2M<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0xd9400000-0xd94d1fff] page 4k<br>
:[=C2=A0 =C2=A0 0.000000] BRK [0x01e21000, 0x01e21fff] PGTABLE<br>
:[=C2=A0 =C2=A0 0.000000] BRK [0x01e22000, 0x01e22fff] PGTABLE<br>
:[=C2=A0 =C2=A0 0.000000] init_memory_mapping: [mem 0xda6b9000-0xda6b9fff]<=
br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0xda6b9000-0xda6b9fff] page 4k<br>
:[=C2=A0 =C2=A0 0.000000] init_memory_mapping: [mem 0xda6fd000-0xdadeefff]<=
br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0xda6fd000-0xda7fffff] page 4k<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0xda800000-0xdabfffff] page 2M<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0xdac00000-0xdadeefff] page 4k<br>
:[=C2=A0 =C2=A0 0.000000] init_memory_mapping: [mem 0xdafe1000-0xdaffffff]<=
br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0xdafe1000-0xdaffffff] page 4k<br>
:[=C2=A0 =C2=A0 0.000000] init_memory_mapping: [mem 0x100000000-0x1ffffffff=
]<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [mem 0x100000000-0x1ffffffff] page 2M<br>
:[=C2=A0 =C2=A0 0.000000] RAMDISK: [mem 0x369a0000-0x374c7fff]<br>
:[=C2=A0 =C2=A0 0.000000] Reserving 161MB of memory at 704MB for crashkerne=
l (System RAM: 8077MB)<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: RSDP 00000000000f0490 00024 (v02 ALASKA)<br=
>
:[=C2=A0 =C2=A0 0.000000] ACPI: XSDT 00000000d9b9c070 00064 (v01 ALASKA=C2=
=A0 =C2=A0 A M I 01072009 AMI=C2=A0 00010013)<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: FACP 00000000d9ba6610 000F4 (v04 ALASKA=C2=
=A0 =C2=A0 A M I 01072009 AMI=C2=A0 00010013)<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: DSDT 00000000d9b9c170 0A49C (v02 ALASKA=C2=
=A0 =C2=A0 A M I 00000012 INTL 20051117)<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: FACS 00000000d9bb9f80 00040<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: APIC 00000000d9ba6708 00062 (v03 ALASKA=C2=
=A0 =C2=A0 A M I 01072009 AMI=C2=A0 00010013)<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: MCFG 00000000d9ba6770 0003C (v01=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A001072009 MSFT 00000097)=
<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: HPET 00000000d9ba67b0 00038 (v01 ALASKA=C2=
=A0 =C2=A0 A M I 01072009 AMI. 00000005)<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: SSDT 00000000d9ba67e8 0036D (v01 SataRe Sat=
aTabl 00001000 INTL 20091112)<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: SSDT 00000000d9ba6b58 00692 (v01=C2=A0 PmRe=
f=C2=A0 Cpu0Ist 00003000 INTL 20051117)<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: SSDT 00000000d9ba71f0 00A92 (v01=C2=A0 PmRe=
f=C2=A0 =C2=A0 CpuPm 00003000 INTL 20051117)<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: BGRT 00000000d9ba7c88 00038 (v00 ALASKA=C2=
=A0 =C2=A0 A M I 01072009 AMI=C2=A0 00010013)<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: Local APIC address 0xfee00000<br>
:[=C2=A0 =C2=A0 0.000000] No NUMA configuration found<br>
:[=C2=A0 =C2=A0 0.000000] Faking a node at [mem 0x0000000000000000-0x000000=
021f5fffff]<br>
:[=C2=A0 =C2=A0 0.000000] Initmem setup node 0 [mem 0x00000000-0x21f5fffff]=
<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0NODE_DATA [mem 0x21f5d0000-0x21f5f6ff=
f]<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 [ffffea0000000000-ffffea00087fffff] PMD -&g=
t; [ffff880216c00000-ffff88021ebfffff] on node 0<br>
:[=C2=A0 =C2=A0 0.000000] Zone ranges:<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0DMA=C2=A0 =C2=A0 =C2=A0 [mem 0x000010=
00-0x00ffffff]<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0DMA32=C2=A0 =C2=A0 [mem 0x01000000-0x=
ffffffff]<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0Normal=C2=A0 =C2=A0[mem 0x100000000-0=
x21f5fffff]<br>
:[=C2=A0 =C2=A0 0.000000] Movable zone start for each node<br>
:[=C2=A0 =C2=A0 0.000000] Early memory node ranges<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0node=C2=A0 =C2=A00: [mem 0x00001000-0=
x0009cfff]<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0node=C2=A0 =C2=A00: [mem 0x00100000-0=
x1fffffff]<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0node=C2=A0 =C2=A00: [mem 0x20200000-0=
x3fffffff]<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0node=C2=A0 =C2=A00: [mem 0x40200000-0=
xd94d1fff]<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0node=C2=A0 =C2=A00: [mem 0xda6b9000-0=
xda6b9fff]<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0node=C2=A0 =C2=A00: [mem 0xda6fd000-0=
xdadeefff]<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0node=C2=A0 =C2=A00: [mem 0xdafe1000-0=
xdaffffff]<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0node=C2=A0 =C2=A00: [mem 0x100000000-=
0x21f5fffff]<br>
:[=C2=A0 =C2=A0 0.000000] On node 0 totalpages: 2067840<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0DMA zone: 64 pages used for memmap<br=
>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0DMA zone: 156 pages reserved<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0DMA zone: 3996 pages, LIFO batch:0<br=
>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0DMA32 zone: 13856 pages used for memm=
ap<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0DMA32 zone: 886756 pages, LIFO batch:=
31<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0Normal zone: 18392 pages used for mem=
map<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0Normal zone: 1177088 pages, LIFO batc=
h:31<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: PM-Timer IO Port: 0x408<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: Local APIC address 0xfee00000<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled=
)<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled=
)<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1=
])<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_ba=
se[0])<br>
:[=C2=A0 =C2=A0 0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00=
000, GSI 0-23<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 d=
fl dfl)<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 h=
igh level)<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: IRQ0 used by override.<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: IRQ2 used by override.<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: IRQ9 used by override.<br>
:[=C2=A0 =C2=A0 0.000000] Using ACPI (MADT) for SMP configuration informati=
on<br>
:[=C2=A0 =C2=A0 0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000<br>
:[=C2=A0 =C2=A0 0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs<br>
:[=C2=A0 =C2=A0 0.000000] nr_irqs_gsi: 40<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0x0009d000-0x0=
009dfff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0=
009ffff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x0=
00dffff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x0=
00fffff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0x20000000-0x2=
01fffff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0x40000000-0x4=
01fffff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xd94d2000-0xd=
9a94fff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xd9a95000-0xd=
9a95fff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xd9a96000-0xd=
9bbafff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xd9bbb000-0xd=
a6b8fff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xda6ba000-0xd=
a6fcfff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xdadef000-0xd=
afe0fff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xdb000000-0xd=
b7fffff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xdb800000-0xd=
f9fffff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xdfa00000-0xf=
7ffffff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xf8000000-0xf=
bffffff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xfc000000-0xf=
ebfffff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xf=
ec00fff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xfec01000-0xf=
ecfffff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xfed00000-0xf=
ed03fff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xfed04000-0xf=
ed1bfff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xf=
ed1ffff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xf=
edfffff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xfee00000-0xf=
ee00fff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xfee01000-0xf=
effffff]<br>
:[=C2=A0 =C2=A0 0.000000] PM: Registered nosave memory: [mem 0xff000000-0xf=
fffffff]<br>
:[=C2=A0 =C2=A0 0.000000] e820: [mem 0xdfa00000-0xf7ffffff] available for P=
CI devices<br>
:[=C2=A0 =C2=A0 0.000000] Booting paravirtualized kernel on bare hardware<b=
r>
:[=C2=A0 =C2=A0 0.000000] setup_percpu: NR_CPUS:5120 nr_cpumask_bits:2 nr_c=
pu_ids:2 nr_node_ids:1<br>
:[=C2=A0 =C2=A0 0.000000] PERCPU: Embedded 29 pages/cpu @ffff88021f200000 s=
86592 r8192 d24000 u1048576<br>
:[=C2=A0 =C2=A0 0.000000] pcpu-alloc: s86592 r8192 d24000 u1048576 alloc=3D=
1*2097152<br>
:[=C2=A0 =C2=A0 0.000000] pcpu-alloc: [0] 0 1<br>
:[=C2=A0 =C2=A0 0.000000] Built 1 zonelists in Zone order, mobility groupin=
g on.=C2=A0 Total pages: 2035372<br>
:[=C2=A0 =C2=A0 0.000000] Policy zone: Normal<br>
:[=C2=A0 =C2=A0 0.000000] Kernel command line: BOOT_IMAGE=3D/vmlinuz-3.10.0=
-123.el7.x86_64 root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro <a hr=
ef=3D"http://rd.lvm.lv" target=3D"_blank">rd.lvm.lv</a>=3Dcentos_router/swa=
p vconsole.font=3Dlatarcyrheb-sun16 <a href=3D"http://rd.lvm.lv" target=3D"=
_blank">rd.lvm.lv</a>=3Dcentos_router/root crashkernel=3Dauto vconsole.keym=
ap=3Dus rhgb quiet LANG=3Den_US.UTF-8<br>
:[=C2=A0 =C2=A0 0.000000] PID hash table entries: 4096 (order: 3, 32768 byt=
es)<br>
:[=C2=A0 =C2=A0 0.000000] xsave: enabled xstate_bv 0x3, cntxt size 0x240<br=
>
:[=C2=A0 =C2=A0 0.000000] Checking aperture...<br>
:[=C2=A0 =C2=A0 0.000000] No AGP bridge found<br>
:[=C2=A0 =C2=A0 0.000000] Memory: 7882168k/8902656k available (6105k kernel=
 code, 631296k absent, 389192k reserved, 4065k data, 1584k init)<br>
:[=C2=A0 =C2=A0 0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, =
CPUs=3D2, Nodes=3D1<br>
:[=C2=A0 =C2=A0 0.000000] Hierarchical RCU implementation.<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0RCU restricting =
CPUs from NR_CPUS=3D5120 to nr_cpu_ids=3D2.<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Experimental no-=
CBs for all CPUs<br>
:[=C2=A0 =C2=A0 0.000000]=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Experimental no-=
CBs CPUs: 0-1.<br>
:[=C2=A0 =C2=A0 0.000000] NR_IRQS:327936 nr_irqs:512 16<br>
:[=C2=A0 =C2=A0 0.000000] Console: colour VGA+ 80x25<br>
:[=C2=A0 =C2=A0 0.000000] console [tty0] enabled<br>
:[=C2=A0 =C2=A0 0.000000] allocated 33554432 bytes of page_cgroup<br>
:[=C2=A0 =C2=A0 0.000000] please try &#39;cgroup_disable=3Dmemory&#39; opti=
on if you don&#39;t want memory cgroups<br>
:[=C2=A0 =C2=A0 0.000000] hpet clockevent registered<br>
:[=C2=A0 =C2=A0 0.000000] tsc: Fast TSC calibration using PIT<br>
:[=C2=A0 =C2=A0 0.002000] tsc: Detected 1097.537 MHz processor<br>
:[=C2=A0 =C2=A0 0.000004] Calibrating delay loop (skipped), value calculate=
d using timer frequency.. 2195.07 BogoMIPS (lpj=3D1097537)<br>
:[=C2=A0 =C2=A0 0.000009] pid_max: default: 32768 minimum: 301<br>
:[=C2=A0 =C2=A0 0.000048] Security Framework initialized<br>
:[=C2=A0 =C2=A0 0.000059] SELinux:=C2=A0 Initializing.<br>
:[=C2=A0 =C2=A0 0.000073] SELinux:=C2=A0 Starting in permissive mode<br>
:[=C2=A0 =C2=A0 0.001469] Dentry cache hash table entries: 1048576 (order: =
11, 8388608 bytes)<br>
:[=C2=A0 =C2=A0 0.005221] Inode-cache hash table entries: 524288 (order: 10=
, 4194304 bytes)<br>
:[=C2=A0 =C2=A0 0.006767] Mount-cache hash table entries: 4096<br>
:[=C2=A0 =C2=A0 0.007121] Initializing cgroup subsys memory<br>
:[=C2=A0 =C2=A0 0.007135] Initializing cgroup subsys devices<br>
:[=C2=A0 =C2=A0 0.007139] Initializing cgroup subsys freezer<br>
:[=C2=A0 =C2=A0 0.007141] Initializing cgroup subsys net_cls<br>
:[=C2=A0 =C2=A0 0.007144] Initializing cgroup subsys blkio<br>
:[=C2=A0 =C2=A0 0.007146] Initializing cgroup subsys perf_event<br>
:[=C2=A0 =C2=A0 0.007150] Initializing cgroup subsys hugetlb<br>
:[=C2=A0 =C2=A0 0.007194] CPU: Physical Processor ID: 0<br>
:[=C2=A0 =C2=A0 0.007197] CPU: Processor Core ID: 0<br>
:[=C2=A0 =C2=A0 0.007205] ENERGY_PERF_BIAS: Set to &#39;normal&#39;, was &#=
39;performance&#39;<br>
:ENERGY_PERF_BIAS: View and update with x86_energy_perf_policy(8)<br>
:[=C2=A0 =C2=A0 0.007211] mce: CPU supports 7 MCE banks<br>
:[=C2=A0 =C2=A0 0.007232] CPU0: Thermal monitoring enabled (TM1)<br>
:[=C2=A0 =C2=A0 0.007248] Last level iTLB entries: 4KB 512, 2MB 0, 4MB 0<br=
>
:Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32<br>
:tlb_flushall_shift: 6<br>
:[=C2=A0 =C2=A0 0.007425] Freeing SMP alternatives: 24k freed<br>
:[=C2=A0 =C2=A0 0.010435] ACPI: Core revision 20130517<br>
:[=C2=A0 =C2=A0 0.022190] ACPI: All ACPI Tables successfully acquired<br>
:[=C2=A0 =C2=A0 0.022419] ftrace: allocating 23383 entries in 92 pages<br>
:[=C2=A0 =C2=A0 0.047596] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=
=3D-1 pin2=3D-1<br>
:[=C2=A0 =C2=A0 0.057604] smpboot: CPU0: Intel(R) Celeron(R) CPU 847 @ 1.10=
GHz (fam: 06, model: 2a, stepping: 07)<br>
:[=C2=A0 =C2=A0 0.057618] TSC deadline timer enabled<br>
:[=C2=A0 =C2=A0 0.057636] Performance Events: PEBS fmt1+, 16-deep LBR, Sand=
yBridge events, full-width counters, Intel PMU driver.<br>
:[=C2=A0 =C2=A0 0.057651] ... version:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 3<br>
:[=C2=A0 =C2=A0 0.057654] ... bit width:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 48<br>
:[=C2=A0 =C2=A0 0.057656] ... generic registers:=C2=A0 =C2=A0 =C2=A0 8<br>
:[=C2=A0 =C2=A0 0.057658] ... value mask:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A00000ffffffffffff<br>
:[=C2=A0 =C2=A0 0.057661] ... max period:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A00000ffffffffffff<br>
:[=C2=A0 =C2=A0 0.057663] ... fixed-purpose events:=C2=A0 =C2=A03<br>
:[=C2=A0 =C2=A0 0.057665] ... event mask:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A000000007000000ff<br>
:[=C2=A0 =C2=A0 0.060083] smpboot: Booting Node=C2=A0 =C2=A00, Processors=
=C2=A0 #1 OK<br>
:[=C2=A0 =C2=A0 0.071147] CPU1 microcode updated early to revision 0x29, da=
te =3D 2013-06-12<br>
:[=C2=A0 =C2=A0 0.073360] Brought up 2 CPUs<br>
:[=C2=A0 =C2=A0 0.073367] smpboot: Total of 2 processors activated (4390.14=
 BogoMIPS)<br>
:[=C2=A0 =C2=A0 0.073465] NMI watchdog: enabled on all CPUs, permanently co=
nsumes one hw-PMU counter.<br>
:[=C2=A0 =C2=A0 0.075983] devtmpfs: initialized<br>
:[=C2=A0 =C2=A0 0.078123] EVM: security.selinux<br>
:[=C2=A0 =C2=A0 0.078126] EVM: security.ima<br>
:[=C2=A0 =C2=A0 0.078129] EVM: security.capability<br>
:[=C2=A0 =C2=A0 0.078258] PM: Registering ACPI NVS region [mem 0xd9a96000-0=
xd9bbafff] (1200128 bytes)<br>
:[=C2=A0 =C2=A0 0.078297] PM: Registering ACPI NVS region [mem 0xda6ba000-0=
xda6fcfff] (274432 bytes)<br>
:[=C2=A0 =C2=A0 0.079950] atomic64 test passed for x86-64 platform with CX8=
 and with SSE<br>
:[=C2=A0 =C2=A0 0.080031] NET: Registered protocol family 16<br>
:[=C2=A0 =C2=A0 0.080296] ACPI: bus type PCI registered<br>
:[=C2=A0 =C2=A0 0.080301] acpiphp: ACPI Hot Plug PCI Controller Driver vers=
ion: 0.5<br>
:[=C2=A0 =C2=A0 0.080383] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem=
 0xf8000000-0xfbffffff] (base 0xf8000000)<br>
:[=C2=A0 =C2=A0 0.080388] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] rese=
rved in E820<br>
:[=C2=A0 =C2=A0 0.095808] PCI: Using configuration type 1 for base access<b=
r>
:[=C2=A0 =C2=A0 0.097442] bio: create slab &lt;bio-0&gt; at 0<br>
:[=C2=A0 =C2=A0 0.097607] ACPI: Added _OSI(Module Device)<br>
:[=C2=A0 =C2=A0 0.097611] ACPI: Added _OSI(Processor Device)<br>
:[=C2=A0 =C2=A0 0.097614] ACPI: Added _OSI(3.0 _SCP Extensions)<br>
:[=C2=A0 =C2=A0 0.097617] ACPI: Added _OSI(Processor Aggregator Device)<br>
:[=C2=A0 =C2=A0 0.100564] ACPI: EC: Look up EC in DSDT<br>
:[=C2=A0 =C2=A0 0.104172] ACPI: Executed 1 blocks of module-level executabl=
e AML code<br>
:[=C2=A0 =C2=A0 0.111498] ACPI: SSDT 00000000d9a37018 0083B (v01=C2=A0 PmRe=
f=C2=A0 Cpu0Cst 00003001 INTL 20051117)<br>
:[=C2=A0 =C2=A0 0.112265] ACPI: Dynamic OEM Table Load:<br>
:[=C2=A0 =C2=A0 0.112270] ACPI: SSDT=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0(null) 0083B (v01=C2=A0 PmRef=C2=A0 Cpu0Cst 00003001 INTL 20051117)<br>
:[=C2=A0 =C2=A0 0.114181] ACPI: SSDT 00000000d9a38a98 00303 (v01=C2=A0 PmRe=
f=C2=A0 =C2=A0 ApIst 00003000 INTL 20051117)<br>
:[=C2=A0 =C2=A0 0.115009] ACPI: Dynamic OEM Table Load:<br>
:[=C2=A0 =C2=A0 0.115014] ACPI: SSDT=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0(null) 00303 (v01=C2=A0 PmRef=C2=A0 =C2=A0 ApIst 00003000 INTL 20051117)=
<br>
:[=C2=A0 =C2=A0 0.116869] ACPI: SSDT 00000000d9a44c18 00119 (v01=C2=A0 PmRe=
f=C2=A0 =C2=A0 ApCst 00003000 INTL 20051117)<br>
:[=C2=A0 =C2=A0 0.117606] ACPI: Dynamic OEM Table Load:<br>
:[=C2=A0 =C2=A0 0.117610] ACPI: SSDT=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0(null) 00119 (v01=C2=A0 PmRef=C2=A0 =C2=A0 ApCst 00003000 INTL 20051117)=
<br>
:[=C2=A0 =C2=A0 0.119503] ACPI: Interpreter enabled<br>
:[=C2=A0 =C2=A0 0.119516] ACPI Exception: AE_NOT_FOUND, While evaluating Sl=
eep State [\_S1_] (20130517/hwxface-571)<br>
:[=C2=A0 =C2=A0 0.119525] ACPI Exception: AE_NOT_FOUND, While evaluating Sl=
eep State [\_S2_] (20130517/hwxface-571)<br>
:[=C2=A0 =C2=A0 0.119553] ACPI: (supports S0 S3 S4 S5)<br>
:[=C2=A0 =C2=A0 0.119556] ACPI: Using IOAPIC for interrupt routing<br>
:[=C2=A0 =C2=A0 0.119611] PCI: Using host bridge windows from ACPI; if nece=
ssary, use &quot;pci=3Dnocrs&quot; and report a bug<br>
:[=C2=A0 =C2=A0 0.119893] ACPI: No dock devices found.<br>
:[=C2=A0 =C2=A0 0.135655] ACPI: Power Resource [FN00] (off)<br>
:[=C2=A0 =C2=A0 0.135820] ACPI: Power Resource [FN01] (off)<br>
:[=C2=A0 =C2=A0 0.135978] ACPI: Power Resource [FN02] (off)<br>
:[=C2=A0 =C2=A0 0.136127] ACPI: Power Resource [FN03] (off)<br>
:[=C2=A0 =C2=A0 0.136279] ACPI: Power Resource [FN04] (off)<br>
:[=C2=A0 =C2=A0 0.137476] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00=
-3e])<br>
:[=C2=A0 =C2=A0 0.137487] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfi=
g ASPM ClockPM Segments MSI]<br>
:[=C2=A0 =C2=A0 0.137926] acpi PNP0A08:00: _OSC: platform does not support =
[PCIeHotplug PME]<br>
:[=C2=A0 =C2=A0 0.138200] acpi PNP0A08:00: _OSC: OS now controls [AER PCIeC=
apability]<br>
:[=C2=A0 =C2=A0 0.139322] PCI host bridge to bus 0000:00<br>
:[=C2=A0 =C2=A0 0.139328] pci_bus 0000:00: root bus resource [bus 00-3e]<br=
>
:[=C2=A0 =C2=A0 0.139333] pci_bus 0000:00: root bus resource [io=C2=A0 0x00=
00-0x0cf7]<br>
:[=C2=A0 =C2=A0 0.139337] pci_bus 0000:00: root bus resource [io=C2=A0 0x0d=
00-0xffff]<br>
:[=C2=A0 =C2=A0 0.139340] pci_bus 0000:00: root bus resource [mem 0x000a000=
0-0x000bffff]<br>
:[=C2=A0 =C2=A0 0.139344] pci_bus 0000:00: root bus resource [mem 0x000d000=
0-0x000d3fff]<br>
:[=C2=A0 =C2=A0 0.139347] pci_bus 0000:00: root bus resource [mem 0x000d400=
0-0x000d7fff]<br>
:[=C2=A0 =C2=A0 0.139351] pci_bus 0000:00: root bus resource [mem 0x000d800=
0-0x000dbfff]<br>
:[=C2=A0 =C2=A0 0.139359] pci_bus 0000:00: root bus resource [mem 0x000dc00=
0-0x000dffff]<br>
:[=C2=A0 =C2=A0 0.139363] pci_bus 0000:00: root bus resource [mem 0x000e000=
0-0x000e3fff]<br>
:[=C2=A0 =C2=A0 0.139366] pci_bus 0000:00: root bus resource [mem 0x000e400=
0-0x000e7fff]<br>
:[=C2=A0 =C2=A0 0.139370] pci_bus 0000:00: root bus resource [mem 0xdfa0000=
0-0xfeafffff]<br>
:[=C2=A0 =C2=A0 0.139387] pci 0000:00:00.0: [8086:0104] type 00 class 0x060=
000<br>
:[=C2=A0 =C2=A0 0.139570] pci 0000:00:02.0: [8086:0106] type 00 class 0x030=
000<br>
:[=C2=A0 =C2=A0 0.139592] pci 0000:00:02.0: reg 0x10: [mem 0xf7800000-0xf7b=
fffff 64bit]<br>
:[=C2=A0 =C2=A0 0.139605] pci 0000:00:02.0: reg 0x18: [mem 0xe0000000-0xeff=
fffff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.139614] pci 0000:00:02.0: reg 0x20: [io=C2=A0 0xf000-0xf0=
3f]<br>
:[=C2=A0 =C2=A0 0.139824] pci 0000:00:16.0: [8086:1e3a] type 00 class 0x078=
000<br>
:[=C2=A0 =C2=A0 0.139857] pci 0000:00:16.0: reg 0x10: [mem 0xf7f0a000-0xf7f=
0a00f 64bit]<br>
:[=C2=A0 =C2=A0 0.139961] pci 0000:00:16.0: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.140131] pci 0000:00:1a.0: [8086:1e2d] type 00 class 0x0c0=
320<br>
:[=C2=A0 =C2=A0 0.140161] pci 0000:00:1a.0: reg 0x10: [mem 0xf7f08000-0xf7f=
083ff]<br>
:[=C2=A0 =C2=A0 0.140285] pci 0000:00:1a.0: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.140414] pci 0000:00:1a.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.140475] pci 0000:00:1b.0: [8086:1e20] type 00 class 0x040=
300<br>
:[=C2=A0 =C2=A0 0.140498] pci 0000:00:1b.0: reg 0x10: [mem 0xf7f00000-0xf7f=
03fff 64bit]<br>
:[=C2=A0 =C2=A0 0.140605] pci 0000:00:1b.0: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.140710] pci 0000:00:1b.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.140764] pci 0000:00:1c.0: [8086:1e10] type 01 class 0x060=
400<br>
:[=C2=A0 =C2=A0 0.140884] pci 0000:00:1c.0: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.140992] pci 0000:00:1c.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.141043] pci 0000:00:1c.1: [8086:1e12] type 01 class 0x060=
400<br>
:[=C2=A0 =C2=A0 0.141155] pci 0000:00:1c.1: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.141261] pci 0000:00:1c.1: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.141313] pci 0000:00:1c.2: [8086:2448] type 01 class 0x060=
401<br>
:[=C2=A0 =C2=A0 0.141425] pci 0000:00:1c.2: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.141534] pci 0000:00:1c.2: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.141585] pci 0000:00:1c.3: [8086:1e16] type 01 class 0x060=
400<br>
:[=C2=A0 =C2=A0 0.141697] pci 0000:00:1c.3: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.141803] pci 0000:00:1c.3: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.141870] pci 0000:00:1d.0: [8086:1e26] type 00 class 0x0c0=
320<br>
:[=C2=A0 =C2=A0 0.141900] pci 0000:00:1d.0: reg 0x10: [mem 0xf7f07000-0xf7f=
073ff]<br>
:[=C2=A0 =C2=A0 0.142024] pci 0000:00:1d.0: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.142150] pci 0000:00:1d.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.142205] pci 0000:00:1f.0: [8086:1e5f] type 00 class 0x060=
100<br>
:[=C2=A0 =C2=A0 0.142478] pci 0000:00:1f.2: [8086:1e03] type 00 class 0x010=
601<br>
:[=C2=A0 =C2=A0 0.142507] pci 0000:00:1f.2: reg 0x10: [io=C2=A0 0xf0b0-0xf0=
b7]<br>
:[=C2=A0 =C2=A0 0.142519] pci 0000:00:1f.2: reg 0x14: [io=C2=A0 0xf0a0-0xf0=
a3]<br>
:[=C2=A0 =C2=A0 0.142531] pci 0000:00:1f.2: reg 0x18: [io=C2=A0 0xf090-0xf0=
97]<br>
:[=C2=A0 =C2=A0 0.142543] pci 0000:00:1f.2: reg 0x1c: [io=C2=A0 0xf080-0xf0=
83]<br>
:[=C2=A0 =C2=A0 0.142556] pci 0000:00:1f.2: reg 0x20: [io=C2=A0 0xf060-0xf0=
7f]<br>
:[=C2=A0 =C2=A0 0.142568] pci 0000:00:1f.2: reg 0x24: [mem 0xf7f06000-0xf7f=
067ff]<br>
:[=C2=A0 =C2=A0 0.142637] pci 0000:00:1f.2: PME# supported from D3hot<br>
:[=C2=A0 =C2=A0 0.142777] pci 0000:00:1f.3: [8086:1e22] type 00 class 0x0c0=
500<br>
:[=C2=A0 =C2=A0 0.142800] pci 0000:00:1f.3: reg 0x10: [mem 0xf7f05000-0xf7f=
050ff 64bit]<br>
:[=C2=A0 =C2=A0 0.142836] pci 0000:00:1f.3: reg 0x20: [io=C2=A0 0xf040-0xf0=
5f]<br>
:[=C2=A0 =C2=A0 0.143098] pci 0000:01:00.0: [10ec:8168] type 00 class 0x020=
000<br>
:[=C2=A0 =C2=A0 0.143124] pci 0000:01:00.0: reg 0x10: [io=C2=A0 0xe000-0xe0=
ff]<br>
:[=C2=A0 =C2=A0 0.143168] pci 0000:01:00.0: reg 0x18: [mem 0xf7e00000-0xf7e=
00fff 64bit]<br>
:[=C2=A0 =C2=A0 0.143196] pci 0000:01:00.0: reg 0x20: [mem 0xf0100000-0xf01=
03fff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.143332] pci 0000:01:00.0: supports D1 D2<br>
:[=C2=A0 =C2=A0 0.143336] pci 0000:01:00.0: PME# supported from D0 D1 D2 D3=
hot D3cold<br>
:[=C2=A0 =C2=A0 0.143388] pci 0000:01:00.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.144857] pci 0000:00:1c.0: PCI bridge to [bus 01]<br>
:[=C2=A0 =C2=A0 0.144866] pci 0000:00:1c.0:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xe000-0xefff]<br>
:[=C2=A0 =C2=A0 0.144874] pci 0000:00:1c.0:=C2=A0 =C2=A0bridge window [mem =
0xf7e00000-0xf7efffff]<br>
:[=C2=A0 =C2=A0 0.144886] pci 0000:00:1c.0:=C2=A0 =C2=A0bridge window [mem =
0xf0100000-0xf01fffff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.145020] pci 0000:02:00.0: [10ec:8168] type 00 class 0x020=
000<br>
:[=C2=A0 =C2=A0 0.145046] pci 0000:02:00.0: reg 0x10: [io=C2=A0 0xd000-0xd0=
ff]<br>
:[=C2=A0 =C2=A0 0.145089] pci 0000:02:00.0: reg 0x18: [mem 0xf0004000-0xf00=
04fff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.145116] pci 0000:02:00.0: reg 0x20: [mem 0xf0000000-0xf00=
03fff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.145251] pci 0000:02:00.0: supports D1 D2<br>
:[=C2=A0 =C2=A0 0.145254] pci 0000:02:00.0: PME# supported from D0 D1 D2 D3=
hot D3cold<br>
:[=C2=A0 =C2=A0 0.145306] pci 0000:02:00.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.146858] pci 0000:00:1c.1: PCI bridge to [bus 02]<br>
:[=C2=A0 =C2=A0 0.146867] pci 0000:00:1c.1:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xd000-0xdfff]<br>
:[=C2=A0 =C2=A0 0.146882] pci 0000:00:1c.1:=C2=A0 =C2=A0bridge window [mem =
0xf0000000-0xf00fffff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.147011] pci 0000:03:00.0: [8086:244e] type 01 class 0x060=
401<br>
:[=C2=A0 =C2=A0 0.147194] pci 0000:03:00.0: supports D1 D2<br>
:[=C2=A0 =C2=A0 0.147197] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3=
hot D3cold<br>
:[=C2=A0 =C2=A0 0.147236] pci 0000:03:00.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.147280] pci 0000:00:1c.2: PCI bridge to [bus 03-04] (subt=
ractive decode)<br>
:[=C2=A0 =C2=A0 0.147286] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xc000-0xcfff]<br>
:[=C2=A0 =C2=A0 0.147292] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0xf7d00000-0xf7dfffff]<br>
:[=C2=A0 =C2=A0 0.147302] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0x0000-0x0cf7] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147306] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0x0d00-0xffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147310] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0x000a0000-0x000bffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147313] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0x000d0000-0x000d3fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147317] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0x000d4000-0x000d7fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147320] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0x000d8000-0x000dbfff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147324] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0x000dc000-0x000dffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147328] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0x000e0000-0x000e3fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147331] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0x000e4000-0x000e7fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147335] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0xdfa00000-0xfeafffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147442] pci 0000:04:00.0: [1186:4300] type 00 class 0x020=
000<br>
:[=C2=A0 =C2=A0 0.147485] pci 0000:04:00.0: reg 0x10: [io=C2=A0 0xc000-0xc0=
ff]<br>
:[=C2=A0 =C2=A0 0.147510] pci 0000:04:00.0: reg 0x14: [mem 0xf7d20000-0xf7d=
200ff]<br>
:[=C2=A0 =C2=A0 0.147618] pci 0000:04:00.0: reg 0x30: [mem 0xf7d00000-0xf7d=
1ffff pref]<br>
:[=C2=A0 =C2=A0 0.147690] pci 0000:04:00.0: supports D1 D2<br>
:[=C2=A0 =C2=A0 0.147693] pci 0000:04:00.0: PME# supported from D1 D2 D3hot=
 D3cold<br>
:[=C2=A0 =C2=A0 0.147851] pci 0000:03:00.0: PCI bridge to [bus 04] (subtrac=
tive decode)<br>
:[=C2=A0 =C2=A0 0.147866] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xc000-0xcfff]<br>
:[=C2=A0 =C2=A0 0.147876] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0xf7d00000-0xf7dfffff]<br>
:[=C2=A0 =C2=A0 0.147890] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xc000-0xcfff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147894] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0xf7d00000-0xf7dfffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147897] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [??? =
0x00000000 flags 0x0] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147901] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [??? =
0x00000000 flags 0x0] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147905] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0x0000-0x0cf7] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147908] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0x0d00-0xffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147912] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0x000a0000-0x000bffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147915] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0x000d0000-0x000d3fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147919] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0x000d4000-0x000d7fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147922] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0x000d8000-0x000dbfff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147926] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0x000dc000-0x000dffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147929] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0x000e0000-0x000e3fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147933] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0x000e4000-0x000e7fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147936] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0xdfa00000-0xfeafffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.148062] pci 0000:05:00.0: [197b:2368] type 00 class 0x010=
185<br>
:[=C2=A0 =C2=A0 0.148106] pci 0000:05:00.0: reg 0x10: [io=C2=A0 0xb040-0xb0=
47]<br>
:[=C2=A0 =C2=A0 0.148126] pci 0000:05:00.0: reg 0x14: [io=C2=A0 0xb030-0xb0=
33]<br>
:[=C2=A0 =C2=A0 0.148147] pci 0000:05:00.0: reg 0x18: [io=C2=A0 0xb020-0xb0=
27]<br>
:[=C2=A0 =C2=A0 0.148168] pci 0000:05:00.0: reg 0x1c: [io=C2=A0 0xb010-0xb0=
13]<br>
:[=C2=A0 =C2=A0 0.148189] pci 0000:05:00.0: reg 0x20: [io=C2=A0 0xb000-0xb0=
0f]<br>
:[=C2=A0 =C2=A0 0.148227] pci 0000:05:00.0: reg 0x30: [mem 0xf7c00000-0xf7c=
0ffff pref]<br>
:[=C2=A0 =C2=A0 0.148366] pci 0000:05:00.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.148407] pci 0000:05:00.0: disabling ASPM on pre-1.1 PCIe =
device.=C2=A0 You can enable it with &#39;pcie_aspm=3Dforce&#39;<br>
:[=C2=A0 =C2=A0 0.148422] pci 0000:00:1c.3: PCI bridge to [bus 05]<br>
:[=C2=A0 =C2=A0 0.148429] pci 0000:00:1c.3:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xb000-0xbfff]<br>
:[=C2=A0 =C2=A0 0.148435] pci 0000:00:1c.3:=C2=A0 =C2=A0bridge window [mem =
0xf7c00000-0xf7cfffff]<br>
:[=C2=A0 =C2=A0 0.149939] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 =
*11 12 14 15)<br>
:[=C2=A0 =C2=A0 0.150042] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 *10=
 11 12 14 15)<br>
:[=C2=A0 =C2=A0 0.150140] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 =
*11 12 14 15)<br>
:[=C2=A0 =C2=A0 0.150238] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10=
 11 12 14 15)<br>
:[=C2=A0 =C2=A0 0.150340] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 10 =
11 12 14 15) *0, disabled.<br>
:[=C2=A0 =C2=A0 0.150441] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 =
11 12 14 15) *0, disabled.<br>
:[=C2=A0 =C2=A0 0.150538] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 10 =
*11 12 14 15)<br>
:[=C2=A0 =C2=A0 0.150634] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *10=
 11 12 14 15)<br>
:[=C2=A0 =C2=A0 0.151075] ACPI: Enabled 5 GPEs in block 00 to 3F<br>
:[=C2=A0 =C2=A0 0.151090] ACPI: \_SB_.PCI0: notify handler is installed<br>
:[=C2=A0 =C2=A0 0.151214] Found 1 acpi root devices<br>
:[=C2=A0 =C2=A0 0.151369] vgaarb: device added: PCI:0000:00:02.0,decodes=3D=
io+mem,owns=3Dio+mem,locks=3Dnone<br>
:[=C2=A0 =C2=A0 0.151376] vgaarb: loaded<br>
:[=C2=A0 =C2=A0 0.151379] vgaarb: bridge control possible 0000:00:02.0<br>
:[=C2=A0 =C2=A0 0.151491] SCSI subsystem initialized<br>
:[=C2=A0 =C2=A0 0.151523] ACPI: bus type USB registered<br>
:[=C2=A0 =C2=A0 0.151560] usbcore: registered new interface driver usbfs<br=
>
:[=C2=A0 =C2=A0 0.151573] usbcore: registered new interface driver hub<br>
:[=C2=A0 =C2=A0 0.151633] usbcore: registered new device driver usb<br>
:[=C2=A0 =C2=A0 0.151757] PCI: Using ACPI for IRQ routing<br>
:[=C2=A0 =C2=A0 0.153871] PCI: pci_cache_line_size set to 64 bytes<br>
:[=C2=A0 =C2=A0 0.153958] e820: reserve RAM buffer [mem 0x0009d800-0x0009ff=
ff]<br>
:[=C2=A0 =C2=A0 0.153962] e820: reserve RAM buffer [mem 0xd94d2000-0xdbffff=
ff]<br>
:[=C2=A0 =C2=A0 0.153967] e820: reserve RAM buffer [mem 0xda6ba000-0xdbffff=
ff]<br>
:[=C2=A0 =C2=A0 0.153970] e820: reserve RAM buffer [mem 0xdadef000-0xdbffff=
ff]<br>
:[=C2=A0 =C2=A0 0.153973] e820: reserve RAM buffer [mem 0xdb000000-0xdbffff=
ff]<br>
:[=C2=A0 =C2=A0 0.153977] e820: reserve RAM buffer [mem 0x21f600000-0x21fff=
ffff]<br>
:[=C2=A0 =C2=A0 0.154122] NetLabel: Initializing<br>
:[=C2=A0 =C2=A0 0.154125] NetLabel:=C2=A0 domain hash size =3D 128<br>
:[=C2=A0 =C2=A0 0.154127] NetLabel:=C2=A0 protocols =3D UNLABELED CIPSOv4<b=
r>
:[=C2=A0 =C2=A0 0.154150] NetLabel:=C2=A0 unlabeled traffic allowed by defa=
ult<br>
:[=C2=A0 =C2=A0 0.154226] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0,=
 0, 0<br>
:[=C2=A0 =C2=A0 0.154236] hpet0: 8 comparators, 64-bit 14.318180 MHz counte=
r<br>
:[=C2=A0 =C2=A0 0.156260] Switching to clocksource hpet<br>
:[=C2=A0 =C2=A0 0.165255] pnp: PnP ACPI init<br>
:[=C2=A0 =C2=A0 0.165287] ACPI: bus type PNP registered<br>
:[=C2=A0 =C2=A0 0.165448] system 00:00: [mem 0xfed40000-0xfed44fff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.165456] system 00:00: Plug and Play ACPI device, IDs PNP0=
c01 (active)<br>
:[=C2=A0 =C2=A0 0.165479] pnp 00:01: [dma 4]<br>
:[=C2=A0 =C2=A0 0.165502] pnp 00:01: Plug and Play ACPI device, IDs PNP0200=
 (active)<br>
:[=C2=A0 =C2=A0 0.165535] pnp 00:02: Plug and Play ACPI device, IDs INT0800=
 (active)<br>
:[=C2=A0 =C2=A0 0.165696] pnp 00:03: Plug and Play ACPI device, IDs PNP0103=
 (active)<br>
:[=C2=A0 =C2=A0 0.165775] system 00:04: [io=C2=A0 0x0680-0x069f] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.165780] system 00:04: [io=C2=A0 0x0200-0x020f] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.165784] system 00:04: [io=C2=A0 0xffff] has been reserved=
<br>
:[=C2=A0 =C2=A0 0.165788] system 00:04: [io=C2=A0 0xffff] has been reserved=
<br>
:[=C2=A0 =C2=A0 0.165793] system 00:04: [io=C2=A0 0x0400-0x0453] could not =
be reserved<br>
:[=C2=A0 =C2=A0 0.165797] system 00:04: [io=C2=A0 0x0458-0x047f] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.165801] system 00:04: [io=C2=A0 0x0500-0x057f] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.165806] system 00:04: Plug and Play ACPI device, IDs PNP0=
c02 (active)<br>
:[=C2=A0 =C2=A0 0.165856] pnp 00:05: Plug and Play ACPI device, IDs PNP0b00=
 (active)<br>
:[=C2=A0 =C2=A0 0.165946] system 00:06: [io=C2=A0 0x0454-0x0457] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.165952] system 00:06: Plug and Play ACPI device, IDs INT3=
f0d PNP0c02 (active)<br>
:[=C2=A0 =C2=A0 0.166187] system 00:07: [io=C2=A0 0x0a00-0x0a0f] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.166192] system 00:07: [io=C2=A0 0x0a30-0x0a3f] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.166195] system 00:07: [io=C2=A0 0x0a20-0x0a2f] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.166200] system 00:07: Plug and Play ACPI device, IDs PNP0=
c02 (active)<br>
:[=C2=A0 =C2=A0 0.166634] pnp 00:08: [dma 0 disabled]<br>
:[=C2=A0 =C2=A0 0.166721] pnp 00:08: Plug and Play ACPI device, IDs PNP0501=
 (active)<br>
:[=C2=A0 =C2=A0 0.167080] pnp 00:09: [dma 0 disabled]<br>
:[=C2=A0 =C2=A0 0.167162] pnp 00:09: Plug and Play ACPI device, IDs PNP0501=
 (active)<br>
:[=C2=A0 =C2=A0 0.167631] pnp 00:0a: [dma 0 disabled]<br>
:[=C2=A0 =C2=A0 0.167824] pnp 00:0a: Plug and Play ACPI device, IDs PNP0400=
 (active)<br>
:[=C2=A0 =C2=A0 0.167915] system 00:0b: [io=C2=A0 0x04d0-0x04d1] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.167921] system 00:0b: Plug and Play ACPI device, IDs PNP0=
c02 (active)<br>
:[=C2=A0 =C2=A0 0.167965] pnp 00:0c: Plug and Play ACPI device, IDs PNP0c04=
 (active)<br>
:[=C2=A0 =C2=A0 0.168450] system 00:0d: [mem 0xfed1c000-0xfed1ffff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168455] system 00:0d: [mem 0xfed10000-0xfed17fff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168459] system 00:0d: [mem 0xfed18000-0xfed18fff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168463] system 00:0d: [mem 0xfed19000-0xfed19fff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168468] system 00:0d: [mem 0xf8000000-0xfbffffff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168472] system 00:0d: [mem 0xfed20000-0xfed3ffff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168475] system 00:0d: [mem 0xfed90000-0xfed93fff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168479] system 00:0d: [mem 0xfed45000-0xfed8ffff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168489] system 00:0d: [mem 0xff000000-0xffffffff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168494] system 00:0d: [mem 0xfee00000-0xfeefffff] could n=
ot be reserved<br>
:[=C2=A0 =C2=A0 0.168498] system 00:0d: [mem 0xdfa00000-0xdfa00fff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168503] system 00:0d: Plug and Play ACPI device, IDs PNP0=
c02 (active)<br>
:[=C2=A0 =C2=A0 0.168793] system 00:0e: [mem 0x20000000-0x201fffff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168797] system 00:0e: [mem 0x40000000-0x401fffff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168802] system 00:0e: Plug and Play ACPI device, IDs PNP0=
c01 (active)<br>
:[=C2=A0 =C2=A0 0.168843] pnp: PnP ACPI: found 15 devices<br>
:[=C2=A0 =C2=A0 0.168845] ACPI: bus type PNP unregistered<br>
:[=C2=A0 =C2=A0 0.176267] pci 0000:00:1c.0: PCI bridge to [bus 01]<br>
:[=C2=A0 =C2=A0 0.176280] pci 0000:00:1c.0:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xe000-0xefff]<br>
:[=C2=A0 =C2=A0 0.176289] pci 0000:00:1c.0:=C2=A0 =C2=A0bridge window [mem =
0xf7e00000-0xf7efffff]<br>
:[=C2=A0 =C2=A0 0.176296] pci 0000:00:1c.0:=C2=A0 =C2=A0bridge window [mem =
0xf0100000-0xf01fffff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.176305] pci 0000:00:1c.1: PCI bridge to [bus 02]<br>
:[=C2=A0 =C2=A0 0.176310] pci 0000:00:1c.1:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xd000-0xdfff]<br>
:[=C2=A0 =C2=A0 0.176321] pci 0000:00:1c.1:=C2=A0 =C2=A0bridge window [mem =
0xf0000000-0xf00fffff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.176331] pci 0000:03:00.0: PCI bridge to [bus 04]<br>
:[=C2=A0 =C2=A0 0.176337] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xc000-0xcfff]<br>
:[=C2=A0 =C2=A0 0.176349] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0xf7d00000-0xf7dfffff]<br>
:[=C2=A0 =C2=A0 0.176369] pci 0000:00:1c.2: PCI bridge to [bus 03-04]<br>
:[=C2=A0 =C2=A0 0.176374] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xc000-0xcfff]<br>
:[=C2=A0 =C2=A0 0.176382] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0xf7d00000-0xf7dfffff]<br>
:[=C2=A0 =C2=A0 0.176394] pci 0000:00:1c.3: PCI bridge to [bus 05]<br>
:[=C2=A0 =C2=A0 0.176399] pci 0000:00:1c.3:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xb000-0xbfff]<br>
:[=C2=A0 =C2=A0 0.176407] pci 0000:00:1c.3:=C2=A0 =C2=A0bridge window [mem =
0xf7c00000-0xf7cfffff]<br>
:[=C2=A0 =C2=A0 0.176420] pci_bus 0000:00: resource 4 [io=C2=A0 0x0000-0x0c=
f7]<br>
:[=C2=A0 =C2=A0 0.176424] pci_bus 0000:00: resource 5 [io=C2=A0 0x0d00-0xff=
ff]<br>
:[=C2=A0 =C2=A0 0.176428] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000=
bffff]<br>
:[=C2=A0 =C2=A0 0.176432] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000=
d3fff]<br>
:[=C2=A0 =C2=A0 0.176435] pci_bus 0000:00: resource 8 [mem 0x000d4000-0x000=
d7fff]<br>
:[=C2=A0 =C2=A0 0.176439] pci_bus 0000:00: resource 9 [mem 0x000d8000-0x000=
dbfff]<br>
:[=C2=A0 =C2=A0 0.176442] pci_bus 0000:00: resource 10 [mem 0x000dc000-0x00=
0dffff]<br>
:[=C2=A0 =C2=A0 0.176446] pci_bus 0000:00: resource 11 [mem 0x000e0000-0x00=
0e3fff]<br>
:[=C2=A0 =C2=A0 0.176449] pci_bus 0000:00: resource 12 [mem 0x000e4000-0x00=
0e7fff]<br>
:[=C2=A0 =C2=A0 0.176453] pci_bus 0000:00: resource 13 [mem 0xdfa00000-0xfe=
afffff]<br>
:[=C2=A0 =C2=A0 0.176457] pci_bus 0000:01: resource 0 [io=C2=A0 0xe000-0xef=
ff]<br>
:[=C2=A0 =C2=A0 0.176460] pci_bus 0000:01: resource 1 [mem 0xf7e00000-0xf7e=
fffff]<br>
:[=C2=A0 =C2=A0 0.176464] pci_bus 0000:01: resource 2 [mem 0xf0100000-0xf01=
fffff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.176468] pci_bus 0000:02: resource 0 [io=C2=A0 0xd000-0xdf=
ff]<br>
:[=C2=A0 =C2=A0 0.176471] pci_bus 0000:02: resource 2 [mem 0xf0000000-0xf00=
fffff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.176475] pci_bus 0000:03: resource 0 [io=C2=A0 0xc000-0xcf=
ff]<br>
:[=C2=A0 =C2=A0 0.176478] pci_bus 0000:03: resource 1 [mem 0xf7d00000-0xf7d=
fffff]<br>
:[=C2=A0 =C2=A0 0.176482] pci_bus 0000:03: resource 4 [io=C2=A0 0x0000-0x0c=
f7]<br>
:[=C2=A0 =C2=A0 0.176486] pci_bus 0000:03: resource 5 [io=C2=A0 0x0d00-0xff=
ff]<br>
:[=C2=A0 =C2=A0 0.176489] pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000=
bffff]<br>
:[=C2=A0 =C2=A0 0.176493] pci_bus 0000:03: resource 7 [mem 0x000d0000-0x000=
d3fff]<br>
:[=C2=A0 =C2=A0 0.176496] pci_bus 0000:03: resource 8 [mem 0x000d4000-0x000=
d7fff]<br>
:[=C2=A0 =C2=A0 0.176500] pci_bus 0000:03: resource 9 [mem 0x000d8000-0x000=
dbfff]<br>
:[=C2=A0 =C2=A0 0.176503] pci_bus 0000:03: resource 10 [mem 0x000dc000-0x00=
0dffff]<br>
:[=C2=A0 =C2=A0 0.176507] pci_bus 0000:03: resource 11 [mem 0x000e0000-0x00=
0e3fff]<br>
:[=C2=A0 =C2=A0 0.176510] pci_bus 0000:03: resource 12 [mem 0x000e4000-0x00=
0e7fff]<br>
:[=C2=A0 =C2=A0 0.176514] pci_bus 0000:03: resource 13 [mem 0xdfa00000-0xfe=
afffff]<br>
:[=C2=A0 =C2=A0 0.176517] pci_bus 0000:04: resource 0 [io=C2=A0 0xc000-0xcf=
ff]<br>
:[=C2=A0 =C2=A0 0.176521] pci_bus 0000:04: resource 1 [mem 0xf7d00000-0xf7d=
fffff]<br>
:[=C2=A0 =C2=A0 0.176524] pci_bus 0000:04: resource 4 [io=C2=A0 0xc000-0xcf=
ff]<br>
:[=C2=A0 =C2=A0 0.176528] pci_bus 0000:04: resource 5 [mem 0xf7d00000-0xf7d=
fffff]<br>
:[=C2=A0 =C2=A0 0.176531] pci_bus 0000:04: resource 8 [io=C2=A0 0x0000-0x0c=
f7]<br>
:[=C2=A0 =C2=A0 0.176535] pci_bus 0000:04: resource 9 [io=C2=A0 0x0d00-0xff=
ff]<br>
:[=C2=A0 =C2=A0 0.176538] pci_bus 0000:04: resource 10 [mem 0x000a0000-0x00=
0bffff]<br>
:[=C2=A0 =C2=A0 0.176542] pci_bus 0000:04: resource 11 [mem 0x000d0000-0x00=
0d3fff]<br>
:[=C2=A0 =C2=A0 0.176545] pci_bus 0000:04: resource 12 [mem 0x000d4000-0x00=
0d7fff]<br>
:[=C2=A0 =C2=A0 0.176549] pci_bus 0000:04: resource 13 [mem 0x000d8000-0x00=
0dbfff]<br>
:[=C2=A0 =C2=A0 0.176552] pci_bus 0000:04: resource 14 [mem 0x000dc000-0x00=
0dffff]<br>
:[=C2=A0 =C2=A0 0.176555] pci_bus 0000:04: resource 15 [mem 0x000e0000-0x00=
0e3fff]<br>
:[=C2=A0 =C2=A0 0.176559] pci_bus 0000:04: resource 16 [mem 0x000e4000-0x00=
0e7fff]<br>
:[=C2=A0 =C2=A0 0.176562] pci_bus 0000:04: resource 17 [mem 0xdfa00000-0xfe=
afffff]<br>
:[=C2=A0 =C2=A0 0.176566] pci_bus 0000:05: resource 0 [io=C2=A0 0xb000-0xbf=
ff]<br>
:[=C2=A0 =C2=A0 0.176569] pci_bus 0000:05: resource 1 [mem 0xf7c00000-0xf7c=
fffff]<br>
:[=C2=A0 =C2=A0 0.176614] NET: Registered protocol family 2<br>
:[=C2=A0 =C2=A0 0.176925] TCP established hash table entries: 65536 (order:=
 7, 524288 bytes)<br>
:[=C2=A0 =C2=A0 0.177300] TCP bind hash table entries: 65536 (order: 8, 104=
8576 bytes)<br>
:[=C2=A0 =C2=A0 0.177567] TCP: Hash tables configured (established 65536 bi=
nd 65536)<br>
:[=C2=A0 =C2=A0 0.177611] TCP: reno registered<br>
:[=C2=A0 =C2=A0 0.177641] UDP hash table entries: 4096 (order: 5, 131072 by=
tes)<br>
:[=C2=A0 =C2=A0 0.177709] UDP-Lite hash table entries: 4096 (order: 5, 1310=
72 bytes)<br>
:[=C2=A0 =C2=A0 0.177841] NET: Registered protocol family 1<br>
:[=C2=A0 =C2=A0 0.177865] pci 0000:00:02.0: Boot video device<br>
:[=C2=A0 =C2=A0 0.209495] PCI: CLS 64 bytes, default 64<br>
:[=C2=A0 =C2=A0 0.209584] Unpacking initramfs...<br>
:[=C2=A0 =C2=A0 0.604426] Freeing initrd memory: 11424k freed<br>
:[=C2=A0 =C2=A0 0.607345] PCI-DMA: Using software bounce buffering for IO (=
SWIOTLB)<br>
:[=C2=A0 =C2=A0 0.607354] software IO TLB [mem 0xd54d2000-0xd94d2000] (64MB=
) mapped at [ffff8800d54d2000-ffff8800d94d1fff]<br>
:[=C2=A0 =C2=A0 0.607865] microcode: CPU0 sig=3D0x206a7, pf=3D0x10, revisio=
n=3D0x29<br>
:[=C2=A0 =C2=A0 0.607876] microcode: CPU1 sig=3D0x206a7, pf=3D0x10, revisio=
n=3D0x29<br>
:[=C2=A0 =C2=A0 0.607919] microcode: Microcode Update Driver: v2.00 &lt;<a =
href=3D"mailto:tigran@aivazian.fsnet.co.uk">tigran@aivazian.fsnet.co.uk</a>=
&gt;, Peter Oruba<br>
:[=C2=A0 =C2=A0 0.608188] futex hash table entries: 512 (order: 3, 32768 by=
tes)<br>
:[=C2=A0 =C2=A0 0.608203] Initialise system trusted keyring<br>
:[=C2=A0 =C2=A0 0.608291] audit: initializing netlink socket (disabled)<br>
:[=C2=A0 =C2=A0 0.608311] type=3D2000 audit(1418209464.594:1): initialized<=
br>
:[=C2=A0 =C2=A0 0.655256] HugeTLB registered 2 MB page size, pre-allocated =
0 pages<br>
:[=C2=A0 =C2=A0 0.657177] zbud: loaded<br>
:[=C2=A0 =C2=A0 0.657464] VFS: Disk quotas dquot_6.5.2<br>
:[=C2=A0 =C2=A0 0.657528] Dquot-cache hash table entries: 512 (order 0, 409=
6 bytes)<br>
:[=C2=A0 =C2=A0 0.657784] msgmni has been set to 15417<br>
:[=C2=A0 =C2=A0 0.657867] Key type big_key registered<br>
:[=C2=A0 =C2=A0 0.657870] SELinux:=C2=A0 Registering netfilter hooks<br>
:[=C2=A0 =C2=A0 0.658770] alg: No test for stdrng (krng)<br>
:[=C2=A0 =C2=A0 0.658782] NET: Registered protocol family 38<br>
:[=C2=A0 =C2=A0 0.658786] Key type asymmetric registered<br>
:[=C2=A0 =C2=A0 0.658789] Asymmetric key parser &#39;x509&#39; registered<b=
r>
:[=C2=A0 =C2=A0 0.658852] Block layer SCSI generic (bsg) driver version 0.4=
 loaded (major 252)<br>
:[=C2=A0 =C2=A0 0.658898] io scheduler noop registered<br>
:[=C2=A0 =C2=A0 0.658901] io scheduler deadline registered (default)<br>
:[=C2=A0 =C2=A0 0.658941] io scheduler cfq registered<br>
:[=C2=A0 =C2=A0 0.659785] pci_hotplug: PCI Hot Plug PCI Core version: 0.5<b=
r>
:[=C2=A0 =C2=A0 0.659810] pciehp: PCI Express Hot Plug Controller Driver ve=
rsion: 0.4<br>
:[=C2=A0 =C2=A0 0.659911] intel_idle: MWAIT substates: 0x21120<br>
:[=C2=A0 =C2=A0 0.659914] intel_idle: v0.4 model 0x2A<br>
:[=C2=A0 =C2=A0 0.659917] intel_idle: lapic_timer_reliable_states 0xfffffff=
f<br>
:[=C2=A0 =C2=A0 0.660050] input: Power Button as /devices/LNXSYSTM:00/devic=
e:00/PNP0C0C:00/input/input0<br>
:[=C2=A0 =C2=A0 0.660057] ACPI: Power Button [PWRB]<br>
:[=C2=A0 =C2=A0 0.660112] input: Power Button as /devices/LNXSYSTM:00/LNXPW=
RBN:00/input/input1<br>
:[=C2=A0 =C2=A0 0.660116] ACPI: Power Button [PWRF]<br>
:[=C2=A0 =C2=A0 0.660204] ACPI: Fan [FAN0] (off)<br>
:[=C2=A0 =C2=A0 0.660252] ACPI: Fan [FAN1] (off)<br>
:[=C2=A0 =C2=A0 0.660306] ACPI: Fan [FAN2] (off)<br>
:[=C2=A0 =C2=A0 0.660349] ACPI: Fan [FAN3] (off)<br>
:[=C2=A0 =C2=A0 0.660388] ACPI: Fan [FAN4] (off)<br>
:[=C2=A0 =C2=A0 0.660472] ACPI: Requesting acpi_cpufreq<br>
:[=C2=A0 =C2=A0 0.669091] thermal LNXTHERM:00: registered as thermal_zone0<=
br>
:[=C2=A0 =C2=A0 0.669097] ACPI: Thermal Zone [TZ00] (28 C)<br>
:[=C2=A0 =C2=A0 0.669534] thermal LNXTHERM:01: registered as thermal_zone1<=
br>
:[=C2=A0 =C2=A0 0.669538] ACPI: Thermal Zone [TZ01] (30 C)<br>
:[=C2=A0 =C2=A0 0.669621] GHES: HEST is not enabled!<br>
:[=C2=A0 =C2=A0 0.669716] Serial: 8250/16550 driver, 4 ports, IRQ sharing e=
nabled<br>
:[=C2=A0 =C2=A0 0.690414] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A=
<br>
:[=C2=A0 =C2=A0 0.711102] 00:09: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A=
<br>
:[=C2=A0 =C2=A0 0.711789] Non-volatile memory driver v1.3<br>
:[=C2=A0 =C2=A0 0.711793] Linux agpgart interface v0.103<br>
:[=C2=A0 =C2=A0 0.711922] crash memory driver: version 1.1<br>
:[=C2=A0 =C2=A0 0.711947] rdac: device handler registered<br>
:[=C2=A0 =C2=A0 0.711996] hp_sw: device handler registered<br>
:[=C2=A0 =C2=A0 0.711999] emc: device handler registered<br>
:[=C2=A0 =C2=A0 0.712002] alua: device handler registered<br>
:[=C2=A0 =C2=A0 0.712051] libphy: Fixed MDIO Bus: probed<br>
:[=C2=A0 =C2=A0 0.712112] ehci_hcd: USB 2.0 &#39;Enhanced&#39; Host Control=
ler (EHCI) Driver<br>
:[=C2=A0 =C2=A0 0.712118] ehci-pci: EHCI PCI platform driver<br>
:[=C2=A0 =C2=A0 0.712329] ehci-pci 0000:00:1a.0: EHCI Host Controller<br>
:[=C2=A0 =C2=A0 0.712391] ehci-pci 0000:00:1a.0: new USB bus registered, as=
signed bus number 1<br>
:[=C2=A0 =C2=A0 0.712410] ehci-pci 0000:00:1a.0: debug port 2<br>
:[=C2=A0 =C2=A0 0.716318] ehci-pci 0000:00:1a.0: cache line size of 64 is n=
ot supported<br>
:[=C2=A0 =C2=A0 0.716347] ehci-pci 0000:00:1a.0: irq 16, io mem 0xf7f08000<=
br>
:[=C2=A0 =C2=A0 0.722278] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00=
<br>
:[=C2=A0 =C2=A0 0.722360] usb usb1: New USB device found, idVendor=3D1d6b, =
idProduct=3D0002<br>
:[=C2=A0 =C2=A0 0.722364] usb usb1: New USB device strings: Mfr=3D3, Produc=
t=3D2, SerialNumber=3D1<br>
:[=C2=A0 =C2=A0 0.722368] usb usb1: Product: EHCI Host Controller<br>
:[=C2=A0 =C2=A0 0.722371] usb usb1: Manufacturer: Linux 3.10.0-123.el7.x86_=
64 ehci_hcd<br>
:[=C2=A0 =C2=A0 0.722374] usb usb1: SerialNumber: 0000:00:1a.0<br>
:[=C2=A0 =C2=A0 0.722537] hub 1-0:1.0: USB hub found<br>
:[=C2=A0 =C2=A0 0.722551] hub 1-0:1.0: 2 ports detected<br>
:[=C2=A0 =C2=A0 0.722918] ehci-pci 0000:00:1d.0: EHCI Host Controller<br>
:[=C2=A0 =C2=A0 0.722988] ehci-pci 0000:00:1d.0: new USB bus registered, as=
signed bus number 2<br>
:[=C2=A0 =C2=A0 0.723006] ehci-pci 0000:00:1d.0: debug port 2<br>
:[=C2=A0 =C2=A0 0.726907] ehci-pci 0000:00:1d.0: cache line size of 64 is n=
ot supported<br>
:[=C2=A0 =C2=A0 0.726932] ehci-pci 0000:00:1d.0: irq 23, io mem 0xf7f07000<=
br>
:[=C2=A0 =C2=A0 0.732277] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00=
<br>
:[=C2=A0 =C2=A0 0.732341] usb usb2: New USB device found, idVendor=3D1d6b, =
idProduct=3D0002<br>
:[=C2=A0 =C2=A0 0.732346] usb usb2: New USB device strings: Mfr=3D3, Produc=
t=3D2, SerialNumber=3D1<br>
:[=C2=A0 =C2=A0 0.732349] usb usb2: Product: EHCI Host Controller<br>
:[=C2=A0 =C2=A0 0.732353] usb usb2: Manufacturer: Linux 3.10.0-123.el7.x86_=
64 ehci_hcd<br>
:[=C2=A0 =C2=A0 0.732356] usb usb2: SerialNumber: 0000:00:1d.0<br>
:[=C2=A0 =C2=A0 0.732506] hub 2-0:1.0: USB hub found<br>
:[=C2=A0 =C2=A0 0.732517] hub 2-0:1.0: 2 ports detected<br>
:[=C2=A0 =C2=A0 0.732691] ohci_hcd: USB 1.1 &#39;Open&#39; Host Controller =
(OHCI) Driver<br>
:[=C2=A0 =C2=A0 0.732694] ohci-pci: OHCI PCI platform driver<br>
:[=C2=A0 =C2=A0 0.732711] uhci_hcd: USB Universal Host Controller Interface=
 driver<br>
:[=C2=A0 =C2=A0 0.732789] usbcore: registered new interface driver usbseria=
l<br>
:[=C2=A0 =C2=A0 0.732803] usbcore: registered new interface driver usbseria=
l_generic<br>
:[=C2=A0 =C2=A0 0.732813] usbserial: USB Serial support registered for gene=
ric<br>
:[=C2=A0 =C2=A0 0.732872] i8042: PNP: No PS/2 controller found. Probing por=
ts directly.<br>
:[=C2=A0 =C2=A0 0.733300] serio: i8042 KBD port at 0x60,0x64 irq 1<br>
:[=C2=A0 =C2=A0 0.733309] serio: i8042 AUX port at 0x60,0x64 irq 12<br>
:[=C2=A0 =C2=A0 0.733440] mousedev: PS/2 mouse device common for all mice<b=
r>
:[=C2=A0 =C2=A0 0.733655] rtc_cmos 00:05: RTC can wake from S4<br>
:[=C2=A0 =C2=A0 0.733830] rtc_cmos 00:05: rtc core: registered rtc_cmos as =
rtc0<br>
:[=C2=A0 =C2=A0 0.733866] rtc_cmos 00:05: alarms up to one month, y3k, 242 =
bytes nvram, hpet irqs<br>
:[=C2=A0 =C2=A0 0.733883] Intel P-state driver initializing.<br>
:[=C2=A0 =C2=A0 0.733899] Intel pstate controlling: cpu 0<br>
:[=C2=A0 =C2=A0 0.733925] Intel pstate controlling: cpu 1<br>
:[=C2=A0 =C2=A0 0.734037] cpuidle: using governor menu<br>
:[=C2=A0 =C2=A0 0.734480] hidraw: raw HID events driver (C) Jiri Kosina<br>
:[=C2=A0 =C2=A0 0.734610] usbcore: registered new interface driver usbhid<b=
r>
:[=C2=A0 =C2=A0 0.734612] usbhid: USB HID core driver<br>
:[=C2=A0 =C2=A0 0.734670] drop_monitor: Initializing network drop monitor s=
ervice<br>
:[=C2=A0 =C2=A0 0.734797] TCP: cubic registered<br>
:[=C2=A0 =C2=A0 0.734801] Initializing XFRM netlink socket<br>
:[=C2=A0 =C2=A0 0.734942] NET: Registered protocol family 10<br>
:[=C2=A0 =C2=A0 0.735187] NET: Registered protocol family 17<br>
:[=C2=A0 =C2=A0 0.735533] Loading compiled-in X.509 certificates<br>
:[=C2=A0 =C2=A0 0.735583] Loaded X.509 cert &#39;CentOS Linux kpatch signin=
g key: ea0413152cde1d98ebdca3fe6f0230904c9ef717&#39;<br>
:[=C2=A0 =C2=A0 0.735621] Loaded X.509 cert &#39;CentOS Linux Driver update=
 signing key: 7f421ee0ab69461574bb358861dbe77762a4201b&#39;<br>
:[=C2=A0 =C2=A0 0.736851] Loaded X.509 cert &#39;CentOS Linux kernel signin=
g key: bc83d0fe70c62fab1c58b4ebaa95e3936128fcf4&#39;<br>
:[=C2=A0 =C2=A0 0.736869] registered taskstats version 1<br>
:[=C2=A0 =C2=A0 0.740369] Key type trusted registered<br>
:[=C2=A0 =C2=A0 0.743683] Key type encrypted registered<br>
:[=C2=A0 =C2=A0 0.746760] IMA: No TPM chip found, activating TPM-bypass!<br=
>
:[=C2=A0 =C2=A0 0.747332] rtc_cmos 00:05: setting system clock to 2014-12-1=
0 11:04:25 UTC (1418209465)<br>
:[=C2=A0 =C2=A0 0.748784] Freeing unused kernel memory: 1584k freed<br>
:[=C2=A0 =C2=A0 0.755639] systemd[1]: systemd 208 running in system mode. (=
+PAM +LIBWRAP +AUDIT +SELINUX +IMA +SYSVINIT +LIBCRYPTSETUP +GCRYPT +ACL +X=
Z)<br>
:[=C2=A0 =C2=A0 0.755935] systemd[1]: Running in initial RAM disk.<br>
:[=C2=A0 =C2=A0 0.756038] systemd[1]: Set hostname to &lt;router.centos&gt;=
.<br>
:[=C2=A0 =C2=A0 0.806660] systemd[1]: Expecting device dev-disk-by\x2duuid-=
328b16e8\x2d5f97\x2d4c97\x2d80c2\x2d1269e2157281.device...<br>
:[=C2=A0 =C2=A0 0.806689] systemd[1]: Starting -.slice.<br>
:[=C2=A0 =C2=A0 0.806966] systemd[1]: Created slice -.slice.<br>
:[=C2=A0 =C2=A0 0.807056] systemd[1]: Starting System Slice.<br>
:[=C2=A0 =C2=A0 0.807185] systemd[1]: Created slice System Slice.<br>
:[=C2=A0 =C2=A0 0.807255] systemd[1]: Starting Slices.<br>
:[=C2=A0 =C2=A0 0.807289] systemd[1]: Reached target Slices.<br>
:[=C2=A0 =C2=A0 0.807350] systemd[1]: Starting Timers.<br>
:[=C2=A0 =C2=A0 0.807370] systemd[1]: Reached target Timers.<br>
:[=C2=A0 =C2=A0 0.807434] systemd[1]: Starting Journal Socket.<br>
:[=C2=A0 =C2=A0 0.807541] systemd[1]: Listening on Journal Socket.<br>
:[=C2=A0 =C2=A0 0.807883] systemd[1]: Starting dracut cmdline hook...<br>
:[=C2=A0 =C2=A0 0.808728] systemd[1]: Started Load Kernel Modules.<br>
:[=C2=A0 =C2=A0 0.808765] systemd[1]: Starting Setup Virtual Console...<br>
:[=C2=A0 =C2=A0 0.809325] systemd[1]: Starting Journal Service...<br>
:[=C2=A0 =C2=A0 0.809926] systemd[1]: Started Journal Service.<br>
:[=C2=A0 =C2=A0 0.831115] systemd-journald[90]: Vacuuming done, freed 0 byt=
es<br>
:[=C2=A0 =C2=A0 1.024326] usb 1-1: new high-speed USB device number 2 using=
 ehci-pci<br>
:[=C2=A0 =C2=A0 1.047379] device-mapper: uevent: version 1.0.3<br>
:[=C2=A0 =C2=A0 1.047490] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) i=
nitialised: <a href=3D"mailto:dm-devel@redhat.com">dm-devel@redhat.com</a><=
br>
:[=C2=A0 =C2=A0 1.097510] systemd-udevd[214]: starting version 208<br>
:[=C2=A0 =C2=A0 1.142672] usb 1-1: New USB device found, idVendor=3D8087, i=
dProduct=3D0024<br>
:[=C2=A0 =C2=A0 1.142681] usb 1-1: New USB device strings: Mfr=3D0, Product=
=3D0, SerialNumber=3D0<br>
:[=C2=A0 =C2=A0 1.142930] hub 1-1:1.0: USB hub found<br>
:[=C2=A0 =C2=A0 1.143002] hub 1-1:1.0: 4 ports detected<br>
:[=C2=A0 =C2=A0 1.206054] [drm] Initialized drm 1.1.0 20060810<br>
:[=C2=A0 =C2=A0 1.226469] ACPI: bus type ATA registered<br>
:[=C2=A0 =C2=A0 1.244192] libata version 3.00 loaded.<br>
:[=C2=A0 =C2=A0 1.247288] usb 2-1: new high-speed USB device number 2 using=
 ehci-pci<br>
:[=C2=A0 =C2=A0 1.270906] scsi0 : pata_jmicron<br>
:[=C2=A0 =C2=A0 1.271240] scsi1 : pata_jmicron<br>
:[=C2=A0 =C2=A0 1.271331] ata1: PATA max UDMA/100 cmd 0xb040 ctl 0xb030 bmd=
ma 0xb000 irq 19<br>
:[=C2=A0 =C2=A0 1.271336] ata2: PATA max UDMA/100 cmd 0xb020 ctl 0xb010 bmd=
ma 0xb008 irq 19<br>
:[=C2=A0 =C2=A0 1.273633] [drm] Memory usable by graphics device =3D 2048M<=
br>
:[=C2=A0 =C2=A0 1.345663] i915 0000:00:02.0: irq 40 for MSI/MSI-X<br>
:[=C2=A0 =C2=A0 1.345681] [drm] Supports vblank timestamp caching Rev 1 (10=
.10.2010).<br>
:[=C2=A0 =C2=A0 1.345684] [drm] Driver supports precise vblank timestamp qu=
ery.<br>
:[=C2=A0 =C2=A0 1.345773] vgaarb: device changed decodes: PCI:0000:00:02.0,=
olddecodes=3Dio+mem,decodes=3Dio+mem:owns=3Dio+mem<br>
:[=C2=A0 =C2=A0 1.360450] [drm] Wrong MCH_SSKPD value: 0x16040307<br>
:[=C2=A0 =C2=A0 1.360456] [drm] This can cause pipe underruns and display i=
ssues.<br>
:[=C2=A0 =C2=A0 1.360459] [drm] Please upgrade your BIOS to fix this.<br>
:[=C2=A0 =C2=A0 1.361628] usb 2-1: New USB device found, idVendor=3D8087, i=
dProduct=3D0024<br>
:[=C2=A0 =C2=A0 1.361635] usb 2-1: New USB device strings: Mfr=3D0, Product=
=3D0, SerialNumber=3D0<br>
:[=C2=A0 =C2=A0 1.361923] hub 2-1:1.0: USB hub found<br>
:[=C2=A0 =C2=A0 1.361996] hub 2-1:1.0: 4 ports detected<br>
:[=C2=A0 =C2=A0 1.371176] i915 0000:00:02.0: No connectors reported connect=
ed with modes<br>
:[=C2=A0 =C2=A0 1.371191] [drm] Cannot find any crtc or sizes - going 1024x=
768<br>
:[=C2=A0 =C2=A0 1.373057] fbcon: inteldrmfb (fb0) is primary device<br>
:[=C2=A0 =C2=A0 1.399213] Console: switching to colour frame buffer device =
128x48<br>
:[=C2=A0 =C2=A0 1.404226] i915 0000:00:02.0: fb0: inteldrmfb frame buffer d=
evice<br>
:[=C2=A0 =C2=A0 1.404231] i915 0000:00:02.0: registered panic notifier<br>
:[=C2=A0 =C2=A0 1.409678] acpi device:59: registered as cooling_device7<br>
:[=C2=A0 =C2=A0 1.409978] ACPI: Video Device [GFX0] (multi-head: yes=C2=A0 =
rom: no=C2=A0 post: no)<br>
:[=C2=A0 =C2=A0 1.410057] input: Video Bus as /devices/LNXSYSTM:00/device:0=
0/PNP0A08:00/LNXVIDEO:00/input/input2<br>
:[=C2=A0 =C2=A0 1.410178] [drm] Initialized i915 1.6.0 20080730 for 0000:00=
:02.0 on minor 0<br>
:[=C2=A0 =C2=A0 1.410466] ahci 0000:00:1f.2: version 3.0<br>
:[=C2=A0 =C2=A0 1.410718] ahci 0000:00:1f.2: irq 41 for MSI/MSI-X<br>
:[=C2=A0 =C2=A0 1.410791] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 4 port=
s 6 Gbps 0x1 impl SATA mode<br>
:[=C2=A0 =C2=A0 1.410798] ahci 0000:00:1f.2: flags: 64bit ncq led clo pio s=
lum part ems apst<br>
:[=C2=A0 =C2=A0 1.415503] scsi2 : ahci<br>
:[=C2=A0 =C2=A0 1.415706] scsi3 : ahci<br>
:[=C2=A0 =C2=A0 1.416022] scsi4 : ahci<br>
:[=C2=A0 =C2=A0 1.416153] scsi5 : ahci<br>
:[=C2=A0 =C2=A0 1.416320] ata3: SATA max UDMA/133 abar m2048@0xf7f06000 por=
t 0xf7f06100 irq 41<br>
:[=C2=A0 =C2=A0 1.416326] ata4: DUMMY<br>
:[=C2=A0 =C2=A0 1.416329] ata5: DUMMY<br>
:[=C2=A0 =C2=A0 1.416331] ata6: DUMMY<br>
:[=C2=A0 =C2=A0 1.608361] tsc: Refined TSC clocksource calibration: 1097.50=
6 MHz<br>
:[=C2=A0 =C2=A0 1.608373] Switching to clocksource tsc<br>
:[=C2=A0 =C2=A0 1.721408] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl=
 300)<br>
:[=C2=A0 =C2=A0 1.724848] ACPI Error: [DSSP] Namespace lookup failure, AE_N=
OT_FOUND (20130517/psargs-359)<br>
:[=C2=A0 =C2=A0 1.724867] ACPI Error: Method parse/execution failed [\_SB_.=
PCI0.SAT0.SPT0._GTF] (Node ffff8802138b5c30), AE_NOT_FOUND (20130517/pspars=
e-536)<br>
:[=C2=A0 =C2=A0 1.725058] ata3.00: ATA-7: SAMSUNG SP2004C, VM100-33, max UD=
MA7<br>
:[=C2=A0 =C2=A0 1.725067] ata3.00: 390721968 sectors, multi 16: LBA48 NCQ (=
depth 31/32), AA<br>
:[=C2=A0 =C2=A0 1.728549] ACPI Error: [DSSP] Namespace lookup failure, AE_N=
OT_FOUND (20130517/psargs-359)<br>
:[=C2=A0 =C2=A0 1.728566] ACPI Error: Method parse/execution failed [\_SB_.=
PCI0.SAT0.SPT0._GTF] (Node ffff8802138b5c30), AE_NOT_FOUND (20130517/pspars=
e-536)<br>
:[=C2=A0 =C2=A0 1.728756] ata3.00: configured for UDMA/133<br>
:[=C2=A0 =C2=A0 1.729110] scsi 2:0:0:0: Direct-Access=C2=A0 =C2=A0 =C2=A0AT=
A=C2=A0 =C2=A0 =C2=A0 SAMSUNG SP2004C=C2=A0 VM10 PQ: 0 ANSI: 5<br>
:[=C2=A0 =C2=A0 1.748009] sd 2:0:0:0: [sda] 390721968 512-byte logical bloc=
ks: (200 GB/186 GiB)<br>
:[=C2=A0 =C2=A0 1.748219] sd 2:0:0:0: [sda] Write Protect is off<br>
:[=C2=A0 =C2=A0 1.748227] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00<br>
:[=C2=A0 =C2=A0 1.748302] sd 2:0:0:0: [sda] Write cache: enabled, read cach=
e: enabled, doesn&#39;t support DPO or FUA<br>
:[=C2=A0 =C2=A0 1.753738]=C2=A0 sda: sda1 sda2<br>
:[=C2=A0 =C2=A0 1.754356] sd 2:0:0:0: [sda] Attached SCSI disk<br>
:[=C2=A0 =C2=A0 2.081247] bio: create slab &lt;bio-1&gt; at 1<br>
:[=C2=A0 =C2=A0 2.426495] SGI XFS with ACLs, security attributes, large blo=
ck/inode numbers, no debug enabled<br>
:[=C2=A0 =C2=A0 2.428871] XFS (dm-1): Mounting Filesystem<br>
:[=C2=A0 =C2=A0 2.575266] XFS (dm-1): Ending clean mount<br>
:[=C2=A0 =C2=A0 2.716589] [drm] Enabling RC6 states: RC6 on, RC6p off, RC6p=
p off<br>
:[=C2=A0 =C2=A0 2.847140] systemd-journald[90]: Received SIGTERM<br>
:[=C2=A0 =C2=A0 3.407186] type=3D1404 audit(1418209468.158:2): enforcing=3D=
1 old_enforcing=3D0 auid=3D4294967295 ses=3D4294967295<br>
:[=C2=A0 =C2=A0 3.713525] SELinux: 2048 avtab hash slots, 106409 rules.<br>
:[=C2=A0 =C2=A0 3.750012] SELinux: 2048 avtab hash slots, 106409 rules.<br>
:[=C2=A0 =C2=A0 3.806480] SELinux:=C2=A0 8 users, 86 roles, 4801 types, 280=
 bools, 1 sens, 1024 cats<br>
:[=C2=A0 =C2=A0 3.806487] SELinux:=C2=A0 83 classes, 106409 rules<br>
:[=C2=A0 =C2=A0 3.817820] SELinux:=C2=A0 Completing initialization.<br>
:[=C2=A0 =C2=A0 3.817826] SELinux:=C2=A0 Setting up existing superblocks.<b=
r>
:[=C2=A0 =C2=A0 3.817839] SELinux: initialized (dev sysfs, type sysfs), use=
s genfs_contexts<br>
:[=C2=A0 =C2=A0 3.817848] SELinux: initialized (dev rootfs, type rootfs), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.817861] SELinux: initialized (dev bdev, type bdev), uses =
genfs_contexts<br>
:[=C2=A0 =C2=A0 3.817869] SELinux: initialized (dev proc, type proc), uses =
genfs_contexts<br>
:[=C2=A0 =C2=A0 3.817937] SELinux: initialized (dev tmpfs, type tmpfs), use=
s transition SIDs<br>
:[=C2=A0 =C2=A0 3.818001] SELinux: initialized (dev devtmpfs, type devtmpfs=
), uses transition SIDs<br>
:[=C2=A0 =C2=A0 3.819365] SELinux: initialized (dev sockfs, type sockfs), u=
ses task SIDs<br>
:[=C2=A0 =C2=A0 3.819373] SELinux: initialized (dev debugfs, type debugfs),=
 uses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.820926] SELinux: initialized (dev pipefs, type pipefs), u=
ses task SIDs<br>
:[=C2=A0 =C2=A0 3.820937] SELinux: initialized (dev anon_inodefs, type anon=
_inodefs), uses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.820942] SELinux: initialized (dev aio, type aio), not con=
figured for labeling<br>
:[=C2=A0 =C2=A0 3.820947] SELinux: initialized (dev devpts, type devpts), u=
ses transition SIDs<br>
:[=C2=A0 =C2=A0 3.820979] SELinux: initialized (dev hugetlbfs, type hugetlb=
fs), uses transition SIDs<br>
:[=C2=A0 =C2=A0 3.820991] SELinux: initialized (dev mqueue, type mqueue), u=
ses transition SIDs<br>
:[=C2=A0 =C2=A0 3.821004] SELinux: initialized (dev selinuxfs, type selinux=
fs), uses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821022] SELinux: initialized (dev securityfs, type securi=
tyfs), uses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821028] SELinux: initialized (dev sysfs, type sysfs), use=
s genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821552] SELinux: initialized (dev tmpfs, type tmpfs), use=
s transition SIDs<br>
:[=C2=A0 =C2=A0 3.821570] SELinux: initialized (dev tmpfs, type tmpfs), use=
s transition SIDs<br>
:[=C2=A0 =C2=A0 3.821762] SELinux: initialized (dev tmpfs, type tmpfs), use=
s transition SIDs<br>
:[=C2=A0 =C2=A0 3.821828] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821841] SELinux: initialized (dev pstore, type pstore), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821845] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821853] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821861] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821873] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821879] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821884] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821890] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821903] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821908] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821917] SELinux: initialized (dev configfs, type configfs=
), uses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.821926] SELinux: initialized (dev dm-1, type xfs), uses x=
attr<br>
:[=C2=A0 =C2=A0 3.834171] type=3D1403 audit(1418209468.585:3): policy loade=
d auid=3D4294967295 ses=3D4294967295<br>
:[=C2=A0 =C2=A0 3.843703] systemd[1]: Successfully loaded SELinux policy in=
 460.952ms.<br>
:[=C2=A0 =C2=A0 3.977338] systemd[1]: RTC configured in localtime, applying=
 delta of 240 minutes to system time.<br>
:[=C2=A0 =C2=A0 4.062264] systemd[1]: Relabelled /dev and /run in 40.475ms.=
<br>
:[=C2=A0 =C2=A0 5.634361] SELinux: initialized (dev autofs, type autofs), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 6.091269] systemd-journald[447]: Vacuuming done, freed 0 by=
tes<br>
:[=C2=A0 =C2=A0 6.703510] SELinux: initialized (dev hugetlbfs, type hugetlb=
fs), uses transition SIDs<br>
:[=C2=A0 =C2=A0 7.523322] systemd-udevd[478]: starting version 208<br>
:[=C2=A0 =C2=A0 7.775839] parport_pc 00:0a: reported by Plug and Play ACPI<=
br>
:[=C2=A0 =C2=A0 7.775899] parport0: PC-style at 0x378, irq 5 [PCSPP,TRISTAT=
E]<br>
:[=C2=A0 =C2=A0 7.821634] shpchp: Standard Hot Plug PCI Controller Driver v=
ersion: 0.4<br>
:[=C2=A0 =C2=A0 7.831041] ACPI Warning: SystemIO range 0x0000000000000428-0=
x000000000000042f conflicts with OpRegion 0x0000000000000400-0x000000000000=
047f (\PMIO) (20130517/utaddress-254)<br>
:[=C2=A0 =C2=A0 7.831055] ACPI: If an ACPI driver is available for this dev=
ice, you should use it instead of the native driver<br>
:[=C2=A0 =C2=A0 7.831061] ACPI Warning: SystemIO range 0x0000000000000530-0=
x000000000000053f conflicts with OpRegion 0x0000000000000500-0x000000000000=
0563 (\GPIO) (20130517/utaddress-254)<br>
:[=C2=A0 =C2=A0 7.831068] ACPI: If an ACPI driver is available for this dev=
ice, you should use it instead of the native driver<br>
:[=C2=A0 =C2=A0 7.831071] ACPI Warning: SystemIO range 0x0000000000000500-0=
x000000000000052f conflicts with OpRegion 0x0000000000000500-0x000000000000=
051f (\LED_) (20130517/utaddress-254)<br>
:[=C2=A0 =C2=A0 7.831102] ACPI Warning: SystemIO range 0x0000000000000500-0=
x000000000000052f conflicts with OpRegion 0x0000000000000500-0x000000000000=
0563 (\GPIO) (20130517/utaddress-254)<br>
:[=C2=A0 =C2=A0 7.831109] ACPI: If an ACPI driver is available for this dev=
ice, you should use it instead of the native driver<br>
:[=C2=A0 =C2=A0 7.831111] lpc_ich: Resource conflict(s) found affecting gpi=
o_ich<br>
:[=C2=A0 =C2=A0 7.869355] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded<b=
r>
:[=C2=A0 =C2=A0 7.869691] r8169 0000:01:00.0: irq 42 for MSI/MSI-X<br>
:[=C2=A0 =C2=A0 7.870007] r8169 0000:01:00.0 eth0: RTL8168evl/8111evl at 0x=
ffffc90004e26000, 90:2b:34:db:46:be, XID 0c900800 IRQ 42<br>
:[=C2=A0 =C2=A0 7.870013] r8169 0000:01:00.0 eth0: jumbo features [frames: =
9200 bytes, tx checksumming: ko]<br>
:[=C2=A0 =C2=A0 7.874289] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded<b=
r>
:[=C2=A0 =C2=A0 7.874616] r8169 0000:02:00.0: irq 43 for MSI/MSI-X<br>
:[=C2=A0 =C2=A0 7.874908] r8169 0000:02:00.0 eth1: RTL8168evl/8111evl at 0x=
ffffc90004e28000, 90:2b:34:db:46:ff, XID 0c900800 IRQ 43<br>
:[=C2=A0 =C2=A0 7.874913] r8169 0000:02:00.0 eth1: jumbo features [frames: =
9200 bytes, tx checksumming: ko]<br>
:[=C2=A0 =C2=A0 7.875974] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded<b=
r>
:[=C2=A0 =C2=A0 7.876406] r8169 0000:04:00.0 (unregistered net_device): not=
 PCI Express<br>
:[=C2=A0 =C2=A0 7.876771] r8169 0000:04:00.0 eth2: RTL8169sb/8110sb at 0xff=
ffc90004e2a000, f0:7d:68:c1:fd:3f, XID 10000000 IRQ 18<br>
:[=C2=A0 =C2=A0 7.876776] r8169 0000:04:00.0 eth2: jumbo features [frames: =
7152 bytes, tx checksumming: ok]<br>
:[=C2=A0 =C2=A0 7.887265] mei_me 0000:00:16.0: irq 44 for MSI/MSI-X<br>
:[=C2=A0 =C2=A0 8.123488] snd_hda_intel 0000:00:1b.0: irq 45 for MSI/MSI-X<=
br>
:[=C2=A0 =C2=A0 8.229173] input: HDA Intel PCH HDMI/DP,pcm=3D3 as /devices/=
pci0000:00/0000:00:1b.0/sound/card0/input3<br>
:[=C2=A0 =C2=A0 8.230015] input: HDA Intel PCH Front Headphone as /devices/=
pci0000:00/0000:00:1b.0/sound/card0/input4<br>
:[=C2=A0 =C2=A0 8.230275] input: HDA Intel PCH Line Out as /devices/pci0000=
:00/0000:00:1b.0/sound/card0/input5<br>
:[=C2=A0 =C2=A0 8.231702] input: HDA Intel PCH Line as /devices/pci0000:00/=
0000:00:1b.0/sound/card0/input6<br>
:[=C2=A0 =C2=A0 8.232200] input: HDA Intel PCH Front Mic as /devices/pci000=
0:00/0000:00:1b.0/sound/card0/input7<br>
:[=C2=A0 =C2=A0 8.233240] input: HDA Intel PCH Rear Mic as /devices/pci0000=
:00/0000:00:1b.0/sound/card0/input8<br>
:[=C2=A0 =C2=A0 8.278698] ACPI Warning: SystemIO range 0x000000000000f040-0=
x000000000000f05f conflicts with OpRegion 0x000000000000f040-0x000000000000=
f04f (\_SB_.PCI0.SBUS.SMBI) (20130517/utaddress-254)<br>
:[=C2=A0 =C2=A0 8.278713] ACPI: If an ACPI driver is available for this dev=
ice, you should use it instead of the native driver<br>
:[=C2=A0 =C2=A0 8.315455] input: PC Speaker as /devices/platform/pcspkr/inp=
ut/input9<br>
:[=C2=A0 =C2=A0 8.366818] alg: No test for crc32 (crc32-pclmul)<br>
:[=C2=A0 =C2=A0 8.429970] ppdev: user-space parallel port driver<br>
:[=C2=A0 =C2=A0 8.431927] iTCO_vendor_support: vendor-support=3D0<br>
:[=C2=A0 =C2=A0 8.433957] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10<b=
r>
:[=C2=A0 =C2=A0 8.434000] iTCO_wdt: unable to reset NO_REBOOT flag, device =
disabled by hardware/BIOS<br>
:[=C2=A0 =C2=A0 8.712032] kvm: disabled by bios<br>
:[=C2=A0 =C2=A0 8.714295] systemd-udevd[484]: renamed network interface eth=
2 to enp4s0<br>
:[=C2=A0 =C2=A0 8.725329] kvm: disabled by bios<br>
:[=C2=A0 =C2=A0 8.725395] systemd-udevd[495]: renamed network interface eth=
1 to enp2s0<br>
:[=C2=A0 =C2=A0 8.821234] systemd-udevd[486]: renamed network interface eth=
0 to enp1s0<br>
:[=C2=A0 =C2=A0 9.930365] Adding 8142844k swap on /dev/mapper/centos_router=
-swap.=C2=A0 Priority:-1 extents:1 across:8142844k FS<br>
:[=C2=A0 =C2=A011.116207] XFS (sda1): Mounting Filesystem<br>
:[=C2=A0 =C2=A011.184980] XFS (dm-2): Mounting Filesystem<br>
:[=C2=A0 =C2=A012.095239] XFS (dm-2): Ending clean mount<br>
:[=C2=A0 =C2=A012.095274] SELinux: initialized (dev dm-2, type xfs), uses x=
attr<br>
:[=C2=A0 =C2=A016.109342] XFS (sda1): Ending clean mount<br>
:[=C2=A0 =C2=A016.109383] SELinux: initialized (dev sda1, type xfs), uses x=
attr<br>
:[=C2=A0 =C2=A016.133176] systemd-journald[447]: Received request to flush =
runtime journal from PID 1<br>
:[=C2=A0 =C2=A016.175544] type=3D1305 audit(1418195080.927:4): audit_pid=3D=
634 old=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dsystem_u:system_r:aud=
itd_t:s0 res=3D1<br>
:[=C2=A0 =C2=A016.872748] sd 2:0:0:0: Attached scsi generic sg0 type 0<br>
:[=C2=A0 =C2=A017.157388] ip_tables: (C) 2000-2006 Netfilter Core Team<br>
:[=C2=A0 =C2=A017.327288] nf_conntrack version 0.5.0 (16384 buckets, 65536 =
max)<br>
:[=C2=A0 =C2=A017.418998] ip6_tables: (C) 2000-2006 Netfilter Core Team<br>
:[=C2=A0 =C2=A017.561155] Ebtables v2.0 registered<br>
:[=C2=A0 =C2=A017.587651] Bridge firewalling registered<br>
:[=C2=A0 =C2=A018.266198] r8169 0000:01:00.0 enp1s0: link down<br>
:[=C2=A0 =C2=A018.266220] r8169 0000:01:00.0 enp1s0: link down<br>
:[=C2=A0 =C2=A018.266460] IPv6: ADDRCONF(NETDEV_UP): enp1s0: link is not re=
ady<br>
:[=C2=A0 =C2=A018.396477] r8169 0000:02:00.0 enp2s0: link down<br>
:[=C2=A0 =C2=A018.396733] IPv6: ADDRCONF(NETDEV_UP): enp2s0: link is not re=
ady<br>
:[=C2=A0 =C2=A018.441873] r8169 0000:04:00.0 enp4s0: link down<br>
:[=C2=A0 =C2=A018.441923] r8169 0000:04:00.0 enp4s0: link down<br>
:[=C2=A0 =C2=A018.442011] IPv6: ADDRCONF(NETDEV_UP): enp4s0: link is not re=
ady<br>
:[=C2=A0 =C2=A019.937537] r8169 0000:01:00.0 enp1s0: link up<br>
:[=C2=A0 =C2=A019.937554] IPv6: ADDRCONF(NETDEV_CHANGE): enp1s0: link becom=
es ready<br>
:[=C2=A0 =C2=A020.099898] PPP generic driver version 2.4.2<br>
:[=C2=A0 =C2=A021.582535] PPP BSD Compression module registered<br>
:[=C2=A0 =C2=A046.441170] r8169 0000:04:00.0 enp4s0: link up<br>
:[=C2=A0 =C2=A046.441190] IPv6: ADDRCONF(NETDEV_CHANGE): enp4s0: link becom=
es ready<br>
:[ 3693.587715] perf samples too long (2515 &gt; 2500), lowering kernel.per=
f_event_max_sample_rate to 50000<br>
:[12382.969343] perf samples too long (5002 &gt; 5000), lowering kernel.per=
f_event_max_sample_rate to 25000<br>
:[18808.075550] Ebtables v2.0 unregistered<br>
:[18808.405133] ip_tables: (C) 2000-2006 Netfilter Core Team<br>
:[18808.435406] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)<br>
:[18808.758001] ip6_tables: (C) 2000-2006 Netfilter Core Team<br>
:[28503.378469] ip_tables: (C) 2000-2006 Netfilter Core Team<br>
:[28503.409093] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)<br>
:[28503.731692] ip6_tables: (C) 2000-2006 Netfilter Core Team<br>
:[29409.061343] ip_tables: (C) 2000-2006 Netfilter Core Team<br>
:[29409.090714] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)<br>
:[29409.410958] ip6_tables: (C) 2000-2006 Netfilter Core Team<br>
:[105103.876746] ip_tables: (C) 2000-2006 Netfilter Core Team<br>
:[105103.908118] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)<br>
:[105104.231344] ip6_tables: (C) 2000-2006 Netfilter Core Team<br>
:[129620.535874] systemd-journald[447]: Vacuuming done, freed 0 bytes<br>
:[172946.916946] ------------[ cut here ]------------<br>
:[172946.916978] WARNING: at net/sched/sch_generic.c:259 dev_watchdog+0x270=
/0x280()<br>
:[172946.916985] NETDEV WATCHDOG: enp4s0 (r8169): transmit queue 0 timed ou=
t<br>
:[172946.916990] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_br=
oadcast xt_nat xt_mark ipt_MASQUERADE ip6t_rpfilter ip6table_nat nf_nat_ipv=
6 ip6table_mangle ip6table_security ip6table_raw ip6t_REJECT nf_conntrack_i=
pv6 nf_defrag_ipv6 ip6table_filter ip6_tables iptable_nat nf_nat_ipv4 nf_na=
t iptable_mangle iptable_security iptable_raw ipt_REJECT nf_conntrack_ipv4 =
nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_filter ip_tables tcp_diag =
inet_diag bsd_comp ppp_synctty ppp_async crc_ccitt ppp_generic slhc bridge =
stp llc sg coretemp kvm serio_raw crct10dif_pclmul iTCO_wdt iTCO_vendor_sup=
port ppdev crc32_pclmul pcspkr i2c_i801 crc32c_intel snd_hda_codec_hdmi snd=
_hda_codec_realtek snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hw=
dep snd_seq snd_seq_device ghash_clmulni_intel snd_pcm snd_page_alloc<br>
:[172946.917077]=C2=A0 snd_timer snd soundcore mei_me mei cryptd r8169 mii =
lpc_ich mfd_core shpchp parport_pc parport mperf xfs libcrc32c sd_mod crc_t=
10dif crct10dif_common ata_generic pata_acpi ahci pata_jmicron i915 libahci=
 libata i2c_algo_bit drm_kms_helper drm i2c_core video dm_mirror dm_region_=
hash dm_log dm_mod [last unloaded: ip_tables]<br>
:[172946.917122] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.10.0-123.el7.x=
86_64 #1<br>
:[172946.917127] Hardware name: Gigabyte Technology Co., Ltd. To be filled =
by O.E.M./C847N, BIOS F2 11/09/2012<br>
:[172946.917132]=C2=A0 ffff88021f303d90 eeb6307312c80fd5 ffff88021f303d48 f=
fffffff815e19ba<br>
:[172946.917140]=C2=A0 ffff88021f303d80 ffffffff8105dee1 0000000000000000 f=
fff880212550000<br>
:[172946.917147]=C2=A0 ffff88021139f280 0000000000000001 0000000000000001 f=
fff88021f303de8<br>
:[172946.917154] Call Trace:<br>
:[172946.917159]=C2=A0 &lt;IRQ&gt;=C2=A0 [&lt;ffffffff815e19ba&gt;] dump_st=
ack+0x19/0x1b<br>
:[172946.917178]=C2=A0 [&lt;ffffffff8105dee1&gt;] warn_slowpath_common+0x61=
/0x80<br>
:[172946.917187]=C2=A0 [&lt;ffffffff8105df5c&gt;] warn_slowpath_fmt+0x5c/0x=
80<br>
:[172946.917196]=C2=A0 [&lt;ffffffff81088671&gt;] ? run_posix_cpu_timers+0x=
51/0x840<br>
:[172946.917207]=C2=A0 [&lt;ffffffff814f0ab0&gt;] dev_watchdog+0x270/0x280<=
br>
:[172946.917213]=C2=A0 [&lt;ffffffff814f0840&gt;] ? dev_graft_qdisc+0x80/0x=
80<br>
:[172946.917222]=C2=A0 [&lt;ffffffff8106d236&gt;] call_timer_fn+0x36/0x110<=
br>
:[172946.917228]=C2=A0 [&lt;ffffffff814f0840&gt;] ? dev_graft_qdisc+0x80/0x=
80<br>
:[172946.917236]=C2=A0 [&lt;ffffffff8106f2ff&gt;] run_timer_softirq+0x21f/0=
x320<br>
:[172946.917244]=C2=A0 [&lt;ffffffff81067047&gt;] __do_softirq+0xf7/0x290<b=
r>
:[172946.917253]=C2=A0 [&lt;ffffffff815f3a5c&gt;] call_softirq+0x1c/0x30<br=
>
:[172946.917264]=C2=A0 [&lt;ffffffff81014d25&gt;] do_softirq+0x55/0x90<br>
:[172946.917271]=C2=A0 [&lt;ffffffff810673e5&gt;] irq_exit+0x115/0x120<br>
:[172946.917279]=C2=A0 [&lt;ffffffff815f4435&gt;] smp_apic_timer_interrupt+=
0x45/0x60<br>
:[172946.917285]=C2=A0 [&lt;ffffffff815f2d9d&gt;] apic_timer_interrupt+0x6d=
/0x80<br>
:[172946.917289]=C2=A0 &lt;EOI&gt;=C2=A0 [&lt;ffffffff814834df&gt;] ? cpuid=
le_enter_state+0x4f/0xc0<br>
:[172946.917306]=C2=A0 [&lt;ffffffff81483615&gt;] cpuidle_idle_call+0xc5/0x=
200<br>
:[172946.917314]=C2=A0 [&lt;ffffffff8101bc7e&gt;] arch_cpu_idle+0xe/0x30<br=
>
:[172946.917324]=C2=A0 [&lt;ffffffff810b4725&gt;] cpu_startup_entry+0xf5/0x=
290<br>
:[172946.917333]=C2=A0 [&lt;ffffffff815cfee1&gt;] start_secondary+0x265/0x2=
7b<br>
:[172946.917339] ---[ end trace 87a83aa998315558 ]---<br>
:[172946.927322] r8169 0000:04:00.0 enp4s0: link up<br>
:[172954.291571] SELinux: initialized (dev binfmt_misc, type binfmt_misc), =
uses genfs_contexts<br>
:[172958.827459] xor: measuring software checksum speed<br>
:[172958.836820]=C2=A0 =C2=A0 prefetch64-sse:=C2=A0 5904.000 MB/sec<br>
:[172958.846817]=C2=A0 =C2=A0 generic_sse:=C2=A0 5500.000 MB/sec<br>
:[172958.846821] xor: using function: prefetch64-sse (5904.000 MB/sec)<br>
:[172958.880819] raid6: sse2x1=C2=A0 =C2=A0 2792 MB/s<br>
:[172958.897820] raid6: sse2x2=C2=A0 =C2=A0 3628 MB/s<br>
:[172958.914820] raid6: sse2x4=C2=A0 =C2=A0 4207 MB/s<br>
:[172958.914824] raid6: using algorithm sse2x4 (4207 MB/s)<br>
:[172958.914827] raid6: using ssse3x2 recovery algorithm<br>
:[172959.007487] bio: create slab &lt;bio-2&gt; at 2<br>
:[172959.009677] Btrfs loaded<br>
:[172959.034533] fuse init (API version 7.22)<br>
:[172959.056836] SELinux: initialized (dev fusectl, type fusectl), uses gen=
fs_contexts<br>
:[172961.172566] nr_pdflush_threads exported in /proc is scheduled for remo=
val<br>
:[172961.173004] sysctl: The scan_unevictable_pages sysctl/node-interface h=
as been disabled for lack of a legitimate use case.=C2=A0 If you have one, =
please send an email to <a href=3D"mailto:linux-mm@kvack.org">linux-mm@kvac=
k.org</a>.<br>
<br>
os_info:<br>
:NAME=3D&quot;CentOS Linux&quot;<br>
:VERSION=3D&quot;7 (Core)&quot;<br>
:ID=3D&quot;centos&quot;<br>
:ID_LIKE=3D&quot;rhel fedora&quot;<br>
:VERSION_ID=3D&quot;7&quot;<br>
:PRETTY_NAME=3D&quot;CentOS Linux 7 (Core)&quot;<br>
:ANSI_COLOR=3D&quot;0;31&quot;<br>
:CPE_NAME=3D&quot;cpe:/o:centos:centos:7&quot;<br>
:HOME_URL=3D&quot;<a href=3D"https://www.centos.org/" target=3D"_blank">htt=
ps://www.centos.org/</a>&quot;<br>
:BUG_REPORT_URL=3D&quot;<a href=3D"https://bugs.centos.org/" target=3D"_bla=
nk">https://bugs.centos.org/</a>&quot;<br>
:<br>
<br>
proc_modules:<br>
:nf_conntrack_netbios_ns 12665 0 - Live 0xffffffffa0585000<br>
:nf_conntrack_broadcast 12589 1 nf_conntrack_netbios_ns, Live 0xffffffffa05=
80000<br>
:xt_nat 12681 21 - Live 0xffffffffa057b000<br>
:xt_mark 12563 63 - Live 0xffffffffa0576000<br>
:ipt_MASQUERADE 12880 1 - Live 0xffffffffa0571000<br>
:ip6t_rpfilter 12546 1 - Live 0xffffffffa056c000<br>
:ip6table_nat 13015 1 - Live 0xffffffffa0567000<br>
:nf_nat_ipv6 13279 1 ip6table_nat, Live 0xffffffffa0538000<br>
:ip6table_mangle 12700 1 - Live 0xffffffffa0533000<br>
:ip6table_security 12710 1 - Live 0xffffffffa052e000<br>
:ip6table_raw 12683 1 - Live 0xffffffffa0529000<br>
:ip6t_REJECT 12939 2 - Live 0xffffffffa0524000<br>
:nf_conntrack_ipv6 18738 11 - Live 0xffffffffa051a000<br>
:nf_defrag_ipv6 34651 1 nf_conntrack_ipv6, Live 0xffffffffa050c000<br>
:ip6table_filter 12815 1 - Live 0xffffffffa0507000<br>
:ip6_tables 27025 5 ip6table_nat,ip6table_mangle,ip6table_security,ip6table=
_raw,ip6table_filter, Live 0xffffffffa04fb000<br>
:iptable_nat 13011 1 - Live 0xffffffffa04f1000<br>
:nf_nat_ipv4 13263 1 iptable_nat, Live 0xffffffffa04f6000<br>
:nf_nat 21798 6 xt_nat,ipt_MASQUERADE,ip6table_nat,nf_nat_ipv6,iptable_nat,=
nf_nat_ipv4, Live 0xffffffffa04ea000<br>
:iptable_mangle 12695 1 - Live 0xffffffffa04e5000<br>
:iptable_security 12705 1 - Live 0xffffffffa04e0000<br>
:iptable_raw 12678 1 - Live 0xffffffffa04db000<br>
:ipt_REJECT 12541 2 - Live 0xffffffffa04d6000<br>
:nf_conntrack_ipv4 14862 31 - Live 0xffffffffa04cd000<br>
:nf_defrag_ipv4 12729 1 nf_conntrack_ipv4, Live 0xffffffffa04a3000<br>
:xt_conntrack 12760 40 - Live 0xffffffffa0493000<br>
:nf_conntrack 101024 11 nf_conntrack_netbios_ns,nf_conntrack_broadcast,ipt_=
MASQUERADE,ip6table_nat,nf_nat_ipv6,nf_conntrack_ipv6,iptable_nat,nf_nat_ip=
v4,nf_nat,nf_conntrack_ipv4,xt_conntrack, Live 0xffffffffa04b3000<br>
:iptable_filter 12810 1 - Live 0xffffffffa0421000<br>
:ip_tables 27239 5 iptable_nat,iptable_mangle,iptable_security,iptable_raw,=
iptable_filter, Live 0xffffffffa04ab000<br>
:tcp_diag 12591 0 - Live 0xffffffffa05b3000<br>
:inet_diag 18543 1 tcp_diag, Live 0xffffffffa058a000<br>
:bsd_comp 12921 0 - Live 0xffffffffa05bd000<br>
:ppp_synctty 13237 0 - Live 0xffffffffa05a3000<br>
:ppp_async 17413 1 - Live 0xffffffffa05ad000<br>
:crc_ccitt 12707 1 ppp_async, Live 0xffffffffa05a8000<br>
:ppp_generic 33037 7 bsd_comp,ppp_synctty,ppp_async, Live 0xffffffffa059900=
0<br>
:slhc 13450 1 ppp_generic, Live 0xffffffffa0594000<br>
:bridge 110196 0 - Live 0xffffffffa054b000<br>
:stp 12976 1 bridge, Live 0xffffffffa0546000<br>
:llc 14552 2 bridge,stp, Live 0xffffffffa053d000<br>
:sg 36533 0 - Live 0xffffffffa0499000<br>
:coretemp 13435 0 - Live 0xffffffffa041c000<br>
:kvm 441119 0 - Live 0xffffffffa0426000<br>
:serio_raw 13462 0 - Live 0xffffffffa0417000<br>
:crct10dif_pclmul 14289 0 - Live 0xffffffffa0412000<br>
:iTCO_wdt 13480 0 - Live 0xffffffffa040d000<br>
:iTCO_vendor_support 13718 1 iTCO_wdt, Live 0xffffffffa0402000<br>
:ppdev 17671 0 - Live 0xffffffffa0407000<br>
:crc32_pclmul 13113 0 - Live 0xffffffffa03f6000<br>
:pcspkr 12718 0 - Live 0xffffffffa03f1000<br>
:i2c_i801 18135 0 - Live 0xffffffffa03fc000<br>
:crc32c_intel 22079 0 - Live 0xffffffffa0385000<br>
:snd_hda_codec_hdmi 46433 1 - Live 0xffffffffa03b3000<br>
:snd_hda_codec_realtek 57226 1 - Live 0xffffffffa03e2000<br>
:snd_hda_codec_generic 68082 1 snd_hda_codec_realtek, Live 0xffffffffa03d00=
00<br>
:snd_hda_intel 48259 0 - Live 0xffffffffa03c3000<br>
:snd_hda_codec 137343 4 snd_hda_codec_hdmi,snd_hda_codec_realtek,snd_hda_co=
dec_generic,snd_hda_intel, Live 0xffffffffa0390000<br>
:snd_hwdep 13602 1 snd_hda_codec, Live 0xffffffffa0369000<br>
:snd_seq 61519 0 - Live 0xffffffffa0374000<br>
:snd_seq_device 14497 1 snd_seq, Live 0xffffffffa0364000<br>
:ghash_clmulni_intel 13259 0 - Live 0xffffffffa036f000<br>
:snd_pcm 97511 3 snd_hda_codec_hdmi,snd_hda_intel,snd_hda_codec, Live 0xfff=
fffffa034b000<br>
:snd_page_alloc 18710 2 snd_hda_intel,snd_pcm, Live 0xffffffffa0338000<br>
:snd_timer 29482 2 snd_seq,snd_pcm, Live 0xffffffffa0342000<br>
:snd 74645 10 snd_hda_codec_hdmi,snd_hda_codec_realtek,snd_hda_codec_generi=
c,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_seq,snd_seq_device,snd_pcm,snd_=
timer, Live 0xffffffffa0324000<br>
:soundcore 15047 1 snd, Live 0xffffffffa02e8000<br>
:mei_me 18568 0 - Live 0xffffffffa0305000<br>
:mei 77872 1 mei_me, Live 0xffffffffa030b000<br>
:cryptd 20359 1 ghash_clmulni_intel, Live 0xffffffffa013a000<br>
:r8169 71677 0 - Live 0xffffffffa02f2000<br>
:mii 13934 1 r8169, Live 0xffffffffa02ed000<br>
:lpc_ich 16977 0 - Live 0xffffffffa0134000<br>
:mfd_core 13435 1 lpc_ich, Live 0xffffffffa011b000<br>
:shpchp 37032 0 - Live 0xffffffffa0140000<br>
:parport_pc 28165 0 - Live 0xffffffffa0120000<br>
:parport 42348 2 ppdev,parport_pc, Live 0xffffffffa0128000<br>
:mperf 12667 0 - Live 0xffffffffa0111000<br>
:xfs 914152 3 - Live 0xffffffffa0207000<br>
:libcrc32c 12644 1 xfs, Live 0xffffffffa0116000<br>
:sd_mod 45373 3 - Live 0xffffffffa0104000<br>
:crc_t10dif 12714 1 sd_mod, Live 0xffffffffa00b5000<br>
:crct10dif_common 12595 2 crct10dif_pclmul,crc_t10dif, Live 0xffffffffa00b0=
000<br>
:ata_generic 12910 0 - Live 0xffffffffa00a8000<br>
:pata_acpi 13038 0 - Live 0xffffffffa003e000<br>
:ahci 25819 2 - Live 0xffffffffa00a0000<br>
:pata_jmicron 12758 0 - Live 0xffffffffa004f000<br>
:i915 710975 1 - Live 0xffffffffa0158000<br>
:libahci 32009 1 ahci, Live 0xffffffffa014f000<br>
:libata 219478 5 ata_generic,pata_acpi,ahci,pata_jmicron,libahci, Live 0xff=
ffffffa00ca000<br>
:i2c_algo_bit 13413 1 i915, Live 0xffffffffa0022000<br>
:drm_kms_helper 52758 1 i915, Live 0xffffffffa00bc000<br>
:drm 297829 2 i915,drm_kms_helper, Live 0xffffffffa0056000<br>
:i2c_core 40325 5 i2c_i801,i915,i2c_algo_bit,drm_kms_helper,drm, Live 0xfff=
fffffa0044000<br>
:video 19267 1 i915, Live 0xffffffffa0038000<br>
:dm_mirror 22135 0 - Live 0xffffffffa002d000<br>
:dm_region_hash 20862 1 dm_mirror, Live 0xffffffffa001b000<br>
:dm_log 18411 2 dm_mirror,dm_region_hash, Live 0xffffffffa0027000<br>
:dm_mod 102999 11 dm_mirror,dm_log, Live 0xffffffffa0000000<br>
<br>
suspend_stats:<br>
:success: 0<br>
:fail: 0<br>
:failed_freeze: 0<br>
:failed_prepare: 0<br>
:failed_suspend: 0<br>
:failed_suspend_late: 0<br>
:failed_suspend_noirq: 0<br>
:failed_resume: 0<br>
:failed_resume_early: 0<br>
:failed_resume_noirq: 0<br>
:failures:<br>
:=C2=A0 last_failed_dev:<br>
:<br>
:=C2=A0 last_failed_errno:=C2=A0 =C2=A00<br>
:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00<br>
:=C2=A0 last_failed_step:<br>
:<br>
<br>----------<br><span class=3D"undefined"><font color=3D"#888">From: <b c=
lass=3D"undefined"></b> <span dir=3D"ltr">&lt;user@localhost.centos&gt;</sp=
an><br>Date: 2015-02-02 2:12 GMT+03:00<br>To: root@localhost.centos<br></fo=
nt><br></span><br><span class=3D"">abrt_version:=C2=A0 =C2=A02.1.11<br>
cmdline:=C2=A0 =C2=A0 =C2=A0 =C2=A0 BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el7.x8=
6_64 root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro <a href=3D"http:=
//rd.lvm.lv" target=3D"_blank">rd.lvm.lv</a>=3Dcentos_router/swap vconsole.=
font=3Dlatarcyrheb-sun16 <a href=3D"http://rd.lvm.lv" target=3D"_blank">rd.=
lvm.lv</a>=3Dcentos_router/root crashkernel=3Dauto vconsole.keymap=3Dus rhg=
b quiet LANG=3Den_US.UTF-8<br>
hostname:=C2=A0 =C2=A0 =C2=A0 =C2=A0router.centos<br>
kernel:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03.10.0-123.el7.x86_64<br>
</span>last_occurrence: 1422832344<br>
<span class=3D"">pkg_arch:=C2=A0 =C2=A0 =C2=A0 =C2=A0x86_64<br>
pkg_epoch:=C2=A0 =C2=A0 =C2=A0 0<br>
pkg_name:=C2=A0 =C2=A0 =C2=A0 =C2=A0kernel<br>
pkg_release:=C2=A0 =C2=A0 123.el7<br>
pkg_version:=C2=A0 =C2=A0 3.10.0<br>
runlevel:=C2=A0 =C2=A0 =C2=A0 =C2=A0N 3<br>
</span>time:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Fri 23 Jan 2015 04:15:=
18 PM MSK<br>
<br>
backtrace:<br>
:BUG: soft lockup - CPU#0 stuck for 21s! [rcuos/0:12]<br>
:Modules linked in: bsd_comp nf_conntrack_netbios_ns nf_conntrack_broadcast=
 ppp_synctty ppp_async crc_ccitt ppp_generic slhc xt_nat xt_mark ipt_MASQUE=
RADE ip6t_rpfilter ip6t_REJECT ipt_REJECT xt_conntrack ebtable_nat ebtable_=
broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv=
6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw=
 ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf=
_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw i=
ptable_filter ip_tables sg coretemp kvm crct10dif_pclmul crc32_pclmul snd_h=
da_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel snd=
_hda_codec serio_raw crc32c_intel snd_hwdep snd_seq snd_seq_device snd_pcm =
ppdev iTCO_wdt iTCO_vendor_support i2c_i801 pcspkr<br>
:ghash_clmulni_intel snd_page_alloc cryptd mei_me mei snd_timer snd soundco=
re r8169 mii parport_pc parport lpc_ich mfd_core shpchp mperf xfs libcrc32c=
 sd_mod crc_t10dif crct10dif_common ata_generic pata_acpi i915 ahci i2c_alg=
o_bit pata_jmicron libahci drm_kms_helper libata drm i2c_core video dm_mirr=
or dm_region_hash dm_log dm_mod<br>
:CPU: 0 PID: 12 Comm: rcuos/0 Not tainted 3.10.0-123.el7.x86_64 #1<br>
<span class=3D"">:Hardware name: Gigabyte Technology Co., Ltd. To be filled=
 by O.E.M./C847N, BIOS F2 11/09/2012<br>
</span>:task: ffff880213970000 ti: ffff88021396e000 task.ti: ffff88021396e0=
00<br>
:RIP: 0010:[&lt;ffffffffa04addf1&gt;]=C2=A0 [&lt;ffffffffa04addf1&gt;] nf_c=
onntrack_tuple_taken+0x91/0x1a0 [nf_conntrack]<br>
:RSP: 0018:ffff88021f203838=C2=A0 EFLAGS: 00000246<br>
:RAX: ffff8801fc8753e8 RBX: ffff88021f2037b8 RCX: 0000000000000000<br>
:RDX: 0000000000000001 RSI: 00000000a7cd4ec5 RDI: ffff8800ca2e7000<br>
:RBP: ffff88021f203860 R08: 000000009b52ef62 R09: 00000000ae0c5d8d<br>
:R10: ffff88021f203888 R11: ffff880212522000 R12: ffff88021f2037a8<br>
:R13: ffffffff815f2d9d R14: ffff88021f203860 R15: ffff88021f203870<br>
:FS:=C2=A0 0000000000000000(0000) GS:ffff88021f200000(0000) knlGS:000000000=
0000000<br>
:CS:=C2=A0 0010 DS: 0000 ES: 0000 CR0: 0000000080050033<br>
:CR2: 00007f0e9ceed000 CR3: 00000002116ad000 CR4: 00000000000407f0<br>
:DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000<br>
:DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400<br>
:Stack:<br>
:ffff8800cc67e9c0 ffff88021f2039e0 ffff88021f203a70 000000000000c16d<br>
:000000000000c2c1 ffff88021f2038a8 ffffffffa04d4198 000000000601a8c0<br>
:0000000000000000 0101a8c00002d59d 0000000000000000 0106c1c600000000<br>
:Call Trace:<br>
<div></div>:[=C2=A0 =C2=A0 0.002000] tsc: Detected 1097.502 MHz processor<b=
r>
:[=C2=A0 =C2=A0 0.000004] Calibrating delay loop (skipped), value calculate=
d using timer frequency.. 2195.00 BogoMIPS (lpj=3D1097502)<br>
<span class=3D"">:[=C2=A0 =C2=A0 0.000009] pid_max: default: 32768 minimum:=
 301<br>
:[=C2=A0 =C2=A0 0.000048] Security Framework initialized<br>
</span>:[=C2=A0 =C2=A0 0.000060] SELinux:=C2=A0 Initializing.<br>
:[=C2=A0 =C2=A0 0.000074] SELinux:=C2=A0 Starting in permissive mode<br>
:[=C2=A0 =C2=A0 0.001472] Dentry cache hash table entries: 1048576 (order: =
11, 8388608 bytes)<br>
:[=C2=A0 =C2=A0 0.005228] Inode-cache hash table entries: 524288 (order: 10=
, 4194304 bytes)<br>
:[=C2=A0 =C2=A0 0.006776] Mount-cache hash table entries: 4096<br>
:[=C2=A0 =C2=A0 0.007130] Initializing cgroup subsys memory<br>
:[=C2=A0 =C2=A0 0.007144] Initializing cgroup subsys devices<br>
:[=C2=A0 =C2=A0 0.007147] Initializing cgroup subsys freezer<br>
:[=C2=A0 =C2=A0 0.007150] Initializing cgroup subsys net_cls<br>
:[=C2=A0 =C2=A0 0.007153] Initializing cgroup subsys blkio<br>
:[=C2=A0 =C2=A0 0.007155] Initializing cgroup subsys perf_event<br>
:[=C2=A0 =C2=A0 0.007158] Initializing cgroup subsys hugetlb<br>
:[=C2=A0 =C2=A0 0.007203] CPU: Physical Processor ID: 0<br>
:[=C2=A0 =C2=A0 0.007205] CPU: Processor Core ID: 0<br>
:[=C2=A0 =C2=A0 0.007214] ENERGY_PERF_BIAS: Set to &#39;normal&#39;, was &#=
39;performance&#39;<br>
<span class=3D"">:ENERGY_PERF_BIAS: View and update with x86_energy_perf_po=
licy(8)<br>
</span>:[=C2=A0 =C2=A0 0.007219] mce: CPU supports 7 MCE banks<br>
:[=C2=A0 =C2=A0 0.007241] CPU0: Thermal monitoring enabled (TM1)<br>
:[=C2=A0 =C2=A0 0.007257] Last level iTLB entries: 4KB 512, 2MB 0, 4MB 0<br=
>
<span class=3D"">:Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32<br>
:tlb_flushall_shift: 6<br>
</span>:[=C2=A0 =C2=A0 0.007433] Freeing SMP alternatives: 24k freed<br>
:[=C2=A0 =C2=A0 0.010436] ACPI: Core revision 20130517<br>
:[=C2=A0 =C2=A0 0.022201] ACPI: All ACPI Tables successfully acquired<br>
:[=C2=A0 =C2=A0 0.022430] ftrace: allocating 23383 entries in 92 pages<br>
:[=C2=A0 =C2=A0 0.047587] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=
=3D-1 pin2=3D-1<br>
:[=C2=A0 =C2=A0 0.057594] smpboot: CPU0: Intel(R) Celeron(R) CPU 847 @ 1.10=
GHz (fam: 06, model: 2a, stepping: 07)<br>
:[=C2=A0 =C2=A0 0.057609] TSC deadline timer enabled<br>
:[=C2=A0 =C2=A0 0.057626] Performance Events: PEBS fmt1+, 16-deep LBR, Sand=
yBridge events, full-width counters, Intel PMU driver.<br>
:[=C2=A0 =C2=A0 0.057642] ... version:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 3<br>
:[=C2=A0 =C2=A0 0.057644] ... bit width:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 48<br>
:[=C2=A0 =C2=A0 0.057646] ... generic registers:=C2=A0 =C2=A0 =C2=A0 8<br>
:[=C2=A0 =C2=A0 0.057648] ... value mask:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A00000ffffffffffff<br>
:[=C2=A0 =C2=A0 0.057651] ... max period:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A00000ffffffffffff<br>
:[=C2=A0 =C2=A0 0.057653] ... fixed-purpose events:=C2=A0 =C2=A03<br>
:[=C2=A0 =C2=A0 0.057655] ... event mask:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A000000007000000ff<br>
:[=C2=A0 =C2=A0 0.060063] smpboot: Booting Node=C2=A0 =C2=A00, Processors=
=C2=A0 #1 OK<br>
:[=C2=A0 =C2=A0 0.071128] CPU1 microcode updated early to revision 0x29, da=
te =3D 2013-06-12<br>
:[=C2=A0 =C2=A0 0.073340] Brought up 2 CPUs<br>
:[=C2=A0 =C2=A0 0.073347] smpboot: Total of 2 processors activated (4390.00=
 BogoMIPS)<br>
:[=C2=A0 =C2=A0 0.073445] NMI watchdog: enabled on all CPUs, permanently co=
nsumes one hw-PMU counter.<br>
:[=C2=A0 =C2=A0 0.075964] devtmpfs: initialized<br>
:[=C2=A0 =C2=A0 0.078104] EVM: security.selinux<br>
:[=C2=A0 =C2=A0 0.078108] EVM: security.ima<br>
:[=C2=A0 =C2=A0 0.078110] EVM: security.capability<br>
:[=C2=A0 =C2=A0 0.078237] PM: Registering ACPI NVS region [mem 0xd9a96000-0=
xd9bbafff] (1200128 bytes)<br>
:[=C2=A0 =C2=A0 0.078277] PM: Registering ACPI NVS region [mem 0xda6ba000-0=
xda6fcfff] (274432 bytes)<br>
:[=C2=A0 =C2=A0 0.079934] atomic64 test passed for x86-64 platform with CX8=
 and with SSE<br>
:[=C2=A0 =C2=A0 0.080014] NET: Registered protocol family 16<br>
:[=C2=A0 =C2=A0 0.080281] ACPI: bus type PCI registered<br>
:[=C2=A0 =C2=A0 0.080285] acpiphp: ACPI Hot Plug PCI Controller Driver vers=
ion: 0.5<br>
:[=C2=A0 =C2=A0 0.080369] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem=
 0xf8000000-0xfbffffff] (base 0xf8000000)<br>
:[=C2=A0 =C2=A0 0.080374] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] rese=
rved in E820<br>
:[=C2=A0 =C2=A0 0.095794] PCI: Using configuration type 1 for base access<b=
r>
:[=C2=A0 =C2=A0 0.097436] bio: create slab &lt;bio-0&gt; at 0<br>
:[=C2=A0 =C2=A0 0.097584] ACPI: Added _OSI(Module Device)<br>
:[=C2=A0 =C2=A0 0.097588] ACPI: Added _OSI(Processor Device)<br>
:[=C2=A0 =C2=A0 0.097591] ACPI: Added _OSI(3.0 _SCP Extensions)<br>
:[=C2=A0 =C2=A0 0.097594] ACPI: Added _OSI(Processor Aggregator Device)<br>
:[=C2=A0 =C2=A0 0.100539] ACPI: EC: Look up EC in DSDT<br>
:[=C2=A0 =C2=A0 0.104150] ACPI: Executed 1 blocks of module-level executabl=
e AML code<br>
:[=C2=A0 =C2=A0 0.111476] ACPI: SSDT 00000000d9a37018 0083B (v01=C2=A0 PmRe=
f=C2=A0 Cpu0Cst 00003001 INTL 20051117)<br>
:[=C2=A0 =C2=A0 0.112239] ACPI: Dynamic OEM Table Load:<br>
:[=C2=A0 =C2=A0 0.112244] ACPI: SSDT=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0(null) 0083B (v01=C2=A0 PmRef=C2=A0 Cpu0Cst 00003001 INTL 20051117)<br>
:[=C2=A0 =C2=A0 0.114159] ACPI: SSDT 00000000d9a38a98 00303 (v01=C2=A0 PmRe=
f=C2=A0 =C2=A0 ApIst 00003000 INTL 20051117)<br>
:[=C2=A0 =C2=A0 0.114984] ACPI: Dynamic OEM Table Load:<br>
:[=C2=A0 =C2=A0 0.114989] ACPI: SSDT=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0(null) 00303 (v01=C2=A0 PmRef=C2=A0 =C2=A0 ApIst 00003000 INTL 20051117)=
<br>
:[=C2=A0 =C2=A0 0.116849] ACPI: SSDT 00000000d9a44c18 00119 (v01=C2=A0 PmRe=
f=C2=A0 =C2=A0 ApCst 00003000 INTL 20051117)<br>
:[=C2=A0 =C2=A0 0.117583] ACPI: Dynamic OEM Table Load:<br>
:[=C2=A0 =C2=A0 0.117587] ACPI: SSDT=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0(null) 00119 (v01=C2=A0 PmRef=C2=A0 =C2=A0 ApCst 00003000 INTL 20051117)=
<br>
:[=C2=A0 =C2=A0 0.119484] ACPI: Interpreter enabled<br>
:[=C2=A0 =C2=A0 0.119497] ACPI Exception: AE_NOT_FOUND, While evaluating Sl=
eep State [\_S1_] (20130517/hwxface-571)<br>
:[=C2=A0 =C2=A0 0.119506] ACPI Exception: AE_NOT_FOUND, While evaluating Sl=
eep State [\_S2_] (20130517/hwxface-571)<br>
:[=C2=A0 =C2=A0 0.119533] ACPI: (supports S0 S3 S4 S5)<br>
:[=C2=A0 =C2=A0 0.119536] ACPI: Using IOAPIC for interrupt routing<br>
:[=C2=A0 =C2=A0 0.119590] PCI: Using host bridge windows from ACPI; if nece=
ssary, use &quot;pci=3Dnocrs&quot; and report a bug<br>
:[=C2=A0 =C2=A0 0.119875] ACPI: No dock devices found.<br>
:[=C2=A0 =C2=A0 0.135632] ACPI: Power Resource [FN00] (off)<br>
:[=C2=A0 =C2=A0 0.135797] ACPI: Power Resource [FN01] (off)<br>
:[=C2=A0 =C2=A0 0.135955] ACPI: Power Resource [FN02] (off)<br>
:[=C2=A0 =C2=A0 0.136104] ACPI: Power Resource [FN03] (off)<br>
:[=C2=A0 =C2=A0 0.136256] ACPI: Power Resource [FN04] (off)<br>
:[=C2=A0 =C2=A0 0.137451] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00=
-3e])<br>
:[=C2=A0 =C2=A0 0.137462] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfi=
g ASPM ClockPM Segments MSI]<br>
:[=C2=A0 =C2=A0 0.137902] acpi PNP0A08:00: _OSC: platform does not support =
[PCIeHotplug PME]<br>
:[=C2=A0 =C2=A0 0.138174] acpi PNP0A08:00: _OSC: OS now controls [AER PCIeC=
apability]<br>
:[=C2=A0 =C2=A0 0.139307] PCI host bridge to bus 0000:00<br>
:[=C2=A0 =C2=A0 0.139314] pci_bus 0000:00: root bus resource [bus 00-3e]<br=
>
:[=C2=A0 =C2=A0 0.139318] pci_bus 0000:00: root bus resource [io=C2=A0 0x00=
00-0x0cf7]<br>
:[=C2=A0 =C2=A0 0.139322] pci_bus 0000:00: root bus resource [io=C2=A0 0x0d=
00-0xffff]<br>
:[=C2=A0 =C2=A0 0.139326] pci_bus 0000:00: root bus resource [mem 0x000a000=
0-0x000bffff]<br>
:[=C2=A0 =C2=A0 0.139329] pci_bus 0000:00: root bus resource [mem 0x000d000=
0-0x000d3fff]<br>
:[=C2=A0 =C2=A0 0.139333] pci_bus 0000:00: root bus resource [mem 0x000d400=
0-0x000d7fff]<br>
:[=C2=A0 =C2=A0 0.139337] pci_bus 0000:00: root bus resource [mem 0x000d800=
0-0x000dbfff]<br>
:[=C2=A0 =C2=A0 0.139340] pci_bus 0000:00: root bus resource [mem 0x000dc00=
0-0x000dffff]<br>
:[=C2=A0 =C2=A0 0.139344] pci_bus 0000:00: root bus resource [mem 0x000e000=
0-0x000e3fff]<br>
:[=C2=A0 =C2=A0 0.139347] pci_bus 0000:00: root bus resource [mem 0x000e400=
0-0x000e7fff]<br>
:[=C2=A0 =C2=A0 0.139351] pci_bus 0000:00: root bus resource [mem 0xdfa0000=
0-0xfeafffff]<br>
:[=C2=A0 =C2=A0 0.139367] pci 0000:00:00.0: [8086:0104] type 00 class 0x060=
000<br>
:[=C2=A0 =C2=A0 0.139550] pci 0000:00:02.0: [8086:0106] type 00 class 0x030=
000<br>
:[=C2=A0 =C2=A0 0.139573] pci 0000:00:02.0: reg 0x10: [mem 0xf7800000-0xf7b=
fffff 64bit]<br>
:[=C2=A0 =C2=A0 0.139585] pci 0000:00:02.0: reg 0x18: [mem 0xe0000000-0xeff=
fffff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.139594] pci 0000:00:02.0: reg 0x20: [io=C2=A0 0xf000-0xf0=
3f]<br>
:[=C2=A0 =C2=A0 0.139805] pci 0000:00:16.0: [8086:1e3a] type 00 class 0x078=
000<br>
:[=C2=A0 =C2=A0 0.139838] pci 0000:00:16.0: reg 0x10: [mem 0xf7f0a000-0xf7f=
0a00f 64bit]<br>
:[=C2=A0 =C2=A0 0.139943] pci 0000:00:16.0: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.140116] pci 0000:00:1a.0: [8086:1e2d] type 00 class 0x0c0=
320<br>
:[=C2=A0 =C2=A0 0.140146] pci 0000:00:1a.0: reg 0x10: [mem 0xf7f08000-0xf7f=
083ff]<br>
:[=C2=A0 =C2=A0 0.140269] pci 0000:00:1a.0: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.140398] pci 0000:00:1a.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.140459] pci 0000:00:1b.0: [8086:1e20] type 00 class 0x040=
300<br>
:[=C2=A0 =C2=A0 0.140482] pci 0000:00:1b.0: reg 0x10: [mem 0xf7f00000-0xf7f=
03fff 64bit]<br>
:[=C2=A0 =C2=A0 0.140590] pci 0000:00:1b.0: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.140695] pci 0000:00:1b.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.140747] pci 0000:00:1c.0: [8086:1e10] type 01 class 0x060=
400<br>
:[=C2=A0 =C2=A0 0.140866] pci 0000:00:1c.0: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.140973] pci 0000:00:1c.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.141025] pci 0000:00:1c.1: [8086:1e12] type 01 class 0x060=
400<br>
:[=C2=A0 =C2=A0 0.141138] pci 0000:00:1c.1: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.141244] pci 0000:00:1c.1: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.141295] pci 0000:00:1c.2: [8086:2448] type 01 class 0x060=
401<br>
:[=C2=A0 =C2=A0 0.141407] pci 0000:00:1c.2: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.141517] pci 0000:00:1c.2: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.141567] pci 0000:00:1c.3: [8086:1e16] type 01 class 0x060=
400<br>
:[=C2=A0 =C2=A0 0.141680] pci 0000:00:1c.3: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.141790] pci 0000:00:1c.3: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.141854] pci 0000:00:1d.0: [8086:1e26] type 00 class 0x0c0=
320<br>
:[=C2=A0 =C2=A0 0.141884] pci 0000:00:1d.0: reg 0x10: [mem 0xf7f07000-0xf7f=
073ff]<br>
:[=C2=A0 =C2=A0 0.142007] pci 0000:00:1d.0: PME# supported from D0 D3hot D3=
cold<br>
:[=C2=A0 =C2=A0 0.142132] pci 0000:00:1d.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.142188] pci 0000:00:1f.0: [8086:1e5f] type 00 class 0x060=
100<br>
:[=C2=A0 =C2=A0 0.142464] pci 0000:00:1f.2: [8086:1e03] type 00 class 0x010=
601<br>
:[=C2=A0 =C2=A0 0.142492] pci 0000:00:1f.2: reg 0x10: [io=C2=A0 0xf0b0-0xf0=
b7]<br>
:[=C2=A0 =C2=A0 0.142505] pci 0000:00:1f.2: reg 0x14: [io=C2=A0 0xf0a0-0xf0=
a3]<br>
:[=C2=A0 =C2=A0 0.142517] pci 0000:00:1f.2: reg 0x18: [io=C2=A0 0xf090-0xf0=
97]<br>
:[=C2=A0 =C2=A0 0.142529] pci 0000:00:1f.2: reg 0x1c: [io=C2=A0 0xf080-0xf0=
83]<br>
:[=C2=A0 =C2=A0 0.142542] pci 0000:00:1f.2: reg 0x20: [io=C2=A0 0xf060-0xf0=
7f]<br>
:[=C2=A0 =C2=A0 0.142554] pci 0000:00:1f.2: reg 0x24: [mem 0xf7f06000-0xf7f=
067ff]<br>
:[=C2=A0 =C2=A0 0.142623] pci 0000:00:1f.2: PME# supported from D3hot<br>
:[=C2=A0 =C2=A0 0.142763] pci 0000:00:1f.3: [8086:1e22] type 00 class 0x0c0=
500<br>
:[=C2=A0 =C2=A0 0.142786] pci 0000:00:1f.3: reg 0x10: [mem 0xf7f05000-0xf7f=
050ff 64bit]<br>
:[=C2=A0 =C2=A0 0.142822] pci 0000:00:1f.3: reg 0x20: [io=C2=A0 0xf040-0xf0=
5f]<br>
:[=C2=A0 =C2=A0 0.143081] pci 0000:01:00.0: [10ec:8168] type 00 class 0x020=
000<br>
:[=C2=A0 =C2=A0 0.143108] pci 0000:01:00.0: reg 0x10: [io=C2=A0 0xe000-0xe0=
ff]<br>
:[=C2=A0 =C2=A0 0.143151] pci 0000:01:00.0: reg 0x18: [mem 0xf7e00000-0xf7e=
00fff 64bit]<br>
:[=C2=A0 =C2=A0 0.143179] pci 0000:01:00.0: reg 0x20: [mem 0xf0100000-0xf01=
03fff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.143316] pci 0000:01:00.0: supports D1 D2<br>
:[=C2=A0 =C2=A0 0.143319] pci 0000:01:00.0: PME# supported from D0 D1 D2 D3=
hot D3cold<br>
:[=C2=A0 =C2=A0 0.143371] pci 0000:01:00.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.144835] pci 0000:00:1c.0: PCI bridge to [bus 01]<br>
:[=C2=A0 =C2=A0 0.144844] pci 0000:00:1c.0:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xe000-0xefff]<br>
:[=C2=A0 =C2=A0 0.144853] pci 0000:00:1c.0:=C2=A0 =C2=A0bridge window [mem =
0xf7e00000-0xf7efffff]<br>
:[=C2=A0 =C2=A0 0.144864] pci 0000:00:1c.0:=C2=A0 =C2=A0bridge window [mem =
0xf0100000-0xf01fffff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.144998] pci 0000:02:00.0: [10ec:8168] type 00 class 0x020=
000<br>
:[=C2=A0 =C2=A0 0.145025] pci 0000:02:00.0: reg 0x10: [io=C2=A0 0xd000-0xd0=
ff]<br>
:[=C2=A0 =C2=A0 0.145068] pci 0000:02:00.0: reg 0x18: [mem 0xf0004000-0xf00=
04fff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.145096] pci 0000:02:00.0: reg 0x20: [mem 0xf0000000-0xf00=
03fff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.145232] pci 0000:02:00.0: supports D1 D2<br>
:[=C2=A0 =C2=A0 0.145236] pci 0000:02:00.0: PME# supported from D0 D1 D2 D3=
hot D3cold<br>
:[=C2=A0 =C2=A0 0.145295] pci 0000:02:00.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.146837] pci 0000:00:1c.1: PCI bridge to [bus 02]<br>
:[=C2=A0 =C2=A0 0.146846] pci 0000:00:1c.1:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xd000-0xdfff]<br>
:[=C2=A0 =C2=A0 0.146860] pci 0000:00:1c.1:=C2=A0 =C2=A0bridge window [mem =
0xf0000000-0xf00fffff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.146990] pci 0000:03:00.0: [8086:244e] type 01 class 0x060=
401<br>
:[=C2=A0 =C2=A0 0.147172] pci 0000:03:00.0: supports D1 D2<br>
:[=C2=A0 =C2=A0 0.147175] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3=
hot D3cold<br>
:[=C2=A0 =C2=A0 0.147214] pci 0000:03:00.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.147257] pci 0000:00:1c.2: PCI bridge to [bus 03-04] (subt=
ractive decode)<br>
:[=C2=A0 =C2=A0 0.147264] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xc000-0xcfff]<br>
:[=C2=A0 =C2=A0 0.147270] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0xf7d00000-0xf7dfffff]<br>
:[=C2=A0 =C2=A0 0.147279] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0x0000-0x0cf7] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147283] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0x0d00-0xffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147287] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0x000a0000-0x000bffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147291] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0x000d0000-0x000d3fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147294] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0x000d4000-0x000d7fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147298] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0x000d8000-0x000dbfff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147301] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0x000dc000-0x000dffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147305] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0x000e0000-0x000e3fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147308] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0x000e4000-0x000e7fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147312] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0xdfa00000-0xfeafffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147419] pci 0000:04:00.0: [1186:4300] type 00 class 0x020=
000<br>
:[=C2=A0 =C2=A0 0.147462] pci 0000:04:00.0: reg 0x10: [io=C2=A0 0xc000-0xc0=
ff]<br>
:[=C2=A0 =C2=A0 0.147487] pci 0000:04:00.0: reg 0x14: [mem 0xf7d20000-0xf7d=
200ff]<br>
:[=C2=A0 =C2=A0 0.147594] pci 0000:04:00.0: reg 0x30: [mem 0xf7d00000-0xf7d=
1ffff pref]<br>
:[=C2=A0 =C2=A0 0.147666] pci 0000:04:00.0: supports D1 D2<br>
:[=C2=A0 =C2=A0 0.147669] pci 0000:04:00.0: PME# supported from D1 D2 D3hot=
 D3cold<br>
:[=C2=A0 =C2=A0 0.147827] pci 0000:03:00.0: PCI bridge to [bus 04] (subtrac=
tive decode)<br>
:[=C2=A0 =C2=A0 0.147842] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xc000-0xcfff]<br>
:[=C2=A0 =C2=A0 0.147851] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0xf7d00000-0xf7dfffff]<br>
:[=C2=A0 =C2=A0 0.147865] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xc000-0xcfff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147869] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0xf7d00000-0xf7dfffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147873] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [??? =
0x00000000 flags 0x0] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147877] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [??? =
0x00000000 flags 0x0] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147880] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0x0000-0x0cf7] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147884] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0x0d00-0xffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147887] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0x000a0000-0x000bffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147891] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0x000d0000-0x000d3fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147894] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0x000d4000-0x000d7fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147898] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0x000d8000-0x000dbfff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147901] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0x000dc000-0x000dffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147905] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0x000e0000-0x000e3fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147908] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0x000e4000-0x000e7fff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.147912] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0xdfa00000-0xfeafffff] (subtractive decode)<br>
:[=C2=A0 =C2=A0 0.148039] pci 0000:05:00.0: [197b:2368] type 00 class 0x010=
185<br>
:[=C2=A0 =C2=A0 0.148083] pci 0000:05:00.0: reg 0x10: [io=C2=A0 0xb040-0xb0=
47]<br>
:[=C2=A0 =C2=A0 0.148104] pci 0000:05:00.0: reg 0x14: [io=C2=A0 0xb030-0xb0=
33]<br>
:[=C2=A0 =C2=A0 0.148124] pci 0000:05:00.0: reg 0x18: [io=C2=A0 0xb020-0xb0=
27]<br>
:[=C2=A0 =C2=A0 0.148145] pci 0000:05:00.0: reg 0x1c: [io=C2=A0 0xb010-0xb0=
13]<br>
:[=C2=A0 =C2=A0 0.148165] pci 0000:05:00.0: reg 0x20: [io=C2=A0 0xb000-0xb0=
0f]<br>
:[=C2=A0 =C2=A0 0.148204] pci 0000:05:00.0: reg 0x30: [mem 0xf7c00000-0xf7c=
0ffff pref]<br>
:[=C2=A0 =C2=A0 0.148342] pci 0000:05:00.0: System wakeup disabled by ACPI<=
br>
:[=C2=A0 =C2=A0 0.148383] pci 0000:05:00.0: disabling ASPM on pre-1.1 PCIe =
device.=C2=A0 You can enable it with &#39;pcie_aspm=3Dforce&#39;<br>
:[=C2=A0 =C2=A0 0.148398] pci 0000:00:1c.3: PCI bridge to [bus 05]<br>
:[=C2=A0 =C2=A0 0.148404] pci 0000:00:1c.3:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xb000-0xbfff]<br>
:[=C2=A0 =C2=A0 0.148411] pci 0000:00:1c.3:=C2=A0 =C2=A0bridge window [mem =
0xf7c00000-0xf7cfffff]<br>
:[=C2=A0 =C2=A0 0.149911] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 =
*11 12 14 15)<br>
:[=C2=A0 =C2=A0 0.150014] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 *10=
 11 12 14 15)<br>
:[=C2=A0 =C2=A0 0.150112] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 =
*11 12 14 15)<br>
:[=C2=A0 =C2=A0 0.150210] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10=
 11 12 14 15)<br>
:[=C2=A0 =C2=A0 0.150312] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 10 =
11 12 14 15) *0, disabled.<br>
:[=C2=A0 =C2=A0 0.150413] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 =
11 12 14 15) *0, disabled.<br>
:[=C2=A0 =C2=A0 0.150510] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 10 =
*11 12 14 15)<br>
:[=C2=A0 =C2=A0 0.150606] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *10=
 11 12 14 15)<br>
:[=C2=A0 =C2=A0 0.151045] ACPI: Enabled 5 GPEs in block 00 to 3F<br>
:[=C2=A0 =C2=A0 0.151060] ACPI: \_SB_.PCI0: notify handler is installed<br>
:[=C2=A0 =C2=A0 0.151184] Found 1 acpi root devices<br>
:[=C2=A0 =C2=A0 0.151342] vgaarb: device added: PCI:0000:00:02.0,decodes=3D=
io+mem,owns=3Dio+mem,locks=3Dnone<br>
:[=C2=A0 =C2=A0 0.151349] vgaarb: loaded<br>
:[=C2=A0 =C2=A0 0.151351] vgaarb: bridge control possible 0000:00:02.0<br>
:[=C2=A0 =C2=A0 0.151467] SCSI subsystem initialized<br>
:[=C2=A0 =C2=A0 0.151499] ACPI: bus type USB registered<br>
:[=C2=A0 =C2=A0 0.151536] usbcore: registered new interface driver usbfs<br=
>
:[=C2=A0 =C2=A0 0.151550] usbcore: registered new interface driver hub<br>
:[=C2=A0 =C2=A0 0.151610] usbcore: registered new device driver usb<br>
:[=C2=A0 =C2=A0 0.151734] PCI: Using ACPI for IRQ routing<br>
:[=C2=A0 =C2=A0 0.153848] PCI: pci_cache_line_size set to 64 bytes<br>
:[=C2=A0 =C2=A0 0.153935] e820: reserve RAM buffer [mem 0x0009d800-0x0009ff=
ff]<br>
:[=C2=A0 =C2=A0 0.153939] e820: reserve RAM buffer [mem 0xd94d2000-0xdbffff=
ff]<br>
:[=C2=A0 =C2=A0 0.153943] e820: reserve RAM buffer [mem 0xda6ba000-0xdbffff=
ff]<br>
:[=C2=A0 =C2=A0 0.153947] e820: reserve RAM buffer [mem 0xdadef000-0xdbffff=
ff]<br>
:[=C2=A0 =C2=A0 0.153950] e820: reserve RAM buffer [mem 0xdb000000-0xdbffff=
ff]<br>
:[=C2=A0 =C2=A0 0.153953] e820: reserve RAM buffer [mem 0x21f600000-0x21fff=
ffff]<br>
:[=C2=A0 =C2=A0 0.154096] NetLabel: Initializing<br>
:[=C2=A0 =C2=A0 0.154099] NetLabel:=C2=A0 domain hash size =3D 128<br>
:[=C2=A0 =C2=A0 0.154101] NetLabel:=C2=A0 protocols =3D UNLABELED CIPSOv4<b=
r>
:[=C2=A0 =C2=A0 0.154122] NetLabel:=C2=A0 unlabeled traffic allowed by defa=
ult<br>
:[=C2=A0 =C2=A0 0.154199] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0,=
 0, 0<br>
:[=C2=A0 =C2=A0 0.154210] hpet0: 8 comparators, 64-bit 14.318180 MHz counte=
r<br>
:[=C2=A0 =C2=A0 0.156234] Switching to clocksource hpet<br>
:[=C2=A0 =C2=A0 0.165233] pnp: PnP ACPI init<br>
:[=C2=A0 =C2=A0 0.165264] ACPI: bus type PNP registered<br>
:[=C2=A0 =C2=A0 0.165425] system 00:00: [mem 0xfed40000-0xfed44fff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.165432] system 00:00: Plug and Play ACPI device, IDs PNP0=
c01 (active)<br>
:[=C2=A0 =C2=A0 0.165456] pnp 00:01: [dma 4]<br>
:[=C2=A0 =C2=A0 0.165480] pnp 00:01: Plug and Play ACPI device, IDs PNP0200=
 (active)<br>
:[=C2=A0 =C2=A0 0.165513] pnp 00:02: Plug and Play ACPI device, IDs INT0800=
 (active)<br>
:[=C2=A0 =C2=A0 0.165674] pnp 00:03: Plug and Play ACPI device, IDs PNP0103=
 (active)<br>
:[=C2=A0 =C2=A0 0.165755] system 00:04: [io=C2=A0 0x0680-0x069f] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.165760] system 00:04: [io=C2=A0 0x0200-0x020f] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.165764] system 00:04: [io=C2=A0 0xffff] has been reserved=
<br>
:[=C2=A0 =C2=A0 0.165768] system 00:04: [io=C2=A0 0xffff] has been reserved=
<br>
:[=C2=A0 =C2=A0 0.165773] system 00:04: [io=C2=A0 0x0400-0x0453] could not =
be reserved<br>
:[=C2=A0 =C2=A0 0.165777] system 00:04: [io=C2=A0 0x0458-0x047f] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.165780] system 00:04: [io=C2=A0 0x0500-0x057f] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.165786] system 00:04: Plug and Play ACPI device, IDs PNP0=
c02 (active)<br>
:[=C2=A0 =C2=A0 0.165837] pnp 00:05: Plug and Play ACPI device, IDs PNP0b00=
 (active)<br>
:[=C2=A0 =C2=A0 0.165925] system 00:06: [io=C2=A0 0x0454-0x0457] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.165931] system 00:06: Plug and Play ACPI device, IDs INT3=
f0d PNP0c02 (active)<br>
:[=C2=A0 =C2=A0 0.166167] system 00:07: [io=C2=A0 0x0a00-0x0a0f] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.166171] system 00:07: [io=C2=A0 0x0a30-0x0a3f] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.166175] system 00:07: [io=C2=A0 0x0a20-0x0a2f] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.166180] system 00:07: Plug and Play ACPI device, IDs PNP0=
c02 (active)<br>
:[=C2=A0 =C2=A0 0.166614] pnp 00:08: [dma 0 disabled]<br>
:[=C2=A0 =C2=A0 0.166701] pnp 00:08: Plug and Play ACPI device, IDs PNP0501=
 (active)<br>
:[=C2=A0 =C2=A0 0.167061] pnp 00:09: [dma 0 disabled]<br>
:[=C2=A0 =C2=A0 0.167146] pnp 00:09: Plug and Play ACPI device, IDs PNP0501=
 (active)<br>
:[=C2=A0 =C2=A0 0.167617] pnp 00:0a: [dma 0 disabled]<br>
:[=C2=A0 =C2=A0 0.167807] pnp 00:0a: Plug and Play ACPI device, IDs PNP0400=
 (active)<br>
:[=C2=A0 =C2=A0 0.167900] system 00:0b: [io=C2=A0 0x04d0-0x04d1] has been r=
eserved<br>
:[=C2=A0 =C2=A0 0.167905] system 00:0b: Plug and Play ACPI device, IDs PNP0=
c02 (active)<br>
:[=C2=A0 =C2=A0 0.167949] pnp 00:0c: Plug and Play ACPI device, IDs PNP0c04=
 (active)<br>
:[=C2=A0 =C2=A0 0.168435] system 00:0d: [mem 0xfed1c000-0xfed1ffff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168440] system 00:0d: [mem 0xfed10000-0xfed17fff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168444] system 00:0d: [mem 0xfed18000-0xfed18fff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168448] system 00:0d: [mem 0xfed19000-0xfed19fff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168452] system 00:0d: [mem 0xf8000000-0xfbffffff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168456] system 00:0d: [mem 0xfed20000-0xfed3ffff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168465] system 00:0d: [mem 0xfed90000-0xfed93fff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168469] system 00:0d: [mem 0xfed45000-0xfed8ffff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168473] system 00:0d: [mem 0xff000000-0xffffffff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168478] system 00:0d: [mem 0xfee00000-0xfeefffff] could n=
ot be reserved<br>
:[=C2=A0 =C2=A0 0.168482] system 00:0d: [mem 0xdfa00000-0xdfa00fff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168487] system 00:0d: Plug and Play ACPI device, IDs PNP0=
c02 (active)<br>
:[=C2=A0 =C2=A0 0.168775] system 00:0e: [mem 0x20000000-0x201fffff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168779] system 00:0e: [mem 0x40000000-0x401fffff] has bee=
n reserved<br>
:[=C2=A0 =C2=A0 0.168784] system 00:0e: Plug and Play ACPI device, IDs PNP0=
c01 (active)<br>
:[=C2=A0 =C2=A0 0.168825] pnp: PnP ACPI: found 15 devices<br>
:[=C2=A0 =C2=A0 0.168827] ACPI: bus type PNP unregistered<br>
:[=C2=A0 =C2=A0 0.176239] pci 0000:00:1c.0: PCI bridge to [bus 01]<br>
:[=C2=A0 =C2=A0 0.176247] pci 0000:00:1c.0:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xe000-0xefff]<br>
:[=C2=A0 =C2=A0 0.176262] pci 0000:00:1c.0:=C2=A0 =C2=A0bridge window [mem =
0xf7e00000-0xf7efffff]<br>
:[=C2=A0 =C2=A0 0.176269] pci 0000:00:1c.0:=C2=A0 =C2=A0bridge window [mem =
0xf0100000-0xf01fffff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.176278] pci 0000:00:1c.1: PCI bridge to [bus 02]<br>
:[=C2=A0 =C2=A0 0.176283] pci 0000:00:1c.1:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xd000-0xdfff]<br>
:[=C2=A0 =C2=A0 0.176294] pci 0000:00:1c.1:=C2=A0 =C2=A0bridge window [mem =
0xf0000000-0xf00fffff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.176304] pci 0000:03:00.0: PCI bridge to [bus 04]<br>
:[=C2=A0 =C2=A0 0.176310] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xc000-0xcfff]<br>
:[=C2=A0 =C2=A0 0.176322] pci 0000:03:00.0:=C2=A0 =C2=A0bridge window [mem =
0xf7d00000-0xf7dfffff]<br>
:[=C2=A0 =C2=A0 0.176342] pci 0000:00:1c.2: PCI bridge to [bus 03-04]<br>
:[=C2=A0 =C2=A0 0.176347] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xc000-0xcfff]<br>
:[=C2=A0 =C2=A0 0.176355] pci 0000:00:1c.2:=C2=A0 =C2=A0bridge window [mem =
0xf7d00000-0xf7dfffff]<br>
:[=C2=A0 =C2=A0 0.176367] pci 0000:00:1c.3: PCI bridge to [bus 05]<br>
:[=C2=A0 =C2=A0 0.176372] pci 0000:00:1c.3:=C2=A0 =C2=A0bridge window [io=
=C2=A0 0xb000-0xbfff]<br>
:[=C2=A0 =C2=A0 0.176379] pci 0000:00:1c.3:=C2=A0 =C2=A0bridge window [mem =
0xf7c00000-0xf7cfffff]<br>
:[=C2=A0 =C2=A0 0.176393] pci_bus 0000:00: resource 4 [io=C2=A0 0x0000-0x0c=
f7]<br>
:[=C2=A0 =C2=A0 0.176397] pci_bus 0000:00: resource 5 [io=C2=A0 0x0d00-0xff=
ff]<br>
:[=C2=A0 =C2=A0 0.176401] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000=
bffff]<br>
:[=C2=A0 =C2=A0 0.176404] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000=
d3fff]<br>
:[=C2=A0 =C2=A0 0.176408] pci_bus 0000:00: resource 8 [mem 0x000d4000-0x000=
d7fff]<br>
:[=C2=A0 =C2=A0 0.176411] pci_bus 0000:00: resource 9 [mem 0x000d8000-0x000=
dbfff]<br>
:[=C2=A0 =C2=A0 0.176415] pci_bus 0000:00: resource 10 [mem 0x000dc000-0x00=
0dffff]<br>
:[=C2=A0 =C2=A0 0.176418] pci_bus 0000:00: resource 11 [mem 0x000e0000-0x00=
0e3fff]<br>
:[=C2=A0 =C2=A0 0.176422] pci_bus 0000:00: resource 12 [mem 0x000e4000-0x00=
0e7fff]<br>
:[=C2=A0 =C2=A0 0.176425] pci_bus 0000:00: resource 13 [mem 0xdfa00000-0xfe=
afffff]<br>
:[=C2=A0 =C2=A0 0.176429] pci_bus 0000:01: resource 0 [io=C2=A0 0xe000-0xef=
ff]<br>
:[=C2=A0 =C2=A0 0.176433] pci_bus 0000:01: resource 1 [mem 0xf7e00000-0xf7e=
fffff]<br>
:[=C2=A0 =C2=A0 0.176437] pci_bus 0000:01: resource 2 [mem 0xf0100000-0xf01=
fffff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.176440] pci_bus 0000:02: resource 0 [io=C2=A0 0xd000-0xdf=
ff]<br>
:[=C2=A0 =C2=A0 0.176444] pci_bus 0000:02: resource 2 [mem 0xf0000000-0xf00=
fffff 64bit pref]<br>
:[=C2=A0 =C2=A0 0.176448] pci_bus 0000:03: resource 0 [io=C2=A0 0xc000-0xcf=
ff]<br>
:[=C2=A0 =C2=A0 0.176451] pci_bus 0000:03: resource 1 [mem 0xf7d00000-0xf7d=
fffff]<br>
:[=C2=A0 =C2=A0 0.176455] pci_bus 0000:03: resource 4 [io=C2=A0 0x0000-0x0c=
f7]<br>
:[=C2=A0 =C2=A0 0.176458] pci_bus 0000:03: resource 5 [io=C2=A0 0x0d00-0xff=
ff]<br>
:[=C2=A0 =C2=A0 0.176462] pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000=
bffff]<br>
:[=C2=A0 =C2=A0 0.176465] pci_bus 0000:03: resource 7 [mem 0x000d0000-0x000=
d3fff]<br>
:[=C2=A0 =C2=A0 0.176469] pci_bus 0000:03: resource 8 [mem 0x000d4000-0x000=
d7fff]<br>
:[=C2=A0 =C2=A0 0.176472] pci_bus 0000:03: resource 9 [mem 0x000d8000-0x000=
dbfff]<br>
:[=C2=A0 =C2=A0 0.176476] pci_bus 0000:03: resource 10 [mem 0x000dc000-0x00=
0dffff]<br>
:[=C2=A0 =C2=A0 0.176479] pci_bus 0000:03: resource 11 [mem 0x000e0000-0x00=
0e3fff]<br>
:[=C2=A0 =C2=A0 0.176483] pci_bus 0000:03: resource 12 [mem 0x000e4000-0x00=
0e7fff]<br>
:[=C2=A0 =C2=A0 0.176486] pci_bus 0000:03: resource 13 [mem 0xdfa00000-0xfe=
afffff]<br>
:[=C2=A0 =C2=A0 0.176490] pci_bus 0000:04: resource 0 [io=C2=A0 0xc000-0xcf=
ff]<br>
:[=C2=A0 =C2=A0 0.176493] pci_bus 0000:04: resource 1 [mem 0xf7d00000-0xf7d=
fffff]<br>
:[=C2=A0 =C2=A0 0.176497] pci_bus 0000:04: resource 4 [io=C2=A0 0xc000-0xcf=
ff]<br>
:[=C2=A0 =C2=A0 0.176500] pci_bus 0000:04: resource 5 [mem 0xf7d00000-0xf7d=
fffff]<br>
:[=C2=A0 =C2=A0 0.176504] pci_bus 0000:04: resource 8 [io=C2=A0 0x0000-0x0c=
f7]<br>
:[=C2=A0 =C2=A0 0.176507] pci_bus 0000:04: resource 9 [io=C2=A0 0x0d00-0xff=
ff]<br>
:[=C2=A0 =C2=A0 0.176511] pci_bus 0000:04: resource 10 [mem 0x000a0000-0x00=
0bffff]<br>
:[=C2=A0 =C2=A0 0.176514] pci_bus 0000:04: resource 11 [mem 0x000d0000-0x00=
0d3fff]<br>
:[=C2=A0 =C2=A0 0.176518] pci_bus 0000:04: resource 12 [mem 0x000d4000-0x00=
0d7fff]<br>
:[=C2=A0 =C2=A0 0.176521] pci_bus 0000:04: resource 13 [mem 0x000d8000-0x00=
0dbfff]<br>
:[=C2=A0 =C2=A0 0.176524] pci_bus 0000:04: resource 14 [mem 0x000dc000-0x00=
0dffff]<br>
:[=C2=A0 =C2=A0 0.176528] pci_bus 0000:04: resource 15 [mem 0x000e0000-0x00=
0e3fff]<br>
:[=C2=A0 =C2=A0 0.176531] pci_bus 0000:04: resource 16 [mem 0x000e4000-0x00=
0e7fff]<br>
:[=C2=A0 =C2=A0 0.176535] pci_bus 0000:04: resource 17 [mem 0xdfa00000-0xfe=
afffff]<br>
:[=C2=A0 =C2=A0 0.176538] pci_bus 0000:05: resource 0 [io=C2=A0 0xb000-0xbf=
ff]<br>
:[=C2=A0 =C2=A0 0.176542] pci_bus 0000:05: resource 1 [mem 0xf7c00000-0xf7c=
fffff]<br>
:[=C2=A0 =C2=A0 0.176590] NET: Registered protocol family 2<br>
:[=C2=A0 =C2=A0 0.176898] TCP established hash table entries: 65536 (order:=
 7, 524288 bytes)<br>
:[=C2=A0 =C2=A0 0.177272] TCP bind hash table entries: 65536 (order: 8, 104=
8576 bytes)<br>
:[=C2=A0 =C2=A0 0.177542] TCP: Hash tables configured (established 65536 bi=
nd 65536)<br>
:[=C2=A0 =C2=A0 0.177585] TCP: reno registered<br>
:[=C2=A0 =C2=A0 0.177614] UDP hash table entries: 4096 (order: 5, 131072 by=
tes)<br>
:[=C2=A0 =C2=A0 0.177683] UDP-Lite hash table entries: 4096 (order: 5, 1310=
72 bytes)<br>
:[=C2=A0 =C2=A0 0.177816] NET: Registered protocol family 1<br>
:[=C2=A0 =C2=A0 0.177840] pci 0000:00:02.0: Boot video device<br>
:[=C2=A0 =C2=A0 0.209469] PCI: CLS 64 bytes, default 64<br>
:[=C2=A0 =C2=A0 0.209560] Unpacking initramfs...<br>
:[=C2=A0 =C2=A0 0.604457] Freeing initrd memory: 11424k freed<br>
:[=C2=A0 =C2=A0 0.607382] PCI-DMA: Using software bounce buffering for IO (=
SWIOTLB)<br>
:[=C2=A0 =C2=A0 0.607391] software IO TLB [mem 0xd54d2000-0xd94d2000] (64MB=
) mapped at [ffff8800d54d2000-ffff8800d94d1fff]<br>
:[=C2=A0 =C2=A0 0.607905] microcode: CPU0 sig=3D0x206a7, pf=3D0x10, revisio=
n=3D0x29<br>
:[=C2=A0 =C2=A0 0.607917] microcode: CPU1 sig=3D0x206a7, pf=3D0x10, revisio=
n=3D0x29<br>
:[=C2=A0 =C2=A0 0.607960] microcode: Microcode Update Driver: v2.00 &lt;<a =
href=3D"mailto:tigran@aivazian.fsnet.co.uk">tigran@aivazian.fsnet.co.uk</a>=
&gt;, Peter Oruba<br>
:[=C2=A0 =C2=A0 0.608228] futex hash table entries: 512 (order: 3, 32768 by=
tes)<br>
:[=C2=A0 =C2=A0 0.608259] Initialise system trusted keyring<br>
:[=C2=A0 =C2=A0 0.608337] audit: initializing netlink socket (disabled)<br>
:[=C2=A0 =C2=A0 0.608357] type=3D2000 audit(1419859884.594:1): initialized<=
br>
:[=C2=A0 =C2=A0 0.655088] HugeTLB registered 2 MB page size, pre-allocated =
0 pages<br>
:[=C2=A0 =C2=A0 0.657011] zbud: loaded<br>
:[=C2=A0 =C2=A0 0.657296] VFS: Disk quotas dquot_6.5.2<br>
:[=C2=A0 =C2=A0 0.657361] Dquot-cache hash table entries: 512 (order 0, 409=
6 bytes)<br>
:[=C2=A0 =C2=A0 0.657619] msgmni has been set to 15417<br>
:[=C2=A0 =C2=A0 0.657703] Key type big_key registered<br>
:[=C2=A0 =C2=A0 0.657706] SELinux:=C2=A0 Registering netfilter hooks<br>
:[=C2=A0 =C2=A0 0.658582] alg: No test for stdrng (krng)<br>
:[=C2=A0 =C2=A0 0.658595] NET: Registered protocol family 38<br>
:[=C2=A0 =C2=A0 0.658600] Key type asymmetric registered<br>
:[=C2=A0 =C2=A0 0.658602] Asymmetric key parser &#39;x509&#39; registered<b=
r>
:[=C2=A0 =C2=A0 0.658655] Block layer SCSI generic (bsg) driver version 0.4=
 loaded (major 252)<br>
:[=C2=A0 =C2=A0 0.658698] io scheduler noop registered<br>
:[=C2=A0 =C2=A0 0.658701] io scheduler deadline registered (default)<br>
:[=C2=A0 =C2=A0 0.658740] io scheduler cfq registered<br>
:[=C2=A0 =C2=A0 0.659561] pci_hotplug: PCI Hot Plug PCI Core version: 0.5<b=
r>
:[=C2=A0 =C2=A0 0.659587] pciehp: PCI Express Hot Plug Controller Driver ve=
rsion: 0.4<br>
:[=C2=A0 =C2=A0 0.659689] intel_idle: MWAIT substates: 0x21120<br>
:[=C2=A0 =C2=A0 0.659692] intel_idle: v0.4 model 0x2A<br>
:[=C2=A0 =C2=A0 0.659695] intel_idle: lapic_timer_reliable_states 0xfffffff=
f<br>
:[=C2=A0 =C2=A0 0.659840] input: Power Button as /devices/LNXSYSTM:00/devic=
e:00/PNP0C0C:00/input/input0<br>
:[=C2=A0 =C2=A0 0.659848] ACPI: Power Button [PWRB]<br>
:[=C2=A0 =C2=A0 0.659904] input: Power Button as /devices/LNXSYSTM:00/LNXPW=
RBN:00/input/input1<br>
:[=C2=A0 =C2=A0 0.659908] ACPI: Power Button [PWRF]<br>
:[=C2=A0 =C2=A0 0.660001] ACPI: Fan [FAN0] (off)<br>
:[=C2=A0 =C2=A0 0.660043] ACPI: Fan [FAN1] (off)<br>
:[=C2=A0 =C2=A0 0.660089] ACPI: Fan [FAN2] (off)<br>
:[=C2=A0 =C2=A0 0.660128] ACPI: Fan [FAN3] (off)<br>
:[=C2=A0 =C2=A0 0.660171] ACPI: Fan [FAN4] (off)<br>
:[=C2=A0 =C2=A0 0.660270] ACPI: Requesting acpi_cpufreq<br>
:[=C2=A0 =C2=A0 0.668020] thermal LNXTHERM:00: registered as thermal_zone0<=
br>
:[=C2=A0 =C2=A0 0.668025] ACPI: Thermal Zone [TZ00] (28 C)<br>
:[=C2=A0 =C2=A0 0.668442] thermal LNXTHERM:01: registered as thermal_zone1<=
br>
:[=C2=A0 =C2=A0 0.668445] ACPI: Thermal Zone [TZ01] (30 C)<br>
:[=C2=A0 =C2=A0 0.668534] GHES: HEST is not enabled!<br>
:[=C2=A0 =C2=A0 0.668627] Serial: 8250/16550 driver, 4 ports, IRQ sharing e=
nabled<br>
:[=C2=A0 =C2=A0 0.689327] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A=
<br>
:[=C2=A0 =C2=A0 0.710011] 00:09: ttyS1 at I/O 0x2f8 (irq =3D 3) is a 16550A=
<br>
:[=C2=A0 =C2=A0 0.710707] Non-volatile memory driver v1.3<br>
:[=C2=A0 =C2=A0 0.710711] Linux agpgart interface v0.103<br>
:[=C2=A0 =C2=A0 0.710840] crash memory driver: version 1.1<br>
:[=C2=A0 =C2=A0 0.710865] rdac: device handler registered<br>
:[=C2=A0 =C2=A0 0.710920] hp_sw: device handler registered<br>
:[=C2=A0 =C2=A0 0.710924] emc: device handler registered<br>
:[=C2=A0 =C2=A0 0.710927] alua: device handler registered<br>
:[=C2=A0 =C2=A0 0.710980] libphy: Fixed MDIO Bus: probed<br>
:[=C2=A0 =C2=A0 0.711055] ehci_hcd: USB 2.0 &#39;Enhanced&#39; Host Control=
ler (EHCI) Driver<br>
:[=C2=A0 =C2=A0 0.711060] ehci-pci: EHCI PCI platform driver<br>
:[=C2=A0 =C2=A0 0.711280] ehci-pci 0000:00:1a.0: EHCI Host Controller<br>
:[=C2=A0 =C2=A0 0.711346] ehci-pci 0000:00:1a.0: new USB bus registered, as=
signed bus number 1<br>
:[=C2=A0 =C2=A0 0.711365] ehci-pci 0000:00:1a.0: debug port 2<br>
:[=C2=A0 =C2=A0 0.715281] ehci-pci 0000:00:1a.0: cache line size of 64 is n=
ot supported<br>
:[=C2=A0 =C2=A0 0.715310] ehci-pci 0000:00:1a.0: irq 16, io mem 0xf7f08000<=
br>
:[=C2=A0 =C2=A0 0.721251] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00=
<br>
:[=C2=A0 =C2=A0 0.721328] usb usb1: New USB device found, idVendor=3D1d6b, =
idProduct=3D0002<br>
:[=C2=A0 =C2=A0 0.721332] usb usb1: New USB device strings: Mfr=3D3, Produc=
t=3D2, SerialNumber=3D1<br>
:[=C2=A0 =C2=A0 0.721335] usb usb1: Product: EHCI Host Controller<br>
:[=C2=A0 =C2=A0 0.721339] usb usb1: Manufacturer: Linux 3.10.0-123.el7.x86_=
64 ehci_hcd<br>
:[=C2=A0 =C2=A0 0.721343] usb usb1: SerialNumber: 0000:00:1a.0<br>
:[=C2=A0 =C2=A0 0.721508] hub 1-0:1.0: USB hub found<br>
:[=C2=A0 =C2=A0 0.721520] hub 1-0:1.0: 2 ports detected<br>
:[=C2=A0 =C2=A0 0.721883] ehci-pci 0000:00:1d.0: EHCI Host Controller<br>
:[=C2=A0 =C2=A0 0.721948] ehci-pci 0000:00:1d.0: new USB bus registered, as=
signed bus number 2<br>
:[=C2=A0 =C2=A0 0.721965] ehci-pci 0000:00:1d.0: debug port 2<br>
:[=C2=A0 =C2=A0 0.725869] ehci-pci 0000:00:1d.0: cache line size of 64 is n=
ot supported<br>
:[=C2=A0 =C2=A0 0.725892] ehci-pci 0000:00:1d.0: irq 23, io mem 0xf7f07000<=
br>
:[=C2=A0 =C2=A0 0.731251] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00=
<br>
:[=C2=A0 =C2=A0 0.731306] usb usb2: New USB device found, idVendor=3D1d6b, =
idProduct=3D0002<br>
:[=C2=A0 =C2=A0 0.731310] usb usb2: New USB device strings: Mfr=3D3, Produc=
t=3D2, SerialNumber=3D1<br>
:[=C2=A0 =C2=A0 0.731314] usb usb2: Product: EHCI Host Controller<br>
:[=C2=A0 =C2=A0 0.731317] usb usb2: Manufacturer: Linux 3.10.0-123.el7.x86_=
64 ehci_hcd<br>
:[=C2=A0 =C2=A0 0.731321] usb usb2: SerialNumber: 0000:00:1d.0<br>
:[=C2=A0 =C2=A0 0.731469] hub 2-0:1.0: USB hub found<br>
:[=C2=A0 =C2=A0 0.731480] hub 2-0:1.0: 2 ports detected<br>
:[=C2=A0 =C2=A0 0.731663] ohci_hcd: USB 1.1 &#39;Open&#39; Host Controller =
(OHCI) Driver<br>
:[=C2=A0 =C2=A0 0.731666] ohci-pci: OHCI PCI platform driver<br>
:[=C2=A0 =C2=A0 0.731680] uhci_hcd: USB Universal Host Controller Interface=
 driver<br>
:[=C2=A0 =C2=A0 0.731757] usbcore: registered new interface driver usbseria=
l<br>
:[=C2=A0 =C2=A0 0.731768] usbcore: registered new interface driver usbseria=
l_generic<br>
:[=C2=A0 =C2=A0 0.731781] usbserial: USB Serial support registered for gene=
ric<br>
:[=C2=A0 =C2=A0 0.731839] i8042: PNP: No PS/2 controller found. Probing por=
ts directly.<br>
:[=C2=A0 =C2=A0 0.732271] serio: i8042 KBD port at 0x60,0x64 irq 1<br>
:[=C2=A0 =C2=A0 0.732281] serio: i8042 AUX port at 0x60,0x64 irq 12<br>
:[=C2=A0 =C2=A0 0.732423] mousedev: PS/2 mouse device common for all mice<b=
r>
:[=C2=A0 =C2=A0 0.732651] rtc_cmos 00:05: RTC can wake from S4<br>
:[=C2=A0 =C2=A0 0.732824] rtc_cmos 00:05: rtc core: registered rtc_cmos as =
rtc0<br>
:[=C2=A0 =C2=A0 0.732860] rtc_cmos 00:05: alarms up to one month, y3k, 242 =
bytes nvram, hpet irqs<br>
:[=C2=A0 =C2=A0 0.732878] Intel P-state driver initializing.<br>
:[=C2=A0 =C2=A0 0.732894] Intel pstate controlling: cpu 0<br>
:[=C2=A0 =C2=A0 0.732920] Intel pstate controlling: cpu 1<br>
:[=C2=A0 =C2=A0 0.733031] cpuidle: using governor menu<br>
:[=C2=A0 =C2=A0 0.733472] hidraw: raw HID events driver (C) Jiri Kosina<br>
:[=C2=A0 =C2=A0 0.733605] usbcore: registered new interface driver usbhid<b=
r>
:[=C2=A0 =C2=A0 0.733607] usbhid: USB HID core driver<br>
:[=C2=A0 =C2=A0 0.733664] drop_monitor: Initializing network drop monitor s=
ervice<br>
:[=C2=A0 =C2=A0 0.733792] TCP: cubic registered<br>
:[=C2=A0 =C2=A0 0.733795] Initializing XFRM netlink socket<br>
:[=C2=A0 =C2=A0 0.733944] NET: Registered protocol family 10<br>
:[=C2=A0 =C2=A0 0.734184] NET: Registered protocol family 17<br>
:[=C2=A0 =C2=A0 0.734533] Loading compiled-in X.509 certificates<br>
:[=C2=A0 =C2=A0 0.734580] Loaded X.509 cert &#39;CentOS Linux kpatch signin=
g key: ea0413152cde1d98ebdca3fe6f0230904c9ef717&#39;<br>
:[=C2=A0 =C2=A0 0.734617] Loaded X.509 cert &#39;CentOS Linux Driver update=
 signing key: 7f421ee0ab69461574bb358861dbe77762a4201b&#39;<br>
:[=C2=A0 =C2=A0 0.735856] Loaded X.509 cert &#39;CentOS Linux kernel signin=
g key: bc83d0fe70c62fab1c58b4ebaa95e3936128fcf4&#39;<br>
:[=C2=A0 =C2=A0 0.735874] registered taskstats version 1<br>
:[=C2=A0 =C2=A0 0.739363] Key type trusted registered<br>
:[=C2=A0 =C2=A0 0.742673] Key type encrypted registered<br>
:[=C2=A0 =C2=A0 0.745824] IMA: No TPM chip found, activating TPM-bypass!<br=
>
:[=C2=A0 =C2=A0 0.746475] rtc_cmos 00:05: setting system clock to 2014-12-2=
9 13:31:25 UTC (1419859885)<br>
:[=C2=A0 =C2=A0 0.748508] Freeing unused kernel memory: 1584k freed<br>
:[=C2=A0 =C2=A0 0.754405] systemd[1]: systemd 208 running in system mode. (=
+PAM +LIBWRAP +AUDIT +SELINUX +IMA +SYSVINIT +LIBCRYPTSETUP +GCRYPT +ACL +X=
Z)<br>
:[=C2=A0 =C2=A0 0.754703] systemd[1]: Running in initial RAM disk.<br>
:[=C2=A0 =C2=A0 0.754802] systemd[1]: Set hostname to &lt;router.centos&gt;=
.<br>
:[=C2=A0 =C2=A0 0.805134] systemd[1]: Expecting device dev-disk-by\x2duuid-=
328b16e8\x2d5f97\x2d4c97\x2d80c2\x2d1269e2157281.device...<br>
:[=C2=A0 =C2=A0 0.805164] systemd[1]: Starting -.slice.<br>
:[=C2=A0 =C2=A0 0.805446] systemd[1]: Created slice -.slice.<br>
:[=C2=A0 =C2=A0 0.805547] systemd[1]: Starting System Slice.<br>
:[=C2=A0 =C2=A0 0.805688] systemd[1]: Created slice System Slice.<br>
:[=C2=A0 =C2=A0 0.805757] systemd[1]: Starting Slices.<br>
:[=C2=A0 =C2=A0 0.805778] systemd[1]: Reached target Slices.<br>
:[=C2=A0 =C2=A0 0.805836] systemd[1]: Starting Timers.<br>
:[=C2=A0 =C2=A0 0.805856] systemd[1]: Reached target Timers.<br>
:[=C2=A0 =C2=A0 0.805914] systemd[1]: Starting Journal Socket.<br>
:[=C2=A0 =C2=A0 0.806019] systemd[1]: Listening on Journal Socket.<br>
:[=C2=A0 =C2=A0 0.806375] systemd[1]: Starting dracut cmdline hook...<br>
:[=C2=A0 =C2=A0 0.807179] systemd[1]: Started Load Kernel Modules.<br>
:[=C2=A0 =C2=A0 0.807212] systemd[1]: Starting Setup Virtual Console...<br>
:[=C2=A0 =C2=A0 0.807844] systemd[1]: Starting Journal Service...<br>
:[=C2=A0 =C2=A0 0.808460] systemd[1]: Started Journal Service.<br>
:[=C2=A0 =C2=A0 0.824104] systemd-journald[90]: Vacuuming done, freed 0 byt=
es<br>
:[=C2=A0 =C2=A0 1.024292] usb 1-1: new high-speed USB device number 2 using=
 ehci-pci<br>
:[=C2=A0 =C2=A0 1.043450] device-mapper: uevent: version 1.0.3<br>
:[=C2=A0 =C2=A0 1.043582] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) i=
nitialised: <a href=3D"mailto:dm-devel@redhat.com">dm-devel@redhat.com</a><=
br>
:[=C2=A0 =C2=A0 1.095150] systemd-udevd[214]: starting version 208<br>
:[=C2=A0 =C2=A0 1.138603] usb 1-1: New USB device found, idVendor=3D8087, i=
dProduct=3D0024<br>
:[=C2=A0 =C2=A0 1.138611] usb 1-1: New USB device strings: Mfr=3D0, Product=
=3D0, SerialNumber=3D0<br>
:[=C2=A0 =C2=A0 1.138887] hub 1-1:1.0: USB hub found<br>
:[=C2=A0 =C2=A0 1.138965] hub 1-1:1.0: 4 ports detected<br>
:[=C2=A0 =C2=A0 1.214959] [drm] Initialized drm 1.1.0 20060810<br>
:[=C2=A0 =C2=A0 1.231450] ACPI: bus type ATA registered<br>
:[=C2=A0 =C2=A0 1.237330] libata version 3.00 loaded.<br>
:[=C2=A0 =C2=A0 1.243256] usb 2-1: new high-speed USB device number 2 using=
 ehci-pci<br>
:[=C2=A0 =C2=A0 1.245014] ahci 0000:00:1f.2: version 3.0<br>
:[=C2=A0 =C2=A0 1.245320] ahci 0000:00:1f.2: irq 40 for MSI/MSI-X<br>
:[=C2=A0 =C2=A0 1.245399] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 4 port=
s 6 Gbps 0x1 impl SATA mode<br>
:[=C2=A0 =C2=A0 1.245406] ahci 0000:00:1f.2: flags: 64bit ncq led clo pio s=
lum part ems apst<br>
:[=C2=A0 =C2=A0 1.279383] scsi0 : pata_jmicron<br>
:[=C2=A0 =C2=A0 1.281670] scsi1 : ahci<br>
:[=C2=A0 =C2=A0 1.291657] scsi3 : ahci<br>
:[=C2=A0 =C2=A0 1.294823] scsi2 : pata_jmicron<br>
:[=C2=A0 =C2=A0 1.294910] ata1: PATA max UDMA/100 cmd 0xb040 ctl 0xb030 bmd=
ma 0xb000 irq 19<br>
:[=C2=A0 =C2=A0 1.294914] ata2: PATA max UDMA/100 cmd 0xb020 ctl 0xb010 bmd=
ma 0xb008 irq 19<br>
:[=C2=A0 =C2=A0 1.308040] scsi4 : ahci<br>
:[=C2=A0 =C2=A0 1.320404] scsi5 : ahci<br>
:[=C2=A0 =C2=A0 1.320583] ata3: SATA max UDMA/133 abar m2048@0xf7f06000 por=
t 0xf7f06100 irq 40<br>
:[=C2=A0 =C2=A0 1.320587] ata4: DUMMY<br>
:[=C2=A0 =C2=A0 1.320590] ata5: DUMMY<br>
:[=C2=A0 =C2=A0 1.320592] ata6: DUMMY<br>
:[=C2=A0 =C2=A0 1.322898] [drm] Memory usable by graphics device =3D 2048M<=
br>
:[=C2=A0 =C2=A0 1.358589] usb 2-1: New USB device found, idVendor=3D8087, i=
dProduct=3D0024<br>
:[=C2=A0 =C2=A0 1.358598] usb 2-1: New USB device strings: Mfr=3D0, Product=
=3D0, SerialNumber=3D0<br>
:[=C2=A0 =C2=A0 1.358875] hub 2-1:1.0: USB hub found<br>
:[=C2=A0 =C2=A0 1.358956] hub 2-1:1.0: 4 ports detected<br>
:[=C2=A0 =C2=A0 1.395684] i915 0000:00:02.0: irq 41 for MSI/MSI-X<br>
:[=C2=A0 =C2=A0 1.395709] [drm] Supports vblank timestamp caching Rev 1 (10=
.10.2010).<br>
:[=C2=A0 =C2=A0 1.395711] [drm] Driver supports precise vblank timestamp qu=
ery.<br>
:[=C2=A0 =C2=A0 1.395804] vgaarb: device changed decodes: PCI:0000:00:02.0,=
olddecodes=3Dio+mem,decodes=3Dio+mem:owns=3Dio+mem<br>
:[=C2=A0 =C2=A0 1.415744] [drm] Wrong MCH_SSKPD value: 0x16040307<br>
:[=C2=A0 =C2=A0 1.415749] [drm] This can cause pipe underruns and display i=
ssues.<br>
:[=C2=A0 =C2=A0 1.415751] [drm] Please upgrade your BIOS to fix this.<br>
:[=C2=A0 =C2=A0 1.425898] i915 0000:00:02.0: No connectors reported connect=
ed with modes<br>
:[=C2=A0 =C2=A0 1.425905] [drm] Cannot find any crtc or sizes - going 1024x=
768<br>
:[=C2=A0 =C2=A0 1.427730] fbcon: inteldrmfb (fb0) is primary device<br>
:[=C2=A0 =C2=A0 1.455620] Console: switching to colour frame buffer device =
128x48<br>
:[=C2=A0 =C2=A0 1.459524] i915 0000:00:02.0: fb0: inteldrmfb frame buffer d=
evice<br>
:[=C2=A0 =C2=A0 1.459527] i915 0000:00:02.0: registered panic notifier<br>
:[=C2=A0 =C2=A0 1.471043] acpi device:59: registered as cooling_device7<br>
:[=C2=A0 =C2=A0 1.471345] ACPI: Video Device [GFX0] (multi-head: yes=C2=A0 =
rom: no=C2=A0 post: no)<br>
:[=C2=A0 =C2=A0 1.471417] input: Video Bus as /devices/LNXSYSTM:00/device:0=
0/PNP0A08:00/LNXVIDEO:00/input/input2<br>
:[=C2=A0 =C2=A0 1.472093] [drm] Initialized i915 1.6.0 20080730 for 0000:00=
:02.0 on minor 0<br>
:[=C2=A0 =C2=A0 1.608229] tsc: Refined TSC clocksource calibration: 1097.50=
6 MHz<br>
:[=C2=A0 =C2=A0 1.608237] Switching to clocksource tsc<br>
:[=C2=A0 =C2=A0 1.625263] ata3: SATA link up 3.0 Gbps (SStatus 123 SControl=
 300)<br>
:[=C2=A0 =C2=A0 1.628527] ACPI Error: [DSSP] Namespace lookup failure, AE_N=
OT_FOUND (20130517/psargs-359)<br>
:[=C2=A0 =C2=A0 1.628540] ACPI Error: Method parse/execution failed [\_SB_.=
PCI0.SAT0.SPT0._GTF] (Node ffff8802138b5c30), AE_NOT_FOUND (20130517/pspars=
e-536)<br>
:[=C2=A0 =C2=A0 1.628708] ata3.00: ATA-7: SAMSUNG SP2004C, VM100-33, max UD=
MA7<br>
:[=C2=A0 =C2=A0 1.628713] ata3.00: 390721968 sectors, multi 16: LBA48 NCQ (=
depth 31/32), AA<br>
:[=C2=A0 =C2=A0 1.631993] ACPI Error: [DSSP] Namespace lookup failure, AE_N=
OT_FOUND (20130517/psargs-359)<br>
:[=C2=A0 =C2=A0 1.632006] ACPI Error: Method parse/execution failed [\_SB_.=
PCI0.SAT0.SPT0._GTF] (Node ffff8802138b5c30), AE_NOT_FOUND (20130517/pspars=
e-536)<br>
:[=C2=A0 =C2=A0 1.632138] ata3.00: configured for UDMA/133<br>
:[=C2=A0 =C2=A0 1.632317] scsi 1:0:0:0: Direct-Access=C2=A0 =C2=A0 =C2=A0AT=
A=C2=A0 =C2=A0 =C2=A0 SAMSUNG SP2004C=C2=A0 VM10 PQ: 0 ANSI: 5<br>
:[=C2=A0 =C2=A0 1.649161] sd 1:0:0:0: [sda] 390721968 512-byte logical bloc=
ks: (200 GB/186 GiB)<br>
:[=C2=A0 =C2=A0 1.649491] sd 1:0:0:0: [sda] Write Protect is off<br>
:[=C2=A0 =C2=A0 1.649498] sd 1:0:0:0: [sda] Mode Sense: 00 3a 00 00<br>
:[=C2=A0 =C2=A0 1.649532] sd 1:0:0:0: [sda] Write cache: enabled, read cach=
e: enabled, doesn&#39;t support DPO or FUA<br>
:[=C2=A0 =C2=A0 1.655470]=C2=A0 sda: sda1 sda2<br>
:[=C2=A0 =C2=A0 1.655883] sd 1:0:0:0: [sda] Attached SCSI disk<br>
:[=C2=A0 =C2=A0 2.061962] bio: create slab &lt;bio-1&gt; at 1<br>
:[=C2=A0 =C2=A0 2.379041] SGI XFS with ACLs, security attributes, large blo=
ck/inode numbers, no debug enabled<br>
:[=C2=A0 =C2=A0 2.381018] XFS (dm-1): Mounting Filesystem<br>
:[=C2=A0 =C2=A0 2.537380] XFS (dm-1): Ending clean mount<br>
:[=C2=A0 =C2=A0 2.720554] [drm] Enabling RC6 states: RC6 on, RC6p off, RC6p=
p off<br>
:[=C2=A0 =C2=A0 2.787861] systemd-journald[90]: Received SIGTERM<br>
:[=C2=A0 =C2=A0 3.350603] type=3D1404 audit(1419859888.103:2): enforcing=3D=
1 old_enforcing=3D0 auid=3D4294967295 ses=3D4294967295<br>
:[=C2=A0 =C2=A0 3.657353] SELinux: 2048 avtab hash slots, 106409 rules.<br>
:[=C2=A0 =C2=A0 3.693846] SELinux: 2048 avtab hash slots, 106409 rules.<br>
:[=C2=A0 =C2=A0 3.751099] SELinux:=C2=A0 8 users, 86 roles, 4801 types, 280=
 bools, 1 sens, 1024 cats<br>
:[=C2=A0 =C2=A0 3.751107] SELinux:=C2=A0 83 classes, 106409 rules<br>
:[=C2=A0 =C2=A0 3.762442] SELinux:=C2=A0 Completing initialization.<br>
:[=C2=A0 =C2=A0 3.762449] SELinux:=C2=A0 Setting up existing superblocks.<b=
r>
:[=C2=A0 =C2=A0 3.762461] SELinux: initialized (dev sysfs, type sysfs), use=
s genfs_contexts<br>
:[=C2=A0 =C2=A0 3.762469] SELinux: initialized (dev rootfs, type rootfs), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.762483] SELinux: initialized (dev bdev, type bdev), uses =
genfs_contexts<br>
:[=C2=A0 =C2=A0 3.762492] SELinux: initialized (dev proc, type proc), uses =
genfs_contexts<br>
:[=C2=A0 =C2=A0 3.762552] SELinux: initialized (dev tmpfs, type tmpfs), use=
s transition SIDs<br>
:[=C2=A0 =C2=A0 3.762616] SELinux: initialized (dev devtmpfs, type devtmpfs=
), uses transition SIDs<br>
:[=C2=A0 =C2=A0 3.763983] SELinux: initialized (dev sockfs, type sockfs), u=
ses task SIDs<br>
:[=C2=A0 =C2=A0 3.763990] SELinux: initialized (dev debugfs, type debugfs),=
 uses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.765541] SELinux: initialized (dev pipefs, type pipefs), u=
ses task SIDs<br>
:[=C2=A0 =C2=A0 3.765554] SELinux: initialized (dev anon_inodefs, type anon=
_inodefs), uses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.765558] SELinux: initialized (dev aio, type aio), not con=
figured for labeling<br>
:[=C2=A0 =C2=A0 3.765563] SELinux: initialized (dev devpts, type devpts), u=
ses transition SIDs<br>
:[=C2=A0 =C2=A0 3.765598] SELinux: initialized (dev hugetlbfs, type hugetlb=
fs), uses transition SIDs<br>
:[=C2=A0 =C2=A0 3.765609] SELinux: initialized (dev mqueue, type mqueue), u=
ses transition SIDs<br>
:[=C2=A0 =C2=A0 3.765622] SELinux: initialized (dev selinuxfs, type selinux=
fs), uses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.765640] SELinux: initialized (dev securityfs, type securi=
tyfs), uses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.765647] SELinux: initialized (dev sysfs, type sysfs), use=
s genfs_contexts<br>
:[=C2=A0 =C2=A0 3.766188] SELinux: initialized (dev tmpfs, type tmpfs), use=
s transition SIDs<br>
:[=C2=A0 =C2=A0 3.766206] SELinux: initialized (dev tmpfs, type tmpfs), use=
s transition SIDs<br>
:[=C2=A0 =C2=A0 3.766397] SELinux: initialized (dev tmpfs, type tmpfs), use=
s transition SIDs<br>
:[=C2=A0 =C2=A0 3.766463] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.766476] SELinux: initialized (dev pstore, type pstore), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.766480] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.766488] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.766496] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.766508] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.766514] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.766520] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.766526] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.766537] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.766543] SELinux: initialized (dev cgroup, type cgroup), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.766552] SELinux: initialized (dev configfs, type configfs=
), uses genfs_contexts<br>
:[=C2=A0 =C2=A0 3.766561] SELinux: initialized (dev dm-1, type xfs), uses x=
attr<br>
:[=C2=A0 =C2=A0 3.778243] type=3D1403 audit(1419859888.530:3): policy loade=
d auid=3D4294967295 ses=3D4294967295<br>
:[=C2=A0 =C2=A0 3.787849] systemd[1]: Successfully loaded SELinux policy in=
 462.134ms.<br>
:[=C2=A0 =C2=A0 3.920876] systemd[1]: RTC configured in localtime, applying=
 delta of 240 minutes to system time.<br>
:[=C2=A0 =C2=A0 4.005427] systemd[1]: Relabelled /dev and /run in 39.980ms.=
<br>
:[=C2=A0 =C2=A0 5.710538] SELinux: initialized (dev autofs, type autofs), u=
ses genfs_contexts<br>
:[=C2=A0 =C2=A0 6.307749] systemd-journald[455]: Vacuuming done, freed 0 by=
tes<br>
:[=C2=A0 =C2=A0 7.178649] SELinux: initialized (dev hugetlbfs, type hugetlb=
fs), uses transition SIDs<br>
:[=C2=A0 =C2=A0 7.351328] systemd-udevd[477]: starting version 208<br>
:[=C2=A0 =C2=A0 7.665816] shpchp: Standard Hot Plug PCI Controller Driver v=
ersion: 0.4<br>
:[=C2=A0 =C2=A0 7.693874] ACPI Warning: SystemIO range 0x0000000000000428-0=
x000000000000042f conflicts with OpRegion 0x0000000000000400-0x000000000000=
047f (\PMIO) (20130517/utaddress-254)<br>
:[=C2=A0 =C2=A0 7.693888] ACPI: If an ACPI driver is available for this dev=
ice, you should use it instead of the native driver<br>
:[=C2=A0 =C2=A0 7.693894] ACPI Warning: SystemIO range 0x0000000000000530-0=
x000000000000053f conflicts with OpRegion 0x0000000000000500-0x000000000000=
0563 (\GPIO) (20130517/utaddress-254)<br>
:[=C2=A0 =C2=A0 7.693901] ACPI: If an ACPI driver is available for this dev=
ice, you should use it instead of the native driver<br>
:[=C2=A0 =C2=A0 7.693904] ACPI Warning: SystemIO range 0x0000000000000500-0=
x000000000000052f conflicts with OpRegion 0x0000000000000500-0x000000000000=
051f (\LED_) (20130517/utaddress-254)<br>
:[=C2=A0 =C2=A0 7.693910] ACPI Warning: SystemIO range 0x0000000000000500-0=
x000000000000052f conflicts with OpRegion 0x0000000000000500-0x000000000000=
0563 (\GPIO) (20130517/utaddress-254)<br>
:[=C2=A0 =C2=A0 7.693916] ACPI: If an ACPI driver is available for this dev=
ice, you should use it instead of the native driver<br>
:[=C2=A0 =C2=A0 7.693918] lpc_ich: Resource conflict(s) found affecting gpi=
o_ich<br>
:[=C2=A0 =C2=A0 7.704394] parport_pc 00:0a: reported by Plug and Play ACPI<=
br>
:[=C2=A0 =C2=A0 7.704454] parport0: PC-style at 0x378, irq 5 [PCSPP,TRISTAT=
E]<br>
:[=C2=A0 =C2=A0 7.750623] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded<b=
r>
:[=C2=A0 =C2=A0 7.750946] r8169 0000:01:00.0: irq 42 for MSI/MSI-X<br>
:[=C2=A0 =C2=A0 7.752251] r8169 0000:01:00.0 eth0: RTL8168evl/8111evl at 0x=
ffffc90000c20000, 90:2b:34:db:46:be, XID 0c900800 IRQ 42<br>
:[=C2=A0 =C2=A0 7.752258] r8169 0000:01:00.0 eth0: jumbo features [frames: =
9200 bytes, tx checksumming: ko]<br>
:[=C2=A0 =C2=A0 7.752290] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded<b=
r>
:[=C2=A0 =C2=A0 7.752609] r8169 0000:02:00.0: irq 43 for MSI/MSI-X<br>
:[=C2=A0 =C2=A0 7.752838] r8169 0000:02:00.0 eth1: RTL8168evl/8111evl at 0x=
ffffc90000c2a000, 90:2b:34:db:46:ff, XID 0c900800 IRQ 43<br>
:[=C2=A0 =C2=A0 7.752843] r8169 0000:02:00.0 eth1: jumbo features [frames: =
9200 bytes, tx checksumming: ko]<br>
:[=C2=A0 =C2=A0 7.752861] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded<b=
r>
:[=C2=A0 =C2=A0 7.753197] r8169 0000:04:00.0 (unregistered net_device): not=
 PCI Express<br>
:[=C2=A0 =C2=A0 7.753527] r8169 0000:04:00.0 eth2: RTL8169sb/8110sb at 0xff=
ffc90004e34000, f0:7d:68:c1:fd:3f, XID 10000000 IRQ 18<br>
:[=C2=A0 =C2=A0 7.753532] r8169 0000:04:00.0 eth2: jumbo features [frames: =
7152 bytes, tx checksumming: ok]<br>
:[=C2=A0 =C2=A0 7.954829] mei_me 0000:00:16.0: irq 44 for MSI/MSI-X<br>
:[=C2=A0 =C2=A0 8.350294] input: PC Speaker as /devices/platform/pcspkr/inp=
ut/input3<br>
:[=C2=A0 =C2=A0 8.354836] ACPI Warning: SystemIO range 0x000000000000f040-0=
x000000000000f05f conflicts with OpRegion 0x000000000000f040-0x000000000000=
f04f (\_SB_.PCI0.SBUS.SMBI) (20130517/utaddress-254)<br>
:[=C2=A0 =C2=A0 8.354850] ACPI: If an ACPI driver is available for this dev=
ice, you should use it instead of the native driver<br>
:[=C2=A0 =C2=A0 8.357773] iTCO_vendor_support: vendor-support=3D0<br>
:[=C2=A0 =C2=A0 8.359958] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10<b=
r>
:[=C2=A0 =C2=A0 8.360003] iTCO_wdt: unable to reset NO_REBOOT flag, device =
disabled by hardware/BIOS<br>
:[=C2=A0 =C2=A0 8.363647] ppdev: user-space parallel port driver<br>
:[=C2=A0 =C2=A0 8.494188] snd_hda_intel 0000:00:1b.0: irq 45 for MSI/MSI-X<=
br>
:[=C2=A0 =C2=A0 8.533553] input: HDA Intel PCH HDMI/DP,pcm=3D3 as /devices/=
pci0000:00/0000:00:1b.0/sound/card0/input4<br>
:[=C2=A0 =C2=A0 8.534515] input: HDA Intel PCH Front Headphone as /devices/=
pci0000:00/0000:00:1b.0/sound/card0/input5<br>
:[=C2=A0 =C2=A0 8.534898] input: HDA Intel PCH Line Out as /devices/pci0000=
:00/0000:00:1b.0/sound/card0/input6<br>
:[=C2=A0 =C2=A0 8.535066] input: HDA Intel PCH Line as /devices/pci0000:00/=
0000:00:1b.0/sound/card0/input7<br>
:[=C2=A0 =C2=A0 8.535258] input: HDA Intel PCH Front Mic as /devices/pci000=
0:00/0000:00:1b.0/sound/card0/input8<br>
:[=C2=A0 =C2=A0 8.535423] input: HDA Intel PCH Rear Mic as /devices/pci0000=
:00/0000:00:1b.0/sound/card0/input9<br>
:[=C2=A0 =C2=A0 8.848016] alg: No test for crc32 (crc32-pclmul)<br>
:[=C2=A0 =C2=A0 8.877913] kvm: disabled by bios<br>
:[=C2=A0 =C2=A0 8.885824] kvm: disabled by bios<br>
:[=C2=A0 =C2=A0 9.158360] systemd-udevd[493]: renamed network interface eth=
1 to enp2s0<br>
:[=C2=A0 =C2=A0 9.236390] systemd-udevd[485]: renamed network interface eth=
0 to enp1s0<br>
:[=C2=A0 =C2=A0 9.332624] systemd-udevd[497]: renamed network interface eth=
2 to enp4s0<br>
:[=C2=A0 =C2=A0 9.703544] XFS (sda1): Mounting Filesystem<br>
:[=C2=A0 =C2=A0 9.846652] XFS (dm-2): Mounting Filesystem<br>
:[=C2=A0 =C2=A010.278975] Adding 8142844k swap on /dev/mapper/centos_router=
-swap.=C2=A0 Priority:-1 extents:1 across:8142844k FS<br>
:[=C2=A0 =C2=A011.723634] XFS (dm-2): Ending clean mount<br>
:[=C2=A0 =C2=A011.723664] SELinux: initialized (dev dm-2, type xfs), uses x=
attr<br>
:[=C2=A0 =C2=A016.508880] XFS (sda1): Ending clean mount<br>
:[=C2=A0 =C2=A016.508914] SELinux: initialized (dev sda1, type xfs), uses x=
attr<br>
:[=C2=A0 =C2=A016.536304] systemd-journald[455]: Received request to flush =
runtime journal from PID 1<br>
:[=C2=A0 =C2=A016.571284] type=3D1305 audit(1419845501.324:4): audit_pid=3D=
643 old=3D0 auid=3D4294967295 ses=3D4294967295 subj=3Dsystem_u:system_r:aud=
itd_t:s0 res=3D1<br>
:[=C2=A0 =C2=A017.153653] sd 1:0:0:0: Attached scsi generic sg0 type 0<br>
:[=C2=A0 =C2=A017.507429] ip_tables: (C) 2000-2006 Netfilter Core Team<br>
:[=C2=A0 =C2=A017.660658] nf_conntrack version 0.5.0 (16384 buckets, 65536 =
max)<br>
:[=C2=A0 =C2=A017.691649] ip6_tables: (C) 2000-2006 Netfilter Core Team<br>
:[=C2=A0 =C2=A017.887724] Ebtables v2.0 registered<br>
:[=C2=A0 =C2=A017.941800] Bridge firewalling registered<br>
:[=C2=A0 =C2=A018.725996] r8169 0000:01:00.0 enp1s0: link down<br>
:[=C2=A0 =C2=A018.726023] r8169 0000:01:00.0 enp1s0: link down<br>
:[=C2=A0 =C2=A018.726063] IPv6: ADDRCONF(NETDEV_UP): enp1s0: link is not re=
ady<br>
:[=C2=A0 =C2=A018.962890] r8169 0000:02:00.0 enp2s0: link down<br>
:[=C2=A0 =C2=A018.962907] r8169 0000:02:00.0 enp2s0: link down<br>
:[=C2=A0 =C2=A018.963901] IPv6: ADDRCONF(NETDEV_UP): enp2s0: link is not re=
ady<br>
:[=C2=A0 =C2=A019.013741] r8169 0000:04:00.0 enp4s0: link down<br>
:[=C2=A0 =C2=A019.013767] r8169 0000:04:00.0 enp4s0: link down<br>
:[=C2=A0 =C2=A019.013807] IPv6: ADDRCONF(NETDEV_UP): enp4s0: link is not re=
ady<br>
:[=C2=A0 =C2=A020.391340] r8169 0000:01:00.0 enp1s0: link up<br>
:[=C2=A0 =C2=A020.391356] IPv6: ADDRCONF(NETDEV_CHANGE): enp1s0: link becom=
es ready<br>
:[=C2=A0 =C2=A020.743693] PPP generic driver version 2.4.2<br>
:[=C2=A0 =C2=A021.965632] PPP BSD Compression module registered<br>
:[=C2=A0 =C2=A023.225499] r8169 0000:02:00.0 enp2s0: link up<br>
:[=C2=A0 =C2=A023.225520] IPv6: ADDRCONF(NETDEV_CHANGE): enp2s0: link becom=
es ready<br>
:[=C2=A0 =C2=A047.001413] r8169 0000:04:00.0 enp4s0: link up<br>
:[=C2=A0 =C2=A047.001433] IPv6: ADDRCONF(NETDEV_CHANGE): enp4s0: link becom=
es ready<br>
:[ 5415.638681] perf samples too long (2508 &gt; 2500), lowering kernel.per=
f_event_max_sample_rate to 50000<br>
:[11457.169428] perf samples too long (5017 &gt; 5000), lowering kernel.per=
f_event_max_sample_rate to 25000<br>
:[191358.932922] systemd-journald[455]: Vacuuming done, freed 0 bytes<br>
:[304423.181608] systemd-journald[455]: Vacuuming done, freed 0 bytes<br>
:[391708.916322] systemd-journald[455]: Vacuuming done, freed 0 bytes<br>
:[479912.211156] systemd-journald[455]: Vacuuming done, freed 0 bytes<br>
:[505860.603691] systemd-journald[455]: Vacuuming done, freed 0 bytes<br>
:[697679.203939] systemd-journald[455]: Vacuuming done, freed 0 bytes<br>
:[743074.307891] systemd-journald[455]: Vacuuming done, freed 0 bytes<br>
:[755870.448830] systemd-journald[455]: Vacuuming done, freed 0 bytes<br>
:[887001.227339] systemd-journald[455]: Vacuuming done, freed 0 bytes<br>
:[948156.740769] systemd-journald[455]: Vacuuming done, freed 0 bytes<br>
:[1009037.886161] systemd-journald[455]: Vacuuming done, freed 41943040 byt=
es<br>
:[1107167.047526] systemd-journald[455]: Vacuuming done, freed 41943040 byt=
es<br>
:[1187677.314504] systemd-journald[455]: Vacuuming done, freed 41943040 byt=
es<br>
:[1221396.417323] systemd-journald[455]: Vacuuming done, freed 33554432 byt=
es<br>
:[1274328.202842] systemd-journald[455]: Vacuuming done, freed 41943040 byt=
es<br>
:[1383365.061849] systemd-journald[455]: Vacuuming done, freed 41943040 byt=
es<br>
:[1458028.242405] systemd-journald[455]: Vacuuming done, freed 33554432 byt=
es<br>
:[1486997.501736] systemd-journald[455]: Vacuuming done, freed 33554432 byt=
es<br>
:[1520487.522344] systemd-journald[455]: Vacuuming done, freed 33554432 byt=
es<br>
:[1603068.878693] systemd-journald[455]: Vacuuming done, freed 33554432 byt=
es<br>
:[1624069.808694] systemd-journald[455]: Vacuuming done, freed 41943040 byt=
es<br>
:[1697147.165742] systemd-journald[455]: Vacuuming done, freed 41943040 byt=
es<br>
:[1764124.987955] systemd-journald[455]: Vacuuming done, freed 41943040 byt=
es<br>
:[1786445.984889] systemd-journald[455]: Vacuuming done, freed 41943040 byt=
es<br>
:[1830870.711673] systemd-journald[455]: Vacuuming done, freed 41943040 byt=
es<br>
:[1907546.639638] systemd-udevd[18049]: starting version 208<br>
:[1907702.391382] SELinux: 2048 avtab hash slots, 100245 rules.<br>
:[1907702.436586] SELinux: 2048 avtab hash slots, 100245 rules.<br>
:[1907702.519654] SELinux:=C2=A0 8 users, 86 roles, 4818 types, 285 bools, =
1 sens, 1024 cats<br>
:[1907702.519664] SELinux:=C2=A0 83 classes, 100245 rules<br>
:[1907702.737102] SELinux:=C2=A0 Context unconfined_u:unconfined_r:sandbox_=
t:s0-s0:c0.c1023 became invalid (unmapped).<br>
:[1907703.614224] SELinux:=C2=A0 Context system_u:unconfined_r:sandbox_t:s0=
-s0:c0.c1023 became invalid (unmapped).<br>
:[1912396.914381] systemd-journald[455]: Vacuuming done, freed 41943040 byt=
es<br>
:[2029686.408895] systemd-journald[455]: Vacuuming done, freed 41943040 byt=
es<br>
:[2098191.398350] systemd-journald[455]: Vacuuming done, freed 33554432 byt=
es<br>
:[2158269.202916] systemd-journald[455]: Vacuuming done, freed 33554432 byt=
es<br>
:[2172179.878334] [sched_delayed] sched: RT throttling activated<br>
:[2173411.070531] BUG: soft lockup - CPU#0 stuck for 21s! [rcuos/0:12]<br>
:[2173411.070594] Modules linked in: bsd_comp nf_conntrack_netbios_ns nf_co=
nntrack_broadcast ppp_synctty ppp_async crc_ccitt ppp_generic slhc xt_nat x=
t_mark ipt_MASQUERADE ip6t_rpfilter ip6t_REJECT ipt_REJECT xt_conntrack ebt=
able_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat=
 nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_secu=
rity ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 =
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_secur=
ity iptable_raw iptable_filter ip_tables sg coretemp kvm crct10dif_pclmul c=
rc32_pclmul snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic =
snd_hda_intel snd_hda_codec serio_raw crc32c_intel snd_hwdep snd_seq snd_se=
q_device snd_pcm ppdev iTCO_wdt iTCO_vendor_support i2c_i801 pcspkr<br>
:[2173411.070664]=C2=A0 ghash_clmulni_intel snd_page_alloc cryptd mei_me me=
i snd_timer snd soundcore r8169 mii parport_pc parport lpc_ich mfd_core shp=
chp mperf xfs libcrc32c sd_mod crc_t10dif crct10dif_common ata_generic pata=
_acpi i915 ahci i2c_algo_bit pata_jmicron libahci drm_kms_helper libata drm=
 i2c_core video dm_mirror dm_region_hash dm_log dm_mod<br>
:[2173411.070706] CPU: 0 PID: 12 Comm: rcuos/0 Not tainted 3.10.0-123.el7.x=
86_64 #1<br>
:[2173411.070709] Hardware name: Gigabyte Technology Co., Ltd. To be filled=
 by O.E.M./C847N, BIOS F2 11/09/2012<br>
:[2173411.070714] task: ffff880213970000 ti: ffff88021396e000 task.ti: ffff=
88021396e000<br>
:[2173411.070717] RIP: 0010:[&lt;ffffffffa04addf1&gt;]=C2=A0 [&lt;ffffffffa=
04addf1&gt;] nf_conntrack_tuple_taken+0x91/0x1a0 [nf_conntrack]<br>
:[2173411.070733] RSP: 0018:ffff88021f203838=C2=A0 EFLAGS: 00000246<br>
:[2173411.070736] RAX: ffff8801fc8753e8 RBX: ffff88021f2037b8 RCX: 00000000=
00000000<br>
:[2173411.070739] RDX: 0000000000000001 RSI: 00000000a7cd4ec5 RDI: ffff8800=
ca2e7000<br>
:[2173411.070742] RBP: ffff88021f203860 R08: 000000009b52ef62 R09: 00000000=
ae0c5d8d<br>
:[2173411.070745] R10: ffff88021f203888 R11: ffff880212522000 R12: ffff8802=
1f2037a8<br>
:[2173411.070747] R13: ffffffff815f2d9d R14: ffff88021f203860 R15: ffff8802=
1f203870<br>
:[2173411.070751] FS:=C2=A0 0000000000000000(0000) GS:ffff88021f200000(0000=
) knlGS:0000000000000000<br>
:[2173411.070754] CS:=C2=A0 0010 DS: 0000 ES: 0000 CR0: 0000000080050033<br=
>
:[2173411.070757] CR2: 00007f0e9ceed000 CR3: 00000002116ad000 CR4: 00000000=
000407f0<br>
:[2173411.070760] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000=
00000000<br>
:[2173411.070763] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000=
00000400<br>
:[2173411.070766] Stack:<br>
:[2173411.070768]=C2=A0 ffff8800cc67e9c0 ffff88021f2039e0 ffff88021f203a70 =
000000000000c16d<br>
:[2173411.070774]=C2=A0 000000000000c2c1 ffff88021f2038a8 ffffffffa04d4198 =
000000000601a8c0<br>
:[2173411.070778]=C2=A0 0000000000000000 0101a8c00002d59d 0000000000000000 =
0106c1c600000000<br>
:[2173411.070783] Call Trace:<br>
:[2173411.070787]=C2=A0 &lt;IRQ&gt;<br>
:<br>
:[2173411.070798]=C2=A0 [&lt;ffffffffa04d4198&gt;] nf_nat_used_tuple+0x38/0=
x60 [nf_nat]<br>
:[2173411.070806]=C2=A0 [&lt;ffffffffa04d55cc&gt;] nf_nat_l4proto_unique_tu=
ple+0xcc/0x170 [nf_nat]<br>
:[2173411.070816]=C2=A0 [&lt;ffffffffa04d57a5&gt;] tcp_unique_tuple+0x15/0x=
20 [nf_nat]<br>
:[2173411.070823]=C2=A0 [&lt;ffffffffa04d4aa9&gt;] get_unique_tuple+0x219/0=
x660 [nf_nat]<br>
:[2173411.070833]=C2=A0 [&lt;ffffffffa04d4f96&gt;] nf_nat_setup_info+0xa6/0=
x3a0 [nf_nat]<br>
:[2173411.070845]=C2=A0 [&lt;ffffffffa04ad7ac&gt;] ? nf_ct_invert_tuple+0x6=
c/0x80 [nf_conntrack]<br>
:[2173411.070851]=C2=A0 [&lt;ffffffffa057d1b8&gt;] masquerade_tg+0xf8/0x140=
 [ipt_MASQUERADE]<br>
:[2173411.070861]=C2=A0 [&lt;ffffffffa04a30b3&gt;] ipt_do_table+0x2d3/0x6d1=
 [ip_tables]<br>
:[2173411.070868]=C2=A0 [&lt;ffffffffa04a3107&gt;] ? ipt_do_table+0x327/0x6=
d1 [ip_tables]<br>
:[2173411.070877]=C2=A0 [&lt;ffffffffa04e01d7&gt;] nf_nat_ipv4_fn+0x1d7/0x3=
20 [iptable_nat]<br>
:[2173411.070884]=C2=A0 [&lt;ffffffff8150da30&gt;] ? ip_fragment+0x870/0x87=
0<br>
:[2173411.070889]=C2=A0 [&lt;ffffffff8150da30&gt;] ? ip_fragment+0x870/0x87=
0<br>
:[2173411.070896]=C2=A0 [&lt;ffffffffa04e04f8&gt;] nf_nat_ipv4_out+0x48/0xf=
0 [iptable_nat]<br>
:[2173411.070900]=C2=A0 [&lt;ffffffff8150da30&gt;] ? ip_fragment+0x870/0x87=
0<br>
:[2173411.070906]=C2=A0 [&lt;ffffffff815003ca&gt;] nf_iterate+0xaa/0xc0<br>
:[2173411.070912]=C2=A0 [&lt;ffffffff8150da30&gt;] ? ip_fragment+0x870/0x87=
0<br>
:[2173411.070917]=C2=A0 [&lt;ffffffff81500464&gt;] nf_hook_slow+0x84/0x140<=
br>
:[2173411.070921]=C2=A0 [&lt;ffffffff8150da30&gt;] ? ip_fragment+0x870/0x87=
0<br>
:[2173411.070927]=C2=A0 [&lt;ffffffff8150f162&gt;] ip_output+0x82/0x90<br>
:[2173411.070932]=C2=A0 [&lt;ffffffff8150b09b&gt;] ip_forward_finish+0x8b/0=
x170<br>
:[2173411.070936]=C2=A0 [&lt;ffffffff8150b4d5&gt;] ip_forward+0x355/0x400<b=
r>
:[2173411.070941]=C2=A0 [&lt;ffffffff815091fd&gt;] ip_rcv_finish+0x7d/0x350=
<br>
:[2173411.070945]=C2=A0 [&lt;ffffffff81509ac4&gt;] ip_rcv+0x234/0x380<br>
:[2173411.070952]=C2=A0 [&lt;ffffffff814cfdb6&gt;] __netif_receive_skb_core=
+0x676/0x870<br>
:[2173411.070957]=C2=A0 [&lt;ffffffff814cffc8&gt;] __netif_receive_skb+0x18=
/0x60<br>
:[2173411.070962]=C2=A0 [&lt;ffffffff814d0b7e&gt;] process_backlog+0xae/0x1=
80<br>
:[2173411.070967]=C2=A0 [&lt;ffffffff814d041a&gt;] net_rx_action+0x15a/0x25=
0<br>
:[2173411.070974]=C2=A0 [&lt;ffffffff81067047&gt;] __do_softirq+0xf7/0x290<=
br>
:[2173411.070980]=C2=A0 [&lt;ffffffff815f3a5c&gt;] call_softirq+0x1c/0x30<b=
r>
:[2173411.070982]=C2=A0 &lt;EOI&gt;<br>
:<br>
:[2173411.070990]=C2=A0 [&lt;ffffffff81014d25&gt;] do_softirq+0x55/0x90<br>
:[2173411.070995]=C2=A0 [&lt;ffffffff81066b44&gt;] local_bh_enable+0x94/0xa=
0<br>
:[2173411.071004]=C2=A0 [&lt;ffffffff810fee05&gt;] rcu_nocb_kthread+0x255/0=
x370<br>
:[2173411.071010]=C2=A0 [&lt;ffffffff81086ab0&gt;] ? wake_up_bit+0x30/0x30<=
br>
:[2173411.071017]=C2=A0 [&lt;ffffffff810febb0&gt;] ? rcu_start_gp+0x40/0x40=
<br>
:[2173411.071022]=C2=A0 [&lt;ffffffff81085aef&gt;] kthread+0xcf/0xe0<br>
:[2173411.071027]=C2=A0 [&lt;ffffffff81085a20&gt;] ? kthread_create_on_node=
+0x140/0x140<br>
:[2173411.071032]=C2=A0 [&lt;ffffffff815f206c&gt;] ret_from_fork+0x7c/0xb0<=
br>
:[2173411.071037]=C2=A0 [&lt;ffffffff81085a20&gt;] ? kthread_create_on_node=
+0x140/0x140<br>
:[2173411.071039] Code: 48 8b 00 a8 01 74 20 e9 ee 00 00 00 66 0f 1f 44 00 =
00 49 8b 95 28 0a 00 00 65 ff 02 48 8b 00 a8 01 0f 85 d3 00 00 00 0f b6 50 =
37 &lt;48&gt; 89 c7 48 8d 0c d5 00 00 00 00 48 c1 e2 06 48 29 ca 48 83 c2<b=
r>
<span class=3D""><br>
os_info:<br>
:NAME=3D&quot;CentOS Linux&quot;<br>
:VERSION=3D&quot;7 (Core)&quot;<br>
:ID=3D&quot;centos&quot;<br>
:ID_LIKE=3D&quot;rhel fedora&quot;<br>
:VERSION_ID=3D&quot;7&quot;<br>
:PRETTY_NAME=3D&quot;CentOS Linux 7 (Core)&quot;<br>
:ANSI_COLOR=3D&quot;0;31&quot;<br>
:CPE_NAME=3D&quot;cpe:/o:centos:centos:7&quot;<br>
:HOME_URL=3D&quot;<a href=3D"https://www.centos.org/" target=3D"_blank">htt=
ps://www.centos.org/</a>&quot;<br>
:BUG_REPORT_URL=3D&quot;<a href=3D"https://bugs.centos.org/" target=3D"_bla=
nk">https://bugs.centos.org/</a>&quot;<br>
:<br>
<br>
proc_modules:<br>
</span>:bsd_comp 12921 0 - Live 0xffffffffa05b5000<br>
:nf_conntrack_netbios_ns 12665 0 - Live 0xffffffffa05b0000<br>
:nf_conntrack_broadcast 12589 1 nf_conntrack_netbios_ns, Live 0xffffffffa05=
ab000<br>
:ppp_synctty 13237 0 - Live 0xffffffffa059b000<br>
:ppp_async 17413 1 - Live 0xffffffffa05a5000<br>
:crc_ccitt 12707 1 ppp_async, Live 0xffffffffa05a0000<br>
:ppp_generic 33037 7 bsd_comp,ppp_synctty,ppp_async, Live 0xffffffffa059100=
0<br>
:slhc 13450 1 ppp_generic, Live 0xffffffffa058c000<br>
:xt_nat 12681 39 - Live 0xffffffffa0587000<br>
:xt_mark 12563 66 - Live 0xffffffffa0582000<br>
:ipt_MASQUERADE 12880 3 - Live 0xffffffffa057d000<br>
:ip6t_rpfilter 12546 1 - Live 0xffffffffa0578000<br>
:ip6t_REJECT 12939 2 - Live 0xffffffffa0573000<br>
:ipt_REJECT 12541 2 - Live 0xffffffffa056e000<br>
:xt_conntrack 12760 41 - Live 0xffffffffa0564000<br>
:ebtable_nat 12807 0 - Live 0xffffffffa055f000<br>
:ebtable_broute 12731 0 - Live 0xffffffffa0569000<br>
:bridge 110196 1 ebtable_broute, Live 0xffffffffa0543000<br>
:stp 12976 1 bridge, Live 0xffffffffa053e000<br>
:llc 14552 2 bridge,stp, Live 0xffffffffa0535000<br>
:ebtable_filter 12827 0 - Live 0xffffffffa0530000<br>
:ebtables 30913 3 ebtable_nat,ebtable_broute,ebtable_filter, Live 0xfffffff=
fa0523000<br>
:ip6table_nat 13015 1 - Live 0xffffffffa051e000<br>
:nf_conntrack_ipv6 18738 11 - Live 0xffffffffa0518000<br>
:nf_defrag_ipv6 34651 1 nf_conntrack_ipv6, Live 0xffffffffa050a000<br>
:nf_nat_ipv6 13279 1 ip6table_nat, Live 0xffffffffa0505000<br>
:ip6table_mangle 12700 1 - Live 0xffffffffa0500000<br>
:ip6table_security 12710 1 - Live 0xffffffffa04fb000<br>
:ip6table_raw 12683 1 - Live 0xffffffffa04f6000<br>
:ip6table_filter 12815 1 - Live 0xffffffffa04f1000<br>
:ip6_tables 27025 5 ip6table_nat,ip6table_mangle,ip6table_security,ip6table=
_raw,ip6table_filter, Live 0xffffffffa04e5000<br>
:iptable_nat 13011 1 - Live 0xffffffffa04e0000<br>
:nf_conntrack_ipv4 14862 32 - Live 0xffffffffa04db000<br>
:nf_defrag_ipv4 12729 1 nf_conntrack_ipv4, Live 0xffffffffa04cc000<br>
:nf_nat_ipv4 13263 1 iptable_nat, Live 0xffffffffa04c7000<br>
:nf_nat 21798 6 xt_nat,ipt_MASQUERADE,ip6table_nat,nf_nat_ipv6,iptable_nat,=
nf_nat_ipv4, Live 0xffffffffa04d4000<br>
:nf_conntrack 101024 11 nf_conntrack_netbios_ns,nf_conntrack_broadcast,ipt_=
MASQUERADE,xt_conntrack,ip6table_nat,nf_conntrack_ipv6,nf_nat_ipv6,iptable_=
nat,nf_conntrack_ipv4,nf_nat_ipv4,nf_nat, Live 0xffffffffa04ad000<br>
:iptable_mangle 12695 1 - Live 0xffffffffa04a8000<br>
:iptable_security 12705 1 - Live 0xffffffffa049b000<br>
:iptable_raw 12678 1 - Live 0xffffffffa048b000<br>
:iptable_filter 12810 1 - Live 0xffffffffa0419000<br>
:ip_tables 27239 5 iptable_nat,iptable_mangle,iptable_security,iptable_raw,=
iptable_filter, Live 0xffffffffa04a0000<br>
:sg 36533 0 - Live 0xffffffffa0491000<br>
:coretemp 13435 0 - Live 0xffffffffa03b0000<br>
:kvm 441119 0 - Live 0xffffffffa041e000<br>
:crct10dif_pclmul 14289 0 - Live 0xffffffffa03f2000<br>
:crc32_pclmul 13113 0 - Live 0xffffffffa03bb000<br>
:snd_hda_codec_hdmi 46433 1 - Live 0xffffffffa040c000<br>
:snd_hda_codec_realtek 57226 1 - Live 0xffffffffa03e3000<br>
:snd_hda_codec_generic 68082 1 snd_hda_codec_realtek, Live 0xffffffffa03fa0=
00<br>
:snd_hda_intel 48259 0 - Live 0xffffffffa03a3000<br>
:snd_hda_codec 137343 4 snd_hda_codec_hdmi,snd_hda_codec_realtek,snd_hda_co=
dec_generic,snd_hda_intel, Live 0xffffffffa03c0000<br>
:serio_raw 13462 0 - Live 0xffffffffa03b6000<br>
:crc32c_intel 22079 0 - Live 0xffffffffa0397000<br>
:snd_hwdep 13602 1 snd_hda_codec, Live 0xffffffffa039e000<br>
:snd_seq 61519 0 - Live 0xffffffffa0386000<br>
:snd_seq_device 14497 1 snd_seq, Live 0xffffffffa033e000<br>
:snd_pcm 97511 3 snd_hda_codec_hdmi,snd_hda_intel,snd_hda_codec, Live 0xfff=
fffffa036d000<br>
:ppdev 17671 0 - Live 0xffffffffa0367000<br>
:iTCO_wdt 13480 0 - Live 0xffffffffa0362000<br>
:iTCO_vendor_support 13718 1 iTCO_wdt, Live 0xffffffffa035a000<br>
:i2c_i801 18135 0 - Live 0xffffffffa0350000<br>
:pcspkr 12718 0 - Live 0xffffffffa0348000<br>
:ghash_clmulni_intel 13259 0 - Live 0xffffffffa0343000<br>
<span class=3D"">:snd_page_alloc 18710 2 snd_hda_intel,snd_pcm, Live 0xffff=
ffffa0338000<br>
</span>:cryptd 20359 1 ghash_clmulni_intel, Live 0xffffffffa0332000<br>
:mei_me 18568 0 - Live 0xffffffffa02f0000<br>
:mei 77872 1 mei_me, Live 0xffffffffa031d000<br>
:snd_timer 29482 2 snd_seq,snd_pcm, Live 0xffffffffa0136000<br>
:snd 74645 10 snd_hda_codec_hdmi,snd_hda_codec_realtek,snd_hda_codec_generi=
c,snd_hda_intel,snd_hda_codec,snd_hwdep,snd_seq,snd_seq_device,snd_pcm,snd_=
timer, Live 0xffffffffa0309000<br>
:soundcore 15047 1 snd, Live 0xffffffffa0125000<br>
:r8169 71677 0 - Live 0xffffffffa02f6000<br>
:mii 13934 1 r8169, Live 0xffffffffa010a000<br>
:parport_pc 28165 0 - Live 0xffffffffa02e8000<br>
:parport 42348 2 ppdev,parport_pc, Live 0xffffffffa012a000<br>
:lpc_ich 16977 0 - Live 0xffffffffa011f000<br>
:mfd_core 13435 1 lpc_ich, Live 0xffffffffa010f000<br>
:shpchp 37032 0 - Live 0xffffffffa0114000<br>
:mperf 12667 0 - Live 0xffffffffa0100000<br>
<span class=3D"">:xfs 914152 3 - Live 0xffffffffa0207000<br>
</span>:libcrc32c 12644 1 xfs, Live 0xffffffffa0105000<br>
:sd_mod 45373 3 - Live 0xffffffffa00f3000<br>
<span class=3D"">:crc_t10dif 12714 1 sd_mod, Live 0xffffffffa00b5000<br>
:crct10dif_common 12595 2 crct10dif_pclmul,crc_t10dif, Live 0xffffffffa00b0=
000<br>
</span>:ata_generic 12910 0 - Live 0xffffffffa00ab000<br>
:pata_acpi 13038 0 - Live 0xffffffffa004f000<br>
<span class=3D"">:i915 710975 1 - Live 0xffffffffa0158000<br>
</span><span class=3D"">:ahci 25819 2 - Live 0xffffffffa00a0000<br>
</span><span class=3D"">:i2c_algo_bit 13413 1 i915, Live 0xffffffffa0022000=
<br>
</span>:pata_jmicron 12758 0 - Live 0xffffffffa003e000<br>
<span class=3D"">:libahci 32009 1 ahci, Live 0xffffffffa014f000<br>
</span>:drm_kms_helper 52758 1 i915, Live 0xffffffffa0141000<br>
:libata 219478 5 ata_generic,pata_acpi,ahci,pata_jmicron,libahci, Live 0xff=
ffffffa00bc000<br>
<div class=3D"HOEnZb"></div><br>----------<br><span class=3D"undefined"><fo=
nt color=3D"#888">From: <b class=3D"undefined"></b> <span dir=3D"ltr">&lt;u=
ser@localhost.centos&gt;</span><br>Date: 2015-02-02 3:24 GMT+03:00<br>To: r=
oot@localhost.centos<br></font><br></span><br><span class=3D"">abrt_version=
:=C2=A0 =C2=A02.1.11<br>
cmdline:=C2=A0 =C2=A0 =C2=A0 =C2=A0 BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el7.x8=
6_64 root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro <a href=3D"http:=
//rd.lvm.lv" target=3D"_blank">rd.lvm.lv</a>=3Dcentos_router/swap vconsole.=
font=3Dlatarcyrheb-sun16 <a href=3D"http://rd.lvm.lv" target=3D"_blank">rd.=
lvm.lv</a>=3Dcentos_router/root crashkernel=3Dauto vconsole.keymap=3Dus rhg=
b quiet LANG=3Den_US.UTF-8<br>
hostname:=C2=A0 =C2=A0 =C2=A0 =C2=A0router.centos<br>
kernel:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03.10.0-123.el7.x86_64<br>
</span>last_occurrence: 1422836636<br>
<div class=3D"HOEnZb"></div><br>----------<br><span class=3D"undefined"><fo=
nt color=3D"#888">From: <b class=3D"undefined"></b> <span dir=3D"ltr">&lt;u=
ser@localhost.centos&gt;</span><br>Date: 2015-02-02 6:05 GMT+03:00<br>To: r=
oot@localhost.centos<br></font><br></span><br><span class=3D"">abrt_version=
:=C2=A0 =C2=A02.1.11<br>
cmdline:=C2=A0 =C2=A0 =C2=A0 =C2=A0 BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el7.x8=
6_64 root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro <a href=3D"http:=
//rd.lvm.lv" target=3D"_blank">rd.lvm.lv</a>=3Dcentos_router/swap vconsole.=
font=3Dlatarcyrheb-sun16 <a href=3D"http://rd.lvm.lv" target=3D"_blank">rd.=
lvm.lv</a>=3Dcentos_router/root crashkernel=3Dauto vconsole.keymap=3Dus rhg=
b quiet LANG=3Den_US.UTF-8<br>
hostname:=C2=A0 =C2=A0 =C2=A0 =C2=A0router.centos<br>
kernel:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03.10.0-123.el7.x86_64<br>
</span>last_occurrence: 1422846288<br>
<div class=3D"HOEnZb"></div><br>----------<br><span class=3D"undefined"><fo=
nt color=3D"#888">From: <b class=3D"undefined"></b> <span dir=3D"ltr">&lt;u=
ser@localhost.centos&gt;</span><br>Date: 2015-02-02 7:28 GMT+03:00<br>To: r=
oot@localhost.centos<br></font><br></span><br><span class=3D"">abrt_version=
:=C2=A0 =C2=A02.1.11<br>
cmdline:=C2=A0 =C2=A0 =C2=A0 =C2=A0 BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el7.x8=
6_64 root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro <a href=3D"http:=
//rd.lvm.lv" target=3D"_blank">rd.lvm.lv</a>=3Dcentos_router/swap vconsole.=
font=3Dlatarcyrheb-sun16 <a href=3D"http://rd.lvm.lv" target=3D"_blank">rd.=
lvm.lv</a>=3Dcentos_router/root crashkernel=3Dauto vconsole.keymap=3Dus rhg=
b quiet LANG=3Den_US.UTF-8<br>
hostname:=C2=A0 =C2=A0 =C2=A0 =C2=A0router.centos<br>
kernel:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03.10.0-123.el7.x86_64<br>
</span>last_occurrence: 1422851292<br>
<div class=3D"HOEnZb"></div><br>----------<br><span class=3D"undefined"><fo=
nt color=3D"#888">From: <b class=3D"undefined"></b> <span dir=3D"ltr">&lt;u=
ser@localhost.centos&gt;</span><br>Date: 2015-02-02 8:11 GMT+03:00<br>To: r=
oot@localhost.centos<br></font><br></span><br><span class=3D"">abrt_version=
:=C2=A0 =C2=A02.1.11<br>
cmdline:=C2=A0 =C2=A0 =C2=A0 =C2=A0 BOOT_IMAGE=3D/vmlinuz-3.10.0-123.el7.x8=
6_64 root=3DUUID=3D328b16e8-5f97-4c97-80c2-1269e2157281 ro <a href=3D"http:=
//rd.lvm.lv" target=3D"_blank">rd.lvm.lv</a>=3Dcentos_router/swap vconsole.=
font=3Dlatarcyrheb-sun16 <a href=3D"http://rd.lvm.lv" target=3D"_blank">rd.=
lvm.lv</a>=3Dcentos_router/root crashkernel=3Dauto vconsole.keymap=3Dus rhg=
b quiet LANG=3Den_US.UTF-8<br>
hostname:=C2=A0 =C2=A0 =C2=A0 =C2=A0router.centos<br>
kernel:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03.10.0-123.el7.x86_64<br>
</span>last_occurrence: 1422853850<br>
<div class=3D"HOEnZb"></div><br></div><br><br clear=3D"all"><div><br></div>=
-- <br><div class=3D"gmail_signature">=D0=A1 =D1=83=D0=B2=D0=B0=D0=B6=D0=B5=
=D0=BD=D0=B8=D0=B5=D0=BC =D0=A8=D0=B5=D0=B2=D1=87=D0=B5=D0=BD=D0=BA=D0=BE =
=D0=98=D0=B3=D0=BE=D1=80=D1=8C.<br>mailto://<a href=3D"mailto:valens254@gma=
il.com">valens254@gmail.com</a></div>
</div>

--047d7bfcf662596bda050e1547c4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
