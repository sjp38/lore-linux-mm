From: Andi Kleen <ak@suse.de>
Subject: Re: [rfc] increase struct page size?!
Date: Sun, 20 May 2007 14:56:25 +0200
References: <20070518040854.GA15654@wotan.suse.de> <Pine.LNX.4.64.0705191121480.17008@schroedinger.engr.sgi.com> <464FCA28.9040009@cosmosbay.com>
In-Reply-To: <464FCA28.9040009@cosmosbay.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Message-Id: <200705201456.26283.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Christoph Lameter <clameter@sgi.com>, William Lee Irwin III <wli@holomorphy.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sunday 20 May 2007 06:10:16 Eric Dumazet wrote:
> Christoph Lameter a ecrit :
> > On Sat, 19 May 2007, William Lee Irwin III wrote:
> > 
> >> However, there are numerous optimizations and features made possible
> >> with flag bits, which might as could be made cheap by padding struct
> >> page up to the next highest power of 2 bytes with space for flag bits.
> > 
> > Well the last time I tried to get this by Andi we became a bit concerned 
> > when we realized that the memory map would grow by 14% in size. Given 
> > that 4k page size challenged platforms have a huge amount of page structs 
> > that growth is significant. I think it would be fine to do it for IA64 
> > with 16k page size but not for x86_64.
> 
> This reminds me Andi attempted in the past to convert 'flags' to a 32 bits field :
> 
> http://marc.info/?l=linux-kernel&m=107903527523739&w=2
> 
> I wonder why this idea was not taken, saving 2MB per GB of memory is nice :)

It made sense in 2.4, but in 2.6 it doesn't actually save any memory because
there is no field to put into the freed padding.

Besides with the scarcity of pageflags it might make sense to do "64 bit only"
flags at some point.

-Andi
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
