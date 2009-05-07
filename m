Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7BC6B003D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 10:15:00 -0400 (EDT)
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
 class citizen
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.DEB.1.10.0905070935530.24528@qirst.com>
References: <20090430072057.GA4663@eskimo.com>
	 <20090430174536.d0f438dd.akpm@linux-foundation.org>
	 <20090430205936.0f8b29fc@riellaptop.surriel.com>
	 <20090430181340.6f07421d.akpm@linux-foundation.org>
	 <20090430215034.4748e615@riellaptop.surriel.com>
	 <20090430195439.e02edc26.akpm@linux-foundation.org>
	 <49FB01C1.6050204@redhat.com>
	 <20090501123541.7983a8ae.akpm@linux-foundation.org>
	 <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins>
	 <20090507121101.GB20934@localhost>
	 <alpine.DEB.1.10.0905070935530.24528@qirst.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Thu, 07 May 2009 16:15:02 +0200
Message-Id: <1241705702.11251.156.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-05-07 at 09:39 -0400, Christoph Lameter wrote:
> On Thu, 7 May 2009, Wu Fengguang wrote:
> 
> > Introduce AS_EXEC to mark executables and their linked libraries, and to
> > protect their referenced active pages from being deactivated.
> 
> 
> We already have support for mlock(). How is this an improvement? This is
> worse since the AS_EXEC pages stay on the active list and are continually
> rescanned.

It re-instates the young bit for PROT_EXEC pages, so that they will only
be paged when they are really cold, or there is severe pressure.

This simply gives them an edge over regular data. I don't think the
extra scanning is a problem, since you rarely have huge amounts of
executable pages around.

mlock()'ing all code just doesn't sound like a good alternative.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
