Date: Thu, 25 Mar 2004 23:06:50 -0500 (EST)
From: Rajesh Venkatasubramanian <vrajesh@umich.edu>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity
 fix
In-Reply-To: <20040325225919.GL20019@dualathlon.random>
Message-ID: <Pine.GSO.4.58.0403252258170.4298@azure.engin.umich.edu>
References: <Pine.LNX.4.44.0403150527400.28579-100000@localhost.localdomain>
 <Pine.GSO.4.58.0403211634350.10248@azure.engin.umich.edu>
 <20040325225919.GL20019@dualathlon.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: akpm@osdl.org, torvalds@osdl.org, hugh@veritas.com, mbligh@aracnet.com, riel@redhat.com, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrea,

I am yet to look at the new -aa you released. A small change is
required below. Currently, I cannot generate a patch. Sorry. Please
fix it by hand. Thanks.

>
> -	list_for_each_entry(vma, list, shared) {
> +	vma = __vma_prio_tree_first(root, &iter, h_pgoff, h_pgoff);

This should be:
	vma = __vma_prio_tree_first(root, &iter, h_pgoff, ULONG_MAX);

> +	while (vma) {
>  		unsigned long h_vm_pgoff;
[snip]
> +		vma = __vma_prio_tree_next(vma, root, &iter, h_pgoff, h_pgoff);
>  	}

and here it should be:
		vma = __vma_prio_tree_next(vma, root, &iter,
						h_pgoff, ULONG_MAX);

Thanks,
Rajesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
