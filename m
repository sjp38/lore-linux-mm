Date: Wed, 7 Jun 2000 23:11:13 +0100 (BST)
From: James Sutherland <jas88@cam.ac.uk>
Subject: Re: journaling & VM  
In-Reply-To: <393EC40A.376BB072@reiser.to>
Message-ID: <Pine.LNX.4.10.10006072304580.21297-100000@dax.joh.cam.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Reiser <hans@reiser.to>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, "Quintela Carreira Juan J." <quintela@fi.udc.es>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Jun 2000, Hans Reiser wrote:

> Let me convey an aspect of its rightness.
> 
> Caches have a declining marginal utility.  It is a good idea to keep
> at least a little bit of each cache around.  The classic problem is
> when you switch usage patterns back and forth, and one of the caches
> has been completely flushed by, say, a large file read.  If just 3% of
> the amount of cache remained from when it was being used that 3% might
> give you a lot of speedup when the usage pattern flipped back.

Incidentally, this effect comes up in Andrew Schulman's book, Unauthorized
Windows '95, in the section where he compares raw DOS, SmartDrive, Windows
3.1 with 32 bit disk access, and WfWG/Win95 with 32 bit file and disk
access. One of his test sets illustrates this beautifully, as well as
showing the performance gains from each; he runs a text search on varying
sizes of text file, and there is a huge speed increase on the second
run-through - up until the file is larger than the cache, at which point
there is almost no difference between the first and second runs in some
configurations, IIRC...

On a related note, any chance of making some caches swappable? The
application I have in mind is for much slower block devices (floppy/CD
media); using the free swap space as a cache for the CD ROM drive could be
quite an improvement in some cases. (Actually, even for hard drives it
could help: imagine an extremely busy disk on /dev/sda, with an
almost-idle swap disk on /dev/hdb. Much more difficult to code, though,
and probably not worth it...)

Thoughts??


James.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
