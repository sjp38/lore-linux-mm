Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D33C6C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:03:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 727892192C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:03:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="g99XmDGv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 727892192C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 196098E0005; Fri, 15 Feb 2019 17:03:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11DD58E0001; Fri, 15 Feb 2019 17:03:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED8B78E0004; Fri, 15 Feb 2019 17:03:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id B87038E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:03:50 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id c74so6924945ywc.9
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:03:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=PwAD888+nxx/Wnfyu0U2CK68HaihH5P14l67i4Nat7o=;
        b=jQ3cfXzpnm7Av91ZdPPyV4Dak1jJb8pKK/57WHLxjzJCSNgGxMv9pPEP4ha62EIhd+
         xlb/Ht5GcJD8GVxrkZfnZbTIx3LVHt+kg5X0f6953kSre/3kP2M/2pJqE7RZ0tq9psqy
         sGKGL4bVYW5PwM6ELQVz6eI2/s4pEnBnDw17J5EJA8QgVUf4RiL5P98PfgMSthTXEC8/
         DLH93rNOn1EL3/kuRlwqjF+7ykI3rEgFxMSHXtNIQmjXjJLPlTddw8MbnbZ/JPZvjF43
         5VYxKv+G2DYqRTrtNtOvbqYSq4dConj1MnMJt8qO3BdPk2ZmXq8BAwm/Mg5wlMGuJuMB
         7TDw==
X-Gm-Message-State: AHQUAuZDdwCFJaEYFdfpM4mNW2sU+BOXKtT0VmK5lDvd45kq3vggkLQZ
	AEpVPeovIgKkf+SI1jU3Q+Y16AQpRrLWzBfewnn9Cb8T9OnBHT0we7eIjULspus3uXpv5iQTyWO
	1lset0zpUXn4nbtZw7wc4sHPEb7RUNhK9pp/9hik1nfo3tWuIF4PybEeaJ/g18YI64g==
X-Received: by 2002:a81:3742:: with SMTP id e63mr9945106ywa.416.1550268230426;
        Fri, 15 Feb 2019 14:03:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYj2Xai2kqycv0pEaryPRYH4EkDLmEpWa8oZ1z6hnDpyWkD5ap7hEXkYlZz8u31zeGnJ4sq
X-Received: by 2002:a81:3742:: with SMTP id e63mr9945018ywa.416.1550268229303;
        Fri, 15 Feb 2019 14:03:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268229; cv=none;
        d=google.com; s=arc-20160816;
        b=ATtJnMQKj64Ka5uld68j6iojsa22XV7EaxvMoUrxytWfGrR8CVF/6OEFxMr2gPIqm8
         XJqxg3WhC/zSqy9Fml2aedmq2jmpImnW4SmPEVwQzDhNb2ERU0+F0nMzthjtZFHqiF1m
         Xwkx8J0ikccEnwqxoFv3i7fiB8/KsDmSMNthdb8RI82JAPNQjkQeh2zUhNHOykN+5db+
         Ngi2rpArcGR2mUppJSztkmoYasBSXzxwUhqXhQQj21sin5fwzH4DrDW1V9ufluTVZ5Xo
         qBv4vLL7EwzPmRO59EmcIGPsJLmoWrt0M0NWEjUJf9GKrOxdpmPkO1MUVMTjrpnP/yWF
         UxMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=PwAD888+nxx/Wnfyu0U2CK68HaihH5P14l67i4Nat7o=;
        b=QaALo9YTbP+e1UktlWg5cYCGddEnYJ00MLbuUpZ84kNsbeJusvncMmiLfwcqO5g3+9
         q83/ko540QRKkJamqZ0eonxFf5vsEG5YZRVd3/Df3rKyYYkdACwGDjTjbcuRzVEgRnfW
         JYdMrm85mLq9Ld10ObNP8ThDFw95REvNs2O6vC7iG3Mpq5HNG8N2rawP0Qy/vmK6giPw
         jXIjk7lpxChqpDNqzsCkrS5HX7lw0vB5pwzdiiaobQ5m81IVFurkC313tX/xmOe8DPhr
         BUv/484pPShv7PybH8qIL2VwEP/5bmCotQTJgWNBGqNMzSau3f7Pse93vlDx/ELEsrv0
         vptg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=g99XmDGv;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id j77si3145332ywj.230.2019.02.15.14.03.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:03:49 -0800 (PST)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=g99XmDGv;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6737470001>; Fri, 15 Feb 2019 14:03:51 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 15 Feb 2019 14:03:48 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 15 Feb 2019 14:03:48 -0800
