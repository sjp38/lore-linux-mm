Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 293A46B21E2
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 22:09:44 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id d14-v6so277649itc.3
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 19:09:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e185-v6sor132017ioa.63.2018.08.21.19.09.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Aug 2018 19:09:42 -0700 (PDT)
MIME-Version: 1.0
References: <20180813161357.GB1199@bombadil.infradead.org>
In-Reply-To: <20180813161357.GB1199@bombadil.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 21 Aug 2018 19:09:31 -0700
Message-ID: <CA+55aFxFjAmrFpwQmEHCthHOzgidCKnod+cNDEE+3Spu9o1s3w@mail.gmail.com>
Subject: Re: [GIT PULL] XArray for 4.19
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Aug 13, 2018 at 9:14 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> Please consider pulling the XArray patch set.

So this merge window has been horrible, but I was just about to start
looking at it.

And no. I'm not going to pull this.

For some unfathomable reason, you have based it on the libnvdimm tree.
I don't understand at all wjhy you did that.

That libnvdimm tree didn't get merged., because it had complete
garbage in the mm/ code. And yes, that buggy shit was what you based
the radix tree code on.

I seriously have no idea why you have based it on some unstable random
tree in the first place.

But basing it on something that I independently refused to pull
because of obvious bugs from just a quick scan - that completely
invalidates this pull request.

Why?

I guess it makes this merge window easier, since now I don't even have
to look at the code, but it annoys the hell out of me when things like
that happen.

There wasn't even a mention in the pull request about how this was all
based on some libnvdimm code that hadn't been merged yet.

But you must have known that, since you must have explicitly done the
pull request not against my tree, but against the bogus base branch.

And since I won't be merging this, I clearly won't be merging your
other pull request that depended on this either.

Why the f*ck were these features so interlinked to begin with?

              Linus
