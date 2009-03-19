Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6842C6B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 18:16:35 -0400 (EDT)
Date: Thu, 19 Mar 2009 23:16:29 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Message-ID: <20090319221629.GA8687@duck.suse.cz>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <200903200248.22623.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903190902000.17240@localhost.localdomain> <200903200334.55710.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903190948510.17240@localhost.localdomain> <alpine.LFD.2.00.0903191317220.3030@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903191317220.3030@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Thu 19-03-09 13:21:28, Linus Torvalds wrote:
> 
> 
> On Thu, 19 Mar 2009, Linus Torvalds wrote:
> > 
> > Ahh, so you re-created it? On ext2 only, or is it visible on ext3 as well? 
> > I've not even tested - I assumed that I would have to boot into less 
> > memory and downgrade my filesystem to ext2, which made me hope somebody 
> > else would pick it up first ;)
> 
> Oh, btw, can people who see this (Ying Han, Nick and apparently Jan) 
> detail their configurations, please? In particular
  I'm able to see it only under UML. I've tried to reproduce under normal
machine but without luck. My system is single CPU Athlon64.

>  - SMP? (CONFIG_SMP and how many cores do you have if so?)
> 
>  - PREEMPT (NONE/VOLUNTARY or full preempt?)
  Above two don't exist in UML, but I assume UML behaves basically like full
preempt SMP...

>  - RCU (CLASSIC/TREE/PREEMPT?)
  RCU is CLASSIC.

										Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
