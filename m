Date: Fri, 20 Apr 2001 11:30:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
In-Reply-To: <Pine.LNX.4.30.0104201525350.20939-100000@fs131-224.f-secure.com>
Message-ID: <Pine.LNX.4.21.0104201129360.1685-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Szabolcs Szakacsits <szaka@f-secure.com>
Cc: Jonathan Morton <chromi@cyberspace.org>, Dave McCracken <dmc@austin.ibm.com>, "James A. Sutherland" <jas88@cam.ac.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2001, Szabolcs Szakacsits wrote:
> On Fri, 20 Apr 2001, Jonathan Morton wrote:
> 
> > Well, OK, let's look at a commercial UNIX known for stability at high load:
> > Solaris.  How does Solaris handle thrashing?
> 
> Just as 2.2 and earlier kernels did [but not 2.4], keeps processes
> running. Moreover the default is non-overcommiting memory handling.
> There are also nice performance tuning guides.

1)  Solaris DOES suspend processes under heavy load
2)  Linux 2.4 does not (but should, IMHO)

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
