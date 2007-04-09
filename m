Date: Mon, 9 Apr 2007 11:51:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [QUICKLIST 3/4] Quicklist support for x86_64
In-Reply-To: <200704092049.34317.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0704091150260.8783@schroedinger.engr.sgi.com>
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
 <200704092043.14335.ak@suse.de> <Pine.LNX.4.64.0704091144270.8783@schroedinger.engr.sgi.com>
 <200704092049.34317.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Apr 2007, Andi Kleen wrote:

> > It has to be done in sync with tlb flushing.
> 
> Why?

Otherwise you will leak pages to the page allocator before the tlb flush 
occurred.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
