Received: from newsguy.com (thparkth@localhost [127.0.0.1])
	by newsguy.com (8.12.9/8.12.8) with ESMTP id i4CFSfXm057288
	for <linux-mm@kvack.org>; Wed, 12 May 2004 08:28:41 -0700 (PDT)
	(envelope-from thparkth@newsguy.com)
Received: (from thparkth@localhost)
	by newsguy.com (8.12.9/8.12.8/Submit) id i4CFSfOn057287
	for linux-mm@kvack.org; Wed, 12 May 2004 08:28:41 -0700 (PDT)
	(envelope-from thparkth)
Date: Wed, 12 May 2004 08:28:41 -0700 (PDT)
Message-Id: <200405121528.i4CFSfOn057287@newsguy.com>
From: Andrew Crawford <acrawford@ieee.org>
Subject: Re: The long, long life of an inactive_dirty page
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Arjan van de Ven wrote:

>bdflush and co WILL commit the data to disk after like 30 seconds.
>They will not move it to inactive_clean; that will happen at the first
>sight of memory pressure. The code that does that notices that the data
>isn't dirty and won't do a write-out just a move.

Thanks for that. I have a couple of follow-up questions if I may be so bold:

1. Is there any way, from user space, to distinguish inactive_dirty pages
which have actually been written from those which haven't?

2. Is there any reason, conceptually, that bdflush shouldn't move the pages to
the inactive_clean list as page_launder does? After all, they become "known
clean" at that point, not X hours later when there is a memory shortfall.

Cheers,

Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
