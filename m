Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5056B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 11:24:52 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id b205so117670111wmb.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 08:24:52 -0800 (PST)
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com. [195.75.94.101])
        by mx.google.com with ESMTPS id z2si34404135wmz.40.2016.02.16.08.24.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 08:24:50 -0800 (PST)
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Tue, 16 Feb 2016 16:24:49 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 97C021B0806E
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 16:25:03 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1GGOlkd58327040
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 16:24:47 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1GGOkVI013916
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 11:24:47 -0500
Date: Tue, 16 Feb 2016 17:24:44 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe
 also on PowerPC and ARM)
Message-ID: <20160216172444.013988d8@thinkpad>
In-Reply-To: <20160215213526.GA9766@node.shutemov.name>
References: <20160211192223.4b517057@thinkpad>
	<20160211190942.GA10244@node.shutemov.name>
	<20160211205702.24f0d17a@thinkpad>
	<20160212154116.GA15142@node.shutemov.name>
	<56BE00E7.1010303@de.ibm.com>
	<20160212181640.4eabb85f@thinkpad>
	<20160212231510.GB15142@node.shutemov.name>
	<alpine.LFD.2.20.1602131238260.1910@schleppi>
	<20160215113159.GA28832@node.shutemov.name>
	<20160215193702.4a15ed5e@thinkpad>
	<20160215213526.GA9766@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Sebastian Ott <sebott@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org

On Mon, 15 Feb 2016 23:35:26 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Mon, Feb 15, 2016 at 07:37:02PM +0100, Gerald Schaefer wrote:
> > On Mon, 15 Feb 2016 13:31:59 +0200
> > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> >=20
> > > On Sat, Feb 13, 2016 at 12:58:31PM +0100, Sebastian Ott wrote:
> > > >=20
> > > > On Sat, 13 Feb 2016, Kirill A. Shutemov wrote:
> > > > > Could you check if revert of fecffad25458 helps?
> > > >=20
> > > > I reverted fecffad25458 on top of 721675fcf277cf - it oopsed with:
> > > >=20
> > > > =C2=A2 1851.721062! Unable to handle kernel pointer dereference in =
virtual kernel address space
> > > > =C2=A2 1851.721075! failing address: 0000000000000000 TEID: 0000000=
000000483
> > > > =C2=A2 1851.721078! Fault in home space mode while using kernel ASC=
E.
> > > > =C2=A2 1851.721085! AS:0000000000d5c007 R3:00000000ffff0007 S:00000=
000ffffa800 P:000000000000003d
> > > > =C2=A2 1851.721128! Oops: 0004 ilc:3 =C2=A2#1! PREEMPT SMP DEBUG_PA=
GEALLOC
> > > > =C2=A2 1851.721135! Modules linked in: bridge stp llc btrfs mlx4_ib=
 mlx4_en ib_sa ib_mad vxlan xor ip6_udp_tunnel ib_core udp_tunnel ptp pps_c=
ore ib_addr ghash_s390raid6_pq prng ecb aes_s390 mlx4_core des_s390 des_gen=
eric genwqe_card sha512_s390 sha256_s390 sha1_s390 sha_common crc_itu_t dm_=
mod scm_block vhost_net tun vhost eadm_sch macvtap macvlan kvm autofs4
> > > > =C2=A2 1851.721183! CPU: 7 PID: 256422 Comm: bash Not tainted 4.5.0=
-rc3-00058-g07923d7-dirty #178
> > > > =C2=A2 1851.721186! task: 000000007fbfd290 ti: 000000008c604000 tas=
k.ti: 000000008c604000
> > > > =C2=A2 1851.721189! Krnl PSW : 0704d00180000000 000000000045d3b8 (_=
_rb_erase_color+0x280/0x308)
> > > > =C2=A2 1851.721200!            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 =
AS:3 CC:1 PM:0 EA:3
> > > >                Krnl GPRS: 0000000000000001 0000000000000020 0000000=
000000000 00000000bd07eff1
> > > > =C2=A2 1851.721205!            000000000027ca10 0000000000000000 00=
00000083e45898 0000000077b61198
> > > > =C2=A2 1851.721207!            000000007ce1a490 00000000bd07eff0 00=
0000007ce1a548 000000000027ca10
> > > > =C2=A2 1851.721210!            00000000bd07c350 00000000bd07eff0 00=
0000008c607aa8 000000008c607a68
> > > > =C2=A2 1851.721221! Krnl Code: 000000000045d3aa: e3c0d0080024      =
 stg     %%r12,8(%%r13)
