Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 590846B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 09:18:05 -0500 (EST)
Date: Mon, 21 Nov 2011 15:17:59 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 5/8] readahead: add /debug/readahead/stats
Message-ID: <20111121141759.GE24062@one.firstfloor.org>
References: <20111121091819.394895091@intel.com> <20111121093846.636765408@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111121093846.636765408@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

> +static unsigned long ra_stats[RA_PATTERN_MAX][RA_ACCOUNT_MAX];

Why not make it per cpu?  That should get the overhead down, probably
even enough that it can be enabled by default.

BTW I have an older framework to make it really easy to add per
cpu stats counters to debugfs. Will repost, that would simplify
it even more.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
