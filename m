Date: Thu, 19 Apr 2001 18:12:46 +0200 (MEST)
From: Simon Derr <Simon.Derr@imag.fr>
Subject: Re: Want to allocate almost all the memory with no swap
In-Reply-To: <200104191557.LAA28201@multics.mit.edu>
Message-ID: <Pine.LNX.4.21.0104191809300.10028-100000@guarani.imag.fr>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kev <klmitch@MIT.EDU>
Cc: Simon Derr <Simon.Derr@imag.fr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Apr 2001, Kev wrote:

> 
> > Well, I have removed as many processes deamons as I could, and there are
> > not many left.
> > But under both 2.4.2 and 2.2.17 (with swap on)I get, when I run my
> > program:
> > 
> > mlockall: Cannot allocate memory
> 
> mlockall() requires root priviledges.
Even when running the program as root I get this error.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
