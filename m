Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F68A6B0010
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 18:43:40 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x19-v6so1140864pfh.15
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 15:43:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t10-v6si21980189pge.624.2018.08.15.15.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 15:43:35 -0700 (PDT)
Date: Wed, 15 Aug 2018 15:43:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/2] mm: soft-offline: fix race against page
 allocation
Message-Id: <20180815154334.f3eecd1029a153421631413a@linux-foundation.org>
In-Reply-To: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, xishi.qiuxishi@alibaba-inc.com, zy.zhengyi@alibaba-inc.com, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>

On Tue, 17 Jul 2018 14:32:30 +0900 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> I've updated the patchset based on feedbacks:
> 
> - updated comments (from Andrew),
> - moved calling set_hwpoison_free_buddy_page() from mm/migrate.c to mm/memory-failure.c,
>   which is necessary to check the return code of set_hwpoison_free_buddy_page(),
> - lkp bot reported a build error when only 1/2 is applied.
> 
>   >    mm/memory-failure.c: In function 'soft_offline_huge_page':
>   > >> mm/memory-failure.c:1610:8: error: implicit declaration of function
>   > 'set_hwpoison_free_buddy_page'; did you mean 'is_free_buddy_page'?
>   > [-Werror=implicit-function-declaration]
>   >        if (set_hwpoison_free_buddy_page(page))
>   >            ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
>   >            is_free_buddy_page
>   >    cc1: some warnings being treated as errors
> 
>   set_hwpoison_free_buddy_page() is defined in 2/2, so we can't use it
>   in 1/2. Simply doing s/set_hwpoison_free_buddy_page/!TestSetPageHWPoison/
>   will fix this.
> 
> v1: https://lkml.org/lkml/2018/7/12/968
> 

Quite a bit of discussion on these two, but no actual acks or
review-by's?
