Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9F39B6B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 13:52:21 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e49so1785059eek.25
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:52:21 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id c48si23816938eeb.7.2014.04.18.10.52.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 10:52:20 -0700 (PDT)
Date: Fri, 18 Apr 2014 13:52:16 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 03/16] mm: page_alloc: Do not update zlc unless the zlc
 is active
Message-ID: <20140418175216.GA29210@cmpxchg.org>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
 <1397832643-14275-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397832643-14275-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, Apr 18, 2014 at 03:50:30PM +0100, Mel Gorman wrote:
> The zlc is used on NUMA machines to quickly skip over zones that are full.
> However it is always updated, even for the first zone scanned when the
> zlc might not even be active. As it's a write to a bitmap that potentially
> bounces cache line it's deceptively expensive and most machines will not
> care. Only update the zlc if it was active.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
