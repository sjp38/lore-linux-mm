Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B8D046B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 13:33:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c84so223450360pfj.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 10:33:23 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id g70si65063112pfc.293.2016.09.19.10.33.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 10:33:23 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id q2so32910867pfj.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 10:33:23 -0700 (PDT)
Date: Mon, 19 Sep 2016 10:33:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping
 out
In-Reply-To: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
Message-ID: <alpine.LSU.2.11.1609191032140.2169@eggly.anvils>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Wed, 7 Sep 2016, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> This patchset is to optimize the performance of Transparent Huge Page
> (THP) swap.
> 
> Hi, Andrew, could you help me to check whether the overall design is
> reasonable?
> 
> Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
> swap part of the patchset?  Especially [01/10], [04/10], [05/10],
> [06/10], [07/10], [10/10].

Sorry, I am very far from having time to do so.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
