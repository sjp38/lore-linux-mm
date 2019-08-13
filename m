Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAD8AC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:53:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 964D720663
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 09:53:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 964D720663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 315936B0005; Tue, 13 Aug 2019 05:53:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C5806B0006; Tue, 13 Aug 2019 05:53:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B4546B0007; Tue, 13 Aug 2019 05:53:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0012.hostedemail.com [216.40.44.12])
	by kanga.kvack.org (Postfix) with ESMTP id E61436B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 05:53:18 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 86E081F20F
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:53:18 +0000 (UTC)
X-FDA: 75816941676.15.pail14_90f86725bee2f
X-HE-Tag: pail14_90f86725bee2f
X-Filterd-Recvd-Size: 4327
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:53:16 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 620201570;
	Tue, 13 Aug 2019 02:53:15 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5F2213F706;
	Tue, 13 Aug 2019 02:53:14 -0700 (PDT)
Date: Tue, 13 Aug 2019 10:53:12 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [rgushchin:fix_vmstats 210/221]
 arch/microblaze/include/asm/pgalloc.h:63:7: error: implicit declaration of
 function 'pgtable_page_ctor'; did you mean 'pgtable_pmd_page_ctor'?
Message-ID: <20190813095312.GB866@lakrids.cambridge.arm.com>
References: <201908131204.B910fkl1%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201908131204.B910fkl1%lkp@intel.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 12:38:50PM +0800, kbuild test robot wrote:
> tree:   https://github.com/rgushchin/linux.git fix_vmstats
> head:   4ec858b5201ae067607e82706b36588631c1b990
> commit: 8abab7c3016f03edee681cd2a8231c0a4f567ec9 [210/221] mm: treewide: clarify pgtable_page_{ctor,dtor}() naming
> config: microblaze-mmu_defconfig (attached as .config)
> compiler: microblaze-linux-gcc (GCC) 7.4.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 8abab7c3016f03edee681cd2a8231c0a4f567ec9
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.4.0 make.cross ARCH=microblaze 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from arch/microblaze/kernel/process.c:21:0:
>    arch/microblaze/include/asm/pgalloc.h: In function 'pte_alloc_one':
> >> arch/microblaze/include/asm/pgalloc.h:63:7: error: implicit declaration of function 'pgtable_page_ctor'; did you mean 'pgtable_pmd_page_ctor'? [-Werror=implicit-function-declaration]
>      if (!pgtable_page_ctor(ptepage)) {
>           ^~~~~~~~~~~~~~~~~
>           pgtable_pmd_page_ctor
>    cc1: some warnings being treated as errors

This was correctly changed to pgtable_pte_page_ctor()  in patch I posted
[1], and the version in today's linux-next (next-20190813), so AFAICT a
hunk went missing when it was applied to this tree.

Dodgy rebase?

Thanks,
Mark.

> 
> vim +63 arch/microblaze/include/asm/pgalloc.h
> 
> 1f84e1ea0e87ad Michal Simek       2009-05-26  59  
> 1f84e1ea0e87ad Michal Simek       2009-05-26  60  	ptepage = alloc_pages(flags, 0);
> 8abe73465660f1 Kirill A. Shutemov 2013-11-14  61  	if (!ptepage)
> 8abe73465660f1 Kirill A. Shutemov 2013-11-14  62  		return NULL;
> 8abe73465660f1 Kirill A. Shutemov 2013-11-14 @63  	if (!pgtable_page_ctor(ptepage)) {
> 8abe73465660f1 Kirill A. Shutemov 2013-11-14  64  		__free_page(ptepage);
> 8abe73465660f1 Kirill A. Shutemov 2013-11-14  65  		return NULL;
> 8abe73465660f1 Kirill A. Shutemov 2013-11-14  66  	}
> 1f84e1ea0e87ad Michal Simek       2009-05-26  67  	return ptepage;
> 1f84e1ea0e87ad Michal Simek       2009-05-26  68  }
> 1f84e1ea0e87ad Michal Simek       2009-05-26  69  
> 
> :::::: The code at line 63 was first introduced by commit
> :::::: 8abe73465660f12dee03871f681175f4dae62e7f microblaze: add missing pgtable_page_ctor/dtor calls
> 
> :::::: TO: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> :::::: CC: Linus Torvalds <torvalds@linux-foundation.org>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation



