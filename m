Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 95D156B0254
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:46:01 -0500 (EST)
Received: by wmww144 with SMTP id w144so63594764wmw.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 02:46:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z133si4876357wmc.82.2015.11.25.02.46.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 02:46:00 -0800 (PST)
Subject: Re: [PATCH v2] mm/cma: always check which page cause allocation
 failure
References: <20151125023913.GA9563@js1304-P5Q-DELUXE>
 <1448429565-29748-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56559165.5080304@suse.cz>
Date: Wed, 25 Nov 2015 11:45:57 +0100
MIME-Version: 1.0
In-Reply-To: <1448429565-29748-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 11/25/2015 06:32 AM, Joonsoo Kim wrote:
> Now, we have tracepoint in test_pages_isolated() to notify
> pfn which cannot be isolated. But, in alloc_contig_range(),
> some error path doesn't call test_pages_isolated() so it's still
> hard to know exact pfn that causes allocation failure.
> 
> This patch change this situation by calling test_pages_isolated()
> in almost error path. In allocation failure case, some overhead
> is added by this change, but, allocation failure is really rare
> event so it would not matter.
> 
> In fatal signal pending case, we don't call test_pages_isolated()
> because this failure is intentional one.
> 
> There was a bogus outer_start problem due to unchecked buddy order
> and this patch also fix it. Before this patch, it didn't matter,
> because end result is same thing. But, after this patch,
> tracepoint will report failed pfn so it should be accurate.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
