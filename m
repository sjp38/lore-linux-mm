Date: Fri, 9 Jun 2000 23:20:58 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: Allocating a page of memory with a given physical address
Message-ID: <20000609232058.C28878@pcep-jamie.cern.ch>
References: <20000608225108Z131165-245+107@kanga.kvack.org> <Pine.LNX.4.21.0006082003120.22665-100000@duckman.distro.conectiva> <20000608235235Z131165-283+94@kanga.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000608235235Z131165-283+94@kanga.kvack.org>; from ttabi@interactivesi.com on Thu, Jun 08, 2000 at 06:29:07PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Timur Tabi wrote:
> My idea is to create a new API, call it alloc_phys() or get_phys_page() or
> whatever, that will scan the ???? (whatever the virtual memory manager calls
> those things that keep track of unused virtual memory) until it finds a block
> that points to the given physical address.  It then allocates that particular
> block.

Even if you implement that, there will be times when you simply can't
have the page.  Sometimes the current owner of the page can't allow it
to be moved.  This happens for vmalloc()ed memory and user processes
that that use mlock().  This includes MP3 players and security
products...

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
