Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 094C76B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 07:48:13 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 98C7B82C850
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 07:48:33 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4UQP-50wjUNG for <linux-mm@kvack.org>;
	Wed, 19 Aug 2009 07:48:28 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id EFDF682C5FD
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 07:48:28 -0400 (EDT)
Date: Wed, 19 Aug 2009 07:48:12 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC PATCH 0/3] Reduce searching in the page allocator
 fast-path
In-Reply-To: <20090819090843.GB24809@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0908190747190.5621@gentwo.org>
References: <1250594162-17322-1-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0908181019130.32284@gentwo.org> <20090818165340.GB13435@csn.ul.ie> <alpine.DEB.1.10.0908181357100.3840@gentwo.org> <20090819090843.GB24809@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Aug 2009, Mel Gorman wrote:

> Ok, I don't see this particular patch merged, is it in a merge queue somewhere?

The patch depends on Tejun's work to be merged that makes the per cpu
allocator available on all platforms. I believe that is in the queue for
2.6.32.

> After glancing through, I can see how it might help.  I'm going to drop patch
> 3 of this set that shuffles data from the PCP to the zone and take a closer
> look at those patches. Patch 1 and 2 of this set should still go ahead. Do
> you agree?

Yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
