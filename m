From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17532.305.602559.660069@gargle.gargle.HOWL>
Date: Tue, 30 May 2006 12:24:17 +0400
Subject: Re: [rfc][patch] remove racy sync_page?
In-Reply-To: <447BD63D.2080900@yahoo.com.au>
References: <447AC011.8050708@yahoo.com.au>
	<20060529121556.349863b8.akpm@osdl.org>
	<447B8CE6.5000208@yahoo.com.au>
	<20060529183201.0e8173bc.akpm@osdl.org>
	<447BB3FD.1070707@yahoo.com.au>
	<Pine.LNX.4.64.0605292117310.5623@g5.osdl.org>
	<447BD31E.7000503@yahoo.com.au>
	<447BD63D.2080900@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com, axboe@suse.de
List-ID: <linux-mm.kvack.org>

Nick Piggin writes:
 > Nick Piggin wrote:
 > > Linus Torvalds wrote:
 > > 
 > >>
 > >> Why do you think the IO layer should get larger requests?
 > > 
 > > 
 > > For workloads where plugging helps (ie. lots of smaller, contiguous
 > > requests going into the IO layer), should be pretty good these days
 > > due to multiple readahead and writeback.
 > 
 > Let me try again.
 > 
 > For workloads where plugging helps (ie. lots of smaller, contiguous
 > requests going into the IO layer), the request pattern should be
 > pretty good without plugging these days, due to multiple page
 > readahead and writeback.

Pageout by VM scanner doesn't benefit from those, and it is still quite
important in some workloads (e.g., mmap intensive).

Nikita.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
