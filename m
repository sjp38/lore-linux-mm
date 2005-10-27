Date: Thu, 27 Oct 2005 13:50:58 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-Id: <20051027135058.2f72e706.akpm@osdl.org>
In-Reply-To: <20051027200434.GT5091@opteron.random>
References: <1130366995.23729.38.camel@localhost.localdomain>
	<200510271038.52277.ak@suse.de>
	<20051027131725.GI5091@opteron.random>
	<1130425212.23729.55.camel@localhost.localdomain>
	<20051027151123.GO5091@opteron.random>
	<20051027112054.10e945ae.akpm@osdl.org>
	<20051027200434.GT5091@opteron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: pbadari@us.ibm.com, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> wrote:
>
> On Thu, Oct 27, 2005 at 11:20:54AM -0700, Andrew Morton wrote:
> > googling MADV_DISCARD comes up with basically nothing.  MADV_TRUNCATE comes
> > up with precisely nothing.
> > 
> > Why does tmpfs need this feature?  What's the requirement here?  Please
> > spill the beans ;)
> 
> MADV_TRUNCATE is a name I made up myself last month.

You misunderstand.  I'm unconcerned about the names.  My reasons for
googling was to wonder "wtf is this feature for?".  And it came up blank.

> ...
> but the partner only needs MADV_TRUNCATE and they don't care about the
> sys_truncate_range, so it got higher prio.

This is what I'm asking about.  What's the requirement?  What's the
application?  What's the workload?  What's the testcase?  All that old
stuff.  This should have been the very, very first thing which Badari
presented to us.

> I think
> the MADV_TRUNCATE API is cleaner for the long term than a tmpfs specific
> hack.

Why?

If we do it this way then we should do it for other filesystems.  And then
we should do it for files which _aren't_ mmapped.  And then we should do it
on a finer-than-PAGE_SIZE granularity.

IOW: we're unlikely to implement MADV_TRUNCATE for anything other than
tmpfs, in which case MADV_TRUNCATE will remain a tmpfs specific hack, no?

> Some app allocates large tmpfs files, then when some task quits and some
> client disconnect, some memory can be released. However the only way to
> release tmpfs-swap is to MADV_TRUNCATE.

Or to swap it out.


I think we need to restart this discussion.  Can we please have a
*detailed* description of the problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
