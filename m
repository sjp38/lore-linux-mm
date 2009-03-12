Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 02C446B004D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:56:59 -0400 (EDT)
Date: Thu, 12 Mar 2009 17:55:57 +0000
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [uClinux-dev] Re: [PATCH] NOMMU: Pages allocated to a ramfs inode's pagecache may get wrongly discarded
Message-ID: <20090312175557.GD14491@shareable.org>
References: <20090311170207.1795cad9.akpm@linux-foundation.org> <28c262360903111735s2b0c43a3pd48fcf8d55416ae3@mail.gmail.com> <20090312100049.43A3.A69D9226@jp.fujitsu.com> <200903120819.08724.rgetz@blackfin.uclinux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200903120819.08724.rgetz@blackfin.uclinux.org>
Sender: owner-linux-mm@kvack.org
To: uClinux development list <uclinux-dev@uclinux.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Rik van Riel <riel@surriel.com>, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Robin Getz wrote:
> > Currently, CONFIG_UNEVICTABLE_LRU can't use on nommu machine
> > because nobody of vmscan folk havbe nommu machine.
> > 
> > Yes, it is very stupid reason. _very_ welcome to tester! :)
> 
> As always - if you (or any kernel developer) would like a noMMU machine to 
> test on - please send me a private email.

Well, that explains why vmscan has historically performed a little
dubiously on small nommu machines!

By the way, this is just a random side thought... nommu kernels work
just fine in emulators :-)

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
