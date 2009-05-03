Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2942C6B003D
	for <linux-mm@kvack.org>; Sat,  2 May 2009 21:34:14 -0400 (EDT)
Date: Sat, 2 May 2009 21:33:56 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v3)
Message-ID: <20090502213356.2f620d81@riellaptop.surriel.com>
In-Reply-To: <20090503011540.GA5702@localhost>
References: <20090428044426.GA5035@eskimo.com>
	<20090428192907.556f3a34@bree.surriel.com>
	<1240987349.4512.18.camel@laptop>
	<20090429114708.66114c03@cuia.bos.redhat.com>
	<2f11576a0904290907g48e94e74ye97aae593f6ac519@mail.gmail.com>
	<20090429131436.640f09ab@cuia.bos.redhat.com>
	<20090503011540.GA5702@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 3 May 2009 09:15:40 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> In the worse scenario, it could waste half the memory that could
> otherwise be used for readahead buffer and to prevent thrashing, in a
> server serving large datasets that are hardly reused, but still slowly
> builds up its active list during the long uptime (think about a slowly
> performance downgrade that can be fixed by a crude dropcache action).

In the best case, the active list ends up containing all the
indirect blocks for the files that are occasionally reused,
and the system ends up being able to serve its clients with
less disk IO.

For systems like ftp.kernel.org, the files that are most
popular will end up on the active list, without being kicked
out by the files that are less popular.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
