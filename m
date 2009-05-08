Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D5F976B0096
	for <linux-mm@kvack.org>; Fri,  8 May 2009 18:04:34 -0400 (EDT)
Date: Fri, 8 May 2009 23:00:45 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
 class citizen
Message-ID: <20090508230045.5346bd32@lxorguk.ukuu.org.uk>
In-Reply-To: <20090508125859.210a2a25.akpm@linux-foundation.org>
References: <20090430181340.6f07421d.akpm@linux-foundation.org>
	<20090430215034.4748e615@riellaptop.surriel.com>
	<20090430195439.e02edc26.akpm@linux-foundation.org>
	<49FB01C1.6050204@redhat.com>
	<20090501123541.7983a8ae.akpm@linux-foundation.org>
	<20090503031539.GC5702@localhost>
	<1241432635.7620.4732.camel@twins>
	<20090507121101.GB20934@localhost>
	<20090507151039.GA2413@cmpxchg.org>
	<20090507134410.0618b308.akpm@linux-foundation.org>
	<20090508081608.GA25117@localhost>
	<20090508125859.210a2a25.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, hannes@cmpxchg.org, peterz@infradead.org, riel@redhat.com, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, elladan@eskimo.com, npiggin@suse.de, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

> The patch seems reasonable but the changelog and the (non-existent)
> design documentation could do with a touch-up.

Is it right that I as a user can do things like mmap my database
PROT_EXEC to get better database numbers by making other
stuff swap first ?

You seem to be giving everyone a "nice my process up" hack.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
