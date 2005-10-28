Date: Fri, 28 Oct 2005 14:28:42 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051028182842.GA8514@ccure.user-mode-linux.org>
References: <1130366995.23729.38.camel@localhost.localdomain> <20051028034616.GA14511@ccure.user-mode-linux.org> <43624F82.6080003@us.ibm.com> <200510281910.39646.blaisorblade@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200510281910.39646.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 28, 2005 at 07:10:39PM +0200, Blaisorblade wrote:
> It may be good when the patch is already really polished, IMHO, but not for 
> verifying what's really wrong.
> 
> Also, you can gdb an UML running with the patch, to verify what's going on.
> 
> But I wouldn't suggest testing this with nested UMLs - using that means 
> looking for trouble.

I think he's looking for test cases, not debugging this inside a UML.

If he's debugging on hardware, then nesting UMLs doesn't come into the
picture.

				Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
