Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 850066B00F3
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 13:42:55 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E8A7E82C6CF
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 13:47:39 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ho21NR8Akb-j for <linux-mm@kvack.org>;
	Wed, 25 Feb 2009 13:47:39 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7BB7582C6D2
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 13:47:25 -0500 (EST)
Date: Wed, 25 Feb 2009 13:33:07 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
In-Reply-To: <20090225160124.GA31915@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0902251331340.24175@qirst.com>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-21-git-send-email-mel@csn.ul.ie> <20090223013723.1d8f11c1.akpm@linux-foundation.org> <20090223233030.GA26562@csn.ul.ie> <20090223155313.abd41881.akpm@linux-foundation.org>
 <20090224115126.GB25151@csn.ul.ie> <20090224160103.df238662.akpm@linux-foundation.org> <20090225160124.GA31915@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, hannes@cmpxchg.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Wed, 25 Feb 2009, Mel Gorman wrote:

> It'd impact it for sure. Due to the non-temporal stores, I'm surprised
> there is any measurable impact from the patch.  This has likely been the
> case since commit 0812a579c92fefa57506821fa08e90f47cb6dbdd. My reading of
> this (someone correct/enlighten) is that even if the data was cache hot,
> it is pushed out as a result of the non-temporal access.

A nontemporal store simply does not set the used flag for the cacheline.
So the cpu cache LRU will evict the cacheline sooner. Thats at least how
it works on I64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
