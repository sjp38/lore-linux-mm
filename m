Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id C8C7C3905E
	for <linux-mm@kvack.org>; Tue,  7 May 2002 16:23:47 -0300 (EST)
Date: Tue, 7 May 2002 16:23:34 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Why *not* rmap, anyway?
In-Reply-To: <Pine.LNX.4.33.0205071625570.1579-100000@erol>
Message-ID: <Pine.LNX.4.44L.0205071620270.7447-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Smith <csmith@micromuse.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 May 2002, Christian Smith wrote:

> >> If not the Mach pmap layer, then surely another pmap-like
> >> layer would be beneficial.
> >
> >How about the one we already have?
>
> I don't like using a data structure as an 'API'. An API ideally gives
> you an interface to what you need to do, not how it's done. Sure, APIs
> can become obsolete, but function calls are MUCH easier to provide
> legacy support for than a large, complex data structure.

OK, this I can agree with.

I'd be interested in working with you towards a way of
hiding some of the data structure manipulation behind
a more abstract interface, kind of like what I've done
with the -rmap stuff ... nothing outside of rmap.c
knows about struct pte_chain and nothing should know.

If you could help find ways in which we can abstract
out manipulation of some more data structures I'd be
really happy to help implement and clean up stuff.

kind regards,

Rik
-- 
	http://www.linuxsymposium.org/2002/
"You're one of those condescending OLS attendants"
"Here's a nickle kid.  Go buy yourself a real t-shirt"

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
