Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8CAC6B04EC
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 07:15:01 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id xr1so4065259wjb.7
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 04:15:01 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 6si13228790wmq.165.2016.11.21.04.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 04:14:59 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id a20so17563wme.2
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 04:14:59 -0800 (PST)
Date: Mon, 21 Nov 2016 15:14:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH -v5 0/9] THP swap: Delay splitting THP during swapping out
Message-ID: <20161121121457.GA8425@node.shutemov.name>
References: <20161116031057.12977-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161116031057.12977-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Wed, Nov 16, 2016 at 11:10:48AM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> This patchset is to optimize the performance of Transparent Huge Page
> (THP) swap.
> 
> Hi, Andrew, could you help me to check whether the overall design is
> reasonable?
> 
> Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
> swap part of the patchset?  Especially [1/9], [3/9], [4/9], [5/9],
> [6/9], [9/9].
> 
> Hi, Andrea and Kirill, could you help me to review the THP part of the
> patchset?  Especially [2/9], [7/9] and [8/9].

Feel free to use my Acked-by for 7/9 and 8/9.

2/9 is more about swap/memcg. It would be better someone else would look
on this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
