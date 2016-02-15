Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 303EE6B0253
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 13:37:14 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id c200so126404105wme.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 10:37:14 -0800 (PST)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id q7si42562297wje.36.2016.02.15.10.37.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 15 Feb 2016 10:37:12 -0800 (PST)
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 15 Feb 2016 18:37:12 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id D1E3F17D805A
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 18:37:22 +0000 (GMT)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1FIb5D236831336
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 18:37:05 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1FIb4Pf027067
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 11:37:05 -0700
Date: Mon, 15 Feb 2016 19:37:02 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe
 also on PowerPC and ARM)
Message-ID: <20160215193702.4a15ed5e@thinkpad>
In-Reply-To: <20160215113159.GA28832@node.shutemov.name>
References: <20160211192223.4b517057@thinkpad>
	<20160211190942.GA10244@node.shutemov.name>
	<20160211205702.24f0d17a@thinkpad>
	<20160212154116.GA15142@node.shutemov.name>
	<56BE00E7.1010303@de.ibm.com>
	<20160212181640.4eabb85f@thinkpad>
	<20160212231510.GB15142@node.shutemov.name>
	<alpine.LFD.2.20.1602131238260.1910@schleppi>
	<20160215113159.GA28832@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Sebastian Ott <sebott@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org

On Mon, 15 Feb 2016 13:31:59 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Sat, Feb 13, 2016 at 12:58:31PM +0100, Sebastian Ott wrote:
> >=20
> > On Sat, 13 Feb 2016, Kirill A. Shutemov wrote:
> > > Could you check if revert of fecffad25458 helps?
> >=20
> > I reverted fecffad25458 on top of 721675fcf277cf - it oopsed with:
> >=20
> > =C2=A2 1851.721062! Unable to handle kernel pointer dereference in virt=
ual kernel address space
> > =C2=A2 1851.721075! failing address: 0000000000000000 TEID: 00000000000=
00483
> > =C2=A2 1851.721078! Fault in home space mode while using kernel ASCE.
> > =C2=A2 1851.721085! AS:0000000000d5c007 R3:00000000ffff0007 S:00000000f=
fffa800 P:000000000000003d
> > =C2=A2 1851.721128! Oops: 0004 ilc:3 =C2=A2#1! PREEMPT SMP DEBUG_PAGEAL=
LOC
> > =C2=A2 1851.721135! Modules linked in: bridge stp llc btrfs mlx4_ib mlx=
4_en ib_sa ib_mad vxlan xor ip6_udp_tunnel ib_core udp_tunnel ptp pps_core =
ib_addr ghash_s390raid6_pq prng ecb aes_s390 mlx4_core des_s390 des_generic=
 genwqe_card sha512_s390 sha256_s390 sha1_s390 sha_common crc_itu_t dm_mod =
scm_block vhost_net tun vhost eadm_sch macvtap macvlan kvm autofs4
> > =C2=A2 1851.721183! CPU: 7 PID: 256422 Comm: bash Not tainted 4.5.0-rc3=
-00058-g07923d7-dirty #178
> > =C2=A2 1851.721186! task: 000000007fbfd290 ti: 000000008c604000 task.ti=
: 000000008c604000
> > =C2=A2 1851.721189! Krnl PSW : 0704d00180000000 000000000045d3b8 (__rb_=
erase_color+0x280/0x308)
> > =C2=A2 1851.721200!            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3=
 CC:1 PM:0 EA:3
> >                Krnl GPRS: 0000000000000001 0000000000000020 00000000000=
00000 00000000bd07eff1
> > =C2=A2 1851.721205!            000000000027ca10 0000000000000000 000000=
0083e45898 0000000077b61198
> > =C2=A2 1851.721207!            000000007ce1a490 00000000bd07eff0 000000=
007ce1a548 000000000027ca10
> > =C2=A2 1851.721210!            00000000bd07c350 00000000bd07eff0 000000=
008c607aa8 000000008c607a68
> > =C2=A2 1851.721221! Krnl Code: 000000000045d3aa: e3c0d0080024       stg=
     %%r12,8(%%r13)
