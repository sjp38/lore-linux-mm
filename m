Date: Sat, 28 Oct 2000 08:29:15 +0100 (BST)
From: James Sutherland <jas88@cam.ac.uk>
Subject: Re: Discussion on my OOM killer API
In-Reply-To: <20001027214816.C4324@goop.org>
Message-ID: <Pine.LNX.4.10.10010280828050.17898-100000@dax.joh.cam.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: jfm2@club-internet.fr, ingo.oeser@informatik.tu-chemnitz.de, riel@conectiva.com.br, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Oct 2000, Jeremy Fitzhardinge wrote:

> On Fri, Oct 27, 2000 at 11:11:11PM +0100, James Sutherland wrote:
> > Ehm... nope. mlockall().
> 
> Better make sure it's statically linked...  don't want every random library
> locked down in their entirety just because the oom killer is using it.

Of course. I did point that out, later in the mail you are replying to...


James.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
