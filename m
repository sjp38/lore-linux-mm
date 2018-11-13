Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 482426B000A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 08:04:24 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id r65-v6so5371287pfa.8
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 05:04:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r36-v6si19190627pgl.257.2018.11.13.05.04.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Nov 2018 05:04:23 -0800 (PST)
Date: Tue, 13 Nov 2018 05:04:20 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] vmscan: return NODE_RECLAIM_NOSCAN in node_reclaim()
 when CONFIG_NUMA is n
Message-ID: <20181113130420.GV21824@bombadil.infradead.org>
References: <20181113041750.20784-1-richard.weiyang@gmail.com>
 <20181113080436.22078-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113080436.22078-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 13, 2018 at 04:04:36PM +0800, Wei Yang wrote:
> Commit fa5e084e43eb ("vmscan: do not unconditionally treat zones that
> fail zone_reclaim() as full") changed the return value of node_reclaim().
> The original return value 0 means NODE_RECLAIM_SOME after this commit.
> 
> While the return value of node_reclaim() when CONFIG_NUMA is n is not
> changed. This will leads to call zone_watermark_ok() again.
> 
> This patch fix the return value by adjusting to NODE_RECLAIM_NOSCAN. Since
> node_reclaim() is only called in page_alloc.c, move it to mm/internal.h.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Reviewed-by: Matthew Wilcox <willy@infradead.org>
