Date: Tue, 16 Sep 2003 14:17:57 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Freeing boot memory
Message-ID: <3540000.1063747077@flay>
In-Reply-To: <200309161817.37802.lmb@exatas.unisinos.br>
References: <200309161817.37802.lmb@exatas.unisinos.br>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Leandro Motta Barros <lmb@exatas.unisinos.br>, linux-mm@kvack.org
Cc: sisopiii-l@cscience.org
List-ID: <linux-mm.kvack.org>

> I and a colleague are studying the VM subsystem (actually this is the first 
> time we are examining the Linux source code more closely) and have a question 
> or two.
> 
> Well, the questions concern the boot memory allocator. To be more precise, 
> We're interested in the memory deallocation routines. We have seen that it is 
> only possible to free full pages. So, theoretically, if we make several 
> allocations smaller than one page, we will not be able to actually free this 
> memory. I just don't know of this kind of situation happens in real life. Do 
> we currently have some pages of memory "wasted" because the boot memory 
> allocator was not able to free small allocations? Is there any estimate (or 
> benchmark or whatever) on the number of pages that could be freed but are 
> not?
> 
> We have interest in hacking a little bit in the VM, and we thought that trying 
> to find out ways to avoid this problem (if this is really a problem) could be 
> nice. Do you have any thoughts about this?

What would you *do* with this half a page? There's no main memory allocator
to stick it in, as far as I can see.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
