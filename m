Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2DD6B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 07:55:51 -0500 (EST)
Received: by wevm14 with SMTP id m14so52737705wev.8
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 04:55:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id uq3si6963858wjc.165.2015.03.05.04.55.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 04:55:48 -0800 (PST)
Message-ID: <54F85233.1010006@redhat.com>
Date: Thu, 05 Mar 2015 13:55:15 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv4 00/24] THP refcounting redesign
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="3PKTrlIjgDimorj7IpXoSH9gUJuclEhuw"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--3PKTrlIjgDimorj7IpXoSH9gUJuclEhuw
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 03/04/2015 05:32 PM, Kirill A. Shutemov wrote:
> Hello everybody,
>=20
> It's bug-fix update of my thp refcounting work.
>=20
> The goal of patchset is to make refcounting on THP pages cheaper with
> simpler semantics and allow the same THP compound page to be mapped wit=
h
> PMD and PTEs. This is required to get reasonable THP-pagecache
> implementation.
>=20
> With the new refcounting design it's much easier to protect against
> split_huge_page(): simple reference on a page will make you the deal.
> It makes gup_fast() implementation simpler and doesn't require
> special-case in futex code to handle tail THP pages.
>=20
> It should improve THP utilization over the system since splitting THP i=
n
> one process doesn't necessary lead to splitting the page in all other
> processes have the page mapped.
>=20
[...]
> I believe all known bugs have been fixed, but I'm sure Sasha will bring=
 more
> reports.
>=20
> The patchset also available on git:
>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git thp/refcoun=
ting/v4
>=20

Hi Kirill,

I ran some ltp tests and it triggered two bugs:

[  318.526528] ------------[ cut here ]------------
[  318.527031] kernel BUG at mm/filemap.c:203!
[  318.527031] invalid opcode: 0000 [#1] SMP=20
[  318.527031] Modules linked in: loop ip6t_rpfilter ip6t_REJECT nf_rejec=
t_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 =
xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge stp llc ebtab=
le_filter ebtables ip6table_mangle ip6table_security ip6table_raw ip6tabl=
e_filter ip6_tables iptable_mangle iptable_security iptable_raw crct10dif=
_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel ppdev microcode joy=
dev virtio_console pcspkr serio_raw virtio_balloon parport_pc parport nfs=
d pvpanic i2c_piix4 acpi_cpufreq auth_rpcgss nfs_acl lockd grace sunrpc q=
xl virtio_blk virtio_net drm_kms_helper ttm drm virtio_pci virtio_ring vi=
rtio ata_generic pata_acpi floppy
[  318.527031] CPU: 0 PID: 8929 Comm: hugemmap01 Not tainted 4.0.0-rc1-ne=
xt-20150227+ #213
[  318.527031] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  318.527031] task: ffff8800783d9200 ti: ffff880078bc0000 task.ti: ffff8=
80078bc0000
[  318.527031] RIP: 0010:[<ffffffff811a74dc>]  [<ffffffff811a74dc>] __del=
ete_from_page_cache+0x2ec/0x350
[  318.527031] RSP: 0018:ffff880078bc3c58  EFLAGS: 00010002
[  318.527031] RAX: 0000000000000001 RBX: ffffea0001338000 RCX: 00000000f=
fffffec
[  318.527031] RDX: 003ffc0000000001 RSI: 000000000000000a RDI: ffff88007=
ffe97c0
[  318.527031] RBP: ffff880078bc3ca8 R08: ffffffff82660f14 R09: 000000000=
0000000
[  318.527031] R10: ffff8800783d9200 R11: 0000000000000001 R12: ffff88007=
7824980
[  318.527031] R13: ffff880077824968 R14: 0000000000000000 R15: ffff88007=
7824970
[  318.527031] FS:  00007fe5cff0b700(0000) GS:ffff88007fc00000(0000) knlG=
S:0000000000000000
[  318.527031] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  318.527031] CR2: 00007fe5cff17000 CR3: 00000000778fb000 CR4: 000000000=
01407f0
[  318.527031] Stack:
[  318.527031]  ffff880077824980 ffff880077824980 0000000000000000 ffff88=
0077824978
[  318.527031]  ffff880078bc3ca8 ffffea0001338000 ffff880077824980 000000=
0000000000
[  318.527031]  0000000000000001 0000000000000000 ffff880078bc3cd8 ffffff=
ff811a758c
[  318.527031] Call Trace:
[  318.527031]  [<ffffffff811a758c>] delete_from_page_cache+0x4c/0x80
[  318.527031]  [<ffffffff81304ecb>] truncate_hugepages+0xfb/0x1d0
[  318.527031]  [<ffffffff8124b19e>] ? inode_wait_for_writeback+0x1e/0x40=

