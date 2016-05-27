Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 908416B0005
	for <linux-mm@kvack.org>; Fri, 27 May 2016 12:40:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g64so140267882pfb.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 09:40:29 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id i184si7278358pfc.224.2016.05.27.09.40.28
        for <linux-mm@kvack.org>;
        Fri, 27 May 2016 09:40:28 -0700 (PDT)
Message-ID: <1464367227.22178.147.camel@linux.intel.com>
Subject: Re: [PATCH 1/7] mm: Cleanup - Reorganize the shrink_page_list code
 into smaller functions
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Fri, 27 May 2016 09:40:27 -0700
In-Reply-To: <1462309280.21143.8.camel@linux.intel.com>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
	 <1462309280.21143.8.camel@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>

On Tue, 2016-05-03 at 14:01 -0700, Tim Chen wrote:
> This patch prepares the code for being able to batch the anonymous
> pages
> to be swapped out.A A It reorganizes shrink_page_list function with
> 2 new functions: handle_pgout and pg_finish.
> 
> The paging operation in shrink_page_list is consolidated into
> handle_pgout function.
> 
> After we have scanned a page shrink_page_list and completed any
> paging,
> the final disposition and clean up of the page is conslidated into
> pg_finish.A A The designated disposition of the page from page scanning
> in shrink_page_list is marked with one of the designation in
> pg_result.
> 
> This is a clean up patch and there is no change in functionality or
> logic of the code.

Hi Michal,

We've talked about doing the clean up of shrink_page_list code
before attempting to do batching on the swap out path as those
set of patches I've previously posted are quit intrusive. A Wonder
if you have a chance to look at this patch and has any comments?

Thanks.

Tim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
