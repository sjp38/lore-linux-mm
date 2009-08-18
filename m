Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 74E806B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 15:05:31 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 546C282C7EF
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 15:05:42 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LT8ZBQhnc7+k for <linux-mm@kvack.org>;
	Tue, 18 Aug 2009 15:05:38 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 53BC182C7AC
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 15:05:38 -0400 (EDT)
Date: Tue, 18 Aug 2009 15:05:25 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC PATCH 0/3] Reduce searching in the page allocator
 fast-path
In-Reply-To: <20090818165340.GB13435@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0908181357100.3840@gentwo.org>
References: <1250594162-17322-1-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0908181019130.32284@gentwo.org> <20090818165340.GB13435@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Aug 2009, Mel Gorman wrote:

> Can you point me to which patchset you are talking about specifically that
> uses per-cpu atomics in the hot path? There are a lot of per-cpu patches
> related to you that have been posted in the last few months and I'm not sure
> what any of their merge status' is.

The following patch just moved the page allocator to use the new per cpu
allocator. It does not use per cpu atomic yet but its possible then.

http://marc.info/?l=linux-mm&m=124527414206546&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
