Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0C3536B003D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 12:42:53 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 91AD082C4BD
	for <linux-mm@kvack.org>; Thu,  7 May 2009 12:55:35 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zVJu095HAHYU for <linux-mm@kvack.org>;
	Thu,  7 May 2009 12:55:35 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id ACD7382C4D4
	for <linux-mm@kvack.org>; Thu,  7 May 2009 12:55:28 -0400 (EDT)
Date: Thu, 7 May 2009 12:32:40 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
 citizen
In-Reply-To: <1241712000.18617.7.camel@lts-notebook>
Message-ID: <alpine.DEB.1.10.0905071231090.10171@qirst.com>
References: <20090430072057.GA4663@eskimo.com>  <20090430174536.d0f438dd.akpm@linux-foundation.org>  <20090430205936.0f8b29fc@riellaptop.surriel.com>  <20090430181340.6f07421d.akpm@linux-foundation.org>  <20090430215034.4748e615@riellaptop.surriel.com>
 <20090430195439.e02edc26.akpm@linux-foundation.org>  <49FB01C1.6050204@redhat.com>  <20090501123541.7983a8ae.akpm@linux-foundation.org>  <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins>  <20090507121101.GB20934@localhost>
 <alpine.DEB.1.10.0905070935530.24528@qirst.com>  <1241705702.11251.156.camel@twins>  <alpine.DEB.1.10.0905071016410.24528@qirst.com> <1241712000.18617.7.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 7 May 2009, Lee Schermerhorn wrote:

> > Another possibility may be to put the exec pages on the mlock list
> > and scan the list if under extreme duress?
>
> Actually, you don't need to go thru the overhead of mucking with the
> PG_mlocked flag which incurs the rmap walk on unlock, etc.  If one sets
> the the AS_UNEVICTABLE flag, the pages will be shuffled off the the
> unevictable LRU iff we ever try to reclaim them.  And, we do have the
> function to scan the unevictable lru to "rescue" pages in a given
> mapping should we want to bring them back under extreme load.  We'd need
> to remove the AS_UNEVICTABLE flag, first.  This is how
> SHM_LOCK/SHM_UNLOCK works.

We need some way to control this. If there would be a way to simply switch
off eviction of exec pages (via /proc/sys/vm/never_reclaim_exec_pages or
so) I'd use it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
