Date: Wed, 11 Jun 2008 08:24:04 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 7/7] powerpc: lockless get_user_pages_fast
Message-ID: <20080611062404.GC11545@wotan.suse.de>
References: <20080605094300.295184000@nick.local0.net> <20080605094826.128415000@nick.local0.net> <Pine.LNX.4.64.0806101159110.17798@schroedinger.engr.sgi.com> <20080611031822.GA8228@wotan.suse.de> <Pine.LNX.4.64.0806102138380.19967@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0806102141010.19967@schroedinger.engr.sgi.com> <20080611044902.GB11545@wotan.suse.de> <20080610230622.abed7b55.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080610230622.abed7b55.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 10, 2008 at 11:06:22PM -0700, Andrew Morton wrote:
> On Wed, 11 Jun 2008 06:49:02 +0200 Nick Piggin <npiggin@suse.de> wrote:
> 
> > Can memory management patches go though mm/? I dislike the cowboy
                                            ^^^
That should read -mm, of course.


> > method of merging things that some other subsystems have adopted :)
> 
> I think I'd prefer that.  I may be a bit slow, but we're shoving at
> least 100 MM patches through each kernel release and I think I review
> things more closely than others choose to.  At least, I find problems
> and I've seen some pretty wild acked-bys...

I wouldn't say you're too slow. You're as close to mm and mm/fs 
maintainer as we're likely to get and I think it would be much worse
to have things merged out-of-band. Even the more peripheral parts like
slab or hugetlb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
