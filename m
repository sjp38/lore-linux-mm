Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DA1AC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:40:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4758522DA7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:40:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4758522DA7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B81396B02E6; Wed, 21 Aug 2019 11:40:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B31006B02EF; Wed, 21 Aug 2019 11:40:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D0A96B02F0; Wed, 21 Aug 2019 11:40:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0077.hostedemail.com [216.40.44.77])
	by kanga.kvack.org (Postfix) with ESMTP id 7980C6B02E6
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:40:23 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1A32D180AD801
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:40:23 +0000 (UTC)
X-FDA: 75846846726.09.sack91_33dd60edbe31
X-HE-Tag: sack91_33dd60edbe31
X-Filterd-Recvd-Size: 6791
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:40:22 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1FC5410F23EA;
	Wed, 21 Aug 2019 15:40:20 +0000 (UTC)
Received: from t460s.redhat.com (unknown [10.36.118.29])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 74B5B2B9D7;
	Wed, 21 Aug 2019 15:40:07 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Lutomirski <luto@kernel.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Halil Pasic <pasic@linux.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Ingo Molnar <mingo@redhat.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jun Yao <yaojun8558363@gmail.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.de>,
	Paul Mackerras <paulus@samba.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Qian Cai <cai@lca.pw>,
	Rich Felker <dalias@libc.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Steve Capper <steve.capper@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	Tony Luck <tony.luck@intel.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Wei Yang <richard.weiyang@gmail.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Will Deacon <will@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Yu Zhao <yuzhao@google.com>
Subject: [PATCH v1 0/5] mm/memory_hotplug: Consider all zones when removing memory
Date: Wed, 21 Aug 2019 17:40:01 +0200
Message-Id: <20190821154006.1338-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.66]); Wed, 21 Aug 2019 15:40:21 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Working on virtio-mem, I was able to trigger a kernel BUG (with debug
options enabled) when removing memory that was never onlined. As far as I
can see the same can also happen without debug configs, if we're unlucky
and the uninitialized memmap contains selected garbage :).

The root problem is that we should not try to derive the zone of memory w=
e
are removing from the first PFN. The individual memory blocks of a DIMM
could be spanned by different ZONEs, multiple ZONES (after being offline =
and
re-onlined) or no ZONE at all (never onlined).

Let's process all applicable zones when removing memory so we're on the
safe side. In the long term, we want to resize the zones when offlining
memory (and before removing ZONE_DEVICE memory), however, that will requi=
re
more thought (and most probably a new SECTION_ACTIVE / pfn_active()
thingy). More details about that in patch #3.

Along with the fix, some related cleanups.

If we run into performance issues (doubt it) we could
- Pass the node along from remove_memory() and only consider zones of
  that node
- Remember zones that are worth calling "set_zone_contiguous()", right no=
w
  we try to recompute it for all zones that are not contiguous.

--- snip ---

I gave this a quick test with a DIMM on x86-64:

Start with a NUMA-less node 1. Hotplug a DIMM (512MB) to Node 1.
1st memory block is not onlined. 2nd and 4th is onlined MOVABLE.
3rd is onlined NORMAL.

:/# echo "online_movable" > /sys/devices/system/memory/memory41/state
[...]
:/# echo "online_movable" > /sys/devices/system/memory/memory43/state
:/# echo "online_kernel" > /sys/devices/system/memory/memory42/state
:/# cat /sys/devices/system/memory/memory40/state
offline

:/# cat /proc/zoneinfo
Node 1, zone   Normal
 [...]
        spanned  32768
        present  32768
        managed  32768
 [...]
Node 1, zone  Movable
 [...]
        spanned  98304
        present  65536
        managed  65536
 [...]

Trigger hotunplug. If it succeeds (block 42 can be offlined):

:/# cat /proc/zoneinfo

Node 1, zone   Normal
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 0, 0, 0)
Node 1, zone  Movable
  pages free     0
        min      0
        low      0
        high     0
        spanned  0
        present  0
        managed  0
        protection: (0, 0, 0, 0, 0)

So all zones were properly fixed up and we don't access the memmap of the
first, never-onlined memory block (garbage). I am no longer able to trigg=
er
the BUG. I did a similar test with an already populated node.


David Hildenbrand (5):
  mm/memory_hotplug: Exit early in __remove_pages() on BUGs
  mm: Exit early in set_zone_contiguous() if already contiguous
  mm/memory_hotplug: Process all zones when removing memory
  mm/memory_hotplug: Cleanup __remove_pages()
  mm/memory_hotplug: Remove zone parameter from __remove_pages()

 arch/arm64/mm/mmu.c            |  4 +--
 arch/ia64/mm/init.c            |  4 +--
 arch/powerpc/mm/mem.c          |  3 +-
 arch/s390/mm/init.c            |  4 +--
 arch/sh/mm/init.c              |  4 +--
 arch/x86/mm/init_32.c          |  4 +--
 arch/x86/mm/init_64.c          |  4 +--
 include/linux/memory_hotplug.h |  4 +--
 mm/memory_hotplug.c            | 50 +++++++++++++++++++---------------
 mm/memremap.c                  |  3 +-
 mm/page_alloc.c                |  3 ++
 11 files changed, 41 insertions(+), 46 deletions(-)

--=20
2.21.0


