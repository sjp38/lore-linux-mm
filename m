Date: Wed, 14 Jul 2004 15:56:38 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [Fwd: remap_page_range() vs nopage()]
Message-ID: <20040714225638.GZ3411@holomorphy.com>
References: <1089844986.15840.144.camel@blackcomb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1089844986.15840.144.camel@blackcomb>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michel Hubert <mhubert@matrox.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 14, 2004 at 06:43:06PM -0400, Michel Hubert wrote:
> I previously posted this question to kernelnewbies.org but without 
> getting any answer.  I hope it is not too basic for this mailing list...
> It's written in Linux Device Driver 2nd edition that remap_page_range
> (which maps an entire range at once) should be used for device IO
> whereas nopage (which maps a single page at a time) should be used for
> real physical memory.
> However, I noticed that mmap_mem() in drivers/char/mem.c uses
> exclusively remap_page_range.  How could this work when dealing with non
> contiguous physical memory ?

I gave up on fixing this and the highmem issue with mem.c a while ago.
There's holy penguin pee here, beware.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
