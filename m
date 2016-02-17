Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id DBF236B0009
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 14:13:46 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id b205so169770028wmb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 11:13:46 -0800 (PST)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id gg9si3901362wjb.115.2016.02.17.11.13.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 11:13:45 -0800 (PST)
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 17 Feb 2016 19:13:45 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 0D55E17D8042
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 19:14:02 +0000 (GMT)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1HJDhmm43712684
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 19:13:43 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1HIDitd018078
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 11:13:45 -0700
Date: Wed, 17 Feb 2016 20:13:40 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe
 also on PowerPC and ARM)
Message-ID: <20160217201340.2dafad8d@thinkpad>
In-Reply-To: <alpine.LFD.2.20.1602131238260.1910@schleppi>
References: <20160211192223.4b517057@thinkpad>
	<20160211190942.GA10244@node.shutemov.name>
	<20160211205702.24f0d17a@thinkpad>
	<20160212154116.GA15142@node.shutemov.name>
	<56BE00E7.1010303@de.ibm.com>
	<20160212181640.4eabb85f@thinkpad>
	<20160212231510.GB15142@node.shutemov.name>
	<alpine.LFD.2.20.1602131238260.1910@schleppi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Ott <sebott@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org

On Sat, 13 Feb 2016 12:58:31 +0100 (CET)
Sebastian Ott <sebott@linux.vnet.ibm.com> wrote:

> [   59.875935] ------------[ cut here ]------------
> [   59.875937] kernel BUG at mm/huge_memory.c:2884!
> [   59.875979] illegal operation: 0001 ilc:1 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [   59.875986] Modules linked in: bridge stp llc btrfs xor mlx4_en vxlan ip6_udp_tunnel udp_tunnel mlx4_ib ptp pps_core ib_sa ib_mad ib_core ib_addr ghash_s390 prng raid6_pq ecb aes_s390 des_s390 des_generic sha512_s390 sha256_s390 sha1_s390 mlx4_core sha_common genwqe_card scm_block crc_itu_t vhost_net tun vhost dm_mod macvtap eadm_sch macvlan kvm autofs4
> [   59.876033] CPU: 2 PID: 5402 Comm: git Tainted: G        W       4.4.0-07794-ga4eff16-dirty #77
> [   59.876036] task: 00000000d2312948 ti: 00000000cfecc000 task.ti: 00000000cfecc000
> [   59.876039] Krnl PSW : 0704d00180000000 00000000002bf3aa (__split_huge_pmd_locked+0x562/0xa10)
> [   59.876045]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:1 PM:0 EA:3
>                Krnl GPRS: 0000000001a7a1cf 000003d10177c000 0000000000044068 000000005df00215
> [   59.876051]            0000000000000001 0000000000000001 0000000000000000 00000000774e6900
> [   59.876054]            000003ff52000000 000000006d403b10 000000006e1eb800 000003ff51f00000
> [   59.876058]            000003d10177c000 0000000000715190 00000000002bf234 00000000cfecfb58
> [   59.876068] Krnl Code: 00000000002bf39c: d507d010a000	clc	16(8,%%r13),0(%%r10)
>                           00000000002bf3a2: a7840004		brc	8,2bf3aa
>                          #00000000002bf3a6: a7f40001		brc	15,2bf3a8
>                          >00000000002bf3aa: 91407440		tm	1088(%%r7),64
>                           00000000002bf3ae: a7840208		brc	8,2bf7be
>                           00000000002bf3b2: a7f401e9		brc	15,2bf784
>                           00000000002bf3b6: 9104a006		tm	6(%%r10),4
>                           00000000002bf3ba: a7740004		brc	7,2bf3c2
> [   59.876089] Call Trace:
> [   59.876092] ([<00000000002bf234>] __split_huge_pmd_locked+0x3ec/0xa10)
> [   59.876095]  [<00000000002c4310>] __split_huge_pmd+0x118/0x218
> [   59.876099]  [<00000000002810e8>] unmap_single_vma+0x2d8/0xb40
> [   59.876102]  [<0000000000282d66>] zap_page_range+0x116/0x318
> [   59.876105]  [<000000000029b834>] SyS_madvise+0x23c/0x5e8
> [   59.876108]  [<00000000006f9f56>] system_call+0xd6/0x258
> [   59.876111]  [<000003ff9bbfd282>] 0x3ff9bbfd282
> [   59.876113] INFO: lockdep is turned off.
> [   59.876115] Last Breaking-Event-Address:
> [   59.876118]  [<00000000002bf3a6>] __split_huge_pmd_locked+0x55e/0xa10

The BUG at mm/huge_memory.c:2884 is interesting, it's the BUG_ON(!pte_none(*pte))
check in __split_huge_pmd_locked(). Obviously we expect the pre-allocated
pagetables to be empty, but in collapse_huge_page() we deposit the original
pagetable instead of allocating a new (empty) one. This saves an allocation,
which is good, but doesn't that mean that if such a collapsed hugepage will
ever be split, we will always run into the BUG_ON(!pte_none(*pte)), or one
of the two other VM_BUG_ONs in mm/huge_memory.c that check the same?

This behavior is not new, it was the same before the THP rework, so I do not
assume that it is related to the current problems, maybe with the exception
of this specific crash. I never saw the BUG at mm/huge_memory.c:2884 myself,
and the other crashes probably cannot be explained with this. Maybe I am
also missing something, but I do not see how collapse_huge_page() and the
(non-empty) pgtable deposit there can work out with the BUG_ON(!pte_none(*pte))
checks. Any thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
