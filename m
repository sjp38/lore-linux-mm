Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8F4356B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 04:40:58 -0500 (EST)
Message-Id: <20111121091819.394895091@intel.com>
Date: Mon, 21 Nov 2011 17:18:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/8] readahead stats/tracing, backwards prefetching and more
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

Andrew,

I'm getting around to pick up the readahead works again :-)

This first series is mainly to add some debug facilities, to support the long
missed backwards prefetching capability, and some old patches that somehow get
delayed (shame me).

The next step would be to better handle the readahead thrashing situations.
That would require rewriting part of the algorithms, this is why I'd like to
keep the backwards prefetching simple and stupid for now.

When (almost) free of readahead thrashing, we'll be in a good position to lift
the default readahead size. Which I suspect would be the single most efficient
way to improve performance for the large volumes of casually maintained Linux
file servers.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
