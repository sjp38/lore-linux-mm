Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58B976B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 20:26:54 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g11-v6so4692327pgs.13
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 17:26:54 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id n34-v6si520477pgm.28.2018.07.19.17.26.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 17:26:53 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v3 4/8] swap: Unify normal/huge code path in swap_page_trans_huge_swapped()
References: <20180719084842.11385-1-ying.huang@intel.com>
	<20180719084842.11385-5-ying.huang@intel.com>
	<20180719124013.GB28522@infradead.org>
Date: Fri, 20 Jul 2018 08:26:48 +0800
In-Reply-To: <20180719124013.GB28522@infradead.org> (Christoph Hellwig's
	message of "Thu, 19 Jul 2018 05:40:13 -0700")
Message-ID: <871sbywy47.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

Christoph Hellwig <hch@infradead.org> writes:

>>  static inline bool cluster_is_huge(struct swap_cluster_info *info)
>>  {
>> -	return info->flags & CLUSTER_FLAG_HUGE;
>> +	if (IS_ENABLED(CONFIG_THP_SWAP))
>> +		return info->flags & CLUSTER_FLAG_HUGE;
>> +	else
>> +		return false;
>
> Nitpick: no need for an else after a return:
>
> 	if (IS_ENABLED(CONFIG_THP_SWAP))
> 		return info->flags & CLUSTER_FLAG_HUGE;
> 	return false;

Sure.  Will change this in next version.

Best Regards,
Huang, Ying
