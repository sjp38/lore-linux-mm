Date: Mon, 27 Feb 2006 21:32:12 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: unuse_pte: set pte dirty if the page is dirty
In-Reply-To: <20060227203923.24e9336c.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0602272117180.15738@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602271731410.14242@schroedinger.engr.sgi.com>
 <20060227175324.229860ca.akpm@osdl.org> <Pine.LNX.4.64.0602271755070.14367@schroedinger.engr.sgi.com>
 <20060227182137.3106a4cf.akpm@osdl.org> <Pine.LNX.4.64.0602272009100.15012@schroedinger.engr.sgi.com>
 <20060227203923.24e9336c.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: hugh@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Feb 2006, Andrew Morton wrote:

> argh.  Whenever you find yourself thinking of the question-mark operator,
> take a cold shower.

Hehe.... Yes I love it...
 
> This?

Okay lets continue the work based on that...

> I think it has the same race - if the page gets cleaned and someone
> mprotects the vma to remove VM_WRITE, we dirty an undirtiable page.

unuse_pte is used:

1. To switch off a swap device.

2. To reestablish ptes for a migrated anonymous page.

In both cases we are only dealing with anonymous pages. The only writer 
can be the swap code and as far as I can tell the only risk is writing a 
swap page out once again. That is if it would be cleaned by pageout().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
