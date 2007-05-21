Date: Mon, 21 May 2007 10:06:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] increase struct page size?!
In-Reply-To: <20070520092552.GA7318@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705211004340.26282@schroedinger.engr.sgi.com>
References: <20070518040854.GA15654@wotan.suse.de>
 <Pine.LNX.4.64.0705181112250.11881@schroedinger.engr.sgi.com>
 <20070519012530.GB15569@wotan.suse.de> <20070519181501.GC19966@holomorphy.com>
 <20070520052229.GA9372@wotan.suse.de> <20070520084647.GF19966@holomorphy.com>
 <20070520092552.GA7318@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: William Lee Irwin III <wli@holomorphy.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 20 May 2007, Nick Piggin wrote:

> I _am_ considering the average case, and I consider the aligned structure
> is likely to win on average :) I just don't have numbers for it yet.

I'd be glad too if you could get some numbers. I did some benchmarking a 
few weeks ago on x86_64 and I found only a very minimal performance drop 
if the calculation was simplified. 

Note also that a smaller structure means that more page structs can be 
covered by a certain amount of cachelines. Doing the alignment may cause 
more cacheline misses.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
