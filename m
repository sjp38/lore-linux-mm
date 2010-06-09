Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BF57D6B01CD
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 02:20:50 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o596Kkcf012229
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 23:20:46 -0700
Received: from pvg2 (pvg2.prod.google.com [10.241.210.130])
	by hpaq12.eem.corp.google.com with ESMTP id o596KiH4008111
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 23:20:45 -0700
Received: by pvg2 with SMTP id 2so1850914pvg.16
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 23:20:44 -0700 (PDT)
Date: Tue, 8 Jun 2010 23:20:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC V2 SLEB 01/14] slab: Introduce a constant for a unspecified
 node.
In-Reply-To: <AANLkTimFmupRJ-np-V9TeiUNAqXmnyui3uYMs3PD1bWB@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1006082315100.28827@chino.kir.corp.google.com>
References: <20100521211452.659982351@quilx.com> <20100521211537.530913777@quilx.com> <alpine.DEB.2.00.1006071443120.10905@chino.kir.corp.google.com> <alpine.DEB.2.00.1006071729560.12482@router.home> <AANLkTikOKy6ZQQh2zORJDvGDE0golvyzsvlvDj-P5cur@mail.gmail.com>
 <alpine.DEB.2.00.1006072319330.31780@chino.kir.corp.google.com> <AANLkTikQhjlCPnwiK7AZo27Xb3h-Lj2JyCeqFQaVzpHX@mail.gmail.com> <alpine.DEB.2.00.1006081633450.19582@chino.kir.corp.google.com> <AANLkTimFmupRJ-np-V9TeiUNAqXmnyui3uYMs3PD1bWB@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jun 2010, Pekka Enberg wrote:

> As I said, we can probably get away with that in slab.git because
> we're so small but that doesn't work in general.
> 
> If we ignore the fact how painful the actual rebase operation is
> (there's a 'sleb/core' branch that shares the commits), I don't think
> the revised history is 'cleaner' by any means. The current patches are
> known to be good (I've tested them) but if I just replace them, all
> the testing effort was basically wasted. So if I need to do a
> git-bisect, for example, I didn't benefit one bit from testing the
> original patches.
> 
> The other issue is patch metadata. If I just nuke the existing
> patches, I'm also could be dropping important stuff like Tested-by or
> Reported-by tags. Yes, I realize that in this particular case, there's
> none but the approach works only as long as you remember exactly what
> you merged.
> 
> There are probably other benefits for larger trees but those two are
> enough for me to keep my published branches append-only.
> 

I wasn't really trying to suggest an alternative way to do it for all git 
trees, I just thought that since Christoph wanted to repropose these 
changes in another set and given there's no harm in doing it within 
slab.git right now that you'd have no problem making an exception in this 
case just for a cleaner history later.

If you'd like to keep a commit that is then completely obsoleted by 
another commit when it's on the tip of your tree right now and could 
be reverted with minimal work simply to follow this general principle, 
that's fine :)

> > Let me know if my suggested changes should be add-on patches to
> > Christoph's first five and I'll come up with a three patch series to do
> > just that.
> 
> Yes, I really would prefer incremental patches on top of the
> 'slub/cleanups' branch.
> 

Ok then, I'll send incremental changes based on my feedback of patches 
1-5.  Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
