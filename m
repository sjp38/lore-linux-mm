Date: Tue, 17 Feb 2004 08:23:34 -0500 (EST)
From: Rajesh Venkatasubramanian <vrajesh@umich.edu>
Subject: Re: [PATCH] mremap NULL pointer dereference fix
In-Reply-To: <Pine.LNX.4.58.0402162203230.2154@home.osdl.org>
Message-ID: <Pine.SOL.4.44.0402170821070.13429-100000@azure.engin.umich.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>


> To trigger the bug you have to have _just_ the right memory usage, I
> suspect. You literally have to have the destination page directory
> allocation unmap the _exact_ source page (which has to be clean) for the
> bug to hit.
>

To trigger the bug, I have to run my test program in a "while true;"
loop for an hour or so.

> So I suspect the oops only triggers on the machine that the trigger
> program was written for.
>
> Your version of the patch saves a goto in the source, but results in an
> extra goto in the generated assembly unless the compiler is clever enough
> to notice the double test for NULL.
>
> Never mind, that's a micro-optimization, and your version is cleaner.
> Let's go with it if Rajesh can verify that it fixes the problem for him.

I will test the patch and report.

Thanks,
Rajesh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
