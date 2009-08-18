Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3FF2B6B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 10:22:04 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A9BFF82C2A6
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 10:22:19 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id eMOxmgpiByCN for <linux-mm@kvack.org>;
	Tue, 18 Aug 2009 10:22:15 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D6B8D82C321
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 10:22:13 -0400 (EDT)
Date: Tue, 18 Aug 2009 10:22:01 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC PATCH 0/3] Reduce searching in the page allocator
 fast-path
In-Reply-To: <1250594162-17322-1-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0908181019130.32284@gentwo.org>
References: <1250594162-17322-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


This could be combined with the per cpu ops patch that makes the page
allocator use alloc_percpu for its per cpu data needs. That in turn would
allow the use of per cpu atomics in the hot paths, maybe we can
get to a point where we can drop the irq disable there.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
