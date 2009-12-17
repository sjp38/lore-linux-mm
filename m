Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B1F536B0062
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 01:24:24 -0500 (EST)
From: "Shilimkar, Santosh" <santosh.shilimkar@ti.com>
Date: Thu, 17 Dec 2009 11:54:10 +0530
Subject: RE: CPU consumption is going as high as 95% on ARM Cortex A8
Message-ID: <EAF47CD23C76F840A9E7FCE10091EFAB02BFB58568@dbde02.ent.ti.com>
References: <19F8576C6E063C45BE387C64729E73940449F43857@dbde02.ent.ti.com>
In-Reply-To: <19F8576C6E063C45BE387C64729E73940449F43857@dbde02.ent.ti.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "Hiremath, Vaibhav" <hvaibhav@ti.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
List-ID: <linux-mm.kvack.org>


> -----Original Message-----
> From: linux-arm-kernel-bounces@lists.infradead.org [mailto:linux-arm-kern=
el-
> bounces@lists.infradead.org] On Behalf Of Hiremath, Vaibhav
> Sent: Thursday, December 17, 2009 11:09 AM
> To: linux@arm.linux.org.uk
> Cc: linux-mm@kvack.org; linux-omap@vger.kernel.org; linux-arm-kernel@list=
s.infradead.org
> Subject: CPU consumption is going as high as 95% on ARM Cortex A8
>=20
> Hi,
>=20
> I am seeing some strange behavior while accessing buffers through User Sp=
ace (mapped using mmap call)
>=20
> Background :-
> ------------
> Platform - TI AM3517
> CPU - ARM Cortex A8
>=20
> root@am3517-evm:~#
> root@am3517-evm:~# cat /proc/cpuinfo
> Processor       : ARMv7 Processor rev 7 (v7l)
> BogoMIPS        : 499.92
> Features        : swp half thumb fastmult vfp edsp neon vfpv3
> CPU implementer : 0x41
> CPU architecture: 7
> CPU variant     : 0x1
> CPU part        : 0xc08
> CPU revision    : 7
> Hardware        : OMAP3517/AM3517 EVM
> Revision        : 0020
> Serial          : 0000000000000000
> root@omap3517-evm:~#
>=20
>=20
> Issue/Usage :-
> -------------
> The V4l2-Capture driver captures the data from video decoder into buffer =
and the application does
> some processing on this buffer. The mmap implementation can be found at d=
rivers/media/video/videobuf-
> dma-contig.c, function__videobuf_mmap_mapper().
>=20
> Observation -
> The CPU consumption goes as high as 95% on read buffer operation, please =
note that write operation on
> these buffers also gives 60-70% CPU consumption. (Using memcpy/memset API=
's for read and write
> operation).
>=20
> Some more inputs :-
> ------------------
> - If I specify PAGE_READONLY or PAGE_SHARED (actual flag is L_PTE_USER) w=
hile mapping the buffer to
> UserSpace in mmap system call, the CPU consumption goes down to expected =
value (20-27%).
> Then I reached till the function cpu_v7_set_pte_ext, where we are configu=
ring level 2 translation
> table entries, which makes use of these flags.
>=20
> - Below is the value of r0, r1 and r2 register (ptep, pteval, ext) in bot=
h the cases -
>=20
>=20
> Without PAGE_READONLY/PAGE_SHARED
>=20
> ptep - cfb5de10, pte - 8d200383, ext - 800
> ptep - cfb5de14, pte - 8d201383, ext - 800

Which kernel version is this? Can you please also give values of PRRR, NMRR=
 and SCTLR=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
