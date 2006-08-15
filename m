Date: Tue, 15 Aug 2006 14:02:28 +0400
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/1] network memory allocator.
Message-ID: <20060815100228.GC1092@2ka.mipt.ru>
References: <20060814110359.GA27704@2ka.mipt.ru> <20060815002724.a635d775.akpm@osdl.org> <p738xlqa0aw.fsf@verdi.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <p738xlqa0aw.fsf@verdi.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 15, 2006 at 10:08:23AM +0200, Andi Kleen (ak@suse.de) wrote:
> Andrew Morton <akpm@osdl.org> writes:
> > 
> > There will be heaps of cacheline pingpong accessing these arrays.  I'd have
> > though that
> > 
> > static struct whatever {
> > 	avl_t avl_node_id;
> > 	struct avl_node **avl_node_array;
> > 	struct list_head *avl_container_array;
> > 	struct avl_node *avl_root;
> > 	struct avl_free_list *avl_free_list_head;
> > 	spinlock_t avl_free_lock;
> > } __cacheline_aligned_in_smp whatevers[NR_CPUS];
> > 
> > would be better.
> 
> Or even better per cpu data. New global/static NR_CPUS arrays should be really discouraged.

I had a version with per-cpu data - it is not very convenient to use here with it's 
per_cpu_ptr dereferencings....

> -Andi

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
