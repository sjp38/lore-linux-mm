Date: Tue, 16 Sep 2003 14:34:23 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Freeing boot memory
Message-ID: <20030916213423.GF14079@holomorphy.com>
References: <200309161817.37802.lmb@exatas.unisinos.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200309161817.37802.lmb@exatas.unisinos.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Leandro Motta Barros <lmb@exatas.unisinos.br>
Cc: linux-mm@kvack.org, sisopiii-l@cscience.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 16, 2003 at 06:17:37PM -0300, Leandro Motta Barros wrote:
> Well, the questions concern the boot memory allocator. To be more precise, 
> We're interested in the memory deallocation routines. We have seen that it is 
> only possible to free full pages. So, theoretically, if we make several 
> allocations smaller than one page, we will not be able to actually free this 
> memory. I just don't know of this kind of situation happens in real life. Do 
> we currently have some pages of memory "wasted" because the boot memory 
> allocator was not able to free small allocations? Is there any estimate (or 
> benchmark or whatever) on the number of pages that could be freed but are 
> not?

When I rewrote this, I got crapped on. I highly doubt anyone will
listen this time, either.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
