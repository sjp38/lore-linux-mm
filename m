From: Andi Kleen <ak@suse.de>
Subject: Re: [QUICKLIST 3/4] Quicklist support for x86_64
Date: Mon, 9 Apr 2007 20:53:05 +0200
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com> <200704092049.34317.ak@suse.de> <Pine.LNX.4.64.0704091150260.8783@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704091150260.8783@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704092053.05590.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 09 April 2007 20:51:00 Christoph Lameter wrote:
> On Mon, 9 Apr 2007, Andi Kleen wrote:
> 
> > > It has to be done in sync with tlb flushing.
> > 
> > Why?
> 
> Otherwise you will leak pages to the page allocator before the tlb flush 
> occurred.

I don't get it sorry. Can you please explain in more detail?

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