Received: from nvrsysarch5.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 15 Feb
 2019 22:03:48 +0000
From: Zi Yan <ziy@nvidia.com>
To: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko
	<mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>, John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>, Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>, Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 00/31] Generating physically contiguous memory after page allocation
Date: Fri, 15 Feb 2019 14:03:03 -0800
Message-ID: <20190215220334.29298-1-ziy@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550268231; bh=PwAD888+nxx/Wnfyu0U2CK68HaihH5P14l67i4Nat7o=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-Originating-IP:X-ClientProxiedBy:Content-Type:
	 Content-Transfer-Encoding;
	b=g99XmDGvWJMJ51nDd2p1OlD8qzNJGklMnV68ZO7Hv8u4+Em+7TzNydsNiIk7UTRbR
	 buV2brDUEeLBn3z9xYshJo686JbO7x9Ut2T/YOUkGh1BJgAFeik2N7mhgpWx24rEJY
	 qcu5JeNDifh1t4ePu4zKi3zHcuJCdyrYangX19+U1l/iPTxHVRkJydaKb0unpLbEIk
	 U894BCIeGGR7qBadeIJqQJXlbJmMqzp7RiWNBdohDcQLbaHa1FYiRfMogHf5AEqa2j
	 6NqvFeUjSlPGDNr7SdUOEYeRPRZNeUHJxVi15UwG8nQtifStwBlwL5hAKg9L1ycQ4u
	 +dZdsdASgWEcQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

This patchset produces physically contiguous memory by moving in-use pages
without allocating any new pages. It targets two scenarios that complements
khugepaged use cases: 1) avoiding page reclaim and memory compaction when t=
he
system is under memory pressure because this patchset does not allocate any=
 new
pages, 2) generating pages larger than 2^MAX_ORDER without changing the bud=
dy
allocator.

To demonstrate its use, I add very basic 1GB THP support and enable promoti=
ng
512 2MB THPs to a 1GB THP in my patchset. Promoting 512 4KB pages to a 2MB
THP is also implemented.

The patches are on top of v5.0-rc5. They are posted as part of my upcoming
LSF/MM proposal.

Motivation=C2=A0
----=C2=A0

The goal of this patchset is to provide alternative way of generating physi=
cally
contiguous memory and making it available as arbitrary sized large pages. T=
his
patchset generates physically contiguous memory/arbitrary size pages after =
pages
are allocated by moving virtually-contiguous pages to become physically
contiguous at any size, thus it does not require changes to memory allocato=
rs.
On the other hand, it works only for moveable pages, so it also faces the s=
ame
fragmentation issues as memory compaction, i.e., if non-moveable pages spre=
ad
across the entire memory, this patchset can only generate contiguity betwee=
n
any two non-moveable pages.=C2=A0

Large pages and physically contiguous memory are important to devices, such=
 as
GPUs, FPGAs, NICs and RDMA controllers, because they can often achieve bett=
er
performance when operating on large pages. The same can be said of CPU
performance, of course, but there is an important difference: GPUs and
high-throughput devices often take a more severe performance hit, in the ev=
ent
of a TLB miss and subsequent page table walks, as compared to a CPU. The ef=
fect
is sufficiently large that such devices *really* want a highly reliable way=
 to
allocate large pages to minimize the number of potential TLB misses and the=
 time
