Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4C6A6B0271
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 03:12:14 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id j10so46052005wjb.3
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 00:12:14 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id pp1si17547285wjc.75.2016.12.19.00.12.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 00:12:12 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id he10so22500560wjc.2
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 00:12:12 -0800 (PST)
Date: Mon, 19 Dec 2016 09:12:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: simplify node/zone name printing
Message-ID: <20161219081210.GA32389@dhcp22.suse.cz>
References: <20161216123232.26307-1-mhocko@kernel.org>
 <2094d241-f40b-2f21-b90b-059374bcd2c2@suse.cz>
 <20161219073228.GA1339@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161219073228.GA1339@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Petr Mladek <pmladek@suse.cz>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon 19-12-16 16:32:28, Sergey Senozhatsky wrote:
[...]
> as far as I can tell, now for_each_populated_zone() iterations are
> split by non-CONT printk() from show_zone_node(), which previously
> has been   printk(KERN_CONT "%s: ", zone->name), so pr_cont(\n)
> between iterations was important, but now that non-CONT printk()
> should do the trick. it's _a bit_ hacky, though.

Do you consider that more hacky than the original? At least for me,
starting with KERN_CONT and relying on an explicit \n sounds more error
prone than leaving the last pr_cont without \n and relying on the
implicit flushing.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
