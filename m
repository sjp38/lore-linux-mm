Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE426B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 18:32:57 -0500 (EST)
Date: Tue, 22 Nov 2011 00:32:55 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 5/8] readahead: add /debug/readahead/stats
Message-ID: <20111121233255.GF24062@one.firstfloor.org>
References: <20111121091819.394895091@intel.com> <20111121093846.636765408@intel.com> <20111121152958.e4fd76d4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111121152958.e4fd76d4.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

> I may be wrong, but I don't think the CPU cost of this code matters a
> lot.  People will rarely turn it on and disk IO is a lot slower than
> CPU actions and it's waaaaaaay more important to get high-quality info
> about readahead than it is to squeeze out a few CPU cycles.

In its current form it would cache line bounce, which tends to be 
extremly slow. But the solution is probably to make it per CPU.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
