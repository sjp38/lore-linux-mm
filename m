Date: Mon, 16 Feb 2004 22:06:48 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] mremap NULL pointer dereference fix
In-Reply-To: <20040216220031.16a2c0c7.akpm@osdl.org>
Message-ID: <Pine.LNX.4.58.0402162203230.2154@home.osdl.org>
References: <Pine.SOL.4.44.0402162331580.20215-100000@blue.engin.umich.edu>
 <Pine.LNX.4.58.0402162127220.30742@home.osdl.org>
 <Pine.LNX.4.58.0402162144510.30742@home.osdl.org> <20040216220031.16a2c0c7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: vrajesh@umich.edu, linux-kernel@vger.kernel.org, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 16 Feb 2004, Andrew Morton wrote:
> 
> This saves a goto.   It works, but I wasn't able to trigger
> the oops without it either.

To trigger the bug you have to have _just_ the right memory usage, I 
suspect. You literally have to have the destination page directory 
allocation unmap the _exact_ source page (which has to be clean) for the 
bug to hit. 

So I suspect the oops only triggers on the machine that the trigger
program was written for.

Your version of the patch saves a goto in the source, but results in an 
extra goto in the generated assembly unless the compiler is clever enough 
to notice the double test for NULL.

Never mind, that's a micro-optimization, and your version is cleaner. 
Let's go with it if Rajesh can verify that it fixes the problem for him.

Rajesh?

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
