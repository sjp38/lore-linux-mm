Message-ID: <464FCA28.9040009@cosmosbay.com>
Date: Sun, 20 May 2007 06:10:16 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [rfc] increase struct page size?!
References: <20070518040854.GA15654@wotan.suse.de> <Pine.LNX.4.64.0705181112250.11881@schroedinger.engr.sgi.com> <20070519012530.GB15569@wotan.suse.de> <20070519181501.GC19966@holomorphy.com> <Pine.LNX.4.64.0705191121480.17008@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0705191121480.17008@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Christoph Lameter a ecrit :
> On Sat, 19 May 2007, William Lee Irwin III wrote:
> 
>> However, there are numerous optimizations and features made possible
>> with flag bits, which might as could be made cheap by padding struct
>> page up to the next highest power of 2 bytes with space for flag bits.
> 
> Well the last time I tried to get this by Andi we became a bit concerned 
> when we realized that the memory map would grow by 14% in size. Given 
> that 4k page size challenged platforms have a huge amount of page structs 
> that growth is significant. I think it would be fine to do it for IA64 
> with 16k page size but not for x86_64.

This reminds me Andi attempted in the past to convert 'flags' to a 32 bits field :

http://marc.info/?l=linux-kernel&m=107903527523739&w=2

I wonder why this idea was not taken, saving 2MB per GB of memory is nice :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
