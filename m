Message-ID: <48F79B42.3070106@linux-foundation.org>
Date: Thu, 16 Oct 2008 14:51:30 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm: rework do_pages_move() to work on page_sized
 chunks
References: <48F3AD47.1050301@inria.fr> <48F3AE1D.3060208@inria.fr>
In-Reply-To: <48F3AE1D.3060208@inria.fr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nathalie Furmento <nathalie.furmento@labri.fr>
List-ID: <linux-mm.kvack.org>

Brice Goglin wrote:

> +	err = -ENOMEM;
> +	pm = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +	if (!pm)

ok.... But if you need a page sized chunk then you can also do
	get_zeroed_page(GFP_KERNEL). Why bother the slab allocator for page 		sized
allocations?


> +	chunk_nr_pages = PAGE_SIZE/sizeof(struct page_to_node) - 1;

Blanks missing.



> +		/* fill the chunk pm with addrs and nodes from user-space */
> +		for (j = 0; j < chunk_nr_pages; j++) {

j? So the chunk_start used to be i?


Acked-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
