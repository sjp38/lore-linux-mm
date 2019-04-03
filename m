Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B565C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5A23206DF
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 17:37:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="49vJ7cLb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5A23206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 613C36B0010; Wed,  3 Apr 2019 13:36:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C49C6B026A; Wed,  3 Apr 2019 13:36:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 467FD6B0269; Wed,  3 Apr 2019 13:36:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1084C6B026B
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 13:36:59 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id j66so3341258ywa.17
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 10:36:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=51JtPg1xXslaRUa2vnZEbVWe5AGpnJ+pKD+VtG75/Kc=;
        b=s89TF0LB5/j835+t4xbHJyoyt72Kjv5F2VsqqAFzEgW9eze6FHLmhaD1HMsilIMH47
         NUAw7lJtDn5GVdKyUm9udyZnVAClQHkqeiwbwcw6+pq4qxOXKXcllVg67Ik2b0HF8cbN
         bTor9XMSdvhqR2v+UeLnjU1fJ8OGwzY/Q+Q/P3iSVNgeKSlo19ROVzLp6qBYeZSaf5uy
         Xc3khq/iDtoCJlencBEK7Ky34npdmE8wVhI3w7T12UkUxReX2qsyLmO9yD5VxHu/u3U7
         /2HSbsLoSi5nbX2E5kcz6nfxUujaulHZJberCcVsh3HuWj5yv03NbMvNgRhyp4rbgavp
         dJAg==
X-Gm-Message-State: APjAAAVTDytETicLYpuAqVZ2zwgnbeDiXmV/4MqOc91O5KUf63oXzPV3
	FS2ogI1kqkugG+nXMW7wND4buTWvId4z31d16wqGHnJqPOWgEqF5QX1fc4oaTwsP7+RS3IC6pHR
	seFEKxoMu6zoBp4VLn8JONCAxm0/JlNtHjg0oQNYwybC+Yeam4Y4K5i59uWlIFU8Z1g==
X-Received: by 2002:a25:7189:: with SMTP id m131mr1212691ybc.24.1554313018646;
        Wed, 03 Apr 2019 10:36:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy98NRXx5JX/p4LRkckZ1E2Q9Hc/RgFf519kwRdBzXCMNXR5QL6erqaS8vFxkf8rNBOkrjj
