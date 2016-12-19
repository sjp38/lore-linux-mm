Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 511396B0273
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 03:26:59 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a190so103700407pgc.0
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 00:26:59 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id j3si17580442pld.177.2016.12.19.00.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 00:26:58 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id 144so7223325pfv.0
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 00:26:58 -0800 (PST)
Date: Mon, 19 Dec 2016 17:27:05 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: simplify node/zone name printing
Message-ID: <20161219082705.GA4298@jagdpanzerIV.localdomain>
References: <20161216123232.26307-1-mhocko@kernel.org>
 <2094d241-f40b-2f21-b90b-059374bcd2c2@suse.cz>
 <20161219073228.GA1339@jagdpanzerIV.localdomain>
 <20161219081210.GA32389@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161219081210.GA32389@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Petr Mladek <pmladek@suse.cz>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (12/19/16 09:12), Michal Hocko wrote:
> On Mon 19-12-16 16:32:28, Sergey Senozhatsky wrote:
> [...]
> > as far as I can tell, now for_each_populated_zone() iterations are
> > split by non-CONT printk() from show_zone_node(), which previously
> > has been   printk(KERN_CONT "%s: ", zone->name), so pr_cont(\n)
> > between iterations was important, but now that non-CONT printk()
> > should do the trick. it's _a bit_ hacky, though.
> 
> Do you consider that more hacky than the original?

well, slightly. merely because (to me) implicit always relies on
internals, which can change; while explicit does not (ideally).
simply because of that.

but I don't have any problems with your patch.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
