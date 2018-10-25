Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1FF6B0003
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 21:06:31 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j9-v6so3081119pfn.20
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 18:06:31 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id u14-v6si6012300plq.268.2018.10.24.18.06.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 18:06:30 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V6 14/21] swap: Support to move swap account for PMD swap mapping
References: <20181010071924.18767-1-ying.huang@intel.com>
	<20181010071924.18767-15-ying.huang@intel.com>
	<20181024172749.bila5pnfsqsu7th3@ca-dmjordan1.us.oracle.com>
Date: Thu, 25 Oct 2018 09:06:26 +0800
In-Reply-To: <20181024172749.bila5pnfsqsu7th3@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Wed, 24 Oct 2018 10:27:49 -0700")
Message-ID: <877ei6vnql.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Wed, Oct 10, 2018 at 03:19:17PM +0800, Huang Ying wrote:
>> +static struct page *mc_handle_swap_pmd(struct vm_area_struct *vma,
>> +			pmd_t pmd, swp_entry_t *entry)
>> +{
>
> Got
> /home/dbbench/linux/mm/memcontrol.c:4719:21: warning: a??mc_handle_swap_pmda?? defined but not used [-Wunused-function]
>  static struct page *mc_handle_swap_pmd(struct vm_area_struct *vma,
> when
> # CONFIG_TRANSPARENT_HUGEPAGE is not set

Thanks for pointing this out.  Will fix it in the next version.

Best Regards,
Huang, Ying
