Message-ID: <3BCB594E.60004@zytor.com>
Date: Mon, 15 Oct 2001 14:46:54 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: More questions...
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

More questions that have come up from this persistent memory work:

a) I would *really* appreciate it if someone would send me userspace
memory maps for different architectures.  I know what the i386 and x86-64
memory maps look like, but I have no clue on the rest.

b) Is there an architecture-independent way to determine if a page fault
was due to a read or write operation?  On i386 I can look at the %cr2
value in the sigcontext, but I'd prefer to do something less arch-specific...

By the way, just so people don't think I'm talking about some
pie-in-the-sky vaporware project, the current code is available at:

ftp://ftp.zytor.com/pub/hpa/objstore-20011015.tar.gz

It basically has full functionality, although I want to do some more
optimizations (e.g. using mremap() for realloc()) and other cleanups (e.g.
renaming it something better than "objstore") before releasing it
officially.  The official release version will *not* be binary compatible;
you have been warned...

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
