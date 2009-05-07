Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 61FF96B003D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 09:49:59 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9177E82C4B6
	for <linux-mm@kvack.org>; Thu,  7 May 2009 10:02:45 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1IQHCvTx8BSr for <linux-mm@kvack.org>;
	Thu,  7 May 2009 10:02:45 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4745F82C4B9
	for <linux-mm@kvack.org>; Thu,  7 May 2009 10:02:39 -0400 (EDT)
Date: Thu, 7 May 2009 09:39:30 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
 citizen
In-Reply-To: <20090507121101.GB20934@localhost>
Message-ID: <alpine.DEB.1.10.0905070935530.24528@qirst.com>
References: <20090430072057.GA4663@eskimo.com> <20090430174536.d0f438dd.akpm@linux-foundation.org> <20090430205936.0f8b29fc@riellaptop.surriel.com> <20090430181340.6f07421d.akpm@linux-foundation.org> <20090430215034.4748e615@riellaptop.surriel.com>
 <20090430195439.e02edc26.akpm@linux-foundation.org> <49FB01C1.6050204@redhat.com> <20090501123541.7983a8ae.akpm@linux-foundation.org> <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins> <20090507121101.GB20934@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 7 May 2009, Wu Fengguang wrote:

> Introduce AS_EXEC to mark executables and their linked libraries, and to
> protect their referenced active pages from being deactivated.


We already have support for mlock(). How is this an improvement? This is
worse since the AS_EXEC pages stay on the active list and are continually
rescanned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
