Date: Thu, 10 Oct 2002 11:32:27 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Hangs in 2.5.41-mm1
Message-ID: <20021010183227.GA12432@holomorphy.com>
References: <3DA4A06A.B84D4C05@digeo.com> <1034264750.30975.83.camel@plars> <3DA5B077.215D7626@digeo.com> <3DA5B277.B5BFC9C0@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DA5B277.B5BFC9C0@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Paul Larson <plars@linuxtestproject.org>, Manfred Spraul <manfred@colorfullife.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 10, 2002 at 10:01:43AM -0700, Andrew Morton wrote:
> Or it could be that the inode cache has been corrupted.
> Bill, can you review the handling in there?  It'd be a
> bit sad if one of the hugetlb privately-kmalloced inodes
> were put back onto the inode_cachep slab somehow.

ergh, the refcounting down there looks dangerous to say the least.

Fix ETA 2-4 hours depending on what else I need to do.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
