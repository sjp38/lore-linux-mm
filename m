Date: Fri, 26 May 2000 14:15:26 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <20000526141526.E10082@redhat.com>
References: <Pine.LNX.4.21.0005241458250.24993-100000@duckman.distro.conectiva> <200005242057.NAA77059@apollo.backplane.com> <20000525115202.A19969@pcep-jamie.cern.ch> <200005251618.JAA82894@apollo.backplane.com> <20000525185059.A20563@pcep-jamie.cern.ch> <20000526120805.C10082@redhat.com> <20000526132219.C21510@pcep-jamie.cern.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000526132219.C21510@pcep-jamie.cern.ch>; from lk@tantalophile.demon.co.uk on Fri, May 26, 2000 at 01:22:19PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Matthew Dillon <dillon@apollo.backplane.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, May 26, 2000 at 01:22:19PM +0200, Jamie Lokier wrote:
> 
> Agreed.  I looked at that code though and it seemed very... large.
> I think COW address_space gets the same results with less code.  Fast, too.
> I know what I've got to do to prove it :-)

How will it deal with fork() cases where the child starts mprotecting
arbitrary regions, so that you have completely independent vmas all
sharing the same private pages?

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
