Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 88A6F6B0038
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 19:46:55 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e9so4195716pgc.5
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 16:46:55 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id j69si25294643pfk.19.2016.11.21.16.46.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 16:46:54 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v5 0/9] THP swap: Delay splitting THP during swapping out
References: <20161116031057.12977-1-ying.huang@intel.com>
	<20161121121457.GA8425@node.shutemov.name>
Date: Tue, 22 Nov 2016 08:46:50 +0800
In-Reply-To: <20161121121457.GA8425@node.shutemov.name> (Kirill A. Shutemov's
	message of "Mon, 21 Nov 2016 15:14:57 +0300")
Message-ID: <87ziksibnp.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Wed, Nov 16, 2016 at 11:10:48AM +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> This patchset is to optimize the performance of Transparent Huge Page
>> (THP) swap.
>> 
>> Hi, Andrew, could you help me to check whether the overall design is
>> reasonable?
>> 
>> Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
>> swap part of the patchset?  Especially [1/9], [3/9], [4/9], [5/9],
>> [6/9], [9/9].
>> 
>> Hi, Andrea and Kirill, could you help me to review the THP part of the
>> patchset?  Especially [2/9], [7/9] and [8/9].
>
> Feel free to use my Acked-by for 7/9 and 8/9.
>
> 2/9 is more about swap/memcg. It would be better someone else would look
> on this.

Thanks!

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
