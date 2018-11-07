Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B5EE76B04AB
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 19:34:37 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id 33-v6so2540905eds.16
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 16:34:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p9-v6sor26657324edr.10.2018.11.06.16.34.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 16:34:36 -0800 (PST)
Date: Wed, 7 Nov 2018 00:34:34 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: remove reset of pcp->counter in pageset_init()
Message-ID: <20181107003434.cqfao7dzo2qf7d3w@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181021023920.5501-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181021023920.5501-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, linux-mm@kvack.org

Andrew,

Do you like this tiny one :-)

On Sun, Oct 21, 2018 at 10:39:20AM +0800, Wei Yang wrote:
>per_cpu_pageset is cleared by memset, it is not necessary to reset it
>again.
>
>Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>---
> mm/page_alloc.c | 1 -
> 1 file changed, 1 deletion(-)
>
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index 15ea511fb41c..730fadd9b639 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -5647,7 +5647,6 @@ static void pageset_init(struct per_cpu_pageset *p)
> 	memset(p, 0, sizeof(*p));
> 
> 	pcp = &p->pcp;
>-	pcp->count = 0;
> 	for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++)
> 		INIT_LIST_HEAD(&pcp->lists[migratetype]);
> }
>-- 
>2.15.1

-- 
Wei Yang
Help you, Help me
