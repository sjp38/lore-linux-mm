Date: Wed, 23 May 2001 11:30:02 -0400 (EDT)
From: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Subject: Re: write drop behind effect on active scanning
In-Reply-To: <Pine.LNX.4.21.0105231022060.1874-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10105231127480.11617-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >   page->age = 0 ?
> 
> That would make any full scan through the active list move all dropped
> pages from generic_file_write() to the inactive list.

well, that's where they're going, aren't they?
when these pages are unlocked, they should wind up on the 
inactive-clean list.  I think the real question is whether 
it's worthwhile to make a separate locked list for them.
it certainly makes no sense to have them on a/ic/id while 
they're locked, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
