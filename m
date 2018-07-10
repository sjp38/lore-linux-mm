Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B49F46B0005
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 21:19:38 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e93-v6so9080335plb.5
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 18:19:38 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id e125-v6si849371pgc.424.2018.07.09.18.19.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 18:19:37 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 02/21] mm, THP, swap: Make CONFIG_THP_SWAP depends on CONFIG_SWAP
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-3-ying.huang@intel.com>
	<4a56313b-1184-56d0-e269-30d5f2ffa706@linux.intel.com>
Date: Tue, 10 Jul 2018 09:19:26 +0800
In-Reply-To: <4a56313b-1184-56d0-e269-30d5f2ffa706@linux.intel.com> (Dave
	Hansen's message of "Mon, 9 Jul 2018 09:00:53 -0700")
Message-ID: <87wou3j3a9.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

Dave Hansen <dave.hansen@linux.intel.com> writes:

>>  config THP_SWAP
>>  	def_bool y
>> -	depends on TRANSPARENT_HUGEPAGE && ARCH_WANTS_THP_SWAP
>> +	depends on TRANSPARENT_HUGEPAGE && ARCH_WANTS_THP_SWAP && SWAP
>>  	help
>
>
> This seems like a bug-fix.  Is there a reason this didn't cause problems
> up to now?

Yes.  The original code has some problem in theory, but not in practice
because all code enclosed by

#ifdef CONFIG_THP_SWAP
#endif

are in swapfile.c.  But that will be not true in this patchset.

Best Regards,
Huang, Ying
