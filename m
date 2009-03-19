Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C09FB6B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 16:11:58 -0400 (EDT)
Date: Thu, 19 Mar 2009 13:05:52 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
In-Reply-To: <20090319170340.GC3899@duck.suse.cz>
Message-ID: <alpine.LFD.2.00.0903191301500.7412@localhost.localdomain>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <200903200248.22623.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903190902000.17240@localhost.localdomain> <200903200334.55710.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903190948510.17240@localhost.localdomain>
 <20090319170340.GC3899@duck.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>



On Thu, 19 Mar 2009, Jan Kara wrote:
> > 
> > Ahh, so you re-created it? On ext2 only, or is it visible on ext3 as well? 
> > I've not even tested - I assumed that I would have to boot into less 
> > memory and downgrade my filesystem to ext2, which made me hope somebody 
> > else would pick it up first ;)
>
>   In thread http://lkml.org/lkml/2009/3/4/179 I've reported similar problem
> - write lost. I'm able to reproduce under UML linux at will. ext3 takes
> with 1KB blocksize about 20 minutes to hit the corruption, ext2 with 1 KB
> blocksize about an hour, ext2 with 4KB blocksize several hours...

Hmm. I can't seem to recreate it with Ying Han's testprog, at least. 
That's with the fs/buffer.c patch applied, but that shouldn't matter since 
Nick reports that his (roughly equivalent) patch didn't help.

I'll continue to run it for a while, but it's been going for about an hour 
now, with vmstat reporting bo/bi at roughly 5-10MB/s pretty continuosly.

Of course, that's with my SSD's and an insanely fast Nehalem box, so my 
timings are likely rather different from most other peoples.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
