Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC8BD6B000D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 02:16:58 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id y83so35607634qka.7
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 23:16:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t9-v6si4901229qth.297.2018.11.13.23.16.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 23:16:53 -0800 (PST)
Date: Wed, 14 Nov 2018 15:16:42 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181114071642.GC2653@MiWiFi-R3L-srv>
References: <20181114070909.GB2653@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20181114070909.GB2653@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mhocko@suse.com, akpm@linux-foundation.org, aarcange@redhat.com, david@redhat.com

On 11/14/18 at 03:09pm, Baoquan He wrote:
> Hi,
>=20
> Tested memory hotplug on a bare metal system, hot removing always
> trigger a lock. Usually need hot plug/unplug several times, then the hot
> removing will hang there at the last block. Surely with memory pressure
> added by executing "stress -m 200".

By the way, the release is 4.20-rc2 on linus's tree.

>=20
> Will attach the log partly. Any idea or suggestion, appreciated.=20
>=20
> Thanks
> Baoquan

> ......
>=20
> [  +0.000000] BIOS-provided physical RAM map:
> [  +0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009ffff] usab=
le
> [  +0.000000] BIOS-e820: [mem 0x00000000000a0000-0x00000000000fffff] rese=
rved
> [  +0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000041a2dfff] usab=
le
> [  +0.000000] BIOS-e820: [mem 0x0000000041a2e000-0x0000000041a2efff] unus=
able
> [  +0.000000] BIOS-e820: [mem 0x0000000041a2f000-0x000000004f22efff] usab=
le
> [  +0.000000] BIOS-e820: [mem 0x000000004f22f000-0x000000005122efff] rese=
rved
> [  +0.000000] BIOS-e820: [mem 0x000000005122f000-0x000000005147efff] ACPI=
 data
> [  +0.000000] BIOS-e820: [mem 0x000000005147f000-0x000000005947efff] ACPI=
 NVS
