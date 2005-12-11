Date: Sat, 10 Dec 2005 16:47:36 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: allowed pages in the block later, was Re: [Ext2-devel] [PATCH]
 ext3: avoid sending down non-refcounted pages
Message-Id: <20051210164736.6e4eaa3f.akpm@osdl.org>
In-Reply-To: <20051208134239.GA13376@infradead.org>
References: <20051208180900T.fujita.tomonori@lab.ntt.co.jp>
	<20051208101833.GM14509@schatzie.adilger.int>
	<20051208134239.GA13376@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: fujita.tomonori@lab.ntt.co.jp, michaelc@cs.wisc.edu, linux-fsdevel@vger.kernel.org, ext2-devel@lists.sourceforge.net, open-iscsi@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@infradead.org> wrote:
>
> The problem we're trying to solve here is how do implement network block
>  devices (nbd, iscsi) efficiently.  The zero copy codepath in the networking
>  layer does need to grab additional references to pages.  So to use sendpage
>  we need a refcountable page.  pages used by the slab allocator are not
>  normally refcounted so try to do get_page/pub_page on them will break.

I don't get it.  Doing get_page/put_page on a slab-allocated page should do
the right thing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
