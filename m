Message-ID: <3D27E1B8.89C116F0@zip.com.au>
Date: Sat, 06 Jul 2002 23:37:44 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
References: <3D27AC81.FC72D08F@zip.com.au> <1048271645.1025997192@[10.10.2.3]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <fletch@aracnet.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> ...
> > I was discussing this with sct a few days back.  iiuc, the proposal
> > was to create a small per-cpu pool (say, 4-8 pages) which is a
> > "front-end" to regular old kmap().
> >
> > Any time you have one of these pages in use, the process gets
> > pinned onto the current CPU.
> 
> Ewww! That's gross ;-)

Hey.  So is highmem ;)

But sys_sched_affinity() allows you to change the affinity of
other tasks (it takes a pid).  So that's torn that idea.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
