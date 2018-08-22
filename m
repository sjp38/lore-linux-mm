Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id EB9B36B25B8
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 14:23:39 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id l4-v6so1290050plt.12
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 11:23:39 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y5-v6si2015385pll.89.2018.08.22.11.23.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 Aug 2018 11:23:38 -0700 (PDT)
Date: Wed, 22 Aug 2018 11:23:38 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [GIT PULL] XArray for 4.19
Message-ID: <20180822182338.GA19458@bombadil.infradead.org>
References: <20180813161357.GB1199@bombadil.infradead.org>
 <CA+55aFxFjAmrFpwQmEHCthHOzgidCKnod+cNDEE+3Spu9o1s3w@mail.gmail.com>
 <20180822025040.GA12244@bombadil.infradead.org>
 <CA+55aFw+dwofadgvzrM-UCMSih+f1choCwW+xFFM3aPjoRQX_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw+dwofadgvzrM-UCMSih+f1choCwW+xFFM3aPjoRQX_g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Aug 21, 2018 at 08:00:18PM -0700, Linus Torvalds wrote:
> On Tue, Aug 21, 2018 at 7:50 PM Matthew Wilcox <willy@infradead.org> wrote:
> > So, should I have based just on your tree and sent you a description of
> > what a resolved conflict should look like?
> 
> Absolutely.
> 
> Or preferably not rebasing at all, just starting from a good solid
> base for new development in the first place.

Ah, I remember now, it was more complex than a textual conflict.

Dan added an entirely new function here:

http://git.infradead.org/users/willy/linux-dax.git/commitdiff/c2a7d2a115525d3501d38e23d24875a79a07e15e

which needed to be converted to XArray.  So I should have pulled in his
branch as a merge somewhere close to the end of my series, then done a
fresh patch on top of that to convert it?

It would have been pretty ugly because he modified a function I deleted.
I might try it out just to show how bad it would have been.
