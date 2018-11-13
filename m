Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C70A16B000C
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 02:49:17 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id h24-v6so6150246ede.9
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 23:49:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t21-v6sor4528527ejr.32.2018.11.12.23.49.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Nov 2018 23:49:16 -0800 (PST)
Date: Tue, 13 Nov 2018 07:49:14 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] vmscan: return NODE_RECLAIM_NOSCAN in node_reclaim()
 when CONFIG_NUMA is n
Message-ID: <20181113074914.5kgiww44gpqit45y@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181113041750.20784-1-richard.weiyang@gmail.com>
 <20181113053615.GJ21824@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113053615.GJ21824@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 12, 2018 at 09:36:15PM -0800, Matthew Wilcox wrote:
>On Tue, Nov 13, 2018 at 12:17:50PM +0800, Wei Yang wrote:
>> Commit fa5e084e43eb ("vmscan: do not unconditionally treat zones that
>> fail zone_reclaim() as full") changed the return value of node_reclaim().
>> The original return value 0 means NODE_RECLAIM_SOME after this commit.
>> 
>> While the return value of node_reclaim() when CONFIG_NUMA is n is not
>> changed. This will leads to call zone_watermark_ok() again.
>> 
>> This patch fix the return value by adjusting to NODE_RECLAIM_NOSCAN. Since
>> it is not proper to include "mm/internal.h", just hard coded it.
>
>Since the return value is defined in mm/internal.h that means no code
>outside mm/ can call node_reclaim (nor should it).  So let's move both
>of node_reclaim's declarations to mm/internal.h instead of keeping them
>in linux/swap.h.

That's reasonable, thanks.

-- 
Wei Yang
Help you, Help me