> [  +0.000000] BIOS-e820: [mem 0x000000005947f000-0x000000005b87efff] rese=
rved
> [  +0.000000] BIOS-e820: [mem 0x000000005b87f000-0x000000006d265fff] usab=
le
> [  +0.000000] BIOS-e820: [mem 0x000000006d266000-0x000000006d2ebfff] rese=
rved
> [  +0.000000] BIOS-e820: [mem 0x000000006d2ec000-0x000000006fffffff] usab=
le
> [  +0.000000] BIOS-e820: [mem 0x0000000070000000-0x000000008fffffff] rese=
rved
> [  +0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] rese=
rved
> [  +0.000000] BIOS-e820: [mem 0x00000000ff000000-0x00000000ffffffff] rese=
rved
> [  +0.000000] BIOS-e820: [mem 0x0000000100000000-0x0000000fffffffff] usab=
le
> [  +0.000000] BIOS-e820: [mem 0x000000ff80000000-0x0000010fffffffff] usab=
le
> [  +0.000000] BIOS-e820: [mem 0x0000080000000000-0x0000080fffffffff] usab=
le
> [  +0.000000] BIOS-e820: [mem 0x0000090000000000-0x0000090fffffffff] usab=
le
> [  +0.000000] BIOS-e820: [mem 0x0000100000000000-0x0000100fffffffff] usab=
le
> [  +0.000000] BIOS-e820: [mem 0x0000110000000000-0x0000110fffffffff] usab=
le
> [  +0.000000] BIOS-e820: [mem 0x0000180000000000-0x0000180fffffffff] usab=
le
> [  +0.000000] BIOS-e820: [mem 0x0000190000000000-0x0000190fffffffff] usab=
le
> [  +0.000000] BIOS-e820: [mem 0x0000200100000000-0x000020013fffffff] rese=
rved
> [  +0.000000] NX (Execute Disable) protection: active
> [  +0.000000] e820: update [mem 0x28bc5018-0x28bdf857] usable =3D=3D> usa=
ble
> [  +0.000000] e820: update [mem 0x28bc5018-0x28bdf857] usable =3D=3D> usa=
ble
> [  +0.000000] extended physical RAM map:
> [  +0.000000] reserve setup_data: [mem 0x0000000000000000-0x000000000009f=
fff] usable
> [  +0.000000] reserve setup_data: [mem 0x00000000000a0000-0x00000000000ff=
fff] reserved
> [  +0.000000] reserve setup_data: [mem 0x0000000000100000-0x0000000028bc5=
017] usable
> [  +0.000000] reserve setup_data: [mem 0x0000000028bc5018-0x0000000028bdf=
857] usable
> [  +0.000000] reserve setup_data: [mem 0x0000000028bdf858-0x0000000041a2d=
fff] usable
> [  +0.000000] reserve setup_data: [mem 0x0000000041a2e000-0x0000000041a2e=
fff] unusable
> [  +0.000000] reserve setup_data: [mem 0x0000000041a2f000-0x000000004f22e=
fff] usable
> [  +0.000000] reserve setup_data: [mem 0x000000004f22f000-0x000000005122e=
fff] reserved
> [  +0.000000] reserve setup_data: [mem 0x000000005122f000-0x000000005147e=
fff] ACPI data
> [  +0.000000] reserve setup_data: [mem 0x000000005147f000-0x000000005947e=
fff] ACPI NVS
> [  +0.000000] reserve setup_data: [mem 0x000000005947f000-0x000000005b87e=
fff] reserved
> [  +0.000000] reserve setup_data: [mem 0x000000005b87f000-0x000000006d265=
fff] usable
> [  +0.000000] reserve setup_data: [mem 0x000000006d266000-0x000000006d2eb=
fff] reserved
> [  +0.000000] reserve setup_data: [mem 0x000000006d2ec000-0x000000006ffff=
fff] usable
> [  +0.000000] reserve setup_data: [mem 0x0000000070000000-0x000000008ffff=
fff] reserved
> [  +0.000000] reserve setup_data: [mem 0x00000000fed1c000-0x00000000fed1f=
fff] reserved
> [  +0.000000] reserve setup_data: [mem 0x00000000ff000000-0x00000000fffff=
fff] reserved
> [  +0.000000] reserve setup_data: [mem 0x0000000100000000-0x0000000ffffff=
fff] usable
> [  +0.000000] reserve setup_data: [mem 0x000000ff80000000-0x0000010ffffff=
fff] usable
> [  +0.000000] reserve setup_data: [mem 0x0000080000000000-0x0000080ffffff=
fff] usable
> [  +0.000000] reserve setup_data: [mem 0x0000090000000000-0x0000090ffffff=
fff] usable
> [  +0.000000] reserve setup_data: [mem 0x0000100000000000-0x0000100ffffff=
fff] usable
> [  +0.000000] reserve setup_data: [mem 0x0000110000000000-0x0000110ffffff=
fff] usable
> [  +0.000000] reserve setup_data: [mem 0x0000180000000000-0x0000180ffffff=
fff] usable
> [  +0.000000] reserve setup_data: [mem 0x0000190000000000-0x0000190ffffff=
fff] usable
> [  +0.000000] reserve setup_data: [mem 0x0000200100000000-0x000020013ffff=
fff] reserved
> [  +0.000000] efi: EFI v2.40 by American Megatrends
> [  +0.000000] efi:  ACPI=3D0x51277000  ACPI 2.0=3D0x51277000  ESRT=3D0x5b=
34fe18  SMBIOS=3D0xf05e0  MPS=3D0xea000=20
> [  +0.000000] SMBIOS 2.8 present.
> [  +0.000000] DMI:  9008/IT91SMUB, BIOS BLXSV512 03/22/2018
> [  +0.000000] tsc: Fast TSC calibration using PIT
> [  +0.000000] tsc: Detected 2399.972 MHz processor
> [  +0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> res=
erved
> [  +0.000001] e820: remove [mem 0x000a0000-0x000fffff] usable
> [  +0.000008] last_pfn =3D 0x191000000 max_arch_pfn =3D 0x400000000
> [  +0.000005] MTRR default type: write-back
> [  +0.000001] MTRR fixed ranges enabled:
> [  +0.000001]   00000-9FFFF write-back
> [  +0.000001]   A0000-BFFFF uncachable
> [  +0.000000]   C0000-FFFFF write-protect
> [  +0.000001] MTRR variable ranges enabled:
> [  +0.000001]   0 base 000080000000 mask 3FFF80000000 uncachable
> [  +0.000001]   1 base 200100000000 mask 3FFFC0000000 uncachable
> [  +0.000001]   2 base 210000000000 mask 3F8000000000 uncachable
> [  +0.000001]   3 base 218000000000 mask 3FE000000000 uncachable
> [  +0.000001]   4 base 21A000000000 mask 3FF800000000 uncachable
> [  +0.000000]   5 disabled
> [  +0.000000]   6 disabled
> [  +0.000001]   7 disabled
> [  +0.000000]   8 disabled
> [  +0.000001]   9 disabled
> [  +0.003688] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  UC- W=
T =20
> [  +0.000700] x2apic: enabled by BIOS, switching to x2apic ops
> [  +0.000004] last_pfn =3D 0x70000 max_arch_pfn =3D 0x400000000
> [  +0.007795] found SMP MP-table at [mem 0x000fcb20-0x000fcb2f] mapped at=
 [(____ptrval____)]
> [  +0.000023] esrt: Reserving ESRT space from 0x000000005b34fe18 to 0x000=
000005b34fe50.
> [  +0.000006] Base memory trampoline at [(____ptrval____)] 98000 size 245=
76
> [  +0.000006] Using GB pages for direct mapping
> [  +0.000002] BRK [0x03004000, 0x03004fff] PGTABLE
> [  +0.000003] BRK [0x03005000, 0x03005fff] PGTABLE
> [  +0.000001] BRK [0x03006000, 0x03006fff] PGTABLE
> [  +0.000249] BRK [0x03007000, 0x03007fff] PGTABLE
> [  +0.000063] BRK [0x03008000, 0x03008fff] PGTABLE
> [  +0.000198] BRK [0x03009000, 0x03009fff] PGTABLE
> [  +0.000096] BRK [0x0300a000, 0x0300afff] PGTABLE
> [  +0.000104] BRK [0x0300b000, 0x0300bfff] PGTABLE
> [  +0.000210] BRK [0x0300c000, 0x0300cfff] PGTABLE
> [  +0.000005] BRK [0x0300d000, 0x0300dfff] PGTABLE
> [  +0.000046] BRK [0x0300e000, 0x0300efff] PGTABLE
> [  +0.000041] BRK [0x0300f000, 0x0300ffff] PGTABLE
> [  +0.000360] Secure boot disabled
> [  +0.000002] RAMDISK: [mem 0x28be0000-0x2a332fff]
> [  +0.000006] ACPI: Early table checksum verification disabled
> [  +0.000005] ACPI: RSDP 0x0000000051277000 000024 (v02 ALASKA)
> [  +0.000004] ACPI: XSDT 0x00000000512770B8 0000F4 (v01 ALASKA A M I    0=
1072009 AMI  00010013)
> [  +0.000006] ACPI: FACP 0x000000005139F100 00010C (v05 ALASKA A M I    0=
1072009 AMI  00010013)
> [  +0.000005] ACPI: DSDT 0x0000000051277240 127EBB (v02 ALASKA A M I    0=
1072009 MSFT 01000013)
> [  +0.000003] ACPI: FACS 0x000000005947DF80 000040
> [  +0.000003] ACPI: APIC 0x000000005139F210 006E2C (v03 ALASKA A M I    0=
1072009 AMI  00010013)
> [  +0.000002] ACPI: FPDT 0x00000000513A6040 000044 (v01 ALASKA A M I    0=
1072009 AMI  00010013)
> [  +0.000003] ACPI: FIDT 0x00000000513A6088 00009C (v01 ALASKA A M I    0=
1072009 AMI  00010013)
> [  +0.000003] ACPI: SPMI 0x00000000513A6128 000041 (v05 ALASKA A M I    0=
0000000 AMI. 00000000)
> [  +0.000002] ACPI: MSDM 0x00000000513A6170 000055 (v03 ALASKA A M I    0=
1072009 AMI  00010013)
> [  +0.000003] ACPI: MCFG 0x00000000513A61C8 00004C (v01 ALASKA A M I    0=
1072009 MSFT 00000097)
> [  +0.000003] ACPI: SSDT 0x00000000513A6218 0111A8 (v02 INTEL  SpsNm    0=
0000002 INTL 20120913)
> [  +0.000002] ACPI: SSDT 0x00000000513B73C0 000040 (v02 INTEL  SpsNvs   0=
0000002 INTL 20120913)
> [  +0.000003] ACPI: PRAD 0x00000000513B7400 000129 (v02 INTEL  SpsPrAgg 0=
0000002 INTL 20120913)
> [  +0.000003] ACPI: UEFI 0x00000000513B7530 000042 (v01 ALASKA A M I    0=
1072009      00000000)
> [  +0.000002] ACPI: BDAT 0x00000000513B7578 000030 (v01 ALASKA A M I    0=
0000000 MSFT 01000013)
> [  +0.000003] ACPI: HPET 0x00000000513B75A8 000038 (v01 ALASKA A M I    0=
0000001 MSFT 01000013)
> [  +0.000002] ACPI: MSCT 0x00000000513B75E0 0002F8 (v01 ALASKA A M I    0=
0000001 MSFT 01000013)
> [  +0.000003] ACPI: PCCT 0x00000000513B78D8 0000AC (v01 ALASKA A M I    0=
0000002 MSFT 01000013)
> [  +0.000002] ACPI: PMCT 0x00000000513B7988 000060 (v01 ALASKA A M I    0=
0000000 MSFT 01000013)
> [  +0.000003] ACPI: RASF 0x00000000513B79E8 000030 (v01 ALASKA A M I    0=
0000001 MSFT 01000013)
> [  +0.000002] ACPI: SLIT 0x00000000513B7A18 00042C (v01 ALASKA A M I    0=
0000001 MSFT 01000013)
> [  +0.000003] ACPI: SRAT 0x00000000513B7E48 009A80 (v03 ALASKA A M I    0=
0000002 MSFT 01000013)
> [  +0.000003] ACPI: WDDT 0x00000000513C18C8 000040 (v01 ALASKA A M I    0=
0000000 MSFT 01000013)
> [  +0.000002] ACPI: SSDT 0x00000000513C1908 0BCC72 (v02 AMI    PmMgt    0=
0000001 INTL 20120913)
> [  +0.000003] ACPI: DMAR 0x000000005147E580 000328 (v01 ALASKA A M I    0=
0000001 MSFT 01000013)
> [  +0.000002] ACPI: HEST 0x000000005147E8A8 0000E8 (v01 ALASKA A M I    0=
0000001 INTL 00000001)
> [  +0.000003] ACPI: BERT 0x000000005147E990 000030 (v01 ALASKA A M I    0=
0000001 INTL 00000001)
> [  +0.000003] ACPI: ERST 0x000000005147E9C0 000230 (v01 ALASKA A M I    0=
0000001 INTL 00000001)
> [  +0.000002] ACPI: EINJ 0x000000005147EBF0 000150 (v01 ALASKA A M I    0=
0000001 INTL 00000001)
> [  +0.000010] ACPI: Local APIC address 0xfee00000
> [  +0.000002] Setting APIC routing to cluster x2apic.
> [  +0.000051] SRAT: PXM 0 -> APIC 0x0000 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0002 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0004 -> Node 0
> [  +0.000000] SRAT: PXM 0 -> APIC 0x0006 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0008 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0010 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0012 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0014 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0016 -> Node 0
> [  +0.000000] SRAT: PXM 0 -> APIC 0x0020 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0022 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0024 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0026 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0028 -> Node 0
> [  +0.000000] SRAT: PXM 0 -> APIC 0x0030 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0032 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0034 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0036 -> Node 0
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0040 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0042 -> Node 1
> [  +0.000000] SRAT: PXM 1 -> APIC 0x0044 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0046 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0048 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0050 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0052 -> Node 1
> [  +0.000000] SRAT: PXM 1 -> APIC 0x0054 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0056 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0060 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0062 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0064 -> Node 1
> [  +0.000000] SRAT: PXM 1 -> APIC 0x0066 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0068 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0070 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0072 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0074 -> Node 1
> [  +0.000000] SRAT: PXM 1 -> APIC 0x0076 -> Node 1
> [  +0.000001] SRAT: PXM 2 -> APIC 0x0080 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x0082 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x0084 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x0086 -> Node 2
> [  +0.000000] SRAT: PXM 2 -> APIC 0x0088 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x0090 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x0092 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x0094 -> Node 2
> [  +0.000000] SRAT: PXM 2 -> APIC 0x0096 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00a0 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00a2 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00a4 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00a6 -> Node 2
> [  +0.000000] SRAT: PXM 2 -> APIC 0x00a8 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00b0 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00b2 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00b4 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00b6 -> Node 2
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00c0 -> Node 3
> [  +0.000000] SRAT: PXM 3 -> APIC 0x00c2 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00c4 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00c6 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00c8 -> Node 3
> [  +0.000000] SRAT: PXM 3 -> APIC 0x00d0 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00d2 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00d4 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00d6 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00e0 -> Node 3
> [  +0.000000] SRAT: PXM 3 -> APIC 0x00e2 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00e4 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00e6 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00e8 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00f0 -> Node 3
> [  +0.000000] SRAT: PXM 3 -> APIC 0x00f2 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00f4 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00f6 -> Node 3
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0100 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0102 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0104 -> Node 4
> [  +0.000000] SRAT: PXM 4 -> APIC 0x0106 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0108 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0110 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0112 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0114 -> Node 4
> [  +0.000000] SRAT: PXM 4 -> APIC 0x0116 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0120 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0122 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0124 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0126 -> Node 4
> [  +0.000000] SRAT: PXM 4 -> APIC 0x0128 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0130 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0132 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0134 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0136 -> Node 4
> [  +0.000000] SRAT: PXM 5 -> APIC 0x0140 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0142 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0144 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0146 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0148 -> Node 5
> [  +0.000000] SRAT: PXM 5 -> APIC 0x0150 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0152 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0154 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0156 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0160 -> Node 5
> [  +0.000000] SRAT: PXM 5 -> APIC 0x0162 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0164 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0166 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0168 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0170 -> Node 5
> [  +0.000000] SRAT: PXM 5 -> APIC 0x0172 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0174 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0176 -> Node 5
> [  +0.000001] SRAT: PXM 6 -> APIC 0x0180 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x0182 -> Node 6
> [  +0.000000] SRAT: PXM 6 -> APIC 0x0184 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x0186 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x0188 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x0190 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x0192 -> Node 6
> [  +0.000000] SRAT: PXM 6 -> APIC 0x0194 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x0196 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x01a0 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x01a2 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x01a4 -> Node 6
> [  +0.000000] SRAT: PXM 6 -> APIC 0x01a6 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x01a8 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x01b0 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x01b2 -> Node 6
> [  +0.000000] SRAT: PXM 6 -> APIC 0x01b4 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x01b6 -> Node 6
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01c0 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01c2 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01c4 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01c6 -> Node 7
> [  +0.000000] SRAT: PXM 7 -> APIC 0x01c8 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01d0 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01d2 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01d4 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01d6 -> Node 7
> [  +0.000000] SRAT: PXM 7 -> APIC 0x01e0 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01e2 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01e4 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01e6 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01e8 -> Node 7
> [  +0.000000] SRAT: PXM 7 -> APIC 0x01f0 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01f2 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01f4 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01f6 -> Node 7
> [  +0.000000] SRAT: PXM 0 -> APIC 0x0001 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0003 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0005 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0007 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0009 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0011 -> Node 0
> [  +0.000000] SRAT: PXM 0 -> APIC 0x0013 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0015 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0017 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0021 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0023 -> Node 0
> [  +0.000000] SRAT: PXM 0 -> APIC 0x0025 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0027 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0029 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0031 -> Node 0
> [  +0.000000] SRAT: PXM 0 -> APIC 0x0033 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0035 -> Node 0
> [  +0.000001] SRAT: PXM 0 -> APIC 0x0037 -> Node 0
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0041 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0043 -> Node 1
> [  +0.000000] SRAT: PXM 1 -> APIC 0x0045 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0047 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0049 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0051 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0053 -> Node 1
> [  +0.000000] SRAT: PXM 1 -> APIC 0x0055 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0057 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0061 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0063 -> Node 1
> [  +0.000000] SRAT: PXM 1 -> APIC 0x0065 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0067 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0069 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0071 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0073 -> Node 1
> [  +0.000000] SRAT: PXM 1 -> APIC 0x0075 -> Node 1
> [  +0.000001] SRAT: PXM 1 -> APIC 0x0077 -> Node 1
> [  +0.000001] SRAT: PXM 2 -> APIC 0x0081 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x0083 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x0085 -> Node 2
> [  +0.000000] SRAT: PXM 2 -> APIC 0x0087 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x0089 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x0091 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x0093 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x0095 -> Node 2
> [  +0.000000] SRAT: PXM 2 -> APIC 0x0097 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00a1 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00a3 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00a5 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00a7 -> Node 2
> [  +0.000000] SRAT: PXM 2 -> APIC 0x00a9 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00b1 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00b3 -> Node 2
> [  +0.000001] SRAT: PXM 2 -> APIC 0x00b5 -> Node 2
> [  +0.000000] SRAT: PXM 2 -> APIC 0x00b7 -> Node 2
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00c1 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00c3 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00c5 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00c7 -> Node 3
> [  +0.000000] SRAT: PXM 3 -> APIC 0x00c9 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00d1 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00d3 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00d5 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00d7 -> Node 3
> [  +0.000000] SRAT: PXM 3 -> APIC 0x00e1 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00e3 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00e5 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00e7 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00e9 -> Node 3
> [  +0.000000] SRAT: PXM 3 -> APIC 0x00f1 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00f3 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00f5 -> Node 3
> [  +0.000001] SRAT: PXM 3 -> APIC 0x00f7 -> Node 3
> [  +0.000000] SRAT: PXM 4 -> APIC 0x0101 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0103 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0105 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0107 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0109 -> Node 4
> [  +0.000000] SRAT: PXM 4 -> APIC 0x0111 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0113 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0115 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0117 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0121 -> Node 4
> [  +0.000000] SRAT: PXM 4 -> APIC 0x0123 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0125 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0127 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0129 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0131 -> Node 4
> [  +0.000000] SRAT: PXM 4 -> APIC 0x0133 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0135 -> Node 4
> [  +0.000001] SRAT: PXM 4 -> APIC 0x0137 -> Node 4
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0141 -> Node 5
> [  +0.000000] SRAT: PXM 5 -> APIC 0x0143 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0145 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0147 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0149 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0151 -> Node 5
> [  +0.000000] SRAT: PXM 5 -> APIC 0x0153 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0155 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0157 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0161 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0163 -> Node 5
> [  +0.000000] SRAT: PXM 5 -> APIC 0x0165 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0167 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0169 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0171 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0173 -> Node 5
> [  +0.000000] SRAT: PXM 5 -> APIC 0x0175 -> Node 5
> [  +0.000001] SRAT: PXM 5 -> APIC 0x0177 -> Node 5
> [  +0.000001] SRAT: PXM 6 -> APIC 0x0181 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x0183 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x0185 -> Node 6
> [  +0.000000] SRAT: PXM 6 -> APIC 0x0187 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x0189 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x0191 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x0193 -> Node 6
> [  +0.000000] SRAT: PXM 6 -> APIC 0x0195 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x0197 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x01a1 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x01a3 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x01a5 -> Node 6
> [  +0.000000] SRAT: PXM 6 -> APIC 0x01a7 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x01a9 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x01b1 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x01b3 -> Node 6
> [  +0.000001] SRAT: PXM 6 -> APIC 0x01b5 -> Node 6
> [  +0.000000] SRAT: PXM 6 -> APIC 0x01b7 -> Node 6
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01c1 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01c3 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01c5 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01c7 -> Node 7
> [  +0.000000] SRAT: PXM 7 -> APIC 0x01c9 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01d1 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01d3 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01d5 -> Node 7
> [  +0.000000] SRAT: PXM 7 -> APIC 0x01d7 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01e1 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01e3 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01e5 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01e7 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01e9 -> Node 7
> [  +0.000000] SRAT: PXM 7 -> APIC 0x01f1 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01f3 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01f5 -> Node 7
> [  +0.000001] SRAT: PXM 7 -> APIC 0x01f7 -> Node 7
> [  +0.000037] ACPI: SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
> [  +0.000001] ACPI: SRAT: Node 0 PXM 0 [mem 0x100000000-0xfffffffff]
> [  +0.000001] ACPI: SRAT: Node 0 PXM 0 [mem 0xff80000000-0xffffffffff]
> [  +0.000001] ACPI: SRAT: Node 1 PXM 1 [mem 0x10000000000-0x1ffffffffff] =
hotplug
> [  +0.000002] ACPI: SRAT: Node 2 PXM 2 [mem 0x80000000000-0x8ffffffffff] =
hotplug
> [  +0.000001] ACPI: SRAT: Node 3 PXM 3 [mem 0x90000000000-0x9ffffffffff] =
hotplug
> [  +0.000001] ACPI: SRAT: Node 4 PXM 4 [mem 0x100000000000-0x10ffffffffff=
] hotplug
> [  +0.000002] ACPI: SRAT: Node 5 PXM 5 [mem 0x110000000000-0x11ffffffffff=
] hotplug
> [  +0.000001] ACPI: SRAT: Node 6 PXM 6 [mem 0x180000000000-0x18ffffffffff=
] hotplug
> [  +0.000001] ACPI: SRAT: Node 7 PXM 7 [mem 0x190000000000-0x19ffffffffff=
] hotplug
> [  +0.000010] NUMA: Initialized distance table, cnt=3D8
> [  +0.000004] NUMA: Node 0 [mem 0x00000000-0x7fffffff] + [mem 0x100000000=
-0xfffffffff] -> [mem 0x00000000-0xfffffffff]
> [  +0.000001] NUMA: Node 0 [mem 0x00000000-0xfffffffff] + [mem 0xff800000=
00-0xffffffffff] -> [mem 0x00000000-0xffffffffff]
> [  +0.000013] NODE_DATA(0) allocated [mem 0xfffffd6000-0xffffffffff]
> [  +0.000079] NODE_DATA(1) allocated [mem 0xfffffac000-0xfffffd5fff]
> [  +0.000001]     NODE_DATA(1) on node 0
> [  +0.000079] NODE_DATA(2) allocated [mem 0xfffff82000-0xfffffabfff]
> [  +0.000001]     NODE_DATA(2) on node 0
> [  +0.000079] NODE_DATA(3) allocated [mem 0xfffff58000-0xfffff81fff]
> [  +0.000000]     NODE_DATA(3) on node 0
> [  +0.000079] NODE_DATA(4) allocated [mem 0xfffff2e000-0xfffff57fff]
> [  +0.000000]     NODE_DATA(4) on node 0
> [  +0.000079] NODE_DATA(5) allocated [mem 0xfffff04000-0xfffff2dfff]
> [  +0.000001]     NODE_DATA(5) on node 0
> [  +0.000079] NODE_DATA(6) allocated [mem 0xffffeda000-0xfffff03fff]
> [  +0.000000]     NODE_DATA(6) on node 0
> [  +0.000079] NODE_DATA(7) allocated [mem 0xffffeb0000-0xffffed9fff]
> [  +0.000001]     NODE_DATA(7) on node 0
> [  +0.000162] crashkernel: memory value expected
> [  +0.005320] Zone ranges:
> [  +0.000001]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
> [  +0.000002]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
> [  +0.000001]   Normal   [mem 0x0000000100000000-0x0000190fffffffff]
> [  +0.000001]   Device   empty
> [  +0.000001] Movable zone start for each node
> [  +0.000001]   Node 1: 0x0000010000000000
> [  +0.000001]   Node 2: 0x0000080000000000
> [  +0.000001]   Node 3: 0x0000090000000000
> [  +0.000001]   Node 4: 0x0000100000000000
> [  +0.000000]   Node 5: 0x0000110000000000
> [  +0.000001]   Node 6: 0x0000180000000000
> [  +0.000001]   Node 7: 0x0000190000000000
> [  +0.000004] Early memory node ranges
> [  +0.000001]   node   0: [mem 0x0000000000001000-0x000000000009ffff]
> [  +0.000001]   node   0: [mem 0x0000000000100000-0x0000000041a2dfff]
> [  +0.000001]   node   0: [mem 0x0000000041a2f000-0x000000004f22efff]
> [  +0.000001]   node   0: [mem 0x000000005b87f000-0x000000006d265fff]
> [  +0.000001]   node   0: [mem 0x000000006d2ec000-0x000000006fffffff]
> [  +0.000001]   node   0: [mem 0x0000000100000000-0x0000000fffffffff]
> [  +0.000000]   node   0: [mem 0x000000ff80000000-0x000000ffffffffff]
> [  +0.000001]   node   1: [mem 0x0000010000000000-0x0000010fffffffff]
> [  +0.000001]   node   2: [mem 0x0000080000000000-0x0000080fffffffff]
> [  +0.000001]   node   3: [mem 0x0000090000000000-0x0000090fffffffff]
> [  +0.000001]   node   4: [mem 0x0000100000000000-0x0000100fffffffff]
> [  +0.000001]   node   5: [mem 0x0000110000000000-0x0000110fffffffff]
> [  +0.000001]   node   6: [mem 0x0000180000000000-0x0000180fffffffff]
> [  +0.000000]   node   7: [mem 0x0000190000000000-0x0000190fffffffff]
> [  +3.253257] Zeroed struct page in unavailable ranges: 117458744 pages
> [  +0.000003] Initmem setup node 0 [mem 0x0000000000001000-0x000000ffffff=
ffff]
> [  +0.000004] On node 0 totalpages: 16660680
> [  +0.000002]   DMA zone: 64 pages used for memmap
> [  +0.000001]   DMA zone: 24 pages reserved
> [  +0.000001]   DMA zone: 3999 pages, LIFO batch:0
> [  +0.000228]   DMA32 zone: 6309 pages used for memmap
> [  +0.000001]   DMA32 zone: 403753 pages, LIFO batch:63
> [  +0.015853]   Normal zone: 253952 pages used for memmap
> [  +0.000001]   Normal zone: 16252928 pages, LIFO batch:63
> [  +0.001068] Initmem setup node 1 [mem 0x0000010000000000-0x0000010fffff=
ffff]
> [  +0.000002] On node 1 totalpages: 16777216
> [  +0.000001]   Movable zone: 262144 pages used for memmap
> [  +0.000001]   Movable zone: 16777216 pages, LIFO batch:63
> [  +0.000923] Initmem setup node 2 [mem 0x0000080000000000-0x0000080fffff=
ffff]
> [  +0.000002] On node 2 totalpages: 16777216
> [  +0.000000]   Movable zone: 262144 pages used for memmap
> [  +0.000001]   Movable zone: 16777216 pages, LIFO batch:63
> [  +0.000916] Initmem setup node 3 [mem 0x0000090000000000-0x0000090fffff=
ffff]
> [  +0.000002] On node 3 totalpages: 16777216
> [  +0.000001]   Movable zone: 262144 pages used for memmap
> [  +0.000000]   Movable zone: 16777216 pages, LIFO batch:63
> [  +0.000923] Initmem setup node 4 [mem 0x0000100000000000-0x0000100fffff=
ffff]
> [  +0.000002] On node 4 totalpages: 16777216
> [  +0.000001]   Movable zone: 262144 pages used for memmap
> [  +0.000000]   Movable zone: 16777216 pages, LIFO batch:63
> [  +0.000921] Initmem setup node 5 [mem 0x0000110000000000-0x0000110fffff=
ffff]
> [  +0.000002] On node 5 totalpages: 16777216
> [  +0.000001]   Movable zone: 262144 pages used for memmap
> [  +0.000000]   Movable zone: 16777216 pages, LIFO batch:63
> [  +0.000900] Initmem setup node 6 [mem 0x0000180000000000-0x0000180fffff=
ffff]
> [  +0.000002] On node 6 totalpages: 16777216
> [  +0.000001]   Movable zone: 262144 pages used for memmap
> [  +0.000001]   Movable zone: 16777216 pages, LIFO batch:63
> [  +0.000912] Initmem setup node 7 [mem 0x0000190000000000-0x0000190fffff=
ffff]
> [  +0.000002] On node 7 totalpages: 16777216
> [  +0.000001]   Movable zone: 262144 pages used for memmap
> [  +0.000000]   Movable zone: 16777216 pages, LIFO batch:63
> [  +0.001034] ACPI: PM-Timer IO Port: 0x408
> [  +0.000003] ACPI: Local APIC address 0xfee00000
> [  +0.000087] ACPI: X2APIC_NMI (uid[0x00] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x08] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x10] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x18] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x20] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x04] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x0c] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x14] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x1c] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x02] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x0a] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x12] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x1a] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x22] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x06] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x0e] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x16] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x1e] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x30] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x38] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x40] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x48] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x50] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x34] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x3c] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x44] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x4c] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x32] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x3a] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x42] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x4a] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x52] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x36] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x3e] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x46] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x4e] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x60] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x68] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x70] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x78] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x80] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x64] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x6c] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x74] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x7c] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x62] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x6a] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x72] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x7a] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x82] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x66] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x6e] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x76] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x7e] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x90] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x98] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0xa0] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xa8] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xb0] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x94] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x9c] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xa4] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0xac] high edge lint[0x1])
> [  +0.000002] ACPI: X2APIC_NMI (uid[0x92] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x9a] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xa2] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xaa] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xb2] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x96] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x9e] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xa6] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xae] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xc0] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0xc8] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xd0] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xd8] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xe0] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xc4] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xcc] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0xd4] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xdc] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xc2] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xca] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xd2] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0xda] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xe2] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xc6] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xce] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xd6] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xde] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0xf0] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xf8] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x100] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x108] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x110] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xf4] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xfc] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x104] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x10c] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xf2] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xfa] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x102] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x10a] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x112] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xf6] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xfe] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x106] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x10e] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x120] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x128] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x130] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x138] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x140] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x124] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x12c] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x134] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x13c] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x122] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x12a] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x132] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x13a] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x142] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x126] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x12e] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x136] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x13e] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x150] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x158] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x160] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x168] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x170] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x154] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x15c] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x164] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x16c] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x152] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x15a] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x162] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x16a] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x172] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x156] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x15e] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x166] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x16e] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x01] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x09] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x11] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x19] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x21] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x05] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x0d] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x15] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x1d] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x03] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x0b] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x13] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x1b] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x23] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x07] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x0f] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x17] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x1f] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x31] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x39] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x41] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x49] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x51] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x35] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x3d] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x45] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x4d] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x33] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x3b] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x43] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x4b] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x53] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x37] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x3f] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x47] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x4f] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x61] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x69] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x71] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x79] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x81] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x65] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x6d] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x75] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x7d] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x63] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x6b] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x73] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x7b] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x83] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x67] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x6f] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x77] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x7f] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x91] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x99] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0xa1] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xa9] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xb1] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x95] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x9d] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xa5] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0xad] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x93] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x9b] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xa3] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xab] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xb3] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x97] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x9f] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xa7] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xaf] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xc1] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0xc9] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xd1] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xd9] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xe1] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xc5] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xcd] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0xd5] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xdd] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xc3] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xcb] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xd3] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0xdb] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xe3] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xc7] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xcf] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xd7] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xdf] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0xf1] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xf9] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x101] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x109] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x111] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xf5] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0xfd] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x105] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x10d] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xf3] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xfb] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x103] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x10b] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x113] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xf7] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0xff] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x107] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x10f] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x121] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x129] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x131] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x139] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x141] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x125] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x12d] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x135] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x13d] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x123] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x12b] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x133] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x13b] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x143] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x127] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x12f] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x137] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x13f] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x151] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x159] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x161] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x169] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x171] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x155] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x15d] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x165] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x16d] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x153] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x15b] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x163] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x16b] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x173] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x157] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x15f] high edge lint[0x1])
> [  +0.000000] ACPI: X2APIC_NMI (uid[0x167] high edge lint[0x1])
> [  +0.000001] ACPI: X2APIC_NMI (uid[0x16f] high edge lint[0x1])
> [  +0.000029] IOAPIC[0]: apic_id 0, version 32, address 0xfec00000, GSI 0=
-23
> [  +0.000007] IOAPIC[1]: apic_id 1, version 32, address 0xfec01000, GSI 2=
4-47
> [  +0.000007] IOAPIC[2]: apic_id 2, version 32, address 0xfec08000, GSI 4=
8-71
> [  +0.000007] IOAPIC[3]: apic_id 3, version 32, address 0xfec10000, GSI 7=
2-95
> [  +0.000008] IOAPIC[4]: apic_id 4, version 32, address 0xfec18000, GSI 9=
6-119
> [  +0.000007] IOAPIC[5]: apic_id 5, version 32, address 0xfec20000, GSI 1=
20-143
> [  +0.000006] IOAPIC[6]: apic_id 6, version 32, address 0xfec28000, GSI 1=
44-167
> [  +0.000008] IOAPIC[7]: apic_id 7, version 32, address 0xfec30000, GSI 1=
68-191
> [  +0.000007] IOAPIC[8]: apic_id 8, version 32, address 0xfec38000, GSI 1=
92-215
> [  +0.000010] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> [  +0.000002] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> [  +0.000003] ACPI: IRQ0 used by override.
> [  +0.000001] ACPI: IRQ9 used by override.
> [  +0.000009] Using ACPI (MADT) for SMP configuration information
> [  +0.000002] ACPI: HPET id: 0x8086a701 base: 0xfed00000
> [  +0.000006] smpboot: Allowing 288 CPUs, 0 hotplug CPUs
> [  +0.000035] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
> [  +0.000002] PM: Registered nosave memory: [mem 0x000a0000-0x000fffff]
> [  +0.000001] PM: Registered nosave memory: [mem 0x28bc5000-0x28bc5fff]
> [  +0.000002] PM: Registered nosave memory: [mem 0x28bdf000-0x28bdffff]
> [  +0.000002] PM: Registered nosave memory: [mem 0x41a2e000-0x41a2efff]
> [  +0.000002] PM: Registered nosave memory: [mem 0x4f22f000-0x5122efff]
> [  +0.000001] PM: Registered nosave memory: [mem 0x5122f000-0x5147efff]
> [  +0.000000] PM: Registered nosave memory: [mem 0x5147f000-0x5947efff]
> [  +0.000001] PM: Registered nosave memory: [mem 0x5947f000-0x5b87efff]
> [  +0.000002] PM: Registered nosave memory: [mem 0x6d266000-0x6d2ebfff]
> [  +0.000002] PM: Registered nosave memory: [mem 0x70000000-0x8fffffff]
> [  +0.000001] PM: Registered nosave memory: [mem 0x90000000-0xfed1bfff]
> [  +0.000001] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
> [  +0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xfeffffff]
> [  +0.000001] PM: Registered nosave memory: [mem 0xff000000-0xffffffff]
> [  +0.000002] PM: Registered nosave memory: [mem 0x1000000000-0xff7ffffff=
f]
> [  +0.000002] PM: Registered nosave memory: [mem 0x11000000000-0x7fffffff=
fff]
> [  +0.000002] PM: Registered nosave memory: [mem 0x81000000000-0x8fffffff=
fff]
> [  +0.000002] PM: Registered nosave memory: [mem 0x91000000000-0xffffffff=
fff]
> [  +0.000002] PM: Registered nosave memory: [mem 0x101000000000-0x10fffff=
fffff]
> [  +0.000002] PM: Registered nosave memory: [mem 0x111000000000-0x17fffff=
fffff]
> [  +0.000002] PM: Registered nosave memory: [mem 0x181000000000-0x18fffff=
fffff]
> [  +0.000002] [mem 0x90000000-0xfed1bfff] available for PCI devices
> [  +0.000002] Booting paravirtualized kernel on bare hardware
> [  +0.000004] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: =
0xffffffff, max_idle_ns: 1910969940391419 ns
> [  +0.112298] random: get_random_bytes called from start_kernel+0x8f/0x51=
0 with crng_init=3D0
> [  +0.000008] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:288 nr_cpu_ids:2=
88 nr_node_ids:8
> [  +0.049374] percpu: Embedded 46 pages/cpu @(____ptrval____) s151552 r81=
92 d28672 u262144
> [  +0.000022] pcpu-alloc: s151552 r8192 d28672 u262144 alloc=3D1*2097152
> [  +0.000001] pcpu-alloc: [0] 000 001 002 003 004 005 006 007=20
> [  +0.000002] pcpu-alloc: [0] 008 009 010 011 012 013 014 015=20
> [  +0.000002] pcpu-alloc: [0] 016 017 144 145 146 147 148 149=20
> [  +0.000002] pcpu-alloc: [0] 150 151 152 153 154 155 156 157=20
> [  +0.000002] pcpu-alloc: [0] 158 159 160 161 --- --- --- ---=20
> [  +0.000002] pcpu-alloc: [1] 018 019 020 021 022 023 024 025=20
> [  +0.000002] pcpu-alloc: [1] 026 027 028 029 030 031 032 033=20
> [  +0.000002] pcpu-alloc: [1] 034 035 162 163 164 165 166 167=20
> [  +0.000002] pcpu-alloc: [1] 168 169 170 171 172 173 174 175=20
> [  +0.000002] pcpu-alloc: [1] 176 177 178 179 --- --- --- ---=20
> [  +0.000001] pcpu-alloc: [2] 036 037 038 039 040 041 042 043=20
> [  +0.000002] pcpu-alloc: [2] 044 045 046 047 048 049 050 051=20
> [  +0.000002] pcpu-alloc: [2] 052 053 180 181 182 183 184 185=20
> [  +0.000002] pcpu-alloc: [2] 186 187 188 189 190 191 192 193=20
> [  +0.000001] pcpu-alloc: [2] 194 195 196 197 --- --- --- ---=20
> [  +0.000002] pcpu-alloc: [3] 054 055 056 057 058 059 060 061=20
> [  +0.000002] pcpu-alloc: [3] 062 063 064 065 066 067 068 069=20
> [  +0.000001] pcpu-alloc: [3] 070 071 198 199 200 201 202 203=20
> [  +0.000002] pcpu-alloc: [3] 204 205 206 207 208 209 210 211=20
> [  +0.000002] pcpu-alloc: [3] 212 213 214 215 --- --- --- ---=20
> [  +0.000002] pcpu-alloc: [4] 072 073 074 075 076 077 078 079=20
> [  +0.000001] pcpu-alloc: [4] 080 081 082 083 084 085 086 087=20
> [  +0.000002] pcpu-alloc: [4] 088 089 216 217 218 219 220 221=20
> [  +0.000002] pcpu-alloc: [4] 222 223 224 225 226 227 228 229=20
> [  +0.000001] pcpu-alloc: [4] 230 231 232 233 --- --- --- ---=20
> [  +0.000002] pcpu-alloc: [5] 090 091 092 093 094 095 096 097=20
> [  +0.000002] pcpu-alloc: [5] 098 099 100 101 102 103 104 105=20
> [  +0.000002] pcpu-alloc: [5] 106 107 234 235 236 237 238 239=20
> [  +0.000001] pcpu-alloc: [5] 240 241 242 243 244 245 246 247=20
> [  +0.000002] pcpu-alloc: [5] 248 249 250 251 --- --- --- ---=20
> [  +0.000002] pcpu-alloc: [6] 108 109 110 111 112 113 114 115=20
> [  +0.000001] pcpu-alloc: [6] 116 117 118 119 120 121 122 123=20
> [  +0.000002] pcpu-alloc: [6] 124 125 252 253 254 255 256 257=20
> [  +0.000002] pcpu-alloc: [6] 258 259 260 261 262 263 264 265=20
> [  +0.000002] pcpu-alloc: [6] 266 267 268 269 --- --- --- ---=20
> [  +0.000001] pcpu-alloc: [7] 126 127 128 129 130 131 132 133=20
> [  +0.000002] pcpu-alloc: [7] 134 135 136 137 138 139 140 141=20
> [  +0.000002] pcpu-alloc: [7] 142 143 270 271 272 273 274 275=20
> [  +0.000002] pcpu-alloc: [7] 276 277 278 279 280 281 282 283=20
> [  +0.000002] pcpu-alloc: [7] 284 285 286 287 --- --- --- ---=20
> [  +0.000107] Built 8 zonelists, mobility grouping on.  Total pages: 1320=
05835
> [  +0.000002] Policy zone: Normal
> ...
>=20
> [  +0.204580] Memory: 2325688K/536404768K available (12293K kernel code, =
2027K rwdata, 3776K rodata, 2184K init, 6636K bss, 8797012K reserved, 0K cm=
a-reserved)
> [  +0.001683] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D288=
, Nodes=3D8
> [  +0.000052] Kernel/User page tables isolation: enabled
> [  +0.000426] ftrace: allocating 35377 entries in 139 pages
> [  +0.021237] rcu: Hierarchical RCU implementation.
> [  +0.000002] rcu: 	RCU restricting CPUs from NR_CPUS=3D8192 to nr_cpu_id=
s=3D288.
> [  +0.000002] rcu: RCU calculated value of scheduler-enlistment delay is =
101 jiffies.
> [  +0.000001] rcu: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_id=
s=3D288
> [  +0.003214] NR_IRQS: 524544, nr_irqs: 5992, preallocated irqs: 16
> [  +0.001105] Console: colour dummy device 80x25
> [Nov13 20:39] printk: console [ttyS0] enabled
> [  +0.005001] mempolicy: Enabling automatic NUMA balancing. Configure wit=
h numa_balancing=3D or the kernel.numa_balancing sysctl
> [  +0.011182] ACPI: Core revision 20181003
> [  +0.005805] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff,=
 max_idle_ns: 133484882848 ns
