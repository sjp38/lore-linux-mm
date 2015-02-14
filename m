Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id A8F346B00A0
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 20:27:06 -0500 (EST)
Received: by pdjz10 with SMTP id z10so22762304pdj.12
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 17:27:06 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id mx3si4922823pdb.184.2015.02.13.17.27.04
        for <linux-mm@kvack.org>;
        Fri, 13 Feb 2015 17:27:04 -0800 (PST)
Date: Sat, 14 Feb 2015 09:26:59 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [akpm merge] BUG: non-zero nr_pmds on freeing mm: 2
Message-ID: <20150214012659.GA4681@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ew6BAiZeqk4r7MaW"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Stephen,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

commit 8fe7fba50596a8efb6e1ef15b1b4890f95eeffcd
Merge: 2ef44b3 d07b956
Author:     Stephen Rothwell <sfr@canb.auug.org.au>
AuthorDate: Fri Feb 13 15:56:51 2015 +1100
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Fri Feb 13 15:56:51 2015 +1100

    Merge branch 'akpm-current/current'
   =20
    Conflicts:
    	arch/x86/include/asm/pgtable_64.h
    	include/linux/memcontrol.h
    	include/linux/mm.h
    	include/linux/slab.h
    	include/linux/swapops.h
    	kernel/fork.c
    	lib/Makefile
    	mm/memcontrol.c
    	mm/mprotect.c
    	mm/slab.h
    	mm/slab_common.c
    	mm/swap.c
    	scripts/module-common.lds

+------------------------------------+------------+------------+-----------=
-+---------------+
|                                    | 2ef44b3a9e | d07b956c65 | 8fe7fba505=
 | next-20150213 |
+------------------------------------+------------+------------+-----------=
-+---------------+
| boot_successes                     | 60         | 60         | 0         =
 | 0             |
| boot_failures                      | 0          | 0          | 20        =
 | 14            |
| BUG:non-zero_nr_pmds_on_freeing_mm | 0          | 0          | 20        =
 | 14            |
+------------------------------------+------------+------------+-----------=
-+---------------+

[    2.209695] debug: unmapping init [mem 0xffff88000ff75000-0xffff88000fff=
ffff]
[    2.210862] debug: unmapping init [mem 0xffff8800103d1000-0xffff8800103f=
ffff]
[    2.217056] random: init urandom read with 3 bits of entropy available
[    2.219092] BUG: non-zero nr_pmds on freeing mm: 2
[    2.221865] BUG: non-zero nr_pmds on freeing mm: 3
[    2.224047] BUG: non-zero nr_pmds on freeing mm: 2
[    2.225538] hostname (100) used greatest stack depth: 14200 bytes left
[    2.226392] BUG: non-zero nr_pmds on freeing mm: 4
[    2.227118] mount (97) used greatest stack depth: 14104 bytes left
[    2.227811] BUG: non-zero nr_pmds on freeing mm: 3
[    2.228896] BUG: non-zero nr_pmds on freeing mm: 3
[    2.230337] BUG: non-zero nr_pmds on freeing mm: 2
[    2.231197] BUG: non-zero nr_pmds on freeing mm: 3
[    2.233237] BUG: non-zero nr_pmds on freeing mm: 3
[    2.234339] BUG: non-zero nr_pmds on freeing mm: 3
[    2.235530] BUG: non-zero nr_pmds on freeing mm: 2
[    2.237687] BUG: non-zero nr_pmds on freeing mm: 4
[    2.240279] BUG: non-zero nr_pmds on freeing mm: 4
[    2.241549] BUG: non-zero nr_pmds on freeing mm: 3
[    2.242726] BUG: non-zero nr_pmds on freeing mm: 3
[    2.243792] BUG: non-zero nr_pmds on freeing mm: 3
[    2.244839] BUG: non-zero nr_pmds on freeing mm: 2
[    2.245741] BUG: non-zero nr_pmds on freeing mm: 4
[    2.246546] BUG: non-zero nr_pmds on freeing mm: 3
/bin/sh: /proc/self/fd/9: No such file or directory
[    2.249348] BUG: non-zero nr_pmds on freeing mm: 4
[    2.250126] BUG: non-zero nr_pmds on freeing mm: 3
[    2.251983] BUG: non-zero nr_pmds on freeing mm: 4
[    2.253333] BUG: non-zero nr_pmds on freeing mm: 2
[    2.255435] BUG: non-zero nr_pmds on freeing mm: 3
[    2.256551] BUG: non-zero nr_pmds on freeing mm: 3
[    2.259066] BUG: non-zero nr_pmds on freeing mm: 3
[    2.260070] BUG: non-zero nr_pmds on freeing mm: 4
[    2.260977] BUG: non-zero nr_pmds on freeing mm: 4
[    2.262336] BUG: non-zero nr_pmds on freeing mm: 2
[    2.264123] sh (122) used greatest stack depth: 13992 bytes left
[    2.264831] BUG: non-zero nr_pmds on freeing mm: 4
[    2.266065] BUG: non-zero nr_pmds on freeing mm: 2
/bin/sh: /proc/self/fd/9: No such file or directory
[    2.268783] BUG: non-zero nr_pmds on freeing mm: 4
[    2.269971] BUG: non-zero nr_pmds on freeing mm: 2
/bin/sh: /proc/self/fd/9: No such file or directory
[    2.272452] BUG: non-zero nr_pmds on freeing mm: 4

