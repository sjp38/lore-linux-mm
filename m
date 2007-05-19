Date: Sat, 19 May 2007 11:25:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] increase struct page size?!
In-Reply-To: <20070519181501.GC19966@holomorphy.com>
Message-ID: <Pine.LNX.4.64.0705191121480.17008@schroedinger.engr.sgi.com>
References: <20070518040854.GA15654@wotan.suse.de>
 <Pine.LNX.4.64.0705181112250.11881@schroedinger.engr.sgi.com>
 <20070519012530.GB15569@wotan.suse.de> <20070519181501.GC19966@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 19 May 2007, William Lee Irwin III wrote:

> However, there are numerous optimizations and features made possible
> with flag bits, which might as could be made cheap by padding struct
> page up to the next highest power of 2 bytes with space for flag bits.

Well the last time I tried to get this by Andi we became a bit concerned 
when we realized that the memory map would grow by 14% in size. Given 
that 4k page size challenged platforms have a huge amount of page structs 
that growth is significant. I think it would be fine to do it for IA64 
with 16k page size but not for x86_64.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
