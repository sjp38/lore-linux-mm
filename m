Date: Thu, 27 Oct 2005 11:50:50 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-Id: <20051027115050.7f5a6fb7.akpm@osdl.org>
In-Reply-To: <1130438135.23729.111.camel@localhost.localdomain>
References: <1130366995.23729.38.camel@localhost.localdomain>
	<200510271038.52277.ak@suse.de>
	<20051027131725.GI5091@opteron.random>
	<1130425212.23729.55.camel@localhost.localdomain>
	<20051027151123.GO5091@opteron.random>
	<20051027112054.10e945ae.akpm@osdl.org>
	<1130438135.23729.111.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: andrea@suse.de, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> wrote:
>
> I have 2 reasons (I don't know if Andrea has more uses/reasons):
>
> (1) Our database folks want to drop parts of shared memory segments
> when they see memory pressure

How do they "see memory pressure"?

The kernel's supposed to write the memory out to swap under memory
pressure, so why is a manual interface needed?

> or memory hotplug/virtualization stuff.

Really?  Are you sure?  Is this the only means by which the memory hotplug
developers can free up shmem pages?  I think not...

> madvise(DONTNEED) is not really releasing the pagecache pages. So 
> they want madvise(DISCARD).
>
> (2) Jeff Dike wants to use this for UML.

Why?  For what purpose?   Will he only ever want it for shmem segments?

> Please advise on what you would prefer. A small extension to madvise()
>  to solve few problems right now OR lets do real sys_holepunch() and
>  bite the bullet (even though we may not get any more users for it).

I don't think that the benefits for a full holepunch would be worth the
complexity - nasty, complex, rarely-tested changes to every filesystem.  So
let's not go there.

If we take the position that this is a shmem-specific thing and we don't
intend to extend it to real/regular filesytems then perhaps a new syscall
would be more appropriate.  On x86 that'd probably be another entry in the
sys_shm() switch statement.  Maybe?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