> > > >                           000000000045d3b0: b9040039           lgr =
    %%r3,%%r9
> > > >                          #000000000045d3b4: a53b0001           oill=
    %%r3,1
> > > >                          >000000000045d3b8: e33010000024       stg =
    %%r3,0(%%r1)
> > > >                           000000000045d3be: ec28000e007c       cgij=
    %%r2,0,8,45d3da
> > > >                           000000000045d3c4: e34020000004       lg  =
    %%r4,0(%%r2)
> > > >                           000000000045d3ca: b904001c           lgr =
    %%r1,%%r12
> > > >                           000000000045d3ce: ec143f3f0056       rosb=
g   %%r1,%%r4,63,63,0
> > > > =C2=A2 1851.721269! Call Trace:
> > > > =C2=A2 1851.721273! (=C2=A2<0000000083e45898>! 0x83e45898)
> > > > =C2=A2 1851.721279!  =C2=A2<000000000029342a>! unlink_anon_vmas+0x9=
a/0x1d8
> > > > =C2=A2 1851.721282!  =C2=A2<0000000000283f34>! free_pgtables+0xcc/0=
x148
> > > > =C2=A2 1851.721285!  =C2=A2<000000000028c376>! exit_mmap+0xd6/0x300
> > > > =C2=A2 1851.721289!  =C2=A2<0000000000134db8>! mmput+0x90/0x118
> > > > =C2=A2 1851.721294!  =C2=A2<00000000002d76bc>! flush_old_exec+0x5d4=
/0x700
> > > > =C2=A2 1851.721298!  =C2=A2<00000000003369f4>! load_elf_binary+0x2f=
4/0x13e8
> > > > =C2=A2 1851.721301!  =C2=A2<00000000002d6e4a>! search_binary_handle=
r+0x9a/0x1f8
> > > > =C2=A2 1851.721304!  =C2=A2<00000000002d8970>! do_execveat_common.i=
sra.32+0x668/0x9a0
> > > > =C2=A2 1851.721307!  =C2=A2<00000000002d8cec>! do_execve+0x44/0x58
> > > > =C2=A2 1851.721310!  =C2=A2<00000000002d8f92>! SyS_execve+0x3a/0x48
> > > > =C2=A2 1851.721315!  =C2=A2<00000000006fb096>! system_call+0xd6/0x2=
58
> > > > =C2=A2 1851.721317!  =C2=A2<000003ff997436d6>! 0x3ff997436d6
> > > > =C2=A2 1851.721319! INFO: lockdep is turned off.
> > > > =C2=A2 1851.721321! Last Breaking-Event-Address:
> > > > =C2=A2 1851.721323!  =C2=A2<000000000045d31a>! __rb_erase_color+0x1=
e2/0x308
> > > > =C2=A2 1851.721327!
> > > > =C2=A2 1851.721329! ---=C2=A2 end trace 0d80041ac00cfae2 !---
> > > >=20
> > > >=20
> > > > >=20
> > > > > And could you share how crashes looks like? I haven't seen backtr=
aces yet.
> > > > >=20
> > > >=20
> > > > Sure. I didn't because they really looked random to me. Most of the=
 time
> > > > in rcu or list debugging but I thought these have just been the mes=
senger
> > > > observing a corruption first. Anyhow, here is an older one that mig=
ht look
> > > > interesting:
> > > >=20
> > > > [   59.851421] list_del corruption. next->prev should be 000000006e=
1eb000, but was 0000000000000400
> > >=20
> > > This kinda interesting: 0x400 is TAIL_MAPPING.. Hm..
> > >=20
> > > Could you check if you see the problem on commit 1c290f642101 and its
> > > immediate parent?
> > >=20
> >=20
> > How should the page->mapping poison end up as next->prev in the list of
> > pre-allocated THP splitting page tables?
>=20
> May be pgtable was casted to struct page or something. I don't know.
>=20
> > Also, commit 1c290f642101 is before the THP rework, at least the
> > non-bisectable part, so we should expect not to see the problem there.
>=20
> Just to make sure: commit 122afea9626a is fine, commit 61f5d698cc97
> crashes. Correct?
>=20
> > 0x400 is also the value of an empty pte on s390, and the thp_deposit/wi=
thdraw
> > listheads are placed inside the pre-allocated pagetables instead of pag=
e->lru,
> > because we have 2K pagetables on s390 and cannot use struct page =3D=3D=
 pgtable_t.