> [  +0.009097] hpet clockevent registered
> ......
>=20
> [Nov13 20:50] perf: interrupt took too long (2574 > 2500), lowering kerne=
l.perf_event_max_sample_rate to 77000
> [ +20.272777] perf: interrupt took too long (3314 > 3217), lowering kerne=
l.perf_event_max_sample_rate to 60000
> [Nov13 20:51] perf: interrupt took too long (4321 > 4142), lowering kerne=
l.perf_event_max_sample_rate to 46000
> [ +45.906576] perf: interrupt took too long (5647 > 5401), lowering kerne=
l.perf_event_max_sample_rate to 35000
> [Nov13 20:52] Offlined Pages 524288
> [  +0.574439] Offlined Pages 524288
> [  +0.593419] Offlined Pages 524288
> [  +0.500564] Offlined Pages 524288
> [  +0.553186] Offlined Pages 524288
> [  +0.477400] Offlined Pages 524288
> [  +0.520972] Offlined Pages 524288
> [  +0.463266] Offlined Pages 524288
> [  +0.473460] perf: interrupt took too long (7185 > 7058), lowering kerne=
l.perf_event_max_sample_rate to 27000
> [  +0.032534] Offlined Pages 524288
> [  +0.444235] Offlined Pages 524288
> [  +0.518495] Offlined Pages 524288
> [  +0.487940] INFO: NMI handler (perf_event_nmi_handler) took too long to=
 run: 1.716 msecs