X-Received: by 2002:a25:7189:: with SMTP id m131mr1212615ybc.24.1554313017742;
        Wed, 03 Apr 2019 10:36:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554313017; cv=none;
        d=google.com; s=arc-20160816;
        b=T82EXq+eofGegfZMJh5ijefCYjhevfSKf6KzVqgdJY5B1hqJMvPnQ6bVnSc/H9Il/i
         5C4CfP4Z3IEMwDRU0UdErfeVi6zQjXf9tbCaGWtSATCe+oaS+sBU3sT7nontHYdrvRgP
         iGs/mD4G+fkemP+GZDIX0y8ZYZVxSGFNJZ2+TaMiftOZmjMgzzSbqHiQVbpa+6tTcW3J
         kLB+zP8khcbtjSmEmp5d+9mHfZK3Ax2B5vw3f9AkQHkML7wEolUmWzx2LfhO5NAsng2y
         EvQrdKSsEbbCenmTjKirBw/t3jk065IkQTib/R4G2ddN+VHWs3Pg69jSDVzvf81Mg2yK
         VCcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=51JtPg1xXslaRUa2vnZEbVWe5AGpnJ+pKD+VtG75/Kc=;
        b=yO+06CVYDS3SHpMcdPaM4uirDJs6Rp6Lmwrdn2vnQ1sknqelQT9G4iBZf2woxrPKU1
         XIXEPd6mOHLHrR17g8INdugXgDU57uV6oKcoK4K5+a7fkeNezfAzrTOhsnLIjOS+wIwj
         BJBCBpeNwXb/CEJ4Yvny+Jpa5EjE42O48xYhHokaxZs0SaGERBhykS2CgeFlY7G+RJb9
         aGnXCh6y5QCYyD60MKUJZ5Q1DPo9LIq7bHAynP6nh12DuXZAng0msvSsiAejokCf88xJ
         koY5MdJGh7ali51L38iTq+BIZGgjwpZkN2nSXlaSOIHBvYU9jERoSfHIw0gumFxvjWoJ
         iwYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=49vJ7cLb;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id z4si10005164ybg.344.2019.04.03.10.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 10:36:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=49vJ7cLb;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HNsTW175465;
	Wed, 3 Apr 2019 17:35:43 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id; s=corp-2018-07-02;
 bh=51JtPg1xXslaRUa2vnZEbVWe5AGpnJ+pKD+VtG75/Kc=;
 b=49vJ7cLb4xixwNkjf2scOTaANGoo/3u6o0p6FblhsElaZqafFmpw2wLsmCVb19xHucnJ
 BODNuaXMHnMfJldDfXk8T5TXHaVbdTE4tAhFlAbOJsNq1RSYzRJzkRDO01yKAn9RP5kf
 KBhHIeBgHOBYUDdhKx2Mpl+hXjgCGLBYdeaB3faTh4QMEkYlz7BdiplYWPWCQ5gA8AsC
 RbnRDgW+budTIwxRcnWK3eyD0nOUU5jII8DC6EUD8Zd+M7kydxauu4ReK6Vi6XQ1E1Gn
 gq/IMqFd35KFJaoIIo+roomIWe0m21cDTOZwM7thUbxq4pNJ2QFi/4gscCCnSe02rnSi qg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2rj13qae6v-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:42 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33HZaed087795;
	Wed, 3 Apr 2019 17:35:42 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2rm8f67xu6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 03 Apr 2019 17:35:42 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x33HZDvX001104;
	Wed, 3 Apr 2019 17:35:15 GMT
Received: from concerto.internal (/10.65.181.37)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 03 Apr 2019 10:35:12 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        liran.alon@oracle.com, keescook@google.com, akpm@linux-foundation.org,
        konrad.wilk@oracle.com
Cc: Khalid Aziz <khalid.aziz@oracle.com>, deepa.srinivasan@oracle.com,
        chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk,
        andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com,
        kanth.ghatraju@oracle.com, joao.m.martins@oracle.com,
        jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com,
        tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de,
        steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
        dave.hansen@intel.com, peterz@infradead.org, aaron.lu@intel.com,
        alexander.h.duyck@linux.intel.com, amir73il@gmail.com,
        andreyknvl@google.com, aneesh.kumar@linux.ibm.com,
        anthony.yznaga@oracle.com, ard.biesheuvel@linaro.org, arnd@arndb.de,
        arunks@codeaurora.org, ben@decadent.org.uk, bigeasy@linutronix.de,
        bp@alien8.de, brgl@bgdev.pl, catalin.marinas@arm.com, corbet@lwn.net,
        cpandya@codeaurora.org, daniel.vetter@ffwll.ch,
        dan.j.williams@intel.com, gregkh@linuxfoundation.org, guro@fb.com,
        hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
        james.morse@arm.com, jannh@google.com, jgross@suse.com,
        jkosina@suse.cz, jmorris@namei.org, joe@perches.com,
        jrdr.linux@gmail.com, jroedel@suse.de, keith.busch@intel.com,
        khlebnikov@yandex-team.ru, logang@deltatee.com,
        marco.antonio.780@gmail.com, mark.rutland@arm.com,
        mgorman@techsingularity.net, mhocko@suse.com, mhocko@suse.cz,
        mike.kravetz@oracle.com, mingo@redhat.com, mst@redhat.com,
        m.szyprowski@samsung.com, npiggin@gmail.com, osalvador@suse.de,
        paulmck@linux.vnet.ibm.com, pavel.tatashin@microsoft.com,
        rdunlap@infradead.org, richard.weiyang@gmail.com, riel@surriel.com,
        rientjes@google.com, robin.murphy@arm.com, rostedt@goodmis.org,
        rppt@linux.vnet.ibm.com, sai.praneeth.prakhya@intel.com,
        serge@hallyn.com, steve.capper@arm.com, thymovanbeers@gmail.com,
        vbabka@suse.cz, will.deacon@arm.com, willy@infradead.org,
        yang.shi@linux.alibaba.com, yaojun8558363@gmail.com,
        ying.huang@intel.com, zhangshaokun@hisilicon.com,
        khalid@gonehiking.org, iommu@lists.linux-foundation.org,
        x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-security-module@vger.kernel.org
