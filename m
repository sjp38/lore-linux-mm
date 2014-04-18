Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD0C6B0037
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 14:05:16 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so1840100eek.38
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 11:05:16 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id d5si41327468eei.88.2014.04.18.11.05.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 11:05:15 -0700 (PDT)
Date: Fri, 18 Apr 2014 14:05:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 07/16] mm: page_alloc: Only check the zone id check if
 pages are buddies
Message-ID: <20140418180512.GD29210@cmpxchg.org>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
 <1397832643-14275-8-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397832643-14275-8-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, Apr 18, 2014 at 03:50:34PM +0100, Mel Gorman wrote:
> A node/zone index is used to check if pages are compatible for merging
> but this happens unconditionally even if the buddy page is not free. Defer
> the calculation as long as possible. Ideally we would check the zone boundary
> but nodes can overlap.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
