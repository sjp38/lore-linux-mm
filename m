Date: Wed, 23 May 2001 11:59:32 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: write drop behind effect on active scanning
In-Reply-To: <Pine.LNX.4.10.10105231127480.11617-100000@coffee.psychology.mcmaster.ca>
Message-ID: <Pine.LNX.4.21.0105231140210.1874-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 May 2001, Mark Hahn wrote:

> > >   page->age = 0 ?
> > 
> > That would make any full scan through the active list move all dropped
> > pages from generic_file_write() to the inactive list.
> 
> well, that's where they're going, aren't they?
> when these pages are unlocked, they should wind up on the 
> inactive-clean list.  I think the real question is whether 
> it's worthwhile to make a separate locked list for them.
> it certainly makes no sense to have them on a/ic/id while 
> they're locked, no?

It makes sense to have a separate list for pages which are being laundered
(written out) from the inactive dirty list. 

This way we have a more "accurate" deactivation target in case the pages
on this "being written" list do not get counted as "deactivated" pages. 

This would avoid the excessive VM pressure of dirty data writeout (which
Rik just mentioned) and also avoid the "inactive dirty list full of
unfreeable pages" problem.

I don't think its a 2.4 thing, though. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