Subject: [RFC PATCH v9 00/13] Add support for eXclusive Page Frame Ownership
Date: Wed,  3 Apr 2019 11:34:01 -0600
Message-Id: <cover.1554248001.git.khalid.aziz@oracle.com>
X-Mailer: git-send-email 2.17.1
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030118
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030118
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is another update to the work Juerg, Tycho and Julian have
done on XPFO. After the last round of updates, we were seeing very
significant performance penalties when stale TLB entries were
flushed actively after an XPFO TLB update.  Benchmark for measuring
performance is kernel build using parallel make. To get full
protection from ret2dir attackes, we must flush stale TLB entries.
Performance penalty from flushing stale TLB entries goes up as the
number of cores goes up. On a desktop class machine with only 4
cores, enabling TLB flush for stale entries causes system time for
"make -j4" to go up by a factor of 2.61x but on a larger machine
with 96 cores, system time with "make -j60" goes up by a factor of
26.37x!  I have been working on reducing this performance penalty.

I implemented two solutions to reduce performance penalty and that
has had large impact. XPFO code flushes TLB every time a page is
allocated to userspace. It does so by sending IPIs to all processors
to flush TLB. Back to back allocations of pages to userspace on
multiple processors results in a storm of IPIs.  Each one of these
incoming IPIs is handled by a processor by flushing its TLB. To
reduce this IPI storm, I have added a per CPU flag that can be set
to tell a processor to flush its TLB. A processor checks this flag
on every context switch. If the flag is set, it flushes its TLB and
clears the flag. This allows for multiple TLB flush requests to a
single CPU to be combined into a single request. A kernel TLB entry
for a page that has been allocated to userspace is flushed on all
processors unlike the previous version of this patch. A processor
could hold a stale kernel TLB entry that was removed on another
processor until the next context switch. A local userspace page
allocation by the currently running process could force the TLB
flush earlier for such entries.

The other solution reduces the number of TLB flushes required, by
performing TLB flush for multiple pages at one time when pages are
refilled on the per-cpu freelist. If the pages being addedd to
per-cpu freelist are marked for userspace allocation, TLB entries
for these pages can be flushed upfront and pages tagged as currently
unmapped. When any such page is allocated to userspace, there is no
need to performa a TLB flush at that time any more. This batching of
TLB flushes reduces performance imapct further. Similarly when
these user pages are freed by userspace and added back to per-cpu
free list, they are left unmapped and tagged so. This further
optimization reduced performance impact from 1.32x to 1.28x for
96-core server and from 1.31x to 1.27x for a 4-core desktop.

I measured system time for parallel make with unmodified 4.20
kernel, 4.20 with XPFO patches before these patches and then again
after applying each of these patches. Here are the results:

Hardware: 96-core Intel Xeon Platinum 8160 CPU @ 2.10GHz, 768 GB RAM
make -j60 all

5.0					913.862s
5.0+this patch series			1165.259ss	1.28x


Hardware: 4-core Intel Core i5-3550 CPU @ 3.30GHz, 8G RAM
make -j4 all

5.0					610.642s
5.0+this patch series			773.075s	1.27x

Performance with this patch set is good enough to use these as
starting point for further refinement before we merge it into main
kernel, hence RFC.

I have restructurerd the patches in this version to separate out
architecture independent code. I folded much of the code
improvement by Julian to not use page extension into patch 3. 

What remains to be done beyond this patch series:

1. Performance improvements: Ideas to explore - (1) kernel mappings
   private to an mm, (2) Any others??
