Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA10016
	for <linux-mm@kvack.org>; Tue, 17 Nov 1998 07:06:43 -0500
Date: Tue, 17 Nov 1998 12:06:33 GMT
Message-Id: <199811171206.MAA01194@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: unexpected paging during large file reads in 2.1.127
In-Reply-To: <Pine.LNX.3.96.981117073807.2352A-100000@mirkwood.dummy.home>
References: <199811162305.XAA07996@dax.scot.redhat.com>
	<Pine.LNX.3.96.981117073807.2352A-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, "David J. Fred" <djf@ic.net>, linux-kernel@vger.rutgers.edu, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 17 Nov 1998 07:42:12 +0100 (CET), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> I meant the page aging that occurs in vmscan.c, where we
> decide on which page to unmap from a program's address
> space. 

For the last time, NO IT DOES NOT.  Read the source.  Linus removed it.
We do not use page->age AT ALL in vmscan.c in current 2.1 kernels.

> There we do aging while we don't age pages from files that are read().

For the last time, YES WE DO.  shrink_mmap() for the page cache in
mm/filemap.c still uses page aging in current 2.1 kernels.  Read() uses
the page cache.

This is a problem.

> OK, I can (and have for quite a while) agree with this.
> Kernels with this feature and enough memory will run great,
> maybe small machines (<16M) will have a bit of trouble
> keeping up readahead performance (since kswapd will have
> made it's round a bit fast) but those machines will have
> sucky performance anyway :)

This change improves low memory performance very measurably in all tests
I have tried so far.

--Stephen.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