[  318.527031]  [<ffffffff81246f8d>] ? __inode_wait_for_writeback+0x6d/0x=
c0
[  318.527031]  [<ffffffff81305118>] hugetlbfs_evict_inode+0x18/0x40
[  318.527031]  [<ffffffff8123852b>] evict+0xab/0x180
[  318.527031]  [<ffffffff81238e7b>] iput+0x19b/0x200
[  318.527031]  [<ffffffff8122b8c9>] do_unlinkat+0x1e9/0x310
[  318.527031]  [<ffffffff817b25f9>] ? ret_from_sys_call+0x24/0x63
[  318.527031]  [<ffffffff810e274d>] ? trace_hardirqs_on_caller+0xfd/0x1c=
0
[  318.527031]  [<ffffffff813ad73b>] ? trace_hardirqs_on_thunk+0x17/0x19
[  318.527031]  [<ffffffff8122cac6>] SyS_unlink+0x16/0x20
[  318.527031]  [<ffffffff817b25d0>] system_call_fastpath+0x12/0x17
[  318.527031] Code: 00 00 48 83 f8 01 19 c0 25 01 fe ff ff 05 00 02 00 0=
0 39 d0 0f 8e 92 fe ff ff 48 63 c2 48 c1 e0 06 48 01 d8 8b 40 18 85 c0 78=
 c4 <0f> 0b 48 8b 43 30 e9 7b fd ff ff e8 aa e6 5f 00 80 3d c0 d8 b5=20
[  318.527031] RIP  [<ffffffff811a74dc>] __delete_from_page_cache+0x2ec/0=
x350
[  318.527031]  RSP <ffff880078bc3c58>
[  318.527031] ---[ end trace 4595a8f53048ea33 ]---
[  320.670687] ------------[ cut here ]------------

And:

