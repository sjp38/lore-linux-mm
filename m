Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 706876B0037
	for <linux-mm@kvack.org>; Tue,  6 May 2014 13:24:35 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id s7so3157047qap.6
        for <linux-mm@kvack.org>; Tue, 06 May 2014 10:24:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a67si1204352qgf.20.2014.05.06.10.24.33
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 10:24:33 -0700 (PDT)
Message-ID: <53691AC9.8070104@redhat.com>
Date: Tue, 06 May 2014 13:24:25 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/17] mm: page_alloc: Only check the alloc flags and
 gfp_mask for dirty once
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-7-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/01/2014 04:44 AM, Mel Gorman wrote:
> Currently it's calculated once per zone in the zonelist.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
