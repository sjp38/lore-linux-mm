Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: Why *not* rmap, anyway?
Date: Tue, 7 May 2002 21:43:29 +0200
References: <Pine.LNX.4.44L.0205071620270.7447-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.44L.0205071620270.7447-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E175Ary-0000Th-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Christian Smith <csmith@micromuse.com>
Cc: Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 07 May 2002 21:23, Rik van Riel wrote:
> On Tue, 7 May 2002, Christian Smith wrote:
> 
> > >> If not the Mach pmap layer, then surely another pmap-like
> > >> layer would be beneficial.
> > >
> > >How about the one we already have?
> >
> > I don't like using a data structure as an 'API'. An API ideally gives
> > you an interface to what you need to do, not how it's done. Sure, APIs
> > can become obsolete, but function calls are MUCH easier to provide
> > legacy support for than a large, complex data structure.
> 
> OK, this I can agree with.
> 
> I'd be interested in working with you towards a way of
> hiding some of the data structure manipulation behind
> a more abstract interface, kind of like what I've done
> with the -rmap stuff ... nothing outside of rmap.c
> knows about struct pte_chain and nothing should know.
> 
> If you could help find ways in which we can abstract
> out manipulation of some more data structures I'd be
> really happy to help implement and clean up stuff.

The most obvious place to start are the page table walking operations, of
which there are a half-dozen instances or so.  Bill started to do some
work on this, but that ran aground somehow.  I think you might run into
the argument 'not broken yet, so don't fix yet'.  Still, it would be
worth experimenting with strategies.

Personally, I'd consider such work a diversion from the more important task
of getting rmap implemented.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
