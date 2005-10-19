Date: Wed, 19 Oct 2005 18:38:15 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [RFC][PATCH] OVERCOMMIT_ALWAYS extension
Message-ID: <20051019223815.GA11240@localhost.localdomain>
References: <1129570219.23632.34.camel@localhost.localdomain> <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com> <Pine.LNX.4.61.0510171919150.6548@goblin.wat.veritas.com> <1129651502.23632.63.camel@localhost.localdomain> <Pine.LNX.4.61.0510191826280.8674@goblin.wat.veritas.com> <20051019183202.GA8120@localhost.localdomain> <1129756908.8716.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1129756908.8716.24.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 19, 2005 at 02:21:48PM -0700, Badari Pulavarty wrote:
> My requirement is a simple subset of yours. All I want is ability to
> completely drop range of pages in a shared memory segment (as if they
> are clean). 

Your implementation seems to do something very different, though.

> madvise(MADV_DISCARD) would be good enough for me. In fact,
> I have another weird requirement that - it should be able to drop these
> pages even when map count is NOT zero. I am still thinking about this
> one. 

I had been planning on using map count == 0 as a sign to the driver that
it should drop the page.  However, dropping map count > 0 pages would also
work for UML.

> Our database folks, map these regions into different db2 processes
> and they want this to work from any given process (even if other
> processes have it mapped). I am not sure what would happen, some
> other process touches it after we dropped it - may be a zero page ?

Yeah, that works for me.  I don't have a requirement that dropped pages
be accessible from multiple processes.  But if they were, that might let
me map them directly into processes without UML zeroing them first (as they'd
be already zeroed by the host).

				Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