> [  +0.008121] perf: interrupt took too long (18018 > 8981), lowering kern=
el.perf_event_max_sample_rate to 11000
> [  +0.006241] Offlined Pages 524288
> [  +0.558948] Offlined Pages 524288
> [  +0.438755] Offlined Pages 524288
> [  +0.469419] Offlined Pages 524288
> [  +0.509457] Offlined Pages 524288
> [  +0.750845] Offlined Pages 524288
> [  +0.899944] Offlined Pages 524288
> [  +0.522106] Offlined Pages 524288
> [  +0.526590] Offlined Pages 524288
> [  +0.496809] Offlined Pages 524288
> [  +0.568061] Offlined Pages 524288
> [  +0.476875] Offlined Pages 524288
> [  +0.544439] Offlined Pages 524288
> [  +0.474484] Offlined Pages 524288
> [  +0.525214] Offlined Pages 524288
> [  +0.672724] Offlined Pages 524288
> [  +0.546363] Offlined Pages 524288
> [  +0.706927] Offlined Pages 524288
> [  +0.777087] Offlined Pages 524288
> [  +1.891640] Offlined Pages 524288
> [Nov13 20:53] INFO: NMI handler (ghes_notify_nmi) took too long to run: 2=
=2E157 msecs
> [  +5.052582] Offlined Pages 524288
> [  +0.073194] Built 8 zonelists, mobility grouping on.  Total pages: 1149=
52219
> [  +0.007203] Policy zone: Normal
> [Nov13 20:54] Offlined Pages 524288
> [ +13.581974] Offlined Pages 524288
> [ +10.806998] Offlined Pages 524288
> [  +6.455132] Offlined Pages 524288
> [  +4.448912] Offlined Pages 524288
> [  +4.878278] Offlined Pages 524288
> [  +5.778869] Offlined Pages 524288
> [  +7.543838] Offlined Pages 524288
> [Nov13 20:55] Offlined Pages 524288
> [  +6.399930] Offlined Pages 524288
> [  +7.095958] Offlined Pages 524288
> [  +4.553672] Offlined Pages 524288
> [  +6.662938] Offlined Pages 524288
> [  +4.527867] Offlined Pages 524288
> [  +4.299780] Offlined Pages 524288
> [  +2.716266] Offlined Pages 524288
> [  +2.477986] Offlined Pages 524288
> [  +4.372535] Offlined Pages 524288
> [  +1.821682] Offlined Pages 524288
> [  +3.036448] Offlined Pages 524288
> [  +1.807979] Offlined Pages 524288
> [  +1.846016] Offlined Pages 524288
> [  +1.672556] Offlined Pages 524288
> [  +1.834171] Offlined Pages 524288
> [Nov13 20:56] Offlined Pages 524288
> [  +2.195826] Offlined Pages 524288
> [  +3.364334] Offlined Pages 524288
> [  +8.256705] INFO: NMI handler (perf_event_nmi_handler) took too long to=
 run: 2.091 msecs
