Date: Fri, 8 Feb 2008 00:10:00 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [git pull] more SLUB updates for 2.6.25
In-Reply-To: <47AC04CD.9090407@cosmosbay.com>
Message-ID: <Pine.LNX.4.64.0802080008560.22689@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802071755580.7473@schroedinger.engr.sgi.com>
 <200802081812.22513.nickpiggin@yahoo.com.au> <47AC04CD.9090407@cosmosbay.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Feb 2008, Eric Dumazet wrote:

> And SLAB/SLUB allocators, even if only used from process context, want to
> disable/re-enable interrupts...

Not any more..... The new fastpath does allow avoiding interrupt 
enable/disable and we will be hopefully able to increase the scope of that 
over time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