[ 4309.839683] page:ffffea0000000640 count:0 mapcount:0 mapping:00000000f=
fffffff index:0x0 compound_mapcount: 0
[ 4309.842296] flags: 0x1ffc0000008000(tail)
[ 4309.843253] page dumped because: VM_BUG_ON_PAGE(PageTail(page))
[ 4309.845357] ------------[ cut here ]------------
[ 4309.846306] kernel BUG at include/linux/page-flags.h:438!
[ 4309.846306] invalid opcode: 0000 [#3] SMP=20
[ 4309.846306] Modules linked in: binfmt_misc loop ip6t_rpfilter ip6t_REJ=
ECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_=
defrag_ipv4 xt_conntrack nf_conntrack ebtable_nat ebtable_broute bridge s=
tp llc ebtable_filter ebtables ip6table_mangle ip6table_security ip6table=
_raw ip6table_filter ip6_tables iptable_mangle iptable_security iptable_r=
aw crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel ppdev m=
icrocode joydev virtio_console pcspkr serio_raw virtio_balloon parport_pc=
 parport nfsd pvpanic i2c_piix4 acpi_cpufreq auth_rpcgss nfs_acl lockd gr=
ace sunrpc qxl virtio_blk virtio_net drm_kms_helper ttm drm virtio_pci vi=
rtio_ring virtio ata_generic pata_acpi floppy
[ 4309.851030] CPU: 1 PID: 30932 Comm: proc01 Tainted: G      D         4=
=2E0.0-rc1-next-20150227+ #213
[ 4309.851030] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 4309.851030] task: ffff88007c883600 ti: ffff8800237e0000 task.ti: ffff8=
800237e0000
[ 4309.851030] RIP: 0010:[<ffffffff81299d7c>]  [<ffffffff81299d7c>] stabl=
e_page_flags+0x30c/0x330
[ 4309.851030] RSP: 0018:ffff8800237e3e08  EFLAGS: 00010292
[ 4309.851030] RAX: 0000000000000033 RBX: 0000000000000800 RCX: 000000000=
0000000
[ 4309.851030] RDX: 0000000000000001 RSI: ffff88007fd0e438 RDI: ffff88007=
fd0e438
[ 4309.851030] RBP: ffff8800237e3e28 R08: 0000000000000001 R09: 000000000=
0000001
[ 4309.851030] R10: 0000000000000000 R11: 0000000000000000 R12: 001ffc000=
0008000
[ 4309.851030] R13: ffffea0000000640 R14: 0000000000000019 R15: 000000000=
0629508
[ 4309.851030] FS:  00007f8fa69c7700(0000) GS:ffff88007fd00000(0000) knlG=
S:0000000000000000
[ 4309.851030] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 4309.851030] CR2: 00007f129037c750 CR3: 0000000078c79000 CR4: 000000000=
01407e0
[ 4309.851030] Stack:
[ 4309.851030]  ffffffff811d4d82 ffffea0000000640 0000000000000338 ffffea=
0000000640
[ 4309.851030]  ffff8800237e3e78 ffffffff81299e67 0000000000629440 ffff88=
00237e3f20
[ 4309.851030]  ffff8800784b8a90 ffff88007c01c300 ffff8800784b8a80 ffff88=
00237e3f20
[ 4309.851030] Call Trace:
[ 4309.851030]  [<ffffffff811d4d82>] ? might_fault+0x42/0xa0
[ 4309.851030]  [<ffffffff81299e67>] kpageflags_read+0xc7/0x140
[ 4309.851030]  [<ffffffff8128a4fd>] proc_reg_read+0x3d/0x80
[ 4309.851030]  [<ffffffff81219ec6>] ? rw_verify_area+0x56/0xe0
[ 4309.851030]  [<ffffffff8121a9b8>] __vfs_read+0x18/0x50
[ 4309.851030]  [<ffffffff8121aa76>] vfs_read+0x86/0x140
[ 4309.851030]  [<ffffffff8121ab79>] SyS_read+0x49/0xb0
[ 4309.851030]  [<ffffffff817b25d0>] system_call_fastpath+0x12/0x17
[ 4309.851030] Code: 63 c2 48 c1 e0 06 4c 01 e8 8b 40 18 85 c0 79 26 83 c=
2 01 49 8b 45 00 f6 c4 80 74 c6 48 c7 c6 38 49 a5 81 4c 89 ef e8 84 95 f3=
 ff <0f> 0b 48 8b 50 30 e9 e2 fe ff ff bb 00 08 00 00 e9 0d fd ff ff=20
[ 4309.851030] RIP  [<ffffffff81299d7c>] stable_page_flags+0x30c/0x330
[ 4309.851030]  RSP <ffff8800237e3e08>
[ 4310.285652] ---[ end trace 4595a8f53048ea35 ]---

I'll try to find out which tests triggered the bugs.

Thanks,
Jerome



--3PKTrlIjgDimorj7IpXoSH9gUJuclEhuw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJU+FIzAAoJEHTzHJCtsuoCo2UH/0S2qPc0WH4jaU/afBM/pHdS
8iJV2lDbf6iWhAwJLMiNwPrQRT/2eFIMG3LHPVIhHcG/bMnQg7/B6xcU7hNyh9gR
aZdAJ2hbEJ+Bnsx0qrGDF2/xZYkijKzt0nmwQ19UZKCAOqy8Sh/5lXPIBDCUX7UE
sTRhxTWK+t8mO1lyGt8SBLhtJghsl99DVFs5AVO7OKZ/9Kb8aVBPsqdhCpF9j0mF
xpNZ4Q9QTGyU0UkEzZZTuhLqc3Z3HPZtPh1qUI67yi7LsGGZWGLY0EGW/3m9lPdL
Y73hAC1PXoVf23V7P3JIcri4xDS6gscqN9C8VBvVEEuNoz8lC8n/d7BAuMCQnHs=
=8EYG
-----END PGP SIGNATURE-----

--3PKTrlIjgDimorj7IpXoSH9gUJuclEhuw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
