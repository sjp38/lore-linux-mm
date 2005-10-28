Date: Thu, 27 Oct 2005 23:46:16 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051028034616.GA14511@ccure.user-mode-linux.org>
References: <1130366995.23729.38.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1130366995.23729.38.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>, Blaisorblade <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 26, 2005 at 03:49:55PM -0700, Badari Pulavarty wrote:
> Basically, I added "truncate_range" inode operation to provide
> opportunity for the filesystem to zero the blocks and/or free
> them up. 
> 
> I also attempted to implement shmem_truncate_range() which 
> needs lots of testing before I work out bugs :(

I added memory hotplug to UML to check this out.  It seems to be freeing
pages that are outside the desired range.  I'm doing the simplest possible
thing - grabbing a bunch of pages that are most likely not dirty yet, 
and MADV_TRUNCATEing them one at a time.  Everything in UML goes harwire
after that, and the cases that I've looked at involve pages being suddenly
zero.

UML isn't exactly a minimal test case, but I'll give you what you need
to reproduce this if you want.

				Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