Elapsed time: 5
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/x86_64-randconfig=
-n0-02131024/8fe7fba50596a8efb6e1ef15b1b4890f95eeffcd/vmlinuz-3.19.0-g8fe7f=
ba -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 rd.udev.log-prio=
rity=3Derr systemd.log_target=3Djournal systemd.log_level=3Dwarning debug a=
pic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=
=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=
=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal =
 root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randconfig-n=
0-02131024/next:master:8fe7fba50596a8efb6e1ef15b1b4890f95eeffcd:bisect-linu=
x-7/.vmlinuz-8fe7fba50596a8efb6e1ef15b1b4890f95eeffcd-20150213172638-7-clie=
nt7 branch=3Dnext/master BOOT_IMAGE=3D/kernel/x86_64-randconfig-n0-02131024=
/8fe7fba50596a8efb6e1ef15b1b4890f95eeffcd/vmlinuz-3.19.0-g8fe7fba drbd.mino=
r_count=3D8'  -initrd /kernel-tests/initrd/quantal-core-x86_64.cgz -m 320 -=
smp 2 -net nic,vlan=3D1,model=3De1000 -net user,vlan=3D1 -boot order=3Dnc -=
no-reboot -watchdog i6300esb -rtc base=3Dlocaltime -pidfile /dev/shm/kboot/=
pid-quantal-client7-5 -serial file:/dev/shm/kboot/serial-quantal-client7-5 =
-daemonize -display none -monitor null=20

git bisect start b8acf73194186a5cba86812eb4ba17b897f0e13e bfa76d49576599a4b=
9f9b7a71f23d73d6dcff735 --
git bisect good 15763db134dd60504dbd93137e6654f06d639acf  # 15:04     20+  =
    0  Merge branch 'for-3.20' of git://git.kernel.org/pub/scm/linux/kernel=
/git/tj/cgroup
git bisect good 6e822065fa5ce80b14e82948c86d91b1844a4092  # 16:13     20+  =
    0  Merge remote-tracking branch 'char-misc/char-misc-next'
git bisect good e4bd2bf79cef1c75552eab6a8623a7005335b361  # 16:35     20+  =
    0  Merge remote-tracking branch 'clk/clk-next'
git bisect good 806acae0b8ec190eacb14c5db56fa492353d8672  # 17:04     20+  =
    0  Merge remote-tracking branch 'y2038/y2038'
git bisect  bad 8fe7fba50596a8efb6e1ef15b1b4890f95eeffcd  # 17:29      0-  =
   20  Merge branch 'akpm-current/current'
git bisect good 2ef44b3a9ead3e81621386b9227f3c12da95a05d  # 18:07     20+  =
    0  Merge remote-tracking branch 'access_once/linux-next'
git bisect good 9ddc30fda3048a05dfb377422a560709bfd6b95a  # 18:28     20+  =
    0  x86-add-pmd_-for-thp-fix
git bisect good 78baabee9d8ed5eca4d6c3e11282f131aad503d5  # 18:58     20+  =
    0  irq: use %*pb[l] to print bitmaps including cpumasks and nodemasks
git bisect good df9fbe22ce6f7048ceb77c2ca72b27066ae75509  # 19:22     20+  =
    0  fs-befs-linuxvfsc-remove-unnecessary-casting-fix
git bisect good 3a1f139f4faaa9e30d7d72f5328410b430f3f74e  # 19:43     20+  =
    0  scripts/gdb: add cache for type objects
git bisect good 97dc3f62c8f37795cdee3001e86c346dd7f7a879  # 20:09     20+  =
    0  scripts/gdb: add internal helper and convenience function for per-cp=
u lookup
git bisect good 135b2593df87b40d0eab61d7e3183106ef622bdf  # 20:26     20+  =
    0  scripts/gdb: convert ModuleList to generator function
git bisect good e0c48fa7b961ea3e420c60fcddd3100b3413546a  # 20:58     20+  =
    0  ipc,sem: use current->state helpers
git bisect good b4970b267279135de6984f101bde0ad7c49bb619  # 21:20     20+  =
    0  samples-seccomp-improve-label-helper-fix
git bisect good d07b956c650ad58a8ce00517515ebaf962e1f5c7  # 21:42     20+  =
    0  scripts/gdb: Add infrastructure
# first bad commit: [8fe7fba50596a8efb6e1ef15b1b4890f95eeffcd] Merge branch=
 'akpm-current/current'
git bisect good 2ef44b3a9ead3e81621386b9227f3c12da95a05d  # 21:44     60+  =
    0  Merge remote-tracking branch 'access_once/linux-next'
git bisect good d07b956c650ad58a8ce00517515ebaf962e1f5c7  # 21:46     60+  =
    0  scripts/gdb: Add infrastructure
# extra tests on HEAD of next/master
git bisect  bad b8acf73194186a5cba86812eb4ba17b897f0e13e  # 21:46      0-  =
   14  Add linux-next specific files for 20150213
# extra tests on tree/branch next/master
git bisect  bad b8acf73194186a5cba86812eb4ba17b897f0e13e  # 21:46      0-  =
   14  Add linux-next specific files for 20150213
# extra tests on tree/branch linus/master
# extra tests on tree/branch next/master
git bisect  bad b8acf73194186a5cba86812eb4ba17b897f0e13e  # 22:02      0-  =
   14  Add linux-next specific files for 20150213


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=3D$1
initrd=3Dquantal-core-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/mas=
ter/initrd/$initrd

kvm=3D(
	qemu-system-x86_64
	-cpu kvm64
	-enable-kvm
	-kernel $kernel
	-initrd $initrd
	-m 320
	-smp 2
	-net nic,vlan=3D1,model=3De1000
	-net user,vlan=3D1
	-boot order=3Dnc
	-no-reboot
	-watchdog i6300esb
	-rtc base=3Dlocaltime
	-serial stdio
	-display none
	-monitor null=20
)