> >                           000000000045d3b0: b9040039           lgr     =
%%r3,%%r9
> >                          #000000000045d3b4: a53b0001           oill    =
%%r3,1
> >                          >000000000045d3b8: e33010000024       stg     =
%%r3,0(%%r1)
> >                           000000000045d3be: ec28000e007c       cgij    =
%%r2,0,8,45d3da
> >                           000000000045d3c4: e34020000004       lg      =
%%r4,0(%%r2)
> >                           000000000045d3ca: b904001c           lgr     =
%%r1,%%r12
> >                           000000000045d3ce: ec143f3f0056       rosbg   =
%%r1,%%r4,63,63,0
> > =C2=A2 1851.721269! Call Trace:
> > =C2=A2 1851.721273! (=C2=A2<0000000083e45898>! 0x83e45898)
> > =C2=A2 1851.721279!  =C2=A2<000000000029342a>! unlink_anon_vmas+0x9a/0x=
1d8
> > =C2=A2 1851.721282!  =C2=A2<0000000000283f34>! free_pgtables+0xcc/0x148
> > =C2=A2 1851.721285!  =C2=A2<000000000028c376>! exit_mmap+0xd6/0x300
> > =C2=A2 1851.721289!  =C2=A2<0000000000134db8>! mmput+0x90/0x118
> > =C2=A2 1851.721294!  =C2=A2<00000000002d76bc>! flush_old_exec+0x5d4/0x7=
00
> > =C2=A2 1851.721298!  =C2=A2<00000000003369f4>! load_elf_binary+0x2f4/0x=
13e8
> > =C2=A2 1851.721301!  =C2=A2<00000000002d6e4a>! search_binary_handler+0x=
9a/0x1f8
> > =C2=A2 1851.721304!  =C2=A2<00000000002d8970>! do_execveat_common.isra.=
32+0x668/0x9a0
> > =C2=A2 1851.721307!  =C2=A2<00000000002d8cec>! do_execve+0x44/0x58
> > =C2=A2 1851.721310!  =C2=A2<00000000002d8f92>! SyS_execve+0x3a/0x48
> > =C2=A2 1851.721315!  =C2=A2<00000000006fb096>! system_call+0xd6/0x258
> > =C2=A2 1851.721317!  =C2=A2<000003ff997436d6>! 0x3ff997436d6
> > =C2=A2 1851.721319! INFO: lockdep is turned off.
> > =C2=A2 1851.721321! Last Breaking-Event-Address:
> > =C2=A2 1851.721323!  =C2=A2<000000000045d31a>! __rb_erase_color+0x1e2/0=
x308
> > =C2=A2 1851.721327!
> > =C2=A2 1851.721329! ---=C2=A2 end trace 0d80041ac00cfae2 !---
> >=20
> >=20
> > >=20
> > > And could you share how crashes looks like? I haven't seen backtraces=
 yet.
> > >=20
> >=20
> > Sure. I didn't because they really looked random to me. Most of the time
> > in rcu or list debugging but I thought these have just been the messeng=
er
> > observing a corruption first. Anyhow, here is an older one that might l=
ook
> > interesting:
> >=20
> > [   59.851421] list_del corruption. next->prev should be 000000006e1eb0=
00, but was 0000000000000400
>=20
> This kinda interesting: 0x400 is TAIL_MAPPING.. Hm..
>=20
> Could you check if you see the problem on commit 1c290f642101 and its
> immediate parent?
>=20

How should the page->mapping poison end up as next->prev in the list of
pre-allocated THP splitting page tables? Also, commit 1c290f642101
is before the THP rework, at least the non-bisectable part, so we should
expect not to see the problem there.

0x400 is also the value of an empty pte on s390, and the thp_deposit/withdr=
aw
listheads are placed inside the pre-allocated pagetables instead of page->l=
ru,
because we have 2K pagetables on s390 and cannot use struct page =3D=3D pgt=
able_t.

So, for example, two concurrent withdraws could produce such a list
corruption, because the first withdraw will overwrite the listhead at the
beginning of the pagetable with 2 empty ptes.

Has anything changed regarding the general THP deposit/withdraw logic?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
