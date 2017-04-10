Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5E576B03A1
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:35:09 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l44so4511274wrc.11
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 01:35:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g16si11187409wmi.100.2017.04.10.01.35.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 01:35:08 -0700 (PDT)
Date: Mon, 10 Apr 2017 10:35:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [HMM 10/16] mm/hmm/mirror: helper to snapshot CPU page table v2
Message-ID: <20170410083505.GA4625@dhcp22.suse.cz>
References: <20170405204026.3940-1-jglisse@redhat.com>
 <20170405204026.3940-11-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170405204026.3940-11-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Wed 05-04-17 16:40:20, Jerome Glisse wrote:
> This does not use existing page table walker because we want to share
> same code for our page fault handler.

I am getting the following compilation error with sparc32
allmodconfig. I didn't check more closely yet.

mm/hmm.c: In function 'hmm_vma_walk_pmd':
mm/hmm.c:370:53: error: macro "pte_index" requires 2 arguments, but only 1 given
    unsigned long pfn = pmd_pfn(pmd) + pte_index(addr);
                                                     ^
mm/hmm.c:370:39: error: 'pte_index' undeclared (first use in this function)
    unsigned long pfn = pmd_pfn(pmd) + pte_index(addr);
                                       ^
mm/hmm.c:370:39: note: each undeclared identifier is reported only once for each function it appears in
mm/hmm.c: In function 'hmm_devmem_release':
mm/hmm.c:816:2: error: implicit declaration of function 'arch_remove_memory' [-Werror=implicit-function-declaration]
  arch_remove_memory(align_start, align_size, devmem->pagemap.type);
  ^
cc1: some warnings being treated as errors
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