append=3D(
	hung_task_panic=3D1
	earlyprintk=3DttyS0,115200
	rd.udev.log-priority=3Derr
	systemd.log_target=3Djournal
	systemd.log_level=3Dwarning
	debug
	apic=3Ddebug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=3D100
	panic=3D-1
	softlockup_panic=3D1
	nmi_watchdog=3Dpanic
	oops=3Dpanic
	load_ramdisk=3D2
	prompt_ramdisk=3D0
	console=3DttyS0,115200
	console=3Dtty0
	vga=3Dnormal
	root=3D/dev/ram0
	rw
	drbd.minor_count=3D8
)

"${kvm[@]}" --append "${append[*]}"
----------------------------------------------------------------------------

Thanks,
Fengguang

--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-client7-5:20150213172913:x86_64-randconfig-n0-02131024:3.19.0-g8fe7fba:5"
Content-Transfer-Encoding: quoted-printable

early console in setup code
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.19.0-g8fe7fba (kbuild@lkp-nhm1) (gcc version=
 4.9.1 (Debian 4.9.1-19) ) #5 Fri Feb 13 17:23:04 CST 2015
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log_level=
=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_t=
imeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpa=
nic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtt=
y0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86=
_64-randconfig-n0-02131024/next:master:8fe7fba50596a8efb6e1ef15b1b4890f95ee=
ffcd:bisect-linux-7/.vmlinuz-8fe7fba50596a8efb6e1ef15b1b4890f95eeffcd-20150=
213172638-7-client7 branch=3Dnext/master BOOT_IMAGE=3D/kernel/x86_64-randco=
nfig-n0-02131024/8fe7fba50596a8efb6e1ef15b1b4890f95eeffcd/vmlinuz-3.19.0-g8=
fe7fba drbd.minor_count=3D8
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013fdffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013fe0000-0x0000000013ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13fe0 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f0eb0-0x000f0ebf] mapped at =
[ffff8800000f0eb0]
[    0.000000]   mpc: f0ec0-f0fa4
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x1144c000, 0x1144cfff] PGTABLE
[    0.000000] BRK [0x1144d000, 0x1144dfff] PGTABLE
[    0.000000] BRK [0x1144e000, 0x1144efff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12600000-0x127fffff]
[    0.000000]  [mem 0x12600000-0x127fffff] page 4k
[    0.000000] BRK [0x1144f000, 0x1144ffff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x125fffff]
[    0.000000]  [mem 0x00100000-0x125fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12800000-0x13fdffff]
[    0.000000]  [mem 0x12800000-0x13fdffff] page 4k
[    0.000000] BRK [0x11450000, 0x11450fff] PGTABLE
[    0.000000] BRK [0x11451000, 0x11451fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x12925000-0x13fd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0C90 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0000000013FE18BD 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0000000013FE0B37 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000013FE0040 000AF7 (v01 BOCHS  BXPCDSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x0000000013FE0000 000040
[    0.000000] ACPI: SSDT 0x0000000013FE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0000000013FE1805 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0000000013FE1885 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13fdf001, primary cpu clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x0000000013fdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x0000000013fdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000013fdf=
fff]
[    0.000000] On node 0 totalpages: 81790
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1216 pages used for memmap
[    0.000000]   DMA32 zone: 77792 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] mapped IOAPIC to ffffffffff5fb000 (fec00000)
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 10430040
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 80489
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log=
_level=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_s=
tall_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oop=
s=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/k=
vm/x86_64-randconfig-n0-02131024/next:master:8fe7fba50596a8efb6e1ef15b1b489=
0f95eeffcd:bisect-linux-7/.vmlinuz-8fe7fba50596a8efb6e1ef15b1b4890f95eeffcd=
-20150213172638-7-client7 branch=3Dnext/master BOOT_IMAGE=3D/kernel/x86_64-=
randconfig-n0-02131024/8fe7fba50596a8efb6e1ef15b1b4890f95eeffcd/vmlinuz-3.1=
9.0-g8fe7fba drbd.minor_count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.000000] Memory: 266524K/327160K available (7628K kernel code, 2876K =
rwdata, 3908K rodata, 724K init, 13080K bss, 60636K reserved, 0K cma-reserv=
ed)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D1, N=
odes=3D1
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8639 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ODEBUG: selftest passed
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2925.998 MHz processor
[    0.008000] Calibrating delay loop (skipped) preset value.. 5851.99 Bogo=
MIPS (lpj=3D11703992)
[    0.008000] pid_max: default: 32768 minimum: 301
[    0.008000] ACPI: Core revision 20150204
[    0.009160] ACPI: All ACPI Tables successfully acquired
[    0.009723] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.010301] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 by=
tes)
[    0.011091] Initializing cgroup subsys devices
[    0.011494] Initializing cgroup subsys net_cls
[    0.011892] Initializing cgroup subsys net_prio
[    0.012008] Initializing cgroup subsys debug
[    0.012446] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.012922] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.013439] CPU: Intel Common KVM processor (fam: 0f, model: 06, steppin=
g: 01)
[    0.016785] Performance Events: unsupported Netburst CPU model 6 no PMU =
driver, software events only.
[    0.017872] Getting VERSION: 1050014
[    0.018197] Getting VERSION: 1050014
[    0.018513] Getting ID: 0
[    0.018756] Getting ID: ff000000
[    0.019049] Getting LVT0: 8700
[    0.019319] Getting LVT1: 8400
[    0.019630] enabled ExtINT on CPU#0
[    0.020592] ENABLING IO-APIC IRQs
[    0.020900] init IO_APIC IRQs
[    0.021166]  apic 0 pin 0 not connected
[    0.021507] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.022206] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.022906] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.023600] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.024035] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.024737] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.025435] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.026125] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.026820] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.028018] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.028710] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.029424] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.030132] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.030837] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.031543] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.032019] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.032726]  apic 0 pin 16 not connected
[    0.033065]  apic 0 pin 17 not connected
[    0.033403]  apic 0 pin 18 not connected
[    0.033746]  apic 0 pin 19 not connected
[    0.034084]  apic 0 pin 20 not connected
[    0.034423]  apic 0 pin 21 not connected
[    0.034766]  apic 0 pin 22 not connected
[    0.035105]  apic 0 pin 23 not connected
[    0.035580] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.036003] Using local APIC timer interrupts.
[    0.036003] calibrating APIC timer ...
[    0.040000] ... lapic delta =3D 6253806
[    0.040000] ... PM-Timer delta =3D 358187
[    0.040000] ... PM-Timer result ok
[    0.040000] ..... delta 6253806
[    0.040000] ..... mult: 268598922
[    0.040000] ..... calibration result: 4002435
[    0.040000] ..... CPU clock speed is 2928.0133 MHz.
[    0.040000] ..... host bus clock speed is 1000.2435 MHz.
[    0.040000] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.040000] devtmpfs: initialized
[    0.040746] prandom: seed boundary self test passed
[    0.041829] prandom: 100 self tests passed
[    0.042494] regulator-dummy: no parameters
[    0.043191] NET: Registered protocol family 16
[    0.044353] cpuidle: using governor ladder
[    0.044821] cpuidle: using governor menu
[    0.045747] ACPI: bus type PCI registered
[    0.046241] dca service started, version 1.12.1
[    0.046792] PCI: Using configuration type 1 for base access
[    0.057974] ACPI: Added _OSI(Module Device)
[    0.058446] ACPI: Added _OSI(Processor Device)
[    0.058956] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.059498] ACPI: Added _OSI(Processor Aggregator Device)
[    0.061566] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.065407] ACPI: Interpreter enabled
[    0.065840] ACPI: (supports S0 S5)
[    0.066228] ACPI: Using IOAPIC for interrupt routing
[    0.066809] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.075542] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.076008] acpi PNP0A03:00: _OSC: OS supports [Segments MSI]
[    0.076668] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.077621] PCI host bridge to bus 0000:00
[    0.078094] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.078704] pci_bus 0000:00: root bus resource [io  0x0cf8-0x0cff]
[    0.079389] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.080003] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff window]
[    0.080752] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff window]
[    0.081509] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf window]
[    0.082263] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff window]
[    0.083012] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f window]
[    0.084003] pci_bus 0000:00: root bus resource [mem 0x14000000-0xfebffff=
f window]
[    0.084881] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.086029] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.087233] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.090441] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.092025] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    0.092800] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.093503] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    0.094263] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.095238] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.096206] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX=
4 ACPI
[    0.096985] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX=
4 SMB
[    0.098092] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.099671] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.100835] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.105647] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.106680] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.108393] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.109807] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.114228] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.115241] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.116218] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.119655] pci_bus 0000:00: on NUMA node 0
[    0.120663] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.121516] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.122384] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.123224] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.124241] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.125402] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.126312] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.126898] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.127742] vgaarb: loaded
[    0.128002] vgaarb: bridge control possible 0000:00:02.0
[    0.128916] SCSI subsystem initialized
[    0.129413] libata version 3.00 loaded.
[    0.129921] Linux video capture interface: v2.00
[    0.130481] pps_core: LinuxPPS API ver. 1 registered
[    0.130998] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.132012] PTP clock support registered
[    0.132541] PCI: Using ACPI for IRQ routing
[    0.133009] PCI: pci_cache_line_size set to 64 bytes
[    0.133650] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.134352] e820: reserve RAM buffer [mem 0x13fe0000-0x13ffffff]
[    0.135283] NET: Registered protocol family 23
[    0.135790] NET: Registered protocol family 8
[    0.136003] NET: Registered protocol family 20
[    0.136469] nfc: nfc_init: NFC Core ver 0.1
[    0.136964] NET: Registered protocol family 39
[    0.137838] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    0.138624] Switched to clocksource kvm-clock
[    0.139184] FS-Cache: Loaded
[    0.139519] pnp: PnP ACPI init
[    0.139519] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.139519] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.139519] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.139800] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.140565] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.141461] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.142236] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.143071] pnp 00:03: [dma 2]
[    0.143460] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.144253] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.145177] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.145956] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.146879] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.148040] pnp: PnP ACPI: found 6 devices
[    0.153653] pci_bus 0000:00: resource 4 [io  0x0cf8-0x0cff]
[    0.154274] pci_bus 0000:00: resource 5 [io  0x0000-0x0cf7 window]
[    0.154945] pci_bus 0000:00: resource 6 [io  0x0d00-0xadff window]
[    0.155596] pci_bus 0000:00: resource 7 [io  0xae0f-0xaeff window]
[    0.156358] pci_bus 0000:00: resource 8 [io  0xaf20-0xafdf window]
[    0.157321] pci_bus 0000:00: resource 9 [io  0xafe4-0xffff window]
[    0.158289] pci_bus 0000:00: resource 10 [mem 0x000a0000-0x000bffff wind=
ow]
[    0.159364] pci_bus 0000:00: resource 11 [mem 0x14000000-0xfebfffff wind=
ow]
[    0.160523] NET: Registered protocol family 2
[    0.161400] TCP established hash table entries: 4096 (order: 3, 32768 by=
tes)
[    0.162596] TCP bind hash table entries: 4096 (order: 6, 327680 bytes)
[    0.163905] TCP: Hash tables configured (established 4096 bind 4096)
[    0.164985] TCP: reno registered
[    0.165553] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    0.166576] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    0.167809] NET: Registered protocol family 1
[    0.168874] RPC: Registered named UNIX socket transport module.
[    0.169894] RPC: Registered udp transport module.
[    0.170719] RPC: Registered tcp transport module.
[    0.171536] RPC: Registered tcp NFSv4.1 backchannel transport module
--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--ew6BAiZeqk4r7MaW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
