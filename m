Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A6DB56B0082
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 15:03:19 -0500 (EST)
Date: Sun, 31 Jan 2010 20:03:16 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: Bug in find_vma_prev - mmap.c
In-Reply-To: <6cafb0f01001311056k3c6a882fla42b714256bb1e6d@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1001311955510.6227@sister.anvils>
References: <6cafb0f01001291657q4ccbee86rce3143a4be7a1433@mail.gmail.com>  <201001301929.47659.rjw@sisk.pl>  <alpine.LSU.2.00.1001311616590.5897@sister.anvils> <6cafb0f01001311056k3c6a882fla42b714256bb1e6d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tony Perkins <da.perk@gmail.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 31 Jan 2010, Tony Perkins wrote:
> 
> Say for instance, that addr is not in the list (but is greater than
> the last element).

Before, you appeared to be talking about a discrepancy with the first
vma; now you're talking about a discrepancy with the last vma?
Or a discrepancy when the first vma is the last vma?

> find_vma_prev will return the last node in the list, whereas find_vma
> will return NULL.

I'd expect find_vma_prev to return prev->vm_next, which would be NULL.

> 
> It seems that it is just inconsistent, in what it should return
> regarding the two.
> For instance, find_vma_prev will never return NULL, if there's at
> least one node within the tree, whereas find_vma would.
> find_extend_vma uses find_vma_prev and checks to see if it returns
> NULL and is less than the return address (which would always be the
> case).

Are we disagreeing about our readings of the code, or have you seen a
problem in practice?

I admit I've not tried running this, injecting addresses into find_vma_prev
and printk'ing the result; but I'm missing what leads you to say that
find_vma_prev will never return NULL.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
