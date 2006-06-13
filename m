Message-ID: <448E4F05.9040804@yahoo.com.au>
Date: Tue, 13 Jun 2006 15:37:09 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: zoned vm counters: per zone counter functionality
References: <20060612211244.20862.41106.sendpatchset@schroedinger.engr.sgi.com> <20060612211255.20862.39044.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060612211255.20862.39044.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, Con Kolivas <kernel@kolivas.org>, Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

Looks like a nice patchset. I really like that you've moved the counters
out of page alloc.

Is there any point in using a more meaningful namespace prefix than NR_
for the zone_stat_items?


> +enum zone_stat_item {
> +	NR_STAT_ITEMS };
> +

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
