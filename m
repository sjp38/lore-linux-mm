Date: Tue, 22 Apr 2008 18:07:58 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 02 of 12] Fix ia64 compilation failure because of
	common code include bug
Message-ID: <20080422230758.GS30298@sgi.com>
References: <3c804dca25b15017b220.1208872278@duo.random> <Pine.LNX.4.64.0804221319430.3640@schroedinger.engr.sgi.com> <20080422224352.GS24536@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080422224352.GS24536@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 12:43:52AM +0200, Andrea Arcangeli wrote:
> On Tue, Apr 22, 2008 at 01:22:55PM -0700, Christoph Lameter wrote:
> > Looks like this is not complete. There are numerous .h files missing which 
> > means that various structs are undefined (fs.h and rmap.h are needed 
> > f.e.) which leads to surprises when dereferencing fields of these struct.
> > 
> > It seems that mm_types.h is expected to be included only in certain 
> > contexts. Could you make sure to include all necessary .h files? Or add
> > some docs to clarify the situation here.
> 
> Robin, what other changes did you need to compile? I only did that one
> because I didn't hear any more feedback from you after I sent that
> patch, so I assumed it was enough.

It was perfect.  Nothing else was needed.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
