Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E91376B0055
	for <linux-mm@kvack.org>; Thu,  7 May 2009 11:46:43 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D4CF782C4E9
	for <linux-mm@kvack.org>; Thu,  7 May 2009 11:59:24 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rg0nFvfD9IG5 for <linux-mm@kvack.org>;
	Thu,  7 May 2009 11:59:24 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E3C8C82C4F2
	for <linux-mm@kvack.org>; Thu,  7 May 2009 11:59:17 -0400 (EDT)
Date: Thu, 7 May 2009 11:36:25 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
 citizen
In-Reply-To: <1241707081.11251.160.camel@twins>
Message-ID: <alpine.DEB.1.10.0905071120110.10171@qirst.com>
References: <20090430072057.GA4663@eskimo.com>  <20090430174536.d0f438dd.akpm@linux-foundation.org>  <20090430205936.0f8b29fc@riellaptop.surriel.com>  <20090430181340.6f07421d.akpm@linux-foundation.org>  <20090430215034.4748e615@riellaptop.surriel.com>
 <20090430195439.e02edc26.akpm@linux-foundation.org>  <49FB01C1.6050204@redhat.com>  <20090501123541.7983a8ae.akpm@linux-foundation.org>  <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins>  <20090507121101.GB20934@localhost>
 <alpine.DEB.1.10.0905070935530.24528@qirst.com>  <1241705702.11251.156.camel@twins>  <alpine.DEB.1.10.0905071016410.24528@qirst.com> <1241707081.11251.160.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 7 May 2009, Peter Zijlstra wrote:

> So if you haven't ran any firefox code, it should be gone from the
> active list after 2 full cycles, and from the inactive list on the first
> full inactive cycle after that.

So some incremental changes. I still want to use firefox after my backup
without having to wait 5 minutes while its paging exec pages back in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
