Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA19050
	for <linux-mm@kvack.org>; Fri, 28 May 1999 21:59:11 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14159.18916.728327.550606@dukat.scot.redhat.com>
Date: Sat, 29 May 1999 02:59:00 +0100 (BST)
Subject: Re: Q: PAGE_CACHE_SIZE?
In-Reply-To: <Pine.LNX.4.03.9905282326100.19045-100000@mirkwood.nl.linux.org>
References: <14159.137.169623.500547@dukat.scot.redhat.com>
	<Pine.LNX.4.03.9905282326100.19045-100000@mirkwood.nl.linux.org>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@nl.linux.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, ak@muc.de, ebiederm+eric@ccr.net, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 28 May 1999 23:33:33 +0200 (CEST), Rik van Riel
<riel@nl.linux.org> said:

>> This has a lot of really nice properties.  If we record sequential
>> accesses when setting up data in the first place, then we can
>> automatically optimise for that when doing the pageout again.  For swap,
>> it reduces fragmentation: we can allocate in multi-page chunks and keep
>> that allocation persistent.

> Since we keep pages in the page cache after swapping them out,
> we can implement this optimization very cheaply.

It should be cheap, yes, but it will require a fundamental change in the
VM: currently, all swap cache is readonly.  No exceptions.  To keep the
allocation persistent, even over write()s to otherwise unshared pages
(and we need to do to sustain good performance), we need to allow dirty
pages in the swap cache.  The current PG_Dirty work impacts on this.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
