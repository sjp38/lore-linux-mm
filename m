Date: Fri, 27 Oct 2000 18:36:13 +0100 (BST)
From: James Sutherland <jas88@cam.ac.uk>
Subject: Re: Discussion on my OOM killer API
In-Reply-To: <20001027191010.N18138@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.10.10010271832020.13084-100000@dax.joh.cam.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Oct 2000, Ingo Oeser wrote:

> On Fri, Oct 27, 2000 at 12:58:44AM +0100, James Sutherland wrote:
> > Which begs the question, where did the userspace OOM policy daemon go? It,
> > coupled with Rik's simple in-kernel last-ditch handler, should cover most
> > eventualities without the need for nasty kernel kludges.
> 
> If I do the full blown variant of my patch: 
> 
> echo "my-kewl-oom-killer" >/proc/sys/vm/oom_handler
> 
> will try to load the module with this name for a new one and
> uninstall the old one.

EBADIDEA. The kernel's OOM killer is a last ditch "something's going to
die - who's first?" - adding extra bloat like this is BAD.

Policy should be decided user-side, and should prevent the kernel-side
killer EVER triggering.

> The original idea was an simple "I install a module and lock it
> into memory" approach[1] for kernel hackers, which is _really_
> easy to to and flexibility for nothing[2].
> 
> If the Rik and Linus prefer the user-accessable variant via
> /proc, I'll happily implement this.
> 
> I just intended to solve a "religious" discussion via code
> instead of words ;-)

I was planning to implement a user-side OOM killer myself - perhaps we
could split the work, you do kernel-side, I'll do the userspace bits?


James.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
