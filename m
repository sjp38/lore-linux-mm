Date: Thu, 18 May 2006 11:14:16 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Query re:  mempolicy for page cache pages
Message-Id: <20060518111416.51de0127.akpm@osdl.org>
In-Reply-To: <1147974599.5195.96.camel@localhost.localdomain>
References: <1147974599.5195.96.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, clameter@sgi.com, ak@suse.de, stevel@mvista.com
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
>
> 1) What ever happened to Steve's patch set?

They were based on Andi's 4-level-pagetable work.  Then we merged Nick's
4-level-pagetable work instead, so
numa-policies-for-file-mappings-mpol_mf_move.patch broke horridly and I
dropped it.  Steve said he'd redo the patch based on the new pagetable code
and would work with SGI on getting it benchmarked, but that obviously
didn't happen.

I was a bit concerned about the expansion in sizeof(address_space), but we
ended up agreeing that it's numa-only and NUMA machines tend to have lots
of memory anyway.  That being said, it would still be better to have a
pointer to a refcounted shared_policy in the address_space if poss, rather
than aggregating the whole thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
