Date: Thu, 4 May 2000 14:41:21 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <3911B131.4A565CE0@sgi.com>
Message-ID: <Pine.LNX.4.21.0005041438360.23740-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, Rajagopal Ananthanarayanan wrote:
> Linus Torvalds wrote:

> > There might be other details like this lurking, but this looks like a good
> > first try. Ananth, willing to give it a whirl?
> 
> I haven't looked at the code, but I replaced the whole while (1)
> loop with the new for(;;). Things still remain the same: when
> running dbench VM starts killing processes.

I've been thinking about it some more. When we look
carefully the killing is always accompanied by a sudden
decrease in free memory (while kswapd could easily keep
up a few seconds ago).

Having an active/inactive queue, where we maintain a
certain target number of inactive pages, should give us
some more robustness against sudden overload. Also,
guaranteeing that we have indeed a certain number of
freeable pages in every zone...

I'm coding this up as we speak, so please hold on a
little longer ...

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
