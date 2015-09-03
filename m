Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id AF3276B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 20:53:35 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so27769583pac.3
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 17:53:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e4si38443945pdc.222.2015.09.02.17.53.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 17:53:35 -0700 (PDT)
Date: Wed, 2 Sep 2015 20:53:33 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150903005332.GB27804@redhat.com>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
 <20150902174815.199d51a480a01e9a754367e3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150902174815.199d51a480a01e9a754367e3@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <dchinner@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Sep 02 2015 at  8:48pm -0400,
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 2 Sep 2015 16:13:44 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > On Wed, Sep 2, 2015 at 10:39 AM, Mike Snitzer <snitzer@redhat.com> wrote:
> > >
> > > - last but not least: add SLAB_NO_MERGE flag to mm/slab_common and
> > >   disable slab merging for all of DM's slabs (XFS will also use
> > >   SLAB_NO_MERGE once merged).
> > 
> > So I'm not at all convinced this is the right thing to do. In fact,
> > I'm pretty convinced it shouldn't be done this way. Since those
> > commits were at the top of your tree, I just didn't pull them, but
> > took the rest..
> 
> I don't have problems with the patch itself, really.  It only affects
> callers who use SLAB_NO_MERGE and those developers can make
> their own decisions.
> 
> It is a bit sad to de-optimise dm for all users for all time in order
> to make life a bit easier for dm's developers, but maybe that's a
> decent tradeoff.
> 
> 
> What I do have a problem with is that afaict the patch appeared on
> linux-mm for the first time just yesterday.  Didn't cc slab developers,
> it isn't in linux-next, didn't cc linux-kernel or linux-mm or slab/mm
> developers on the pull request.  Bad!

Yeap, noted.  Won't happen again.

> I'd like the slab developers to have time to understand and review this
> change, please.  Partly so they have a chance to provide feedback for
> the usual reasons, but also to help them understand the effect their
> design choice had on client subystems.

Sure, sorry to force the issue like I did.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
