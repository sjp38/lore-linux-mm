Date: Mon, 22 Mar 2004 01:46:52 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040322004652.GF3649@dualathlon.random>
References: <Pine.LNX.4.44.0403150527400.28579-100000@localhost.localdomain> <Pine.GSO.4.58.0403211634350.10248@azure.engin.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.58.0403211634350.10248@azure.engin.umich.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajesh Venkatasubramanian <vrajesh@umich.edu>
Cc: akpm@osdl.org, torvalds@osdl.org, hugh@veritas.com, mbligh@aracnet.com, riel@redhat.com, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 21, 2004 at 05:10:45PM -0500, Rajesh Venkatasubramanian wrote:
> 	http://marc.theaimsgroup.com/?l=linux-kernel&m=107966438414248
> 
> 	Andrea says the system may hang, however, in this case system
> 	does not hang.

It's a live lock, not a deadlock. I didn't wait more than a few minutes
every time before declaring the kernel broken and rebooting the machine.
still if the prio_tree fixed my problem it means at the very least it
reduced the contention on the locks a lot ;)

It would be curious to test it after changing the return 1 to return 0
in the page_referenced trylock failures?

the results looks great, thanks.

what about the cost of a tree rebalance, is that O(log(N)) like with the
rbtrees?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
