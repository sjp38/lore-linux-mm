Date: Tue, 13 May 2003 16:19:38 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [RFC][PATCH] Interface to invalidate regions of mmaps
Message-Id: <20030513161938.1fc00a5e.akpm@digeo.com>
In-Reply-To: <3EC17BA3.7060403@zabbo.net>
References: <20030513133636.C2929@us.ibm.com>
	<20030513152141.5ab69f07.akpm@digeo.com>
	<3EC17BA3.7060403@zabbo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zach Brown <zab@zabbo.net>
Cc: paulmck@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mjbligh@us.ibm.com
List-ID: <linux-mm.kvack.org>

Zach Brown <zab@zabbo.net> wrote:
>
> so what we'd like most is the ability to invalidate a region of the file
> in an efficient go.
> 
> void truncate_inode_pages(struct address_space * mapping, loff_t lstart,
> loff_t end)
> 
> that sort of thing.

That's trivial in 2.5.

>  this might not suck so bad if the page cache was an
> rbtree :)

Or a radix tree.

> but on the other hand, this doesn't solve another problem we have with
> opportunistic lock extents and sparse page cache populations.  Ideally
> we'd like a FS specific pointer in struct page so we can associate pages
> in the cache with a lock,

In 2.5, page->buffers was abstracted out to page->private, and is available
to filesystems for functions such as this.


> but I can't imagine suggesting such a thing
> within earshot of wli. 

wli doesn't have to run your kernel.  If you want to add a pointer to the
pageframe, go add it.  But I'd suggest that you do it with a view to
migrating it to page->private.

When you finally decide to do your development in a development kernel ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
