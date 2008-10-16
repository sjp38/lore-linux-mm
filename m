Message-ID: <48F7AFA0.1080100@inria.fr>
Date: Thu, 16 Oct 2008 23:18:24 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm: rework do_pages_move() to work on page_sized
 chunks
References: <48F3AD47.1050301@inria.fr> <48F3AE1D.3060208@inria.fr> <48F79B42.3070106@linux-foundation.org>
In-Reply-To: <48F79B42.3070106@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nathalie Furmento <nathalie.furmento@labri.fr>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
>> +	err = -ENOMEM;
>> +	pm = kmalloc(PAGE_SIZE, GFP_KERNEL);
>> +	if (!pm)
>>     
>
> ok.... But if you need a page sized chunk then you can also do
> 	get_zeroed_page(GFP_KERNEL). Why bother the slab allocator for page 		sized
> allocations?
>   

Right. But why get_zeroed_page()? I don't think I need anything zeroed
(and I needed so, I would have to zero again between each chunk).

alloc_pages(order=0)+__free_pages() is probably good.

>> +		/* fill the chunk pm with addrs and nodes from user-space */
>> +		for (j = 0; j < chunk_nr_pages; j++) {
>>     
>
> j? So the chunk_start used to be i?
>   

The original "i" is somehow "chunk_start+j" now.

Thanks Christoph, I'll send an updated "4/5" patch in the next days.

Brice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
