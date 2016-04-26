Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2D6E6B025E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:20:15 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id n67so20118298vkf.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:20:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gi8si29437750wjc.158.2016.04.26.04.20.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 04:20:14 -0700 (PDT)
Subject: Re: [PATCH 01/28] mm, page_alloc: Only check PageCompound for
 high-order pages
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-2-git-send-email-mgorman@techsingularity.net>
 <571DE45B.2050504@suse.cz> <20160426103334.GB2858@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F4EED.2060208@suse.cz>
Date: Tue, 26 Apr 2016 13:20:13 +0200
MIME-Version: 1.0
In-Reply-To: <20160426103334.GB2858@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/26/2016 12:33 PM, Mel Gorman wrote:
>
> I dithered on this a bit and could not convince myself that the order
> case really is unlikely. It depends on the situation as we could be
> tearing down a large THP-backed mapping. SLUB is also using compound
> pages so it's both workload and configuration dependent whether this
> path is really likely or not.

Hmm I see. But e.g. buffered_rmqueue uses "if (likely(order == 0))" so it would 
be at least consistent. Also compound pages can amortize the extra cost over 
more base pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
