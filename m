Date: Fri, 26 May 2000 09:04:23 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] 2.3/4 VM queues idea
In-Reply-To: <20000526120805.C10082@redhat.com>
Message-ID: <Pine.LNX.4.21.0005260859090.26570-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, Matthew Dillon <dillon@apollo.backplane.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 May 2000, Stephen C. Tweedie wrote:
> On Thu, May 25, 2000 at 06:50:59PM +0200, Jamie Lokier wrote:
> > 
> > Fwiw, with COW address_spaces (I posted an article a couple of weeks ago
> > explaining) it should be fairly simple to find all the ptes for a given
> > page without the space overhead of pte chaining.
> 
> Davem's anon area stuff already implements a large chunk of what
> is needed.

It would be cool if somebody could take the time and implement
the rest of what's needed. I'm currently working at making page
aging and deferred swapout work, so we have the basic mechanisms
for aging the active pages and doing swapout from the inactive
queue.

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
