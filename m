Date: Fri, 26 May 2000 12:08:05 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <20000526120805.C10082@redhat.com>
References: <Pine.LNX.4.21.0005241458250.24993-100000@duckman.distro.conectiva> <200005242057.NAA77059@apollo.backplane.com> <20000525115202.A19969@pcep-jamie.cern.ch> <200005251618.JAA82894@apollo.backplane.com> <20000525185059.A20563@pcep-jamie.cern.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000525185059.A20563@pcep-jamie.cern.ch>; from lk@tantalophile.demon.co.uk on Thu, May 25, 2000 at 06:50:59PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Matthew Dillon <dillon@apollo.backplane.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, May 25, 2000 at 06:50:59PM +0200, Jamie Lokier wrote:
> 
> Fwiw, with COW address_spaces (I posted an article a couple of weeks ago
> explaining) it should be fairly simple to find all the ptes for a given
> page without the space overhead of pte chaining.

Davem's anon area stuff already implements a large chunk of what is needed.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
