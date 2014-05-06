Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5168299E
	for <linux-mm@kvack.org>; Tue,  6 May 2014 11:04:23 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id m5so5294999qaj.2
        for <linux-mm@kvack.org>; Tue, 06 May 2014 08:04:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 110si5271943qgv.113.2014.05.06.08.04.22
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 08:04:22 -0700 (PDT)
Message-ID: <5368F9F0.5070702@redhat.com>
Date: Tue, 06 May 2014 11:04:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/17] mm: page_alloc: Do not update zlc unless the zlc
 is active
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/01/2014 04:44 AM, Mel Gorman wrote:
> The zlc is used on NUMA machines to quickly skip over zones that are full.
> However it is always updated, even for the first zone scanned when the
> zlc might not even be active. As it's a write to a bitmap that potentially
> bounces cache line it's deceptively expensive and most machines will not
> care. Only update the zlc if it was active.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