> [  +0.008100] perf: interrupt took too long (25461 > 22522), lowering ker=
nel.perf_event_max_sample_rate to 7000
> [  +3.797401] Offlined Pages 524288
> [Nov13 20:58] Offlined Pages 524288
> [ +34.185985] INFO: NMI handler (perf_event_nmi_handler) took too long to=
 run: 2.101 msecs
> [Nov13 21:00] Offlined Pages 524288
> [Nov13 21:01] INFO: NMI handler (ghes_notify_nmi) took too long to run: 2=
=2E198 msecs
> [Nov13 21:02] Offlined Pages 524288
> [Nov13 21:03] INFO: NMI handler (nmi_cpu_backtrace_handler) took too long=
 to run: 2.108 msecs
> [Nov13 21:04] INFO: NMI handler (perf_event_nmi_handler) took too long to=
 run: 2.193 msecs
> [Nov13 21:05] INFO: task kworker/181:1:1187 blocked for more than 120 sec=
onds.
> [  +0.007169]       Not tainted 4.20.0-rc2+ #4
> [  +0.004630] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables=
 this message.
> [  +0.008001] kworker/181:1   D    0  1187      2 0x80000000
> [  +0.005711] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [  +0.006467] Call Trace:
> [  +0.002591]  ? __schedule+0x24e/0x880
> [  +0.004995]  schedule+0x28/0x80
> [  +0.003380]  rwsem_down_read_failed+0x103/0x190
> [  +0.006528]  call_rwsem_down_read_failed+0x14/0x30
> [  +0.004937]  __percpu_down_read+0x4f/0x80
> [  +0.004204]  get_online_mems+0x2d/0x30
> [  +0.003871]  memcg_create_kmem_cache+0x1b/0x120
> [  +0.004740]  memcg_kmem_cache_create_func+0x1b/0x60
> [  +0.004986]  process_one_work+0x1a1/0x3a0
> [  +0.004255]  worker_thread+0x30/0x380
> [  +0.003764]  ? drain_workqueue+0x120/0x120
> [  +0.004238]  kthread+0x112/0x130
> [  +0.003320]  ? kthread_park+0x80/0x80
> [  +0.003796]  ret_from_fork+0x35/0x40
> [  +0.003707] INFO: task kworker/183:1:1189 blocked for more than 120 sec=
onds.
> [  +0.007124]       Not tainted 4.20.0-rc2+ #4
> [  +0.004363] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables=
 this message.
> [  +0.009522] kworker/183:1   D    0  1189      2 0x80000000
> [  +0.005640] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [  +0.006512] Call Trace:
> [  +0.002675]  ? __schedule+0x24e/0x880
> [  +0.003862]  schedule+0x28/0x80
> [  +0.003351]  rwsem_down_read_failed+0x103/0x190
> [  +0.004714]  call_rwsem_down_read_failed+0x14/0x30
> [  +0.004985]  __percpu_down_read+0x4f/0x80
> [  +0.004177]  get_online_mems+0x2d/0x30
> [  +0.003886]  memcg_create_kmem_cache+0x1b/0x120
> [  +0.004660]  memcg_kmem_cache_create_func+0x1b/0x60
> [  +0.005050]  process_one_work+0x1a1/0x3a0
> [  +0.004175]  worker_thread+0x30/0x380
> [  +0.005972]  ? drain_workqueue+0x120/0x120
> [  +0.004206]  kthread+0x112/0x130
> [  +0.003387]  ? kthread_park+0x80/0x80
> [  +0.003821]  ret_from_fork+0x35/0x40
> [  +0.003727] INFO: task kworker/188:1:1194 blocked for more than 120 sec=
onds.
> [  +0.007136]       Not tainted 4.20.0-rc2+ #4
> [  +0.004378] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables=
 this message.
> [  +0.007909] kworker/188:1   D    0  1194      2 0x80000000
> [  +0.005626] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [  +0.006464] Call Trace:
> [  +0.002563]  ? __schedule+0x24e/0x880
> [  +0.003765]  schedule+0x28/0x80
> [  +0.008841]  rwsem_down_read_failed+0x103/0x190
> [  +0.004669]  call_rwsem_down_read_failed+0x14/0x30
> [  +0.004857]  __percpu_down_read+0x4f/0x80
> [  +0.004130]  get_online_mems+0x2d/0x30
> [  +0.003839]  memcg_create_kmem_cache+0x1b/0x120
> [  +0.004599]  memcg_kmem_cache_create_func+0x1b/0x60
> [  +0.005010]  process_one_work+0x1a1/0x3a0
> [  +0.004144]  worker_thread+0x30/0x380
> [  +0.003728]  ? drain_workqueue+0x120/0x120
> [  +0.004288]  kthread+0x112/0x130
> [  +0.003421]  ? kthread_park+0x80/0x80
> [  +0.003819]  ret_from_fork+0x35/0x40
> [  +0.004499] INFO: task kworker/204:1:1672 blocked for more than 120 sec=
onds.
> [  +0.007121]       Not tainted 4.20.0-rc2+ #4
> [  +0.005935] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables=
 this message.
> [  +0.007887] kworker/204:1   D    0  1672      2 0x80000000
> [  +0.005691] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [  +0.006437] Call Trace:
> [  +0.002575]  ? __schedule+0x24e/0x880
> [  +0.003773]  schedule+0x28/0x80
> [  +0.003335]  rwsem_down_read_failed+0x103/0x190
> [  +0.004580]  call_rwsem_down_read_failed+0x14/0x30
> [  +0.005135]  __percpu_down_read+0x4f/0x80
> [  +0.004215]  get_online_mems+0x2d/0x30
> [  +0.003912]  memcg_create_kmem_cache+0x1b/0x120
> [  +0.004713]  memcg_kmem_cache_create_func+0x1b/0x60
> [  +0.005067]  process_one_work+0x1a1/0x3a0
> [  +0.005878]  worker_thread+0x30/0x380
> [  +0.003923]  ? drain_workqueue+0x120/0x120
> [  +0.004298]  kthread+0x112/0x130
> [  +0.003479]  ? kthread_park+0x80/0x80
> [  +0.003834]  ret_from_fork+0x35/0x40
> [  +0.003743] INFO: task kworker/215:1:1679 blocked for more than 120 sec=
onds.
> [  +0.007222]       Not tainted 4.20.0-rc2+ #4
> [  +0.004411] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables=
 this message.
> [  +0.007957] kworker/215:1   D    0  1679      2 0x80000000
> [  +0.005676] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [  +0.006514] Call Trace:
> [  +0.002544]  ? __schedule+0x24e/0x880
> [  +0.003836]  schedule+0x28/0x80
> [  +0.005306]  rwsem_down_read_failed+0x103/0x190
> [  +0.004652]  call_rwsem_down_read_failed+0x14/0x30
> [  +0.004966]  __percpu_down_read+0x4f/0x80
> [  +0.004170]  get_online_mems+0x2d/0x30
> [  +0.003940]  memcg_create_kmem_cache+0x1b/0x120
> [  +0.004586]  memcg_kmem_cache_create_func+0x1b/0x60
> [  +0.005051]  process_one_work+0x1a1/0x3a0
> [  +0.004122]  worker_thread+0x30/0x380
> [  +0.003850]  ? drain_workqueue+0x120/0x120
> [  +0.004260]  kthread+0x112/0x130
> [  +0.003462]  ? kthread_park+0x80/0x80
> [  +0.003843]  ret_from_fork+0x35/0x40
> [Nov13 21:07] perf: interrupt took too long (34033 > 31826), lowering ker=
nel.perf_event_max_sample_rate to 5000
> [ +15.568475] INFO: task kworker/181:1:1187 blocked for more than 120 sec=
onds.
> [  +0.007070]       Not tainted 4.20.0-rc2+ #4
> [  +0.004302] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables=
 this message.
> [  +0.007962] kworker/181:1   D    0  1187      2 0x80000000
> [  +0.005563] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [  +0.006391] Call Trace:
> [  +0.002541]  ? __schedule+0x24e/0x880
> [  +0.003706]  schedule+0x28/0x80
> [  +0.003186]  rwsem_down_read_failed+0x103/0x190
> [  +0.006117]  call_rwsem_down_read_failed+0x14/0x30
> [  +0.004882]  __percpu_down_read+0x4f/0x80
> [  +0.004101]  get_online_mems+0x2d/0x30
> [  +0.003809]  memcg_create_kmem_cache+0x1b/0x120
> [  +0.004585]  memcg_kmem_cache_create_func+0x1b/0x60
> [  +0.004967]  process_one_work+0x1a1/0x3a0
> [  +0.004058]  worker_thread+0x30/0x380
> [  +0.003693]  ? drain_workqueue+0x120/0x120
> [  +0.004139]  kthread+0x112/0x130
> [  +0.003262]  ? kthread_park+0x80/0x80
> [  +0.006287]  ret_from_fork+0x35/0x40
> [  +0.003654] INFO: task kworker/183:1:1189 blocked for more than 120 sec=
onds.
> [  +0.007101]       Not tainted 4.20.0-rc2+ #4
> [  +0.004300] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables=
 this message.
