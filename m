Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 604BD6B0039
	for <linux-mm@kvack.org>; Tue,  6 May 2014 14:47:09 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id i8so3192149qcq.15
        for <linux-mm@kvack.org>; Tue, 06 May 2014 11:47:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k9si5569898qan.173.2014.05.06.11.47.08
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 11:47:08 -0700 (PDT)
Message-ID: <53692E25.1040200@redhat.com>
Date: Tue, 06 May 2014 14:47:01 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/17] mm: page_alloc: Reduce number of times page_to_pfn
 is called
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-10-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/01/2014 04:44 AM, Mel Gorman wrote:
> In the free path we calculate page_to_pfn multiple times. Reduce that.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