spent on the induced page table walks.=C2=A0

Vendors (like Oracle, Mellanox, IBM, NVIDIA) are interested in generating
physically contiguous memory beyond THP sizes and looking for solutions [1]=
,[2],[3].
This patchset provides an alternative approach, compared to allocating
physically contiguous memory at page allocation time, to generating physica=
lly
contiguous memory after pages are allocated. This approach can avoid page
reclaim and memory compaction, which happen during the process of page
allocation, but still produces comparable physically contiguous memory.=C2=
=A0

In terms of THPs, it helps, but we are interested in even larger contiguous
ranges (or page size support) to further reduce the address translation ove=
rheads.
With this patchset, we can generate pages larger than PMD-level THPs withou=
t
requiring MAX_ORDER changes in the buddy allocators.=C2=A0


Patch structure=C2=A0
----=C2=A0

The patchset I developed to generate physically contiguous memory/arbitrary
sized pages merely moves pages around. There are three components in this
patchset:

1) a new page migration mechanism, called exchange pages, that exchanges th=
e
content of two in-use pages instead of performing two back-to-back page
migration. It saves on overheads and avoids page reclaim and memory compact=
ion
in the page allocation path, although it is not strictly required if enough
free memory is available in the system.

2) a new mechanism that utilizes both page migration and exchange pages to
produce physically contiguous memory/arbitrary sized pages without allocati=
ng
any new pages, unlike what khugepaged does. It works on per-VMA basis, crea=
ting
physically contiguous memory out of each VMA, which is virtually contiguous=
.
A simple range tree is used to ensure no two VMAs are overlapping with each
other in the physical address space.

3) a use case of the new physically contiguous memory producing mechanism t=
hat
generates 1GB THPs by migrating and exchanging pages and promoting 512
contiguous 2MB THPs to a 1GB THP, although even larger physically contiguou=
s
memory ranges can be generated. The 1GB THP implement is very basic, which =
can
handle 1GB THP faults when buddy allocator is modified to allocate 1GB page=
s,
support 1GB THP split to 2MB THP and in-place promotion from 2MB THP to 1GB=
 THP,
and PMD/PTE-mapped 1GB THP. These are not fully tested.


[1] https://lwn.net/Articles/736170/=C2=A0
[2] https://lwn.net/Articles/753167/=C2=A0
[3] https://blogs.nvidia.com/blog/2018/06/08/worlds-fastest-exascale-ai-sup=
ercomputer-summit/=C2=A0

