Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2A4280250
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 04:11:13 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z65so312366itc.2
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 01:11:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 9si22812509ioj.248.2016.10.07.01.11.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 01:11:12 -0700 (PDT)
Message-ID: <1475827866.2421.12.camel@redhat.com>
Subject: Re: [PATCH 1/8] mm/swap: Fix kernel message in swap_info_get()
From: Rik van Riel <riel@redhat.com>
Date: Fri, 07 Oct 2016 04:11:06 -0400
In-Reply-To: <20160927171754.GA17824@linux.intel.com>
References: <20160927171754.GA17824@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tim.c.chen@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>
Cc: dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Tue, 2016-09-27 at 10:17 -0700, Tim Chen wrote:
> From: "Huang, Ying" <ying.huang@intel.com>
> 
> swap_info_get() is used not only in swap free code path but also in
> page_swapcount(), etc.A A So the original kernel message in
> swap_info_get() is not correct now.A A Fix it via replacing "swap_free"
> to
> "swap_info_get" in the message.
> 
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> 
Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
