Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D3C956B005C
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 12:58:38 -0400 (EDT)
Date: Thu, 19 Mar 2009 09:51:59 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
In-Reply-To: <200903200334.55710.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0903190948510.17240@localhost.localdomain>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <200903200248.22623.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903190902000.17240@localhost.localdomain> <200903200334.55710.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ying Han <yinghan@google.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>



On Fri, 20 Mar 2009, Nick Piggin wrote:
> 
> Yeah, probably no need to hold private_lock while tagging the radix
> tree (which is what my version did). So maybe this one is a little
> better. I did test mine, it worked, but it didn't solve the problem.

Ahh, so you re-created it? On ext2 only, or is it visible on ext3 as well? 
I've not even tested - I assumed that I would have to boot into less 
memory and downgrade my filesystem to ext2, which made me hope somebody 
else would pick it up first ;)

> Still, it does appear to solve a real race, which we should close.

A very small and unlikely race, but yeah - the patch isn't large, removes 
more lines than it adds, and the code seems to make _more_ sense with it 
in place than without. 

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
