Date: Wed, 25 Oct 2006 08:41:07 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2/3] hugetlb: fix prio_tree unit
In-Reply-To: <20061025070805.GA9628@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0610250828020.8576@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0610250323570.30678@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0610250331220.30678@blonde.wat.veritas.com>
 <20061025070805.GA9628@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: Andrew Morton <akpm@osdl.org>, Ken Chen <kenneth.w.chen@intel.com>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Oct 2006, David Gibson wrote:
> 
> Hugh, I'd like to add a testcase to the libhugetlbfs testsuite which
> will trigger this bug, but from the description above I'm not sure
> exactly how to tickle it.  Can you give some more details of what
> sequence of calls will cause the BUG_ON() to be called.
> 
> I've attached the skeleton test I have now, but I'm not sure if it's
> even close to what's really required for this.

I'll take a look, or reconstruct my own sequence, later on today and
send it just to you.  The BUG_ON was not at all what I was expecting,
and I spent quite a while working out how it came about (v_offset
wrapped, so vm_start + v_offset less than vm_start, so the huge unmap
applied to a non-huge vma before it).  Though I'm dubious whether it's
really worthwhile devising such a test now.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
