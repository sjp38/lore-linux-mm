Date: Tue, 9 May 2000 20:11:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] active/inactive queues for pre7-4
In-Reply-To: <3918B66D.C7B7C777@norran.net>
Message-ID: <Pine.LNX.4.21.0005092009330.25637-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: Arjan van de Ven <arjan@fenrus.demon.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 May 2000, Roger Larsson wrote:

> I think I found one bug in __page_reactivate
> 
> > --- linux-2.3.99-pre7-4/mm/filemap.c.orig       Thu May  4 11:38:24 2000
> > +++ linux-2.3.99-pre7-4/mm/filemap.c    Tue May  9 12:09:42 2000

> > +       pgdat->active_pages++;
> > +       pgdat->active_pages++;
> 
> pgdat->active_pages is incremented twice!
> second one should IMHO be
>  zone->active_pages

Indeed. In the meantime I found another small bug (the return
value from refill_inactivate() doesn't make much sense) and
have fixed a few other minor bugs.

If we continue like this the active/inactive page scheme should
be working soon ;)

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
