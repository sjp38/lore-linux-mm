Date: Sat, 06 Nov 2004 07:17:38 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
Message-ID: <204290000.1099754257@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
References: <4189EC67.40601@yahoo.com.au>  <Pine.LNX.4.58.0411040820250.8211@schroedinger.engr.sgi.com> <418AD329.3000609@yahoo.com.au>  <Pine.LNX.4.58.0411041733270.11583@schroedinger.engr.sgi.com> <418AE0F0.5050908@yahoo.com.au>  <418AE9BB.1000602@yahoo.com.au><1099622957.29587.101.camel@gaston> <418C55A7.9030100@yahoo.com.au> <Pine.LNX.4.58.0411060120190.22874@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

> My page scalability patches need to make rss atomic and now with the
> addition of anon_rss I would also have to make that atomic.
> 
> But when I looked at the code I found that the only significant use of
> both is in for proc statistics. There are 3 other uses in mm/rmap.c where
> the use of mm->rss may be replaced by mm->total_vm.
> 
> So I removed all uses of mm->rss and anon_rss from the kernel and
> introduced a bean counter count_vm() that is only run when the
> corresponding /proc file is used. count_vm then runs throught the vm
> and counts all the page types. This could also add additional page types to our
> statistics and solve some of the consistency issues.

I would've thought SGI would be more worried about this kind of thing
than anyone else ... what's going to happen when you type 'ps' on a large
box, and it does this for 10,000 processes? 

If you want to make it quicker, how about doing per-cpu stats, and totalling
them at runtime, which'd be lockless, instead of all the atomic ops?

M.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
