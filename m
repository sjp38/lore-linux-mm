Date: Mon, 4 Sep 2000 21:49:56 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: zero copy IO project
In-Reply-To: <39B3FD1D.EB33427D@free.fr>
Message-ID: <Pine.LNX.4.21.0009042136030.23932-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fabio Riccardi <fabio.riccardi@free.fr>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Sep 2000, Fabio Riccardi wrote:

> Hi, thanks for the pointers & explainations!
> 
> What I want is a server capable of handling high bandwidth communication and
> the kiobuf mechanisms seem to be able to do the right thing, provided that
> one rewrites the user applications accordingly...
> 
> If I understand correctly the kiobuf interface allows a user process to map a
> piece of kernel memory in its own addressing space to use as an IO buffer.
> What I originally had in mind was more something like netbsd's
> UVM: _transparent_ zero-copy IO.

> With the UVM  user applications just invokes the plain old fwrite (buff,
> ...) and the system grabs the buffer from the user space into kernel space
> without the application noticing it (the original buffer becomes TCOW in the
> application space).

Anything that requires playing VM tricks is not something you'll find a
great deal of support for amongst developers -- see the posting Linus made
against exactly this.

It comes down to complexity and the amount of gain in generic
applications.  Take apache for example.  Enabling "zero copy" through VM
tricks will buy you no benefit when it comes to the http header sent out
on a request.  But the act of transmitting a file is already well handled
by the sendfile() model.

Fwiw, there are lots of libc optimisations that are worth *more* than
"zero copy" for typical applications.  Like pre-linking libraries.  stdio
could make use of mmap for fread.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
