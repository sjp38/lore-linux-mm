Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: Why *not* rmap, anyway?
Date: Wed, 8 May 2002 01:11:03 +0200
References: <Pine.LNX.4.44L.0205071650170.7447-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.44L.0205071650170.7447-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E175E6r-0000UH-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 07 May 2002 21:51, Rik van Riel wrote:
> On Tue, 7 May 2002, Daniel Phillips wrote:
> 
> > The most obvious place to start are the page table walking operations,
> > of which there are a half-dozen instances or so.  Bill started to do
> > some work on this, but that ran aground somehow.  I think you might run
> > into the argument 'not broken yet, so don't fix yet'.  Still, it would
> > be worth experimenting with strategies.
> >
> > Personally, I'd consider such work a diversion from the more important
> > task of getting rmap implemented.
> 
> They're orthagonal. If we find somebody to implement the
> stuff it's easy enough to just merge it everywhere.

It's not orthogonal, it's very inconvenient to have the superficial structure
of the vm ops changing while working on deep changes.  It makes it really hard
to do regression testing.  Parallel dvelopment I'd buy - somebody can be working
this out at the same time, then merge *after* the rmap work is completed.  The
current nested-loop approach isn't broken yet.

> In fact, I'm pretty sure that if we get this stuff
> abstracted out properly it should be easier to get -rmap
> merged and improved.

Color me skeptical about that.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
