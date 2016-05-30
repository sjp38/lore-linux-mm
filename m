Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D09F6B025E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 04:48:46 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h68so47357919lfh.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 01:48:46 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id v74si26878455wmv.34.2016.05.30.01.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 01:48:44 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id a136so20447295wme.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 01:48:44 -0700 (PDT)
Date: Mon, 30 May 2016 10:48:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/7] mm: Cleanup - Reorganize the shrink_page_list code
 into smaller functions
Message-ID: <20160530084843.GL22928@dhcp22.suse.cz>
References: <cover.1462306228.git.tim.c.chen@linux.intel.com>
 <1462309280.21143.8.camel@linux.intel.com>
 <1464367227.22178.147.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1464367227.22178.147.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>

On Fri 27-05-16 09:40:27, Tim Chen wrote:
> On Tue, 2016-05-03 at 14:01 -0700, Tim Chen wrote:
> > This patch prepares the code for being able to batch the anonymous
> > pages
> > to be swapped out.  It reorganizes shrink_page_list function with
> > 2 new functions: handle_pgout and pg_finish.
> > 
> > The paging operation in shrink_page_list is consolidated into
> > handle_pgout function.
> > 
> > After we have scanned a page shrink_page_list and completed any
> > paging,
> > the final disposition and clean up of the page is conslidated into
> > pg_finish.  The designated disposition of the page from page scanning
> > in shrink_page_list is marked with one of the designation in
> > pg_result.
> > 
> > This is a clean up patch and there is no change in functionality or
> > logic of the code.
> 
> Hi Michal,
> 
> We've talked about doing the clean up of shrink_page_list code
> before attempting to do batching on the swap out path as those
> set of patches I've previously posted are quit intrusive.  Wonder
> if you have a chance to look at this patch and has any comments?

I have noticed your
http://lkml.kernel.org/r/1463779979.22178.142.camel@linux.intel.com but
still haven't found time to look at it. Sorry about that. There is
rather a lot on my pile...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