> [  +0.009789] kworker/183:1   D    0  1189      2 0x80000000
> [  +0.005572] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [  +0.006420] Call Trace:
> [  +0.002515]  ? __schedule+0x24e/0x880
> [  +0.005508]  schedule+0x28/0x80
> [  +0.003220]  rwsem_down_read_failed+0x103/0x190
> [  +0.004620]  call_rwsem_down_read_failed+0x14/0x30
> [  +0.004852]  __percpu_down_read+0x4f/0x80
> [  +0.004080]  get_online_mems+0x2d/0x30
> [  +0.003820]  memcg_create_kmem_cache+0x1b/0x120
> [  +0.004593]  memcg_kmem_cache_create_func+0x1b/0x60
> [  +0.004985]  process_one_work+0x1a1/0x3a0
> [  +0.004082]  worker_thread+0x30/0x380
> [  +0.007119]  ? drain_workqueue+0x120/0x120
> [  +0.004147]  kthread+0x112/0x130
> [  +0.003268]  ? kthread_park+0x80/0x80
> [  +0.003708]  ret_from_fork+0x35/0x40
> [  +0.003619] INFO: task kworker/188:1:1194 blocked for more than 120 sec=
onds.
> [  +0.007080]       Not tainted 4.20.0-rc2+ #4
> [  +0.004300] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables=
 this message.
> [  +0.007845] kworker/188:1   D    0  1194      2 0x80000000
> [  +0.005542] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [  +0.006379] Call Trace:
> [  +0.002558]  ? __schedule+0x24e/0x880
> [  +0.003700]  schedule+0x28/0x80
> [  +0.003188]  rwsem_down_read_failed+0x103/0x190
> [  +0.006625]  call_rwsem_down_read_failed+0x14/0x30
> [  +0.004868]  __percpu_down_read+0x4f/0x80
> [  +0.004059]  get_online_mems+0x2d/0x30
> [  +0.003813]  memcg_create_kmem_cache+0x1b/0x120
> [  +0.004621]  memcg_kmem_cache_create_func+0x1b/0x60
> [  +0.004991]  process_one_work+0x1a1/0x3a0
> [  +0.004071]  worker_thread+0x30/0x380
> [  +0.003702]  ? drain_workqueue+0x120/0x120
> [  +0.004142]  kthread+0x112/0x130
> [  +0.003284]  ? kthread_park+0x80/0x80
> [  +0.003714]  ret_from_fork+0x35/0x40
> [  +0.005858] INFO: task kworker/204:1:1672 blocked for more than 120 sec=
onds.
> [  +0.007068]       Not tainted 4.20.0-rc2+ #4
> [  +0.006282] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables=
 this message.
> [  +0.007839] kworker/204:1   D    0  1672      2 0x80000000
> [  +0.005583] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [  +0.006410] Call Trace:
> [  +0.002544]  ? __schedule+0x24e/0x880
> [  +0.003795]  schedule+0x28/0x80
> [  +0.003191]  rwsem_down_read_failed+0x103/0x190
> [  +0.004608]  call_rwsem_down_read_failed+0x14/0x30
> [  +0.004856]  __percpu_down_read+0x4f/0x80
> [  +0.004058]  get_online_mems+0x2d/0x30
> [  +0.003793]  memcg_create_kmem_cache+0x1b/0x120
> [  +0.004601]  memcg_kmem_cache_create_func+0x1b/0x60
> [  +0.004928]  process_one_work+0x1a1/0x3a0
> [  +0.006197]  worker_thread+0x30/0x380
> [  +0.003709]  ? drain_workqueue+0x120/0x120
> [  +0.004137]  kthread+0x112/0x130
> [  +0.003287]  ? kthread_park+0x80/0x80
> [  +0.003716]  ret_from_fork+0x35/0x40
> [  +0.003674] INFO: task kworker/215:1:1679 blocked for more than 120 sec=
onds.
> [  +0.007096]       Not tainted 4.20.0-rc2+ #4
> [  +0.004312] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables=
 this message.
> [  +0.007836] kworker/215:1   D    0  1679      2 0x80000000
> [  +0.005555] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [  +0.006370] Call Trace:
> [  +0.002503]  ? __schedule+0x24e/0x880
> [  +0.003692]  schedule+0x28/0x80
> [  +0.003180]  rwsem_down_read_failed+0x103/0x190
> [  +0.006669]  call_rwsem_down_read_failed+0x14/0x30
> [  +0.004854]  __percpu_down_read+0x4f/0x80
> [  +0.004067]  get_online_mems+0x2d/0x30
> [  +0.003784]  memcg_create_kmem_cache+0x1b/0x120
> [  +0.004586]  memcg_kmem_cache_create_func+0x1b/0x60
> [  +0.004969]  process_one_work+0x1a1/0x3a0
> [  +0.004068]  worker_thread+0x30/0x380
> [  +0.003727]  ? drain_workqueue+0x120/0x120
> [  +0.004147]  kthread+0x112/0x130
> [  +0.003257]  ? kthread_park+0x80/0x80
> [  +0.003704]  ret_from_fork+0x35/0x40
> [Nov13 21:08] INFO: NMI handler (ghes_notify_nmi) took too long to run: 2=
=2E284 msecs
> [Nov13 21:13] INFO: NMI handler (perf_event_nmi_handler) took too long to=
 run: 2.220 msecs
> [Nov13 21:15] perf: interrupt took too long (43043 > 42541), lowering ker=
nel.perf_event_max_sample_rate to 4000
> [Nov13 21:18] INFO: NMI handler (perf_event_nmi_handler) took too long to=
 run: 2.230 msecs
> [ +21.096246] INFO: NMI handler (perf_event_nmi_handler) took too long to=
 run: 2.253 msecs
> [Nov13 21:25] sysrq: SysRq : Show State
> [  +0.003680]   task                        PC stack   pid father
> [  +0.007945] systemd         S    0     1      0 0x00000000
> [  +0.005495] Call Trace:
> [  +0.002516]  ? __schedule+0x24e/0x880
> [  +0.003686]  schedule+0x28/0x80
> [  +0.003154]  schedule_hrtimeout_range_clock+0x18d/0x1a0
> [  +0.005259]  ? ep_scan_ready_list.constprop.21+0x1f0/0x220
> [  +0.005490]  ep_poll+0x3b7/0x3f0
> [  +0.003258]  ? wake_up_q+0x70/0x70
> [  +0.003406]  do_epoll_wait+0xb0/0xd0
> [  +0.003588]  __x64_sys_epoll_wait+0x1a/0x20
> [  +0.004216]  do_syscall_64+0x55/0x1a0
> [  +0.003680]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> [  +0.005065] RIP: 0033:0x7f12d9099cc7
> [  +0.003596] Code: Bad RIP value.
> [  +0.003240] RSP: 002b:00007ffd5e90fca0 EFLAGS: 00000293 ORIG_RAX: 00000=
000000000e8
> [  +0.009502] RAX: ffffffffffffffda RBX: 0000000000000004 RCX: 00007f12d9=
099cc7
> [  +0.007123] RDX: 0000000000000043 RSI: 00007ffd5e90fce0 RDI: 0000000000=
000004
> [  +0.007128] RBP: 00007ffd5e90fce0 R08: 0000000000000000 R09: 7465677261=
742e79
> [  +0.007130] R10: 00000000ffffffff R11: 0000000000000293 R12: 0000000000=
000043
> [  +0.007131] R13: 00000000ffffffff R14: 00007ffd5e90fce0 R15: 0000000000=
000001
> [  +0.007328] kthreadd        S    0     2      0 0x80000000
> [  +0.005486] Call Trace:
> [  +0.002464]  ? __schedule+0x24e/0x880
> [  +0.003674]  schedule+0x28/0x80
> [  +0.003159]  kthreadd+0x2d1/0x2f0
> [  +0.003327]  ? kthread_create_on_cpu+0xa0/0xa0
> [  +0.006395]  ret_from_fork+0x35/0x40
> [  +0.003731] rcu_gp          I    0     3      2 0x80000000
> [  +0.005489] Call Trace:
> [  +0.002461]  ? __schedule+0x24e/0x880
> [  +0.003674]  schedule+0x28/0x80
> [  +0.003171]  rescuer_thread+0x2e2/0x340
> [  +0.003847]  ? worker_thread+0x380/0x380
> [  +0.003939]  kthread+0x112/0x130
> [  +0.003249]  ? kthread_park+0x80/0x80
> [  +0.003673]  ret_from_fork+0x35/0x40
> [  +0.003719] rcu_par_gp      I    0     4      2 0x80000000
> [  +0.005496] Call Trace:
> [  +0.002477]  ? __schedule+0x24e/0x880
> [  +0.003688]  schedule+0x28/0x80
> [  +0.003155]  rescuer_thread+0x2e2/0x340
> [  +0.003844]  ? worker_thread+0x380/0x380
> [  +0.005520]  kthread+0x112/0x130
> [  +0.003242]  ? kthread_park+0x80/0x80
> [  +0.003671]  ret_from_fork+0x35/0x40
> [  +0.003745] kworker/0:0     I    0     5      2 0x80000000
> [  +0.005500] Workqueue:            (null) (events)
> [  +0.004717] Call Trace:
> [  +0.002469]  ? __schedule+0x24e/0x880
> [  +0.003696]  schedule+0x28/0x80
> [  +0.003159]  worker_thread+0xb2/0x380
> [  +0.003685]  ? drain_workqueue+0x120/0x120
> [  +0.004108]  kthread+0x112/0x130
> [  +0.003247]  ? kthread_park+0x80/0x80
> [  +0.003676]  ret_from_fork+0x35/0x40
> [  +0.003735] kworker/0:0H    I    0     6      2 0x80000000
> [  +0.005504] Workqueue:            (null) (events_highpri)
> [  +0.005403] Call Trace:
> [  +0.004097]  ? __schedule+0x24e/0x880
> [  +0.003682]  ? flush_backlog+0x3c/0x130
> [  +0.003852]  schedule+0x28/0x80
> [  +0.003154]  worker_thread+0xb2/0x380
> [  +0.003689]  ? drain_workqueue+0x120/0x120
> [  +0.004108]  kthread+0x112/0x130
> [  +0.003235]  ? kthread_park+0x80/0x80
> [  +0.003685]  ret_from_fork+0x35/0x40
> [  +0.003734] kworker/u576:0  R  running task        0     8      2 0x800=
00000
> [  +0.007062] Workqueue: kacpi_hotplug acpi_hotplug_work_fn
> [  +0.005398] Call Trace:
> [  +0.002476]  ? page_vma_mapped_walk+0x307/0x710
> [  +0.004538]  ? page_remove_rmap+0xa2/0x340
> [  +0.004104]  ? ptep_clear_flush+0x54/0x60
> [  +0.004027]  ? enqueue_entity+0x11c/0x620
> [  +0.005904]  ? schedule+0x28/0x80
> [  +0.003336]  ? rmap_walk_file+0xf9/0x270
> [  +0.003940]  ? try_to_unmap+0x9c/0xf0
> [  +0.003695]  ? migrate_pages+0x2b0/0xb90
> [  +0.003959]  ? try_offline_node+0x160/0x160
> [  +0.004214]  ? __offline_pages+0x6ce/0x8e0
> [  +0.004134]  ? memory_subsys_offline+0x40/0x60
> [  +0.004474]  ? device_offline+0x81/0xb0
> [  +0.003867]  ? acpi_bus_offline+0xdb/0x140
> [  +0.004117]  ? acpi_device_hotplug+0x21c/0x460
> [  +0.004458]  ? acpi_hotplug_work_fn+0x1a/0x30
> [  +0.004372]  ? process_one_work+0x1a1/0x3a0
> [  +0.004195]  ? worker_thread+0x30/0x380
> [  +0.003851]  ? drain_workqueue+0x120/0x120
> [  +0.004117]  ? kthread+0x112/0x130
> [  +0.003411]  ? kthread_park+0x80/0x80
> [  +0.005325]  ? ret_from_fork+0x35/0x40
> [  +0.003918] mm_percpu_wq    I    0     9      2 0x80000000
> [  +0.005495] Workqueue:            (null) (mm_percpu_wq)
> [  +0.005227] Call Trace:
> [  +0.002468]  ? __schedule+0x24e/0x880
> [  +0.003671]  schedule+0x28/0x80
> [  +0.003160]  rescuer_thread+0x2e2/0x340
> [  +0.003850]  ? worker_thread+0x380/0x380
> [  +0.003930]  kthread+0x112/0x130
> [  +0.003244]  ? kthread_park+0x80/0x80
> [  +0.003678]  ret_from_fork+0x35/0x40
> [  +0.003713] ksoftirqd/0     S    0    10      2 0x80000000
> [  +0.005486] Call Trace:
> [  +0.002462]  ? __schedule+0x24e/0x880
> [  +0.003684]  ? __do_softirq+0x19c/0x2fe
> [  +0.003855]  ? sort_range+0x20/0x20
> [  +0.005179]  schedule+0x28/0x80
> [  +0.003155]  smpboot_thread_fn+0x10b/0x160
> [  +0.004103]  kthread+0x112/0x130
> [  +0.003254]  ? kthread_park+0x80/0x80
> [  +0.003673]  ret_from_fork+0x35/0x40
> [  +0.003774] rcu_sched       I    0    11      2 0x80000000
> [  +0.005486] Call Trace:
> [  +0.002465]  ? __schedule+0x24e/0x880
> [  +0.003679]  schedule+0x28/0x80
> [  +0.003162]  schedule_timeout+0x16b/0x390
> [  +0.004054]  ? __next_timer_interrupt+0xc0/0xc0
> [  +0.004556]  rcu_gp_kthread+0x42f/0x890
> [  +0.003885]  ? rcu_eqs_enter.constprop.60+0xa0/0xa0
> [  +0.004885]  kthread+0x112/0x130
> [  +0.003241]  ? kthread_park+0x80/0x80
> [  +0.003679]  ret_from_fork+0x35/0x40
> [  +0.005679] migration/0     S    0    12      2 0x80000000
> [  +0.005486] Call Trace:
> [  +0.002487]  ? __schedule+0x24e/0x880
> [  +0.003677]  ? sort_range+0x20/0x20
> [  +0.003509]  schedule+0x28/0x80
> [  +0.003156]  smpboot_thread_fn+0x10b/0x160
> [  +0.004101]  kthread+0x112/0x130
> [  +0.003248]  ? kthread_park+0x80/0x80
> [  +0.003677]  ret_from_fork+0x35/0x40
> [  +0.003720] kworker/0:1     I    0    13      2 0x80000000
>=20
> ......
>=20
> [  +0.011300] Showing busy workqueues and worker pools:
> [  +0.006762] workqueue mm_percpu_wq: flags=3D0x8
> [  +0.004453]   pwq 432: cpus=3D216 node=3D4 flags=3D0x0 nice=3D0 active=
=3D1/256
> [  +0.006336]     pending: vmstat_update
> [  +0.004001]   pwq 116: cpus=3D58 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/256
> [  +0.006278]     pending: vmstat_update
> [  +0.004654] workqueue memcg_kmem_cache: flags=3D0x0
> [  +0.006686]   pwq 430: cpus=3D215 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006164]     in-flight: 1679:memcg_kmem_cache_create_func
> [  +0.005649]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000046] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.087324] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090665] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.138852]   pwq 424: cpus=3D212 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006164]     in-flight: 1678:memcg_kmem_cache_create_func
> [  +0.005639]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000038] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.087473] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090684] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func
> [  +0.133351]   pwq 422: cpus=3D211 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006161]     in-flight: 1675:memcg_kmem_cache_create_func
> [  +0.005639]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000039] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.087380] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090542] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func
> [  +0.134096]   pwq 420: cpus=3D210 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006158]     in-flight: 1674:memcg_kmem_cache_create_func
> [  +0.005641]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000042] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089204] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089119] , memcg_kmem_cache_create_func
> [  +0.007636] watchdog: BUG: soft lockup - CPU#216 stuck for 22s! [migrat=
ion/216:1295]
> [  +0.081071] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000052] , memcg_kmem_cache_create_func
> [  +0.004076] Modules linked in:
> [  +0.009643] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000062] , memcg_kmem_cache_create_func
> [  +0.089190]  vfat
> [  +0.004048] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000067] , memcg_kmem_cache_create_func
> [  +0.003042]  fat
> [  +0.090462] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func
> [  +0.004130]  intel_rapl sb_edac x86_pkg_temp_thermal coretemp kvm_intel=
 kvm irqbypass crct10dif_pclmul crc32_pclmul ghash_clmulni_intel intel_csta=
