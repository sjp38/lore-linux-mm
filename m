Date: Mon, 5 Apr 2004 06:42:50 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040405044250.GB2234@dualathlon.random>
References: <Pine.LNX.4.44.0403150527400.28579-100000@localhost.localdomain> <Pine.GSO.4.58.0403211634350.10248@azure.engin.umich.edu> <20040325225919.GL20019@dualathlon.random> <Pine.GSO.4.58.0403252258170.4298@azure.engin.umich.edu> <Pine.LNX.4.58.0404042311380.19523@red.engin.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0404042311380.19523@red.engin.umich.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajesh Venkatasubramanian <vrajesh@umich.edu>
Cc: akpm@osdl.org, hugh@veritas.com, mbligh@aracnet.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 04, 2004 at 11:14:25PM -0400, Rajesh Venkatasubramanian wrote:
> 
> This patch fixes a couple of mask overflow bugs in the prio_tree
> search code. These bugs trigger in some very rare corner cases.
> The patch also removes a couple of BUG_ONs from the fast paths.
> 
> Now the code is well-tested. I have tested all __vma_prio_tree_*
> functions in the user-space with as many as 10 million vmas and
> all prio_tree functions work fine.

This is a great news.

> 
> This patch is against 2.6.5-aa2. It will apply on top of Hugh's
> patches also.

I'm releasing an update for this.

> If you like to test the prio_tree code further in the user-space,
> the programs in the following link may help you.
> 
> http://www-personal.engin.umich.edu/~vrajesh/linux/prio_tree/user_space/

thanks for this great work.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