>=20
> 0x400 from empty pte makes more sense than TAIL_MAPPING. But I guess it
> worth changing TAIL_MAPPING to some other value to make sure.

Right, but we cannot trigger this list corruption symptom reliably, in fact
I didn't hit it at all during the last runs, and previous crash logs also
showed list corruptions with other values than 0x400, which may hint towards
concurrent pagetable freeing and re-use, given that our THP splitting paget=
able
listhead is located inside the pre-allocated pagetables.

>=20
> > So, for example, two concurrent withdraws could produce such a list
> > corruption, because the first withdraw will overwrite the listhead at t=
he
> > beginning of the pagetable with 2 empty ptes.
> >=20
> > Has anything changed regarding the general THP deposit/withdraw logic?
>=20
> I don't see any changes in this area.
>=20
> To eliminate one more variable, I would propose to disable split pmd lock
> for testing and check if it makes difference.

Disabling ARCH_ENABLE_SPLIT_PMD_PTLOCK didn't make any difference, other
than maybe a little reduction in "randomness" of the crashes, but that
may be pure coincidence. Out of about 10 runs, I always ended up with either
ODEBUG "WARNING: at lib/debugobjects.c:263" and subsequent "kernel BUG at
mm/slub.c:3629", or "bad swap file / page map" with subsequent "kernel BUG
at kernel/cred.c:142", see below for the full traces.

>=20
> Is there any chance that I'll be able to trigger the bug using QEMU?
> Does anybody have an QEMU image I can use?
>=20

I have no image, but trying to reproduce this under virtualization may
help to trigger this also on other architectures. After ruling out IPI
vs. fast_gup I do not really see why this should be arch-specific, and
it wouldn't be the first time that we hit subtle races first on s390, due
to our virtualized environment (my test case is make -j20 with 10 CPUs and
4GB of memory, no swap).


Here are the full traces from the runs w/o split pmd lock:

1)

[ 2584.391880] cc1 (71885) used greatest stack depth: 10496 bytes left
[ 2951.268250] ld (147667) used greatest stack depth: 10472 bytes left
[ 2972.530753] swap_free: Bad swap file entry 1000000000000000
[ 2972.530763] BUG: Bad page map in process cc1  pte:00000420 pmd:6cfd3000
[ 2972.530766] addr:0000000080d00000 vm_flags:00000875 anon_vma:          (=
null) mapping:000000005dc6ac70 index
:d00
[ 2972.530776] file:cc1 fault:ext4_filemap_fault mmap:ext4_file_mmap readpa=
ge:ext4_readpage
[ 2972.530781] CPU: 6 PID: 152043 Comm: cc1 Not tainted 4.5.0-rc4-00014-g19=
26e54-dirty #70
[ 2972.530784]        0000000071947a60 0000000071947af0 0000000000000002 00=
00000000000000=20
                      0000000071947b90 0000000071947b08 0000000071947b08 00=
00000000113d38=20
                      0000000000000000 0000000000b70df4 0000000000b4f348 00=
0000000000000b=20
                      0000000071947b50 0000000071947af0 0000000000000000 00=
00000000000000=20
                      07000000c3763ae8 0000000000113d38 0000000071947af0 00=
