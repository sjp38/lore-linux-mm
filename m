Date: Fri, 9 Jun 2000 18:34:18 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Allocating a page of memory with a given physical address
In-Reply-To: <20000608235235Z131165-283+94@kanga.kvack.org>
Message-ID: <Pine.LNX.4.21.0006091833290.31358-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Jun 2000, Timur Tabi wrote:

> Well, the idea is to make it some kind of elegant enhancement
> that Linus would approve of.
> 
> My idea is to create a new API, call it alloc_phys() or
> get_phys_page() or whatever, that will scan the ???? (whatever
> the virtual memory manager calls those things that keep track of
> unused virtual memory) until it finds a block that points to the
> given physical address.  It then allocates that particular
> block.

I've got two comments on this.

1) it's a horrible kludge, not elegant at all
2) why would the kernel need this? I see absolutely
   no use for this...

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
