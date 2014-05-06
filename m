Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id C5D2D6B003C
	for <linux-mm@kvack.org>; Tue,  6 May 2014 12:48:57 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id j7so3229813qaq.3
        for <linux-mm@kvack.org>; Tue, 06 May 2014 09:48:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id p8si5382397qag.191.2014.05.06.09.48.57
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 09:48:57 -0700 (PDT)
Message-ID: <53691272.1050602@redhat.com>
Date: Tue, 06 May 2014 12:48:50 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/17] mm: page_alloc: Only check the zone id check if
 pages are buddies
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-6-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/01/2014 04:44 AM, Mel Gorman wrote:
> A node/zone index is used to check if pages are compatible for merging
> but this happens unconditionally even if the buddy page is not free. Defer
> the calculation as long as possible. Ideally we would check the zone boundary
> but nodes can overlap.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
