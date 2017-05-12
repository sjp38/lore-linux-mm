Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 558B46B0038
	for <linux-mm@kvack.org>; Fri, 12 May 2017 12:47:58 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 139so3247489wmf.5
        for <linux-mm@kvack.org>; Fri, 12 May 2017 09:47:58 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o27si4187259edo.54.2017.05.12.09.47.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 May 2017 09:47:57 -0700 (PDT)
Date: Fri, 12 May 2017 12:47:45 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm: swap: unify swap slot free functions to
 put_swap_page
Message-ID: <20170512164745.GB22367@cmpxchg.org>
References: <87h90sb4jq.fsf@yhuang-dev.intel.com>
 <1494555684-11982-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494555684-11982-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 12, 2017 at 11:21:23AM +0900, Minchan Kim wrote:
> Now, get_swap_page takes struct page and allocates swap space
> according to page size(ie, normal or THP) so it would be more
> cleaner to introduce put_swap_page which is a counter function
> of get_swap_page. Then, it calls right swap slot free function
> depending on page's size.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
