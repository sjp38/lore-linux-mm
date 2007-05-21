Date: Mon, 21 May 2007 10:08:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] increase struct page size?!
In-Reply-To: <200705201456.26283.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0705211006550.26282@schroedinger.engr.sgi.com>
References: <20070518040854.GA15654@wotan.suse.de>
 <Pine.LNX.4.64.0705191121480.17008@schroedinger.engr.sgi.com>
 <464FCA28.9040009@cosmosbay.com> <200705201456.26283.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Eric Dumazet <dada1@cosmosbay.com>, William Lee Irwin III <wli@holomorphy.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 20 May 2007, Andi Kleen wrote:

> Besides with the scarcity of pageflags it might make sense to do "64 bit only"
> flags at some point.

There is no scarcity of page flags. There is

1. Hoarding by Andrew

2. Waste by Sparsemem (section flags no longer necessary with
   virtual memmap)

2 will hopefully be addressed soon and with that 1 will go away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
