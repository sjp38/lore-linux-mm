Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1532F6B0005
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 13:36:37 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id m7-v6so1989451qtg.1
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 10:36:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e7-v6si1561020qvo.64.2018.04.27.10.36.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 10:36:35 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3RHYbHM012236
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 13:36:34 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hm4y9hct7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 13:36:34 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Fri, 27 Apr 2018 18:36:31 +0100
Date: Fri, 27 Apr 2018 19:36:19 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [RFC PATCH 0/9] Enable THP migration for all possible
 architectures
In-Reply-To: <20180426142804.180152-1-zi.yan@sent.com>
References: <20180426142804.180152-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20180427193619.435eb53a@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zi Yan <zi.yan@cs.rutgers.edu>, Vineet Gupta <vgupta@synopsys.com>, linux-snps-arc@lists.infradead.org, Russell King <linux@armlinux.org.uk>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steve Capper <steve.capper@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Dan Williams <dan.j.williams@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michal Hocko <mhocko@suse.com>, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ram Pai <linuxram@us.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linuxppc-dev@lists.ozlabs.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Janosch Frank <frankja@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, "Huang, Ying" <ying.huang@intel.com>

On Thu, 26 Apr 2018 10:27:55 -0400
Zi Yan <zi.yan@sent.com> wrote:

> From: Zi Yan <zi.yan@cs.rutgers.edu>
> 
> Hi all,
> 
> THP migration is only enabled on x86_64 with a special
> ARCH_ENABLE_THP_MIGRATION macro. This patchset enables THP migration for
> all architectures that uses transparent hugepage, so that special macro can
> be dropped. Instead, THP migration is enabled/disabled via
> /sys/kernel/mm/transparent_hugepage/enable_thp_migration.
> 
> I grepped for TRANSPARENT_HUGEPAGE in arch folder and got 9 architectures that
> are supporting transparent hugepage. I mechanically add __pmd_to_swp_entry() and
> __swp_entry_to_pmd() based on existing __pte_to_swp_entry() and
> __swp_entry_to_pte() for all these architectures, except tile which is going to
> be dropped.

This will not work on s390, the pmd layout is very different from the pte
layout. Using __swp_entry/type/offset() on a pmd will go horribly wrong.
I currently don't see a chance to make this work for us, so please make/keep
this configurable, and do not configure it for s390.

Regards,
Gerald