te intel_uncore iTCO_wdt iTCO_vendor_support ses joydev intel_rapl_perf enc=
losure scsi_transport_sas ipmi_si ipmi_devintf pcspkr ipmi_msghandler sg lp=
c_ich i2c_i801 mei_me mei xfs libcrc32c sd_mod crc32c_intel igb ahci libahc=
i i2c_algo_bit dca libata megaraid_sas wmi dm_mirror dm_region_hash dm_log =
dm_mod
> [  +0.001959]   pwq 412: cpus=3D206 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.089072] CPU: 216 PID: 1295 Comm: migration/216 Tainted: G          =
   L    4.20.0-rc2+ #4
> [  +0.004073]     in-flight: 1665:memcg_kmem_cache_create_func
> [  +0.001855] Hardware name:  9008/IT91SMUB, BIOS BLXSV512 03/22/2018
> [  +0.039783]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000072] , memcg_kmem_cache_create_func
> [  +0.039548] RIP: 0010:multi_cpu_stop+0x42/0xe0
> [  +0.008079] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000063] , memcg_kmem_cache_create_func
> [  +0.008491] Code: 1d f3 71 ea 7e 9c 41 5f 48 8b 47 18 48 85 c0 0f 84 88=
 00 00 00 89 db 48 0f a3 18 41 0f 92 c6 4c 8d 65 24 31 c0 45 31 ed f3 90 <8=
b> 5d 20 44 39 eb 74 3c 83 fb 02 74 51 83 fb 03 75 12 45 84 f6 74
> [  +0.005612] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000053] , memcg_kmem_cache_create_func
> [  +0.006231] RSP: 0000:ffffc9000f803e78 EFLAGS: 00000246
> [  +0.086898] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000053] , memcg_kmem_cache_create_func
> [  +0.004074]  ORIG_RAX: ffffffffffffff13
> [  +0.004413] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000066] , memcg_kmem_cache_create_func
> [  +0.090749] RAX: 0000000000000000 RBX: 0000000000000001 RCX: ffff888e7d=
29c730
> [  +0.004053] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000054] , memcg_kmem_cache_create_func
> [  +0.018694] RDX: ffffc900159dbbf0 RSI: ffffc900159dbbf0 RDI: ffffc90015=
9dbc40
> [  +0.090655] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func
> [  +0.004135] RBP: ffffc900159dbc40 R08: 0000028f87366c00 R09: 0000000000=
000000
> [  +0.005227]   pwq 410: cpus=3D205 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.088661] R10: 00000000aaaaaaa8 R11: 00000000000005b2 R12: ffffc90015=
9dbc64
> [  +0.004067]     in-flight: 1669:memcg_kmem_cache_create_func
> [  +0.003874] R13: 0000000000000001 R14: ffff888e7d29c700 R15: 0000000000=
000296
> [  +0.090717]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000062] , memcg_kmem_cache_create_func
> [  +0.004080] FS:  0000000000000000(0000) GS:ffff888e7d280000(0000) knlGS=
:0000000000000000
> [  +0.007083] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000055] , memcg_kmem_cache_create_func
> [  +0.088630] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  +0.004064] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000057] , memcg_kmem_cache_create_func
> [  +0.009125] CR2: 00007ffcee1d5d18 CR3: 0000000daab24001 CR4: 0000000000=
3606e0
> [  +0.032578] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000055] , memcg_kmem_cache_create_func
> [  +0.007090] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000=
000000
> [  +0.006143] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000047] , memcg_kmem_cache_create_func
> [  +0.007099] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000=
000400
> [  +0.007430] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000060] , memcg_kmem_cache_create_func
> [  +0.007098] Call Trace:
> [  +0.087211] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000052] , memcg_kmem_cache_create_func
> [  +0.004144]  ? __schedule+0x256/0x880
> [  +0.007978] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000070] , memcg_kmem_cache_create_func
> [  +0.090319]  ? cpu_stop_queue_work+0xc0/0xc0
> [  +0.004025] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000047] , memcg_kmem_cache_create_func
> [  +0.005767]  cpu_stopper_thread+0x7a/0x100
> [  +0.088708] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func
> [  +0.004175]  ? sort_range+0x20/0x20
> [  +0.007081]   pwq 408: cpus=3D204 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.091040]  smpboot_thread_fn+0xc5/0x160
> [  +0.004033]     in-flight: 1672:memcg_kmem_cache_create_func
> [  +0.007193]  kthread+0x112/0x130
> [  +0.088976]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000059] , memcg_kmem_cache_create_func
> [  +0.005696]  ? kthread_park+0x80/0x80
> [  +0.007048] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000059] , memcg_kmem_cache_create_func
> [  +0.089369]  ret_from_fork+0x35/0x40
> [  +0.003759] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.000058] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.646860] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func
> [  +0.143377]   pwq 404: cpus=3D202 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006163]     in-flight: 1662:memcg_kmem_cache_create_func
> [  +0.005640]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000040] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.087036] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.113279]   pwq 402: cpus=3D201 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006156]     in-flight: 1668:memcg_kmem_cache_create_func
> [  +0.005639]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func
> [  +0.033033]   pwq 400: cpus=3D200 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006161]     in-flight: 1664:memcg_kmem_cache_create_func
> [  +0.005639]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000029] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.087416] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.100097]   pwq 398: cpus=3D199 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006159]     in-flight: 1666:memcg_kmem_cache_create_func
> [  +0.005640]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000040] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.087134] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func
> [  +0.115426]   pwq 396: cpus=3D198 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006159]     in-flight: 1671:memcg_kmem_cache_create_func
> [  +0.005637]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000043] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088942] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089064] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090497] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089148] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090326] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088847] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089027] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090567] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088955] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090775] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088721] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088816] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090606] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088833] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.091012] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088703] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090772] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088670] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089054] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func
> [  +0.177268]   pwq 376: cpus=3D188 node=3D2 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006161]     in-flight: 1194:memcg_kmem_cache_create_func
> [  +0.005640]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000043] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func
> [  +0.160211]   pwq 366: cpus=3D183 node=3D2 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006160]     in-flight: 1189:memcg_kmem_cache_create_func
> [  +0.005639]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func
> [  +0.045635]   pwq 362: cpus=3D181 node=3D2 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006159]     in-flight: 1187:memcg_kmem_cache_create_func
> [  +0.005700]   pwq 322: cpus=3D161 node=3D0 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006163]     in-flight: 1167:memcg_kmem_cache_create_func
> [  +0.005639]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.035685]   pwq 140: cpus=3D70 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006073]     in-flight: 1075:memcg_kmem_cache_create_func
> [  +0.005641]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000035] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.087482] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090983] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089024] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090527] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088900] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090691] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089071] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089030] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090884] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088733] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090737] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088813] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089038] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090421] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088668] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090559] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089029] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.091022] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088829] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func
> [  +0.115806]   pwq 138: cpus=3D69 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006072]     in-flight: 1077:memcg_kmem_cache_create_func
> [  +0.005642]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000039] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.087318] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.153628]   pwq 136: cpus=3D68 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006075]     in-flight: 1076:memcg_kmem_cache_create_func
> [  +0.005640]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000042] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.086933] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.091009] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089082] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090688] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088744] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090707] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088657] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088865] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090808] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088731] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090613] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089019] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088799] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090966] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088625] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090831] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func
> [  +0.146462]   pwq 132: cpus=3D66 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006079]     in-flight: 1072:memcg_kmem_cache_create_func
> [  +0.005642]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000037] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089276] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088760] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090860] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089025] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089034] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.141036]   pwq 130: cpus=3D65 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006076]     in-flight: 1071:memcg_kmem_cache_create_func
> [  +0.005639]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000035] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func
> [  +0.132012]   pwq 128: cpus=3D64 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006072]     in-flight: 1070:memcg_kmem_cache_create_func
> [  +0.005641]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000045] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.087330] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090945] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088761] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func
> [  +0.115367]   pwq 126: cpus=3D63 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006074]     in-flight: 1069:memcg_kmem_cache_create_func
> [  +0.005640]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000037] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089299] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func
> [  +0.156967]   pwq 124: cpus=3D62 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006077]     in-flight: 1068:memcg_kmem_cache_create_func
> [  +0.005631]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000046] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089231] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089045] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.091066] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088918] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090714] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089013] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088776] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func
> [  +0.090784]   pwq 122: cpus=3D61 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.066499]     in-flight: 4710:memcg_kmem_cache_create_func
> [  +0.005639]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000037] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.087047] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090873] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088924] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090556] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089049] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088946] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090502] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088684] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.091024] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089045] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090371] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088885] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089042] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.091161] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func
> [  +0.131196]   pwq 120: cpus=3D60 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006075]     in-flight: 1066:memcg_kmem_cache_create_func
> [  +0.005641]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000042] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.086989] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090667] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.139362]   pwq 116: cpus=3D58 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006071]     in-flight: 1063:memcg_kmem_cache_create_func
> [  +0.005640]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000035] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089254] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088871] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090691] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088691] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088597] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090347] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [Nov13 21:30] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.091023] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089035] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088985] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090761] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088992] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090828] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088984] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090659] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088830] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088703] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090620] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088810] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090675] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088913] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090962] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088864] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088947] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090734] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.089132] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.090393] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.088723] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func
> [  +0.176744]   pwq 114: cpus=3D57 node=3D3 flags=3D0x0 nice=3D0 active=
=3D1/1
> [  +0.006073]     in-flight: 1062:memcg_kmem_cache_create_func
> [  +0.005642]     delayed: memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, m=
emcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache=
_create_func
> [  +0.000045] , memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func, memcg_kmem_cache_create_func, memcg_kmem_c=
ache_create_func, memcg_kmem_cache_create_func, memcg_kmem_cache_create_fun=
c, memcg_kmem_cache_create_func
> [  +0.165992] workqueue kacpi_hotplug: flags=3D0xa0002
> [  +0.004793]   pwq 576: cpus=3D0-287 flags=3D0x4 nice=3D0 active=3D1/1
> [  +0.005731]     in-flight: 8:acpi_hotplug_work_fn
> [  +0.013716] pool 114: cpus=3D57 node=3D3 flags=3D0x0 nice=3D0 hung=3D0s=
 workers=3D3 idle: 7587 4988
