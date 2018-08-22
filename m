Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C676C6B21F6
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 23:00:31 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m13-v6so427677ioq.9
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 20:00:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f83-v6sor179195jac.9.2018.08.21.20.00.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Aug 2018 20:00:30 -0700 (PDT)
MIME-Version: 1.0
References: <20180813161357.GB1199@bombadil.infradead.org> <CA+55aFxFjAmrFpwQmEHCthHOzgidCKnod+cNDEE+3Spu9o1s3w@mail.gmail.com>
 <20180822025040.GA12244@bombadil.infradead.org>
In-Reply-To: <20180822025040.GA12244@bombadil.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 21 Aug 2018 20:00:18 -0700
Message-ID: <CA+55aFw+dwofadgvzrM-UCMSih+f1choCwW+xFFM3aPjoRQX_g@mail.gmail.com>
Subject: Re: [GIT PULL] XArray for 4.19
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Aug 21, 2018 at 7:50 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> So, should I have based just on your tree and sent you a description of
> what a resolved conflict should look like?

Absolutely.

Or preferably not rebasing at all, just starting from a good solid
base for new development in the first place.

Sometimes you start from the wrong point, and decide that you really
need to rebase, but then you should rebase to a more stable point, not
on top of some random independent development.

Rebasing can be a really good tool to clean up development that was
haphazard - maybe as you  go along you notice that something you did
earlier turned out to be counter-productive, so you rebase and clean
up your history that has not been made public yet.

But when you send me a big new feature, the absolutely *last* thing I
want to ever see is to see it based on some random unstable base.

And rebasing to avoid merge conflicts is *always* the wrong thing to
do, unless the reason you're rebasing is "hey, I wrote this feature
ages ago, I need to really refresh it to a more modern and stable
kernel, so I'll rebase it onto the current last release instead, so
that I have a good starting point".

And even then the basic reason is not so much that there were
conflicts, but that you just want your series to make more sense on
its own, and not have one horribly complex merge that is just due to
the fact that it was based on something ancient.

The absolute last thing I want to see during the merge window is
multiple independent features that have been tied together just
because they are rebased on top of each other.

Because that means - as in this case - that if one branch has
problems, it now affects all of them.

Merge conflicts aren't bad. In 99% of all cases, the conflict is
trivial to solve. And the cost of trying to deal with them with
rebasing is much much higher.

               Linus
