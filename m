Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 952096B0082
	for <linux-mm@kvack.org>; Wed, 20 May 2009 07:20:13 -0400 (EDT)
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class citizen
From: Andi Kleen <andi@firstfloor.org>
References: <alpine.DEB.1.10.0905181045340.20244@qirst.com>
	<20090519032759.GA7608@localhost>
	<20090519133422.4ECC.A69D9226@jp.fujitsu.com>
	<20090519062503.GA9580@localhost>
Date: Wed, 20 May 2009 13:20:24 +0200
In-Reply-To: <20090519062503.GA9580@localhost> (Wu Fengguang's message of "Tue, 19 May 2009 14:25:03 +0800")
Message-ID: <87pre4nhqf.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Wu Fengguang <fengguang.wu@intel.com> writes:
>
> 2.6.30-rc4-mm, VM_EXEC protection ON
> ------------------------------------
> begin:       2444             6652            50021              207                0           619959
> end:          284           231752           233394              210           773879         20890132
> restore:      399           231973           234352              251           776879         20960568
>
> We can reach basically the same conclusion from the above data.

One scenario that might be useful to test is what happens when some very large
processes, all mapped and executable exceed memory and fight each other
for the working set. Do you have regressions then compared to without
the patches?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
