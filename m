Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 302D46B0036
	for <linux-mm@kvack.org>; Tue,  6 May 2014 12:19:56 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so5155866qgd.15
        for <linux-mm@kvack.org>; Tue, 06 May 2014 09:19:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id m6si5334335qay.241.2014.05.06.09.19.54
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 09:19:54 -0700 (PDT)
Message-ID: <5369073F.70001@redhat.com>
Date: Tue, 06 May 2014 12:01:03 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/17] mm: page_alloc: Calculate classzone_idx once from
 the zonelist ref
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/01/2014 04:44 AM, Mel Gorman wrote:
> There is no need to calculate zone_idx(preferred_zone) multiple times
> or use the pgdat to figure it out.
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
