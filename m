Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 47F626B0036
	for <linux-mm@kvack.org>; Thu,  1 May 2014 09:33:44 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so2246377eek.15
        for <linux-mm@kvack.org>; Thu, 01 May 2014 06:33:43 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id t3si34208256eeg.91.2014.05.01.06.33.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 01 May 2014 06:33:42 -0700 (PDT)
Date: Thu, 1 May 2014 09:33:40 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 15/17] mm: Do not use unnecessary atomic operations when
 adding pages to the LRU
Message-ID: <20140501133340.GE23420@cmpxchg.org>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
 <1398933888-4940-16-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398933888-4940-16-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, May 01, 2014 at 09:44:46AM +0100, Mel Gorman wrote:
> When adding pages to the LRU we clear the active bit unconditionally. As the
> page could be reachable from other paths we cannot use unlocked operations
> without risk of corruption such as a parallel mark_page_accessed. This
> patch test if is necessary to clear the atomic flag before using an atomic
> operation. In the unlikely even this races with mark_page_accesssed the

                             event

> consequences are simply that the page may be promoted to the active list
> that might have been left on the inactive list before the patch. This is
> a marginal consequence.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
