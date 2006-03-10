Date: Thu, 9 Mar 2006 21:48:46 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] hugetlb strict commit accounting - v3
Message-Id: <20060309214846.64943f60.akpm@osdl.org>
In-Reply-To: <20060309213957.211aaec9.akpm@osdl.org>
References: <200603100314.k2A3Evg28313@unix-os.sc.intel.com>
	<20060310043737.GG9776@localhost.localdomain>
	<20060309204653.0f780ba1.akpm@osdl.org>
	<20060310045033.GH9776@localhost.localdomain>
	<20060309213957.211aaec9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david@gibson.dropbear.id.au, kenneth.w.chen@intel.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:
>
>  > > private_list and private_lock are available for use by the subsystem which
>  > > owns this mapping's address_space_operations.  ie: hugetlbfs.
>  > 
>  > If that's so, why is clear_inode messing with it?
>  > 
> 
>  Oh.   It's being bad.

That doesn't rule out reuse.  It just means that only buffer_head users are
allowed to run clear_inode() with a non-empty list.

So it's bad, but not fatally so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