> [  +0.007998] pool 116: cpus=3D58 node=3D3 flags=3D0x0 nice=3D0 hung=3D28=
8s workers=3D3 idle: 7576 3913
> [  +0.008170] pool 120: cpus=3D60 node=3D3 flags=3D0x0 nice=3D0 hung=3D10=
7s workers=3D3 idle: 7592 316
> [  +0.008081] pool 122: cpus=3D61 node=3D3 flags=3D0x0 nice=3D0 hung=3D16=
s workers=3D3 idle: 7603 1067
> [  +0.009773] pool 124: cpus=3D62 node=3D3 flags=3D0x0 nice=3D0 hung=3D23=
6s workers=3D3 idle: 7602 326
> [  +0.008081] pool 126: cpus=3D63 node=3D3 flags=3D0x0 nice=3D0 hung=3D29=
3s workers=3D3 idle: 7590 331
> [  +0.008190] pool 128: cpus=3D64 node=3D3 flags=3D0x0 nice=3D0 hung=3D29=
3s workers=3D3 idle: 7577 5666
> [  +0.008179] pool 130: cpus=3D65 node=3D3 flags=3D0x0 nice=3D0 hung=3D29=
2s workers=3D3 idle: 7579 5665
> [  +0.008177] pool 132: cpus=3D66 node=3D3 flags=3D0x0 nice=3D0 hung=3D29=
5s workers=3D3 idle: 7605 346
> [  +0.008089] pool 136: cpus=3D68 node=3D3 flags=3D0x0 nice=3D0 hung=3D10=
7s workers=3D3 idle: 7604 356
> [  +0.008082] pool 138: cpus=3D69 node=3D3 flags=3D0x0 nice=3D0 hung=3D29=
2s workers=3D3 idle: 7585 361
> [  +0.009689] pool 140: cpus=3D70 node=3D3 flags=3D0x0 nice=3D0 hung=3D29=
0s workers=3D3 idle: 7567 4993
> [  +0.008293] pool 322: cpus=3D161 node=3D0 flags=3D0x0 nice=3D0 hung=3D0=
s workers=3D3 idle: 7891 825
> [  +0.008018] pool 362: cpus=3D181 node=3D2 flags=3D0x0 nice=3D0 hung=3D2=
s workers=3D3 idle: 6062 925
> [  +0.007995] pool 366: cpus=3D183 node=3D2 flags=3D0x0 nice=3D0 hung=3D0=
s workers=3D3 idle: 5862 935
> [  +0.008003] pool 376: cpus=3D188 node=3D2 flags=3D0x0 nice=3D0 hung=3D0=
s workers=3D3 idle: 6055 960
> [  +0.008017] pool 396: cpus=3D198 node=3D3 flags=3D0x0 nice=3D0 hung=3D1=
6s workers=3D3 idle: 7571 5287
> [  +0.008176] pool 398: cpus=3D199 node=3D3 flags=3D0x0 nice=3D0 hung=3D2=
3s workers=3D3 idle: 7568 3969
> [  +0.008172] pool 400: cpus=3D200 node=3D3 flags=3D0x0 nice=3D0 hung=3D2=
2s workers=3D3 idle: 7569 1217
> [  +0.010158] pool 402: cpus=3D201 node=3D3 flags=3D0x0 nice=3D0 hung=3D2=
2s workers=3D3 idle: 7893 1222
> [  +0.008181] pool 404: cpus=3D202 node=3D3 flags=3D0x0 nice=3D0 hung=3D2=
24s workers=3D3 idle: 7578 4699
> [  +0.008260] pool 408: cpus=3D204 node=3D3 flags=3D0x0 nice=3D0 hung=3D2=
23s workers=3D3 idle: 6051 1237
> [  +0.008253] pool 410: cpus=3D205 node=3D3 flags=3D0x0 nice=3D0 hung=3D1=
44s workers=3D3 idle: 7601 1242
> [  +0.008265] pool 412: cpus=3D206 node=3D3 flags=3D0x0 nice=3D0 hung=3D2=
61s workers=3D3 idle: 7606 1247
> [  +0.008256] pool 420: cpus=3D210 node=3D3 flags=3D0x0 nice=3D0 hung=3D2=
20s workers=3D3 idle: 7607 1267
> [  +0.008251] pool 422: cpus=3D211 node=3D3 flags=3D0x0 nice=3D0 hung=3D2=
69s workers=3D3 idle: 7582 1272
> [  +0.010228] pool 424: cpus=3D212 node=3D3 flags=3D0x0 nice=3D0 hung=3D2=
19s workers=3D3 idle: 7619 1277
> [  +0.008260] pool 430: cpus=3D215 node=3D3 flags=3D0x0 nice=3D0 hung=3D2=
17s workers=3D3 idle: 6050 1292
> [  +0.008377] pool 576: cpus=3D0-287 flags=3D0x4 nice=3D0 hung=3D2182s wo=
rkers=3D2 idle: 1774
> [  +0.007568] rcu: INFO: rcu_sched detected stalls on CPUs/tasks:
> [  +0.000009] clocksource: timekeeping watchdog on CPU58: Marking clockso=
urce 'tsc' as unstable because the skew is too large:
> [  +0.000031] rcu: 	58-....: (38973 ticks this GP) idle=3D156/1/0x4000000=
000000000 softirq=3D83053/83053 fqs=3D54344=20
> [  +0.005884] clocksource:                       'hpet' wd_now: 374c60ca =
wd_last: b4cdce7c mask: ffffffff
> [  +0.011175] rcu: 	(detected by 197, t=3D288575 jiffies, g=3D108005, q=
=3D261412)
> [  +0.009892] clocksource:                       'tsc' cs_now: 7a398a46bd=
4 cs_last: 74e27405334 mask: ffffffffffffffff
> [  +0.011301] Sending NMI from CPU 197 to CPUs 58:
> [  +0.000168] NMI backtrace for cpu 58
> [  +0.000002] CPU: 58 PID: 305 Comm: ksoftirqd/58 Tainted: G             =
L    4.20.0-rc2+ #4
> [  +0.000001] Hardware name:  9008/IT91SMUB, BIOS BLXSV512 03/22/2018
> [  +0.000001] RIP: 0010:vprintk_emit+0x1d2/0x230
> [  +0.000002] Code: 01 c6 07 00 0f 1f 40 00 0f b6 05 19 ed 8d 01 48 c7 c2=
 20 12 9f 82 84 c0 74 09 f3 90 0f b6 02 84 c0 75 f7 e8 e0 0a 00 00 55 9d <e=
8> 29 ee ff ff e8 e4 fd ff ff e9 5d ff ff ff 80 3d a0 cc 2d 01 00
> [  +0.000001] RSP: 0018:ffffc9000d913ce0 EFLAGS: 00000202
> [  +0.000002] RAX: 0000000000000000 RBX: 0000000000000068 RCX: 0000000000=
000068
> [  +0.000001] RDX: ffffffff829f1220 RSI: 0000000000000002 RDI: ffffffff82=
9f1230
> [  +0.000001] RBP: 0000000000000202 R08: 0000000000000002 R09: 0000000000=
021640
> [  +0.000000] R10: 000007a39c812a4c R11: 00000000000a8c14 R12: 0000000000=
000001
> [  +0.000000] R13: 0000000000000001 R14: 000000000000e5de R15: ffffc9000d=
913d38
> [  +0.000001] FS:  0000000000000000(0000) GS:ffff888e7d900000(0000) knlGS=
:0000000000000000
> [  +0.000001] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  +0.000000] CR2: 00007f7e8c212b1e CR3: 0000000e474ae006 CR4: 0000000000=
3606e0
> [  +0.000001] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000=
000000
> [  +0.000000] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000=
000400
> [  +0.000000] Call Trace:
> [  +0.000001]  printk+0x58/0x6f
> [  +0.000000]  ? __switch_to_asm+0x40/0x70
> [  +0.000000]  clocksource_watchdog+0x2da/0x2f0
> [  +0.000001]  ? __clocksource_unstable+0x60/0x60
> [  +0.000000]  call_timer_fn+0x2b/0x130
> [  +0.000000]  run_timer_softirq+0x3b9/0x3f0
> [  +0.000001]  ? __switch_to_asm+0x40/0x70
> [  +0.000000]  ? __switch_to_asm+0x34/0x70
> [  +0.000000]  ? __switch_to_asm+0x40/0x70
> [  +0.000000]  ? __switch_to_asm+0x34/0x70
> [  +0.000001]  ? __switch_to_asm+0x40/0x70
> [  +0.000000]  ? __switch_to_asm+0x40/0x70
> [  +0.000000]  __do_softirq+0xdd/0x2fe
> [  +0.000023]  ? sort_range+0x20/0x20
> [  +0.000000]  run_ksoftirqd+0x1a/0x20
> [  +0.000001]  smpboot_thread_fn+0xc5/0x160
> [  +0.000000]  kthread+0x112/0x130
> [  +0.000001]  ? kthread_park+0x80/0x80
> [  +0.000004]  ret_from_fork+0x35/0x40
> [  +0.219060] tsc: Marking TSC unstable due to clocksource watchdog
> [  +0.006381] TSC found unstable after boot, most likely due to broken BI=
OS. Use 'tsc=3Dunstable'.
> [  +0.008594] sched_clock: Marking unstable (3065928264139, 4859457120)<-=
(3073001951393, -2214749450)
> [  +0.027388] clocksource: Switched to clocksource hpet
> [Nov13 21:33] perf: interrupt took too long (63348 > 53803), lowering ker=
nel.perf_event_max_sample_rate to 3000
> [Nov13 21:36] INFO: NMI handler (nmi_cpu_backtrace_handler) took too long=
 to run: 2.130 msecs
> [Nov13 21:51] hrtimer: interrupt took 2022824 ns
