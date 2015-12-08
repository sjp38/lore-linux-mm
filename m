Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 392CF6B0278
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 19:40:09 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so2349851pac.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 16:40:09 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id b10si995694pas.127.2015.12.07.16.40.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 07 Dec 2015 16:40:08 -0800 (PST)
Date: Tue, 8 Dec 2015 09:41:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 0/3] reduce latency of direct async compaction
Message-ID: <20151208004118.GA4325@js1304-P5Q-DELUXE>
References: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
 <20151203092525.GA20945@aaronlu.sh.intel.com>
 <56600DAA.4050208@suse.cz>
 <20151203113508.GA23780@aaronlu.sh.intel.com>
 <20151203115255.GA24773@aaronlu.sh.intel.com>
 <56618841.2080808@suse.cz>
 <20151207073523.GA27292@js1304-P5Q-DELUXE>
 <20151207085956.GA16783@aaronlu.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151207085956.GA16783@aaronlu.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

On Mon, Dec 07, 2015 at 04:59:56PM +0800, Aaron Lu wrote:
> On Mon, Dec 07, 2015 at 04:35:24PM +0900, Joonsoo Kim wrote:
> > It looks like overhead still remain. I guess that migration scanner
> > would call pageblock_pfn_to_page() for more extended range so
> > overhead still remain.
> > 
> > I have an idea to solve his problem. Aaron, could you test following patch
> > on top of base? It tries to skip calling pageblock_pfn_to_page()
> 
> It doesn't apply on top of 25364a9e54fb8296837061bf684b76d20eec01fb
> cleanly, so I made some changes to make it apply and the result is:
> https://github.com/aaronlu/linux/commit/cb8d05829190b806ad3948ff9b9e08c8ba1daf63

Yes, that's okay. I made it on my working branch but it will not result in
any problem except applying.

> 
> There is a problem occured right after the test starts:
> [   58.080962] BUG: unable to handle kernel paging request at ffffea0082000018
> [   58.089124] IP: [<ffffffff81193f29>] compaction_alloc+0xf9/0x270
> [   58.096109] PGD 107ffd6067 PUD 207f7d5067 PMD 0
> [   58.101569] Oops: 0000 [#1] SMP 

I did some mistake. Please test following patch. It is also made
on my working branch so you need to resolve conflict but it would be
trivial.

I inserted some logs to check whether zone is contiguous or not.
Please check that normal zone is set to contiguous after testing.

Thanks.

------>8------
