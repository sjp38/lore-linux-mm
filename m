Date: Fri, 4 Apr 2003 20:10:18 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <20030405041018.GG993@holomorphy.com>
References: <20030405024414.GP16293@dualathlon.random> <Pine.LNX.4.44.0304042255390.32336-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0304042255390.32336-100000@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: Andrea Arcangeli <andrea@suse.de>, "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@digeo.com>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 04, 2003 at 10:59:59PM -0500, Rik van Riel wrote:
> The only issues with objrmap seems to be mremap, which Hugh
> seems to have taken care of, and the case of a large number
> of processes mapping different parts of the same file multiple
> times (1000 processes mapping each 1000 parts of the same file),
> which would grow the complexity of the VMA search from linear
> to quadratical.
> That last case is also fixable, though, probably best done using
> k-d trees.
> Except for nonlinear VMAs I don't think there are any big obstacles
> left that would keep us from switching to object rmap.

The k-d trees only solve the "external" interference case, that is,
it thins the search space by eliminating vma's the page must
necessarily be outside of.

They don't solve the "internal" interference case, where the page does
fall into all of the vma's, but only a few out of those have actually
faulted the page into the pagetables. This is likely only "fixable" by
pointwise methods, which seem to come with notable maintenance expense.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
