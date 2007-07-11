Date: Wed, 11 Jul 2007 13:39:44 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: buffered write patches, -mm merge plans for 2.6.23
Message-ID: <20070711113944.GC18665@lst.de>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070710013152.ef2cd200.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>  pagefault-in-write deadlock fixes.  Will hold for 2.6.24.

Why that?  This stuff has been in forever and is needed at various
levels.  We need this in for anything to move forward on the buffered
write front.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
