Date: Fri, 26 May 2000 13:22:19 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <20000526132219.C21510@pcep-jamie.cern.ch>
References: <Pine.LNX.4.21.0005241458250.24993-100000@duckman.distro.conectiva> <200005242057.NAA77059@apollo.backplane.com> <20000525115202.A19969@pcep-jamie.cern.ch> <200005251618.JAA82894@apollo.backplane.com> <20000525185059.A20563@pcep-jamie.cern.ch> <20000526120805.C10082@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000526120805.C10082@redhat.com>; from sct@redhat.com on Fri, May 26, 2000 at 12:08:05PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Matthew Dillon <dillon@apollo.backplane.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> > Fwiw, with COW address_spaces (I posted an article a couple of weeks ago
> > explaining) it should be fairly simple to find all the ptes for a given
> > page without the space overhead of pte chaining.
> 
> Davem's anon area stuff already implements a large chunk of what is needed.

Agreed.  I looked at that code though and it seemed very... large.
I think COW address_space gets the same results with less code.  Fast, too.
I know what I've got to do to prove it :-)

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
