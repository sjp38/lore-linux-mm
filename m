Subject: Re: [patch 2/2] htlb forget rss with pt sharing
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <000101c6f3b2$7f9cf980$ff0da8c0@amr.corp.intel.com>
References: <000101c6f3b2$7f9cf980$ff0da8c0@amr.corp.intel.com>
Content-Type: text/plain
Date: Sat, 21 Oct 2006 17:58:41 +0200
Message-Id: <1161446321.5230.69.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Hugh Dickins' <hugh@veritas.com>, 'Andrew Morton' <akpm@osdl.org>, linux-mm@kvack.org, arjan <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-10-19 at 12:12 -0700, Chen, Kenneth W wrote:
> Imprecise RSS accounting is an irritating ill effect with pt sharing. 
> After consulted with several VM experts, I have tried various methods to
> solve that problem: (1) iterate through all mm_structs that share the PT
> and increment count; (2) keep RSS count in page table structure and then
> sum them up at reporting time.  None of the above methods yield any
> satisfactory implementation.
> 
> Since process RSS accounting is pure information only, I propose we don't
> count them at all for hugetlb page. rlimit has such field, though there is
> absolutely no enforcement on limiting that resource.  One other method is
> to account all RSS at hugetlb mmap time regardless they are faulted or not.
> I opt for the simplicity of no accounting at all.

I do feel I must object to this. Especially with hugetlb getting real
accessible with libhugetlbfs etc., I suspect administrators will shortly
be confused where all their memory went.

Also, like stated earlier, I don't like breaking RSS accounting now, and
when we do have thought up a valid meaning for the field, again. You
state correctly that RLIMIT_RSS is currently not enforced, but its an
active area int that we do want to enforce it in the near future.

I do grant its a very hard problem, comming up with a
valid/meaningfull/workable definition of RSS, but I dislike this opt out
of just not counting it at all - and thereby making the effort of
enforcing RSS harder.

Just my 0.02 eurocent ;-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
