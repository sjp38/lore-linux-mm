Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 549E36B0006
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 01:19:56 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id w23-v6so5924998pgv.1
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 22:19:56 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id a16-v6si4467893pga.168.2018.07.01.22.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 22:19:55 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 03/21] mm, THP, swap: Support PMD swap mapping in swap_duplicate()
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-4-ying.huang@intel.com>
	<20180629060412.GI7646@bombadil.infradead.org>
Date: Mon, 02 Jul 2018 13:19:51 +0800
In-Reply-To: <20180629060412.GI7646@bombadil.infradead.org> (Matthew Wilcox's
	message of "Thu, 28 Jun 2018 23:04:12 -0700")
Message-ID: <87k1qexlhk.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Matthew Wilcox <willy@infradead.org> writes:

> On Fri, Jun 22, 2018 at 11:51:33AM +0800, Huang, Ying wrote:
>> +++ b/mm/swap_state.c
>> @@ -433,7 +433,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>>  		/*
>>  		 * Swap entry may have been freed since our caller observed it.
>>  		 */
>> -		err = swapcache_prepare(entry);
>> +		err = swapcache_prepare(entry, false);
>>  		if (err == -EEXIST) {
>>  			radix_tree_preload_end();
>>  			/*
>
> This commit should be just a textual conflict.

Yes.  Will check it.

Best Regards,
Huang, Ying