00000071947b50=20
[ 2972.530811] Call Trace:
[ 2972.530818] ([<0000000000113c3c>] show_trace+0x12c/0x150)
[ 2972.530821]  [<0000000000113cee>] show_stack+0x8e/0xf0
[ 2972.530826]  [<000000000068b8ec>] dump_stack+0x9c/0xe0
[ 2972.530830]  [<00000000002bbeda>] print_bad_pte+0x222/0x238
[ 2972.530833]  [<00000000002beb92>] zap_pte_range+0x442/0x790
[ 2972.530835]  [<00000000002bf2c6>] unmap_single_vma+0x3e6/0x400
[ 2972.530837]  [<00000000002c0f46>] unmap_vmas+0x8e/0xc8
[ 2972.530840]  [<00000000002c9a56>] exit_mmap+0xc6/0x300
[ 2972.530844]  [<0000000000138b10>] mmput+0xa0/0x128
[ 2972.530847]  [<000000000013fcb4>] do_exit+0x42c/0xd60
[ 2972.530849]  [<00000000001406f0>] do_group_exit+0x98/0xe0
[ 2972.530851]  [<0000000000140768>] __wake_up_parent+0x0/0x28
[ 2972.530855]  [<0000000000910f2e>] system_call+0xd6/0x270
[ 2972.530883]  [<000003ff89b43698>] 0x3ff89b43698
[ 2972.530886] 1 lock held by cc1/152043:
[ 2972.530887]  #0:  (&(ptlock_ptr(page))->rlock){+.+.-.}, at: [<0000000000=
2be7f6>] zap_pte_range+0xa6/0x790
[ 2972.530897] Disabling lock debugging due to kernel taint
[ 2972.533069] BUG: Bad rss-counter state mm:00000000719d0e00 idx:2 val:-1
[ 5899.109157] ------------[ cut here ]------------
[ 5899.109166] kernel BUG at kernel/cred.c:142!
[ 5899.109211] illegal operation: 0001 ilc:1 [#1] PREEMPT SMP DEBUG_PAGEALL=
OC
[ 5899.109217] Modules linked in: nf_conntrack_ipv4 nf_defrag_ipv4 xt_connt=
rack nf_conntrack ipt_REJECT nf_reject_ipv4 xt_tcpudp iptable_filter ip_tab=
les x_tables bridge stp llc mlx4_ib ib_sa ib_mad mlx4_en ib_core vxlan udp_=
tunnel ptp ib_addr pps_core ghash_s390 prng ecb aes_s390 des_s390 des_gener=
ic sha512_s390 sha256_s390 sha1_s390 sha_common mlx4_core eadm_sch nfsd vho=
st_net tun vhost macvtap auth_rpcgss macvlan kvm oid_registry nfs_acl lockd=
 grace sunrpc dm_multipath dm_mod autofs4
[ 5899.109279] CPU: 1 PID: 12 Comm: ksoftirqd/1 Tainted: G    B           4=
.5.0-rc4-00014-g1926e54-dirty #70
[ 5899.109283] task: 00000000d09e2a48 ti: 00000000d09f4000 task.ti: 0000000=
0d09f4000
[ 5899.109286] Krnl PSW : 0704c00180000000 00000000001651aa (__put_cred+0x2=
2/0x68)
[ 5899.109296]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:0 PM:=
0 EA:3
               Krnl GPRS: 0000000000000002 0000000000000020 000000007431f00=
0 00000000c38e3400
[ 5899.109301]            000000000032aaf8 0000000000000002 000000000000000=
0 000000000000000a
[ 5899.109304]            0000000000000000 000000000032aac0 000000000000000=
8 00000000749ad000
[ 5899.109306]            00000000c38e3400 000000007431f000 000000000032ab2=
e 00000000d09f7bf0
[ 5899.109316] Krnl Code: 000000000016519c: 58102004            l       %%r=
1,4(%%r2)
                          00000000001651a0: ec180005007e        cij     %%r=
1,0,8,1651aa
                         #00000000001651a6: a7f40001            brc     15,=
1651a8
                         >00000000001651aa: e3e020080024        stg     %%r=
14,8(%%r2)
                          00000000001651b0: c01944656144        iilf    %%r=
1,1147494724
                          00000000001651b6: 50102010            st      %%r=
1,16(%%r2)
                          00000000001651ba: e31003100004        lg      %%r=
1,784
                          00000000001651c0: e32018300020        cg      %%r=
2,2096(%%r1)
[ 5899.109371] Call Trace:
[ 5899.109376] ([<000000000032aaf8>] file_free_rcu+0x38/0x88)
[ 5899.109381]  [<00000000001c5ddc>] rcu_process_callbacks+0x5fc/0x9f0
[ 5899.109385]  [<0000000000141794>] __do_softirq+0x25c/0x570
[ 5899.109387]  [<0000000000141ae6>] run_ksoftirqd+0x3e/0xa0
[ 5899.109391]  [<0000000000167bee>] smpboot_thread_fn+0x30e/0x360
[ 5899.109394]  [<0000000000162f4a>] kthread+0x112/0x128
[ 5899.109398]  [<00000000009110fa>] kernel_thread_starter+0x6/0xc
[ 5899.109401]  [<00000000009110f4>] kernel_thread_starter+0x0/0xc
[ 5899.109403] INFO: lockdep is turned off.
[ 5899.109405] Last Breaking-Event-Address:
[ 5899.109407]  [<00000000001651a6>] __put_cred+0x1e/0x68
[ 5899.109411] =20
[ 5899.109414] Kernel panic - not syncing: Fatal exception in interrupt


2)