2. Re-evaluate the patch "arm64/mm: Add support for XPFO to swiotlb"
   from Juerg. I dropped it for now since swiotlb code for ARM has
   changed a lot since this patch was written. I could use help
   from ARM experts on this.
3. Extend the patch "xpfo, mm: Defer TLB flushes for non-current
   CPUs" to other architectures besides x86.
4. Change kmap to not map the page back to physmap, instead map it
   to a new va similar to what kmap_high does. Mapping page back
   into physmap re-opens the ret2dir security for the duration of
   kmap. All of the kmap_high and related code can be reused for this
   but that will require restructuring that code so it can be built for
   64-bits as well. Any objections to that?

---------------------------------------------------------

Juerg Haefliger (6):
  mm: Add support for eXclusive Page Frame Ownership (XPFO)
  xpfo, x86: Add support for XPFO for x86-64
  lkdtm: Add test for XPFO
  arm64/mm: Add support for XPFO
  swiotlb: Map the buffer if it was unmapped by XPFO
  arm64/mm, xpfo: temporarily map dcache regions

Julian Stecklina (1):
  xpfo, mm: optimize spinlock usage in xpfo_kunmap

Khalid Aziz (2):
  xpfo, mm: Defer TLB flushes for non-current CPUs (x86 only)
  xpfo, mm: Optimize XPFO TLB flushes by batching them together

Tycho Andersen (4):
  mm: add MAP_HUGETLB support to vm_mmap
  x86: always set IF before oopsing from page fault
  mm: add a user_virt_to_phys symbol
  xpfo: add primitives for mapping underlying memory

 .../admin-guide/kernel-parameters.txt         |   6 +
 arch/arm64/Kconfig                            |   1 +
 arch/arm64/mm/Makefile                        |   2 +
 arch/arm64/mm/flush.c                         |   7 +
 arch/arm64/mm/mmu.c                           |   2 +-
 arch/arm64/mm/xpfo.c                          |  66 ++++++
 arch/x86/Kconfig                              |   1 +
 arch/x86/include/asm/pgtable.h                |  26 +++
 arch/x86/include/asm/tlbflush.h               |   1 +
 arch/x86/mm/Makefile                          |   2 +
 arch/x86/mm/fault.c                           |   6 +
 arch/x86/mm/pageattr.c                        |  32 +--
 arch/x86/mm/tlb.c                             |  39 ++++
 arch/x86/mm/xpfo.c                            | 185 +++++++++++++++++
 drivers/misc/lkdtm/Makefile                   |   1 +
 drivers/misc/lkdtm/core.c                     |   3 +
 drivers/misc/lkdtm/lkdtm.h                    |   5 +
 drivers/misc/lkdtm/xpfo.c                     | 196 ++++++++++++++++++
 include/linux/highmem.h                       |  34 +--
 include/linux/mm.h                            |   2 +
 include/linux/mm_types.h                      |   8 +
 include/linux/page-flags.h                    |  23 +-
 include/linux/xpfo.h                          | 191 +++++++++++++++++
 include/trace/events/mmflags.h                |  10 +-
 kernel/dma/swiotlb.c                          |   3 +-
 mm/Makefile                                   |   1 +
 mm/compaction.c                               |   2 +-
 mm/internal.h                                 |   2 +-
 mm/mmap.c                                     |  19 +-
 mm/page_alloc.c                               |  19 +-
 mm/page_isolation.c                           |   2 +-
 mm/util.c                                     |  32 +++
 mm/xpfo.c                                     | 170 +++++++++++++++
 security/Kconfig                              |  27 +++
 34 files changed, 1047 insertions(+), 79 deletions(-)
 create mode 100644 arch/arm64/mm/xpfo.c
 create mode 100644 arch/x86/mm/xpfo.c
 create mode 100644 drivers/misc/lkdtm/xpfo.c
 create mode 100644 include/linux/xpfo.h
 create mode 100644 mm/xpfo.c

-- 
2.17.1

