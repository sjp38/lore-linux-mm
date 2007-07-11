Date: Wed, 11 Jul 2007 10:23:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: buffered write patches, -mm merge plans for 2.6.23
Message-Id: <20070711102332.d5ffd572.akpm@linux-foundation.org>
In-Reply-To: <20070711113944.GC18665@lst.de>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	<20070711113944.GC18665@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jul 2007 13:39:44 +0200 Christoph Hellwig <hch@lst.de> wrote:

> >  pagefault-in-write deadlock fixes.  Will hold for 2.6.24.
> 
> Why that?

At Nick's request.  More work is needed and the code hasn't had a lot of
testing/thought/exposure/review.

>  This stuff has been in forever and is needed at various
> levels.  We need this in for anything to move forward on the buffered
> write front.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
