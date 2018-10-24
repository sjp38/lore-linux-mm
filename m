Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 53B366B000D
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 13:27:57 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id v18-v6so3140784edq.23
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 10:27:57 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id o56-v6si3320894edc.388.2018.10.24.10.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 10:27:56 -0700 (PDT)
Date: Wed, 24 Oct 2018 10:27:49 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -V6 14/21] swap: Support to move swap account for PMD
 swap mapping
Message-ID: <20181024172749.bila5pnfsqsu7th3@ca-dmjordan1.us.oracle.com>
References: <20181010071924.18767-1-ying.huang@intel.com>
 <20181010071924.18767-15-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181010071924.18767-15-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Wed, Oct 10, 2018 at 03:19:17PM +0800, Huang Ying wrote:
> +static struct page *mc_handle_swap_pmd(struct vm_area_struct *vma,
> +			pmd_t pmd, swp_entry_t *entry)
> +{

Got
/home/dbbench/linux/mm/memcontrol.c:4719:21: warning: a??mc_handle_swap_pmda?? defined but not used [-Wunused-function]
 static struct page *mc_handle_swap_pmd(struct vm_area_struct *vma,
when
# CONFIG_TRANSPARENT_HUGEPAGE is not set
