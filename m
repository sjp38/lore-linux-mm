Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A14A56B0055
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 13:03:44 -0400 (EDT)
Date: Thu, 19 Mar 2009 18:03:40 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Message-ID: <20090319170340.GC3899@duck.suse.cz>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <200903200248.22623.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903190902000.17240@localhost.localdomain> <200903200334.55710.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903190948510.17240@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903190948510.17240@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ying Han <yinghan@google.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Thu 19-03-09 09:51:59, Linus Torvalds wrote:
> 
> 
> On Fri, 20 Mar 2009, Nick Piggin wrote:
> > 
> > Yeah, probably no need to hold private_lock while tagging the radix
> > tree (which is what my version did). So maybe this one is a little
> > better. I did test mine, it worked, but it didn't solve the problem.
> 
> Ahh, so you re-created it? On ext2 only, or is it visible on ext3 as well? 
> I've not even tested - I assumed that I would have to boot into less 
> memory and downgrade my filesystem to ext2, which made me hope somebody 
> else would pick it up first ;)
  In thread http://lkml.org/lkml/2009/3/4/179 I've reported similar problem
- write lost. I'm able to reproduce under UML linux at will. ext3 takes
with 1KB blocksize about 20 minutes to hit the corruption, ext2 with 1 KB
blocksize about an hour, ext2 with 4KB blocksize several hours...
  I've reported that also ordinary write() got lost once but that might
have been an error in me reading the fsx logs since I never saw it again...

									Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
