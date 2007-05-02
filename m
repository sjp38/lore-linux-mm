Date: Wed, 2 May 2007 11:52:01 -0700
From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Subject: Re: 2.6.22 -mm merge plans: slub
Message-ID: <20070502185201.GA12097@linux-os.sc.intel.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com> <20070501125559.9ab42896.akpm@linux-foundation.org> <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com> <20070501133618.93793687.akpm@linux-foundation.org> <Pine.LNX.4.64.0705021346170.16517@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705021346170.16517@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 02, 2007 at 05:54:53AM -0700, Hugh Dickins wrote:
> On Tue, 1 May 2007, Andrew Morton wrote:
> > So on balance, given that we _do_ expect slub to have a future, I'm
> > inclined to crash ahead with it.  The worst that can happen will be a later
> > rm mm/slub.c which would be pretty simple to do.
> 
> Okay.  And there's been no chorus to echo my concern.

I have been looking into "slub" recently to avoid some of the NUMA alien
cache issues that we were encountering on the regular slab.

I am having some stability issues with slub on an ia64 NUMA platform and
didn't have time to dig further. I am hoping to look into it soon
and share the data/findings with  Christoph.

We also did a quick perf collection on x86_64(atleast didn't hear
any stability issues from our team on regular x86_64 SMP), that we will be
sharing shortly.

> But if Linus' tree is to be better than a warehouse to avoid
> awkward merges, I still think we want it to default to on for
> all the architectures, and for most if not all -rcs.

I will not suggest for default on at this point.

thanks,
suresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
