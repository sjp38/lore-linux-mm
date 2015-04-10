Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id EF2C66B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 20:14:48 -0400 (EDT)
Received: by wizk4 with SMTP id k4so110627266wiz.1
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 17:14:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id wk3si437104wjb.136.2015.04.09.17.14.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 17:14:47 -0700 (PDT)
Message-ID: <552715E4.2080100@redhat.com>
Date: Thu, 09 Apr 2015 20:14:28 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm: make every pte dirty on do_swap_page
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>	<1426036838-18154-4-git-send-email-minchan@kernel.org>	<20150408235012.GA13690@blaptop> <20150409135939.bbc9025d925de9d0fdd12797@linux-foundation.org>
In-Reply-To: <20150409135939.bbc9025d925de9d0fdd12797@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com, Hugh Dickins <hughd@google.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>

On 04/09/2015 04:59 PM, Andrew Morton wrote:
> On Thu, 9 Apr 2015 08:50:25 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
>> Bump.
> 
> I'm getting the feeling that MADV_FREE is out of control.
> 
> Below is the overall rollup of
> 
> mm-support-madvisemadv_free.patch
> mm-support-madvisemadv_free-fix.patch
> mm-support-madvisemadv_free-fix-2.patch
> mm-dont-split-thp-page-when-syscall-is-called.patch
> mm-dont-split-thp-page-when-syscall-is-called-fix.patch
> mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
> mm-free-swp_entry-in-madvise_free.patch
> mm-move-lazy-free-pages-to-inactive-list.patch
> mm-move-lazy-free-pages-to-inactive-list-fix.patch
> mm-move-lazy-free-pages-to-inactive-list-fix-fix.patch
> mm-move-lazy-free-pages-to-inactive-list-fix-fix-fix.patch
> mm-make-every-pte-dirty-on-do_swap_page.patch
> 
> 
> It's pretty large and has its sticky little paws in all sorts of places.
> 
> 
> The feature would need to be pretty darn useful to justify a mainline
> merge.  Has any such usefulness been demonstrated?

The performance increase of MADV_FREE over MADV_DONTNEED is
quite significant. I suspect this is especially important for
mobile devices, which are more memory starved than desktop
systems and servers.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
