Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3FC6B003D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 19:03:19 -0500 (EST)
Message-ID: <4B22DD89.2020901@agilent.com>
Date: Fri, 11 Dec 2009 16:02:17 -0800
From: Earl Chew <earl_chew@agilent.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] Userspace I/O (UIO): Add support for userspace DMA
In-Reply-To: <1228379942.5092.14.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, hjk@linutronix.de, gregkh@suse.de, hugh <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

I'm taking another look at the changes that were submitted in

http://lkml.org/lkml/2008/12/3/453

to see if they can be made more palatable.


In http://lkml.org/lkml/2008/12/4/64 you wrote:

> Why not create another special device that will give you DMA memory when
> you mmap it? That would also allow you to obtain the physical address
> without this utter horrid hack of writing it in the mmap'ed memory.
> 
> /dev/uioN-dma would seem like a fine name for that.


I understand the main objection was the hack to return the physical
address of the allocated DMA buffer within the buffer itself amongst
some other things.

Your suggestion was to create /dev/uioN-dma for the purpose of
allocating DMA memory.

I'm having trouble figuring out how this would help to return the
physical (bus) address of the DMA memory in a more elegant manner.

What idea did you have for the userspace program to obtain
the physical (bus) of the allocated DMA memory buffer?


Earl


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
