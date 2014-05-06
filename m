Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 466ED6B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 15:21:10 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id i17so9462343qcy.11
        for <linux-mm@kvack.org>; Tue, 06 May 2014 12:21:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id b39si5695526qge.6.2014.05.06.12.21.09
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 12:21:09 -0700 (PDT)
Message-ID: <53692ED7.9080700@redhat.com>
Date: Tue, 06 May 2014 14:49:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 12/17] mm: page_alloc: Convert hot/cold parameter and
 immediate callers to bool
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-13-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/01/2014 04:44 AM, Mel Gorman wrote:
> cold is a bool, make it one. Make the likely case the "if" part of the
> block instead of the else as according to the optimisation manual this
> is preferred.
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
