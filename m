Date: Sat, 4 Oct 2003 02:31:32 -0400 (EDT)
From: Rajesh Venkatasubramanian <vrajesh@eecs.umich.edu>
Subject: Re: [PATCH] fix split_vma vs. invalidate_mmap_range_list race
In-Reply-To: <20031003224056.09421fb1.akpm@osdl.org>
Message-ID: <Pine.LNX.4.44.0310040223230.27636-100000@cello.eecs.umich.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "David S. Miller" <davem@redhat.com>, hch@lst.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> It looks OK.  I updated the VM lock ranking docco to cover this.

>   *
> + *  ->i_sem
> + *    ->i_shared_sem		(truncate->invalidate_mmap_range)
> + *

I don't understand how my patch introduced this new(?) ordering.
My patch does not introduce any new semaphores or spin_locks in
any code path. Am I missing something ? Please give a clue if so.

Thanks,
Rajesh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
