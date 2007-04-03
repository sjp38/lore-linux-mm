Date: Tue, 3 Apr 2007 16:19:16 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: [xfs-masters] Re: [PATCH] Cleanup and kernelify shrinker registration (rc5-mm2)
Message-ID: <20070403061916.GW32597093@melbourne.sgi.com>
References: <1175571885.12230.473.camel@localhost.localdomain> <20070402205825.12190e52.akpm@linux-foundation.org> <1175575503.12230.484.camel@localhost.localdomain> <20070402215702.6e3782a9.akpm@linux-foundation.org> <20070403054419.GV32597093@melbourne.sgi.com> <20070402230158.4fcdd455.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070402230158.4fcdd455.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Chinner <dgc@sgi.com>, xfs-masters@oss.sgi.com, Rusty Russell <rusty@rustcorp.com.au>, lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, reiserfs-dev@namesys.com
List-ID: <linux-mm.kvack.org>

On Mon, Apr 02, 2007 at 11:01:58PM -0700, Andrew Morton wrote:
> On Tue, 3 Apr 2007 15:44:19 +1000 David Chinner <dgc@sgi.com> wrote:
> 
> > In XFS, one of the shrinkers cwthat gets registered calls causes all
> > the xfsbufd's in the system to run and write back delayed write
> > metadata - this can't be freed up until it is clean, and this is the
> > only hook we have that can be used to trigger writeback on memory
> > pressure. We need this because we can potentially have hundreds of
> > megabytes of dirty metadata per XFS filesystem.
> > 
> 
> <looks>
> 
> Gad, someone went mad in there.  Can we do this (please)?

Yup, added to my QA tree.

Rusty, can you redo you patch on top of this one? I'll
add it to my QA tree as well...

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
