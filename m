Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB4C6B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 08:06:46 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id m5so3946404qaj.35
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 05:06:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 61si1743769qgw.61.2014.03.07.05.06.45
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 05:06:45 -0800 (PST)
Message-ID: <5319BB3A.6020102@redhat.com>
Date: Fri, 07 Mar 2014 07:27:38 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, compaction: determine isolation mode only once
References: <alpine.DEB.2.02.1403070358120.13046@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1403070358120.13046@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/07/2014 07:01 AM, David Rientjes wrote:
> The conditions that control the isolation mode in 
> isolate_migratepages_range() do not change during the iteration, so 
> extract them out and only define the value once.
> 
> This actually does have an effect, gcc doesn't optimize it itself because 
> of cc->sync.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
