Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0EA276B0069
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 05:52:32 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r126so25507211wmr.2
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 02:52:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w72si22343435wrc.19.2017.01.24.02.52.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 02:52:30 -0800 (PST)
Subject: Re: [PATCH 2/4] mm, page_alloc: Split alloc_pages_nodemask
References: <20170123153906.3122-1-mgorman@techsingularity.net>
 <20170123153906.3122-3-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <527f302a-644b-de24-b9ce-a65d5d7aec95@suse.cz>
Date: Tue, 24 Jan 2017 11:52:27 +0100
MIME-Version: 1.0
In-Reply-To: <20170123153906.3122-3-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On 01/23/2017 04:39 PM, Mel Gorman wrote:
> alloc_pages_nodemask does a number of preperation steps that determine
> what zones can be used for the allocation depending on a variety of
> factors. This is fine but a hypothetical caller that wanted multiple
> order-0 pages has to do the preparation steps multiple times. This patch
> structures __alloc_pages_nodemask such that it's relatively easy to build
> a bulk order-0 page allocator. There is no functional change.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
