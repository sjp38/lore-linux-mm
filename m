Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8FC6F6B0055
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:09:04 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A802282CA08
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:16:59 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id C36CW4eUZ45s for <linux-mm@kvack.org>;
	Fri, 20 Mar 2009 12:16:55 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 09EBE82C9FF
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:16:55 -0400 (EDT)
Date: Fri, 20 Mar 2009 12:07:22 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00/25] Cleanup and optimise the page allocator V5
In-Reply-To: <20090320153723.GO24586@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903201205260.18010@qirst.com>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903201059240.3740@qirst.com> <20090320153723.GO24586@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Mar 2009, Mel Gorman wrote:

> good idea one way or the other. Course, this meant a search of the PCP
> lists or increasing the size of the PCP structure - swings and
> roundabouts :/

The PCP list structure irks me a bit. Manipulating doubly linked lists
means touching at least 3 cachelines. Is it possible to go to a simple
linked list (one cacheline to be touched)? Or an array of pointers to
pages instead (one cacheline may contian multiple pointers to pcp pages
which means multiple pages could be handled with a single cacheline)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