[ 7790.934295] ODEBUG: active_state not available (active state 0) object t=
ype: rcu_head hint:           (null)
[ 7790.934356] ------------[ cut here ]------------
[ 7790.934359] WARNING: at lib/debugobjects.c:263
[ 7790.934361] Modules linked in: nf_conntrack_ipv4 nf_defrag_ipv4 xt_connt=
rack nf_conntrack mlx4_ib ib_sa ipt_REJECT mlx4_en ib_mad nf_reject_ipv4 ib=
_core vxlan udp_tunnel ptp xt_tcpudp ib_addr pps_core iptable_filter ip_tab=
les x_tables bridge stp llc ghash_s390 prng ecb aes_s390 des_s390 des_gener=
ic sha512_s390 sha256_s390 mlx4_core sha1_s390 sha_common eadm_sch vhost_ne=
t nfsd tun vhost macvtap macvlan auth_rpcgss kvm oid_registry nfs_acl lockd=
 grace sunrpc dm_multipath dm_mod autofs4
[ 7790.934417] CPU: 8 PID: 40 Comm: ksoftirqd/8 Not tainted 4.5.0-rc4-00014=
-g1926e54-dirty #149
[ 7790.934420] task: 00000000e2955490 ti: 00000000e2958000 task.ti: 0000000=
0e2958000
[ 7790.934422] Krnl PSW : 0404c00180000000 000000000071c340 (debug_print_ob=
ject+0xb0/0xd0)
[ 7790.934431]            R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:3 CC:0 PM:=
0 EA:3
               Krnl GPRS: 0000000001e6e3c7 00000000e2955490 000000000000006=
0 00000000e2958000
[ 7790.934435]            000000000071c33c 0000000000000000 0000000000b975e=
8 0000000001f2b008
[ 7790.934437]            07000000001d7e24 0000000000000000 0000000001f2b01=
0 0000000000bea6b8
[ 7790.934440]            0000000000e241f8 00000000e295bc38 000000000071c33=
c 00000000e295bb38
[ 7790.934449] Krnl Code: 000000000071c330: c41f00bf6a14        strl    %%r=
1,1f09758
                          000000000071c336: c0e5ffdbd64d        brasl   %%r=
14,296fd0
                         #000000000071c33c: a7f40001            brc     15,=
71c33e
                         >000000000071c340: c41d0036e746        lrl     %%r=
1,df91cc
                          000000000071c346: e340f0e80004        lg      %%r=
4,232(%%r15)
                          000000000071c34c: a71a0001            ahi     %%r=
1,1
                          000000000071c350: eb6ff0a80004        lmg     %%r=
6,%%r15,168(%%r15)
                          000000000071c356: c41f0036e73b        strl    %%r=
