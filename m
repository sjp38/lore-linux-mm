Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23A756B25CC
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 14:41:24 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id x5-v6so2223647ioa.6
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 11:41:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 195-v6sor837914itz.80.2018.08.22.11.41.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 11:41:22 -0700 (PDT)
MIME-Version: 1.0
References: <20180813161357.GB1199@bombadil.infradead.org> <CA+55aFxFjAmrFpwQmEHCthHOzgidCKnod+cNDEE+3Spu9o1s3w@mail.gmail.com>
 <20180822025040.GA12244@bombadil.infradead.org> <CA+55aFw+dwofadgvzrM-UCMSih+f1choCwW+xFFM3aPjoRQX_g@mail.gmail.com>
 <20180822182338.GA19458@bombadil.infradead.org>
In-Reply-To: <20180822182338.GA19458@bombadil.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 22 Aug 2018 11:41:11 -0700
Message-ID: <CA+55aFyLmwm2CDcXXhUpmovKjYaFfeP+95Bx5OZDsYT5iiHTCQ@mail.gmail.com>
Subject: Re: [GIT PULL] XArray for 4.19
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Aug 22, 2018 at 11:23 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> Dan added an entirely new function here:
>
> http://git.infradead.org/users/willy/linux-dax.git/commitdiff/c2a7d2a115525d3501d38e23d24875a79a07e15e
>
> which needed to be converted to XArray.  So I should have pulled in his
> branch as a merge somewhere close to the end of my series, then done a
> fresh patch on top of that to convert it?

No, it doesn't matter if you rebase on top of a broken branch, or you
merge it in. Either way, it's broken and I can't merge your end
result.

You should simply NOT CARE about other branches. Particularly not
other branches that might not even get merged in the first place!

You should care about *YOUR* work.  You should make sure *your* work
is rock solid, and that it is based on a rock solid base. Not some
random shifting quick-sand of somebody elses development branch.

Sure, then linux-next will give a merge conflict, but at that point
YOU DO NOT REBASE OR MERGE. You tell linux-next how to merge it, and
mention it to me in the pull request.

Because at that point, I have the *choice* of merging just one of the
branches or both.  Or I can merge them in either order, and test them
independently?

See how that is fundamentally different from you tying the two
branches together and handing me a fait accompli?

Yes, yes, sometimes you have to tie branches together because one
branch fundamentally depends on the features the other branch offers.
But that should be avoided like a plague if at all possible.

And it damn well isn't an issue for something like xarray, which has a
life entirely independently of libnvdimm (and vice versa), and the
conflict was just random happenstance, not some "my changes
fundamentally rely on the new features you provide".

              Linus
