Date: Fri, 3 Oct 2003 22:29:21 -0700
From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix split_vma vs. invalidate_mmap_range_list race
Message-Id: <20031003222921.33d5c88d.davem@redhat.com>
In-Reply-To: <Pine.LNX.4.44.0310032353070.26794-100000@cello.eecs.umich.edu>
References: <Pine.LNX.4.44.0310032353070.26794-100000@cello.eecs.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "V. Rajesh" <vrajesh@eecs.umich.edu>
Cc: akpm@osdl.org, hch@lst.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 3 Oct 2003 23:58:04 -0400 (EDT)
"V. Rajesh" <vrajesh@eecs.umich.edu> wrote:

> 4) In arch/sparc64, vm_end is updated without holding i_shared_sem.
>    Check make_hugetlb_page_present.  I hope that is fine, but 
>    I am not sure. 

You can ignore this case for now if you want, the sparc64 hugetlb code
is in a state of disrepair.  I plan to nearly rewrite it over the
weekend so it's more uptodate and in line with the current x86 and
ia64 hugetlb support code.

I think you are right about these races, they exist and they are
real.  Someone should just make sure you haven't added any deadlock
or semaphore taking with spinlocks held in higher level callers.
I don't think your patch does, but it's something to audit.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
