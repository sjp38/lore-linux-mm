Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 971626B0269
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 08:18:44 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e17so3072116edr.7
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 05:18:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p24-v6sor10368776edq.28.2018.11.13.05.18.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 05:18:43 -0800 (PST)
Date: Tue, 13 Nov 2018 13:18:41 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] vmscan: return NODE_RECLAIM_NOSCAN in node_reclaim()
 when CONFIG_NUMA is n
Message-ID: <20181113131841.z5t7uckslfjq2mwe@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181113041750.20784-1-richard.weiyang@gmail.com>
 <20181113080436.22078-1-richard.weiyang@gmail.com>
 <20181113130420.GV21824@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113130420.GV21824@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 13, 2018 at 05:04:20AM -0800, Matthew Wilcox wrote:
>On Tue, Nov 13, 2018 at 04:04:36PM +0800, Wei Yang wrote:
>> Commit fa5e084e43eb ("vmscan: do not unconditionally treat zones that
>> fail zone_reclaim() as full") changed the return value of node_reclaim().
>> The original return value 0 means NODE_RECLAIM_SOME after this commit.
>> 
>> While the return value of node_reclaim() when CONFIG_NUMA is n is not
>> changed. This will leads to call zone_watermark_ok() again.
>> 
>> This patch fix the return value by adjusting to NODE_RECLAIM_NOSCAN. Since
>> node_reclaim() is only called in page_alloc.c, move it to mm/internal.h.
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>
>Reviewed-by: Matthew Wilcox <willy@infradead.org>

Thanks

-- 
Wei Yang
Help you, Help me