Zi Yan (31):
  mm: migrate: Add exchange_pages to exchange two lists of pages.
  mm: migrate: Add THP exchange support.
  mm: migrate: Add tmpfs exchange support.
  mm: add mem_defrag functionality.
  mem_defrag: split a THP if either src or dst is THP only.
  mm: Make MAX_ORDER configurable in Kconfig for buddy allocator.
  mm: deallocate pages with order > MAX_ORDER.
  mm: add pagechain container for storing multiple pages.
  mm: thp: 1GB anonymous page implementation.
  mm: proc: add 1GB THP kpageflag.
  mm: debug: print compound page order in dump_page().
  mm: stats: Separate PMD THP and PUD THP stats.
  mm: thp: 1GB THP copy on write implementation.
  mm: thp: handling 1GB THP reference bit.
  mm: thp: add 1GB THP split_huge_pud_page() function.
  mm: thp: check compound_mapcount of PMD-mapped PUD THPs at free time.
  mm: thp: split properly PMD-mapped PUD THP to PTE-mapped PUD THP.
  mm: page_vma_walk: teach it about PMD-mapped PUD THP.
  mm: thp: 1GB THP support in try_to_unmap().
  mm: thp: split 1GB THPs at page reclaim.
  mm: thp: 1GB zero page shrinker.
  mm: thp: 1GB THP follow_p*d_page() support.
  mm: support 1GB THP pagemap support.
  sysctl: add an option to only print the head page virtual address.
  mm: thp: add a knob to enable/disable 1GB THPs.
  mm: thp: promote PTE-mapped THP to PMD-mapped THP.
  mm: thp: promote PMD-mapped PUD pages to PUD-mapped PUD pages.
  mm: vmstats: add page promotion stats.
  mm: madvise: add madvise options to split PMD and PUD THPs.
  mm: mem_defrag: thp: PMD THP and PUD THP in-place promotion support.
  sysctl: toggle to promote PUD-mapped 1GB THP or not.

 arch/x86/Kconfig                       |   15 +
 arch/x86/entry/syscalls/syscall_64.tbl |    1 +
 arch/x86/include/asm/pgalloc.h         |   69 +
 arch/x86/include/asm/pgtable.h         |   20 +
 arch/x86/include/asm/sparsemem.h       |    4 +-
 arch/x86/mm/pgtable.c                  |   38 +
 drivers/base/node.c                    |    3 +
 fs/exec.c                              |    4 +
 fs/proc/meminfo.c                      |    2 +
 fs/proc/page.c                         |    2 +
 fs/proc/task_mmu.c                     |   47 +-
 include/asm-generic/pgtable.h          |  110 +
 include/linux/huge_mm.h                |   78 +-
 include/linux/khugepaged.h             |    1 +
 include/linux/ksm.h                    |    5 +
 include/linux/mem_defrag.h             |   60 +
 include/linux/memcontrol.h             |    5 +
 include/linux/mm.h                     |   34 +
 include/linux/mm_types.h               |    5 +
 include/linux/mmu_notifier.h           |   13 +
 include/linux/mmzone.h                 |    1 +
 include/linux/page-flags.h             |   79 +-
 include/linux/pagechain.h              |   73 +
 include/linux/rmap.h                   |   10 +-
 include/linux/sched/coredump.h         |    4 +
 include/linux/swap.h                   |    2 +
 include/linux/syscalls.h               |    3 +
 include/linux/vm_event_item.h          |   33 +
 include/uapi/asm-generic/mman-common.h |   15 +
 include/uapi/linux/kernel-page-flags.h |    2 +
 kernel/events/uprobes.c                |    4 +-
 kernel/fork.c                          |   14 +
 kernel/sysctl.c                        |  101 +-
 mm/Makefile                            |    2 +
 mm/compaction.c                        |   17 +-
 mm/debug.c                             |    8 +-
 mm/exchange.c                          |  878 +++++++
 mm/filemap.c                           |    8 +
 mm/gup.c                               |   60 +-
 mm/huge_memory.c                       | 3360 ++++++++++++++++++++----
 mm/hugetlb.c                           |    4 +-
 mm/internal.h                          |   46 +
 mm/khugepaged.c                        |    7 +-
 mm/ksm.c                               |   39 +-
 mm/madvise.c                           |  121 +
 mm/mem_defrag.c                        | 1941 ++++++++++++++
 mm/memcontrol.c                        |   13 +
 mm/memory.c                            |   55 +-
 mm/migrate.c                           |   14 +-
 mm/mmap.c                              |   29 +
 mm/page_alloc.c                        |  108 +-
 mm/page_vma_mapped.c                   |  129 +-
 mm/pgtable-generic.c                   |   78 +-
 mm/rmap.c                              |  283 +-
 mm/swap.c                              |   38 +
 mm/swap_slots.c                        |    2 +
 mm/swapfile.c                          |    4 +-
 mm/userfaultfd.c                       |    2 +-
 mm/util.c                              |    7 +
 mm/vmscan.c                            |   55 +-
 mm/vmstat.c                            |   32 +
 61 files changed, 7452 insertions(+), 745 deletions(-)
 create mode 100644 include/linux/mem_defrag.h
 create mode 100644 include/linux/pagechain.h
 create mode 100644 mm/exchange.c
 create mode 100644 mm/mem_defrag.c

--
2.20.1

