Date: Thu, 8 Jun 2000 20:09:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Allocating a page of memory with a given physical address
In-Reply-To: <20000608225108Z131165-245+107@kanga.kvack.org>
Message-ID: <Pine.LNX.4.21.0006082003120.22665-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Jun 2000, Timur Tabi wrote:
> ** Reply to message from "Juan J. Quintela" <quintela@fi.udc.es> on 09 Jun 2000
> 00:15:39 +0200
> 
> > Try to grep the kernel for mem_map_reserve uses, it does something
> > similar, and can be similar to what you want to do.  Notice that you
> > need to reserve the page *soon* in the boot process.
> 
> Unfortunately, that's not an option.  We need to be able to
> reserve/allocate pages in a driver's init_module() function, and
> I don't mean drivers that are compiled with the kernel.  We need
> to be able to ship a stand-alone driver that can work with
> pretty much any Linux distro of a particular version (e.g. we
> can say that only 2.4.14 and above is supported).
> 
> For the time being, we can work with a patch to the kernel, but
> that patch be relatively generic, and it must support our
> dynamically loadable driver.

Linus his policy on this is pretty strict. We won't kludge
stuff into our kernel just to support some proprietary driver.

Since nothing else seems to need the contorted functionality
you're asking for, I guess you should look for another way
to do things...

(or opensource the driver, of course)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
