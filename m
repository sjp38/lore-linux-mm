Date: Fri, 28 Oct 2005 12:33:08 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051028163308.GA17407@thunk.org>
References: <1130366995.23729.38.camel@localhost.localdomain> <200510271038.52277.ak@suse.de> <20051027131725.GI5091@opteron.random> <1130425212.23729.55.camel@localhost.localdomain> <20051027151123.GO5091@opteron.random> <20051027112054.10e945ae.akpm@osdl.org> <1130438135.23729.111.camel@localhost.localdomain> <20051027115050.7f5a6fb7.akpm@osdl.org> <20051027200515.GB12407@thunk.org> <4361820C.7070607@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4361820C.7070607@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, andrea@suse.de, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 27, 2005 at 06:42:36PM -0700, Badari Pulavarty wrote:
> Like Andrea mentioned MADV_DONTNEED should be able to do what JVM
> folks want. If they want more than that, get in touch with me.
> While doing MADV_REMOVE, I will see if I can satsify their needs also.

Well, I asked if what he wanted was simply walking all of the page
tables and marking the indicated pages as "clean", but he claimed that
anything that involved walking the pages tables would be too slow.
But it may be that he was assuming this would be as painful as
munmap(), when of course it wouldn't be.  I don't know if they've
actually benchmarked MADV_DONTNEED or not.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