1,df91cc
[ 7790.934493] Call Trace:
[ 7790.934495] ([<000000000071c33c>] debug_print_object+0xac/0xd0)
[ 7790.934498]  [<000000000071d704>] debug_object_active_state+0x164/0x178
[ 7790.934504]  [<00000000001d7da4>] rcu_process_callbacks+0x57c/0xa00
[ 7790.934508]  [<00000000001487ec>] __do_softirq+0x26c/0x580
[ 7790.934510]  [<0000000000148b50>] run_ksoftirqd+0x50/0xb0
[ 7790.934515]  [<0000000000172b28>] smpboot_thread_fn+0x320/0x378
[ 7790.934517]  [<000000000016d21c>] kthread+0x124/0x138
[ 7790.934521]  [<00000000009a1d72>] kernel_thread_starter+0x6/0xc
[ 7790.934524]  [<00000000009a1d6c>] kernel_thread_starter+0x0/0xc
[ 7790.934526] 1 lock held by ksoftirqd/8/40:
[ 7790.934528]  #0:  (&obj_hash[i].lock){-.-.-.}, at: [<000000000071d64c>] =
debug_object_active_state+0xac/0x178
[ 7790.934535] Last Breaking-Event-Address:
[ 7790.934537]  [<000000000071c33c>] debug_print_object+0xac/0xd0
[ 7790.934539] ---[ end trace b583bfd967a78637 ]---
[ 7790.934543] ODEBUG: deactivate not available (active state 0) object typ=
e: rcu_head hint:           (null)
[ 7790.934551] ------------[ cut here ]------------
[ 7790.934553] WARNING: at lib/debugobjects.c:263
[ 7790.934555] Modules linked in: nf_conntrack_ipv4 nf_defrag_ipv4 xt_connt=
rack nf_conntrack mlx4_ib ib_sa ipt_REJECT mlx4_en ib_mad nf_reject_ipv4 ib=
_core vxlan udp_tunnel ptp xt_tcpudp ib_addr pps_core iptable_filter ip_tab=
les x_tables bridge stp llc ghash_s390 prng ecb aes_s390 des_s390 des_gener=
ic sha512_s390 sha256_s390 mlx4_core sha1_s390 sha_common eadm_sch vhost_ne=
t nfsd tun vhost macvtap macvlan auth_rpcgss kvm oid_registry nfs_acl lockd=
 grace sunrpc dm_multipath dm_mod autofs4
[ 7790.934599] CPU: 8 PID: 40 Comm: ksoftirqd/8 Tainted: G        W       4=
.5.0-rc4-00014-g1926e54-dirty #149
[ 7790.934601] task: 00000000e2955490 ti: 00000000e2958000 task.ti: 0000000=
0e2958000
[ 7790.934603] Krnl PSW : 0404c00180000000 000000000071c340 (debug_print_ob=
ject+0xb0/0xd0)
[ 7790.934608]            R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:3 CC:0 PM:=
0 EA:3
               Krnl GPRS: 0000000001e6e3c7 00000000e2955490 000000000000005=
e 00000000e2958000
[ 7790.934612]            000000000071c33c 0000000000000000 0000000000b975e=
8 000000000000000a
[ 7790.934614]            0000000004bcd020 0700000001f2b010 0000000001f2b01=
0 0000000000ba5d0a
[ 7790.934617]            0000000000e241f8 00000000e295bc48 000000000071c33=
c 00000000e295bb48
[ 7790.934622] Krnl Code: 000000000071c330: c41f00bf6a14        strl    %%r=
1,1f09758
                          000000000071c336: c0e5ffdbd64d        brasl   %%r=
14,296fd0
                         #000000000071c33c: a7f40001            brc     15,=
71c33e
                         >000000000071c340: c41d0036e746        lrl     %%r=
1,df91cc
                          000000000071c346: e340f0e80004        lg      %%r=
4,232(%%r15)
                          000000000071c34c: a71a0001            ahi     %%r=
1,1
                          000000000071c350: eb6ff0a80004        lmg     %%r=
6,%%r15,168(%%r15)
                          000000000071c356: c41f0036e73b        strl    %%r=
