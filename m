From: volodya@mindspring.com
Date: Mon, 30 Oct 2000 07:19:56 -0500 (EST)
Reply-To: volodya@mindspring.com
Subject: Re: page fault.
In-Reply-To: <Pine.LNX.4.10.10010270739550.5849-100000@agastya.serc.iisc.ernet.in>
Message-ID: <Pine.LNX.4.20.0010300718040.429-100000@node2.localnet.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "M.Jagadish Kumar" <jagadish@rishi.serc.iisc.ernet.in>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I was interested in that too :)) So far the best I came up with was a
loadable module that prints out all pages in active memory. Perhaps you
can use it together with debugger to step through the program and see what
happens.

                          Vladimir Dergachev

On Fri, 27 Oct 2000, M.Jagadish Kumar wrote:

> hello,
> Is there any way in which i can know when the pagefault occured,
> i mean at what instruction of my program execution.
> Does OS provide any support. This would help me to improve my program.
> thanx
> jagadish
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
