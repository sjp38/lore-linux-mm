Date: Wed, 7 Jun 2000 19:29:16 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: journaling & VM  
In-Reply-To: <Pine.LNX.4.10.10006072304580.21297-100000@dax.joh.cam.ac.uk>
Message-ID: <Pine.LNX.4.21.0006071927350.14304-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Sutherland <jas88@cam.ac.uk>
Cc: Hans Reiser <hans@reiser.to>, "Stephen C. Tweedie" <sct@redhat.com>, "Quintela Carreira Juan J." <quintela@fi.udc.es>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Jun 2000, James Sutherland wrote:
> On Wed, 7 Jun 2000, Hans Reiser wrote:
> 
> > Let me convey an aspect of its rightness.
> > 
> > Caches have a declining marginal utility.
> 
> Incidentally, this effect comes up in Andrew Schulman's book,
> Unauthorized Windows '95, in the section where he compares raw
> DOS, SmartDrive, Windows 3.1 with 32 bit disk access,

	[SNIP]

The difference here is that those systems do NOT have a
unified VM. Also, mmap() isn't used for program data and
lots of other stuff we're doing isn't done on those
systems.

In a world where you mmap() your executables and major
parts of your program data, properly managing all the
caches *is* important...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