1,df91cc
[ 7790.934639] Call Trace:
[ 7790.934641] ([<000000000071c33c>] debug_print_object+0xac/0xd0)
[ 7790.934644]  [<000000000071d0a8>] debug_object_deactivate+0x170/0x188
[ 7790.934646]  [<00000000001d7db6>] rcu_process_callbacks+0x58e/0xa00
[ 7790.934648]  [<00000000001487ec>] __do_softirq+0x26c/0x580
[ 7790.934651]  [<0000000000148b50>] run_ksoftirqd+0x50/0xb0
[ 7790.934653]  [<0000000000172b28>] smpboot_thread_fn+0x320/0x378
[ 7790.934655]  [<000000000016d21c>] kthread+0x124/0x138
[ 7790.934657]  [<00000000009a1d72>] kernel_thread_starter+0x6/0xc
[ 7790.934659]  [<00000000009a1d6c>] kernel_thread_starter+0x0/0xc
[ 7790.934661] 1 lock held by ksoftirqd/8/40:
[ 7790.934663]  #0:  (&obj_hash[i].lock){-.-.-.}, at: [<000000000071cfdc>] =
debug_object_deactivate+0xa4/0x188
[ 7790.934669] Last Breaking-Event-Address:
[ 7790.934671]  [<000000000071c33c>] debug_print_object+0xac/0xd0
[ 7790.934673] ---[ end trace b583bfd967a78638 ]---
[ 7790.934680] ------------[ cut here ]------------
[ 7790.934682] kernel BUG at mm/slub.c:3629!
[ 7790.934707] illegal operation: 0001 ilc:1 [#1] PREEMPT SMP DEBUG_PAGEALL=
OC
[ 7790.934715] Modules linked in: nf_conntrack_ipv4 nf_defrag_ipv4 xt_connt=
rack nf_conntrack mlx4_ib ib_sa ipt_REJECT mlx4_en ib_mad nf_reject_ipv4 ib=
_core vxlan udp_tunnel ptp xt_tcpudp ib_addr pps_core iptable_filter ip_tab=
les x_tables bridge stp llc ghash_s390 prng ecb aes_s390 des_s390 des_gener=
ic sha512_s390 sha256_s390 mlx4_core sha1_s390 sha_common eadm_sch vhost_ne=
t nfsd tun vhost macvtap macvlan auth_rpcgss kvm oid_registry nfs_acl lockd=
 grace sunrpc dm_multipath dm_mod autofs4
[ 7790.934789] CPU: 8 PID: 40 Comm: ksoftirqd/8 Tainted: G        W       4=
.5.0-rc4-00014-g1926e54-dirty #149
[ 7790.934791] task: 00000000e2955490 ti: 00000000e2958000 task.ti: 0000000=
0e2958000
[ 7790.934794] Krnl PSW : 0704c00180000000 000000000032295a (kfree+0x3f2/0x=
428)
[ 7790.934801]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:0 PM:=
0 EA:3
               Krnl GPRS: 0000000000000000 0000000000000100 000000000000010=
0 0000000000e24260
[ 7790.934806]            00000000001d1c82 0000000000000000 000000000000000=
0 000000000000000a
[ 7790.934809]            0000000000000001 00000000001d7e0a 000000000000000=
6 000003d10012f340
[ 7790.934812]            0000000004bcd000 0000000000f0433c 000000000032267=
a 00000000e295bbb0
[ 7790.934818] Krnl Code: 000000000032294c: c0e50033bef6        brasl   %%r=
14,99a738
                          0000000000322952: a7f4feba            brc     15,=
3226c6
                         #0000000000322956: a7f40001            brc     15,=
322958
                         >000000000032295a: e310b0060090        llgc    %%r=
1,6(%%r11)
                          0000000000322960: a7110040            tmll    %%r=
1,64
                          0000000000322964: a774fee9            brc     7,3=
22736
                          0000000000322968: a7f4feeb            brc     15,=
32273e
                          000000000032296c: c0e50033be32        brasl   %%r=
14,99a5d0
[ 7790.934838] Call Trace:
[ 7790.934841] ([<000000000032267a>] kfree+0x112/0x428)
[ 7790.934844]  [<00000000001d7e0a>] rcu_process_callbacks+0x5e2/0xa00
[ 7790.934847]  [<00000000001487ec>] __do_softirq+0x26c/0x580
[ 7790.934850]  [<0000000000148b50>] run_ksoftirqd+0x50/0xb0
[ 7790.934854]  [<0000000000172b28>] smpboot_thread_fn+0x320/0x378
[ 7790.934856]  [<000000000016d21c>] kthread+0x124/0x138
[ 7790.934859]  [<00000000009a1d72>] kernel_thread_starter+0x6/0xc
[ 7790.934862]  [<00000000009a1d6c>] kernel_thread_starter+0x0/0xc
[ 7790.934864] INFO: lockdep is turned off.
[ 7790.934866] Last Breaking-Event-Address:
[ 7790.934869]  [<0000000000322956>] kfree+0x3ee/0x428
[ 7790.934873] =20
[ 7790.934876] Kernel panic - not syncing: Fatal exception in interrupt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
