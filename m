Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1316B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:59:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so36227247wmw.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 04:59:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k189si8698856wme.107.2016.04.27.04.59.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 04:59:04 -0700 (PDT)
Subject: Re: [PATCH 27/28] mm, page_alloc: Defer debugging checks of freed
 pages until a PCP drain
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-15-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5720A987.7060507@suse.cz>
Date: Wed, 27 Apr 2016 13:59:03 +0200
MIME-Version: 1.0
In-Reply-To: <1460711275-1130-15-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 11:07 AM, Mel Gorman wrote:
> Every page free checks a number of page fields for validity. This
> catches premature frees and corruptions but it is also expensive.
> This patch weakens the debugging check by checking PCP pages at the
> time they are drained from the PCP list. This will trigger the bug
> but the site that freed the corrupt page will be lost. To get the
> full context, a kernel rebuild with DEBUG_VM is necessary.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

I don't like the duplicated code in free_pcp_prepare() from maintenance 
perspective, as Hugh just reminded me that similar kind of duplication 
between page_alloc.c and compaction.c can easily lead to mistakes. I've 
tried to fix that, which resulted in 3 small patches I'll post as 
replies here. Could be that the ideas will be applicable also to 28/28 
which I haven't checked yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
