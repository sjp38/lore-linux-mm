Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA066B003B
	for <linux-mm@kvack.org>; Tue,  6 May 2014 14:48:09 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id j15so3836060qaq.13
        for <linux-mm@kvack.org>; Tue, 06 May 2014 11:48:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id d5si5566707qad.247.2014.05.06.11.48.06
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 11:48:06 -0700 (PDT)
Message-ID: <53692E61.7040207@redhat.com>
Date: Tue, 06 May 2014 14:48:01 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/17] mm: page_alloc: Lookup pageblock migratetype with
 IRQs enabled during free
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-11-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/01/2014 04:44 AM, Mel Gorman wrote:
> get_pageblock_migratetype() is called during free with IRQs disabled. This
> is unnecessary and disables IRQs for longer than necessary.
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
