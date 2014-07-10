Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 811156B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 08:01:26 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so4405720wib.17
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 05:01:25 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id mc10si12316773wic.84.2014.07.10.05.01.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 05:01:25 -0700 (PDT)
Date: Thu, 10 Jul 2014 08:01:20 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/6] mm: pagemap: Avoid unnecessary overhead when
 tracepoints are deactivated
Message-ID: <20140710120120.GI29639@cmpxchg.org>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
 <1404893588-21371-2-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404893588-21371-2-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Wed, Jul 09, 2014 at 09:13:03AM +0100, Mel Gorman wrote:
> The LRU insertion and activate tracepoints take PFN as a parameter forcing
> the overhead to the caller.  Move the overhead to the tracepoint fast-assign
> method to ensure the cost is only incurred when the tracepoint is active.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
