Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7246B2215
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 22:50:44 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id e8-v6so307325plt.4
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 19:50:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x24-v6si547137pgh.295.2018.08.21.19.50.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 Aug 2018 19:50:41 -0700 (PDT)
Date: Tue, 21 Aug 2018 19:50:40 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [GIT PULL] XArray for 4.19
Message-ID: <20180822025040.GA12244@bombadil.infradead.org>
References: <20180813161357.GB1199@bombadil.infradead.org>
 <CA+55aFxFjAmrFpwQmEHCthHOzgidCKnod+cNDEE+3Spu9o1s3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxFjAmrFpwQmEHCthHOzgidCKnod+cNDEE+3Spu9o1s3w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Aug 21, 2018 at 07:09:31PM -0700, Linus Torvalds wrote:
> On Mon, Aug 13, 2018 at 9:14 AM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > Please consider pulling the XArray patch set.
> 
> So this merge window has been horrible, but I was just about to start
> looking at it.
> 
> And no. I'm not going to pull this.
> 
> For some unfathomable reason, you have based it on the libnvdimm tree.
> I don't understand at all wjhy you did that.

I said in the pull request ...

  There are two conflicts I wanted to flag; the first is against the
  linux-nvdimm tree.  I rebased on top of one of the branches that went
  into that tree, so if you pull my tree before linux-nvdimm, you'll get
  fifteen commits I've had no involvement with.

Dan asked me to do that so that his commit (which I had no involvement
with) would be easier to backport.  At the time I thought this was a
reasonable request; I know this API change is disruptive and I wanted
to accommodate that.  I didn't know his patch was "complete garbage";
I didn't review it.

So, should I have based just on your tree and sent you a description of
what a resolved conflict should look like?

> And since I won't be merging this, I clearly won't be merging your
> other pull request that depended on this either.

I can yank most of the patches (all but the last two, iirc) out of the
IDA patchset and submit those as a separate pull request.  Would that
be acceptable?  I'm really struggling to juggle all the pieces here to
get them merged.
