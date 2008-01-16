Date: Wed, 16 Jan 2008 12:39:31 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Increasing partial pages
In-Reply-To: <20080116195949.GO18741@parisc-linux.org>
Message-ID: <Pine.LNX.4.64.0801161219050.9694@schroedinger.engr.sgi.com>
References: <20080116195949.GO18741@parisc-linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jan 2008, Matthew Wilcox wrote:

> We tested 2.6.24-rc5 + 76be895001f2b0bee42a7685e942d3e08d5dd46c
> 
> For 2.6.24-rc5 before that patch, slub had a performance penalty of
> 6.19%.  With the patch, slub's performance penalty was reduced to 4.38%.
> This is great progress.  Can you think of anything else worth trying?

Ahhh.. Good to hear that the issue on x86_64 gets better. I am still 
waiting for a test with the patchset that I did specifically to address 
your regression: http://lkml.org/lkml/2007/10/27/245 (where I tried to 
come up with an in kernel benchmark that exposes the issue even more)? It 
is much more likely now that this patchset in mm addresses your regression 
since the hackbench performance improvement fix already reduce it 
partially.

2.6.25 will add the performance enhancements for the free patch that I 
hope will address your issues. In addition the fastpath was reworked. See 
the patch mentioned above.

2.6.26 (hopefully) will remove the per cpu array lookups that are 
currently necessary on x86 and other platforms through improvements to 
the way that percpu data is handled. That leads to further fastpath 
improvements.

There are also ways to optimize the partial block handling further by f.e.
switching the percpu slab on free in order to have a higher fastpath rate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
