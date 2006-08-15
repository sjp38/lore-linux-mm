Subject: Re: [PATCH 1/1] network memory allocator.
References: <20060814110359.GA27704@2ka.mipt.ru>
	<20060815002724.a635d775.akpm@osdl.org>
From: Andi Kleen <ak@suse.de>
Date: 15 Aug 2006 10:08:23 +0200
In-Reply-To: <20060815002724.a635d775.akpm@osdl.org>
Message-ID: <p738xlqa0aw.fsf@verdi.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> writes:
> 
> There will be heaps of cacheline pingpong accessing these arrays.  I'd have
> though that
> 
> static struct whatever {
> 	avl_t avl_node_id;
> 	struct avl_node **avl_node_array;
> 	struct list_head *avl_container_array;
> 	struct avl_node *avl_root;
> 	struct avl_free_list *avl_free_list_head;
> 	spinlock_t avl_free_lock;
> } __cacheline_aligned_in_smp whatevers[NR_CPUS];
> 
> would be better.

Or even better per cpu data. New global/static NR_CPUS arrays should be really discouraged.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
