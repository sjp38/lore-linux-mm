Date: Thu, 22 Jun 2000 18:37:58 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] RSS guarantees and limits
In-Reply-To: <20000622221923.A8744@redhat.com>
Message-ID: <Pine.LNX.4.21.0006221834530.1137-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Tweedie <sct@redhat.com>
Cc: John Fremlin <vii@penguinpowered.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jun 2000, Stephen Tweedie wrote:
> On Thu, Jun 22, 2000 at 07:00:54PM +0100, John Fremlin wrote:
> > 
> > > - protect smaller apps from bigger memory hogs
> > 
> > Why? Yes, it's very altruistic, very sportsmanlike, but giving small,
> > rarely used processes a form of social security is only going to
> > increase bureaucracy ;-)
> 
> It is critically important that when under memory pressure, a
> system administrator can still log in and kill any runaway
> processes.  The smaller apps in question here are system daemons
> such as init, inetd and telnetd, and user apps such as bash and
> ps.  We _must_ be able to allow them to make at least some
> progress while the VM is under load.

Also, the memory space used by these small apps is usually
negligable compared to the memory used by the big program.

What is 2% memory use for the big program can be the difference
between running and crawling for something like bash...

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
