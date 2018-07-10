Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E73B76B0005
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 21:59:29 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x2-v6so11330047plv.0
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 18:59:29 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r3-v6si2191423pgg.201.2018.07.09.18.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 18:59:28 -0700 (PDT)
Subject: Re: [PATCH -mm -v4 02/21] mm, THP, swap: Make CONFIG_THP_SWAP depends
 on CONFIG_SWAP
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180622035151.6676-3-ying.huang@intel.com>
 <4a56313b-1184-56d0-e269-30d5f2ffa706@linux.intel.com>
 <87wou3j3a9.fsf@yhuang-dev.intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <66d12d39-5079-c836-744c-ee97ce40d553@linux.intel.com>
Date: Mon, 9 Jul 2018 18:59:14 -0700
MIME-Version: 1.0
In-Reply-To: <87wou3j3a9.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

On 07/09/2018 06:19 PM, Huang, Ying wrote:
> Dave Hansen <dave.hansen@linux.intel.com> writes:
> 
>>>  config THP_SWAP
>>>  	def_bool y
>>> -	depends on TRANSPARENT_HUGEPAGE && ARCH_WANTS_THP_SWAP
>>> +	depends on TRANSPARENT_HUGEPAGE && ARCH_WANTS_THP_SWAP && SWAP
>>>  	help
>>
>> This seems like a bug-fix.  Is there a reason this didn't cause problems
>> up to now?
> Yes.  The original code has some problem in theory, but not in practice
> because all code enclosed by
> 
> #ifdef CONFIG_THP_SWAP
> #endif
> 
> are in swapfile.c.  But that will be not true in this patchset.

That's great info for the changelog.
