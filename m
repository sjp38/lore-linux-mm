Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05EF96B02F2
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 12:00:58 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id m2-v6so10400368plt.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 09:00:57 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 136-v6si13971521pgb.587.2018.07.09.09.00.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 09:00:57 -0700 (PDT)
Subject: Re: [PATCH -mm -v4 02/21] mm, THP, swap: Make CONFIG_THP_SWAP depends
 on CONFIG_SWAP
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180622035151.6676-3-ying.huang@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <4a56313b-1184-56d0-e269-30d5f2ffa706@linux.intel.com>
Date: Mon, 9 Jul 2018 09:00:53 -0700
MIME-Version: 1.0
In-Reply-To: <20180622035151.6676-3-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

>  config THP_SWAP
>  	def_bool y
> -	depends on TRANSPARENT_HUGEPAGE && ARCH_WANTS_THP_SWAP
> +	depends on TRANSPARENT_HUGEPAGE && ARCH_WANTS_THP_SWAP && SWAP
>  	help


This seems like a bug-fix.  Is there a reason this didn't cause problems
up to now?
