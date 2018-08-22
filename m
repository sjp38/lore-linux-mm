Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 93FE66B25B6
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 14:23:21 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id p22-v6so2183661ioh.7
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 11:23:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r201-v6sor828775itc.14.2018.08.22.11.23.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 11:23:19 -0700 (PDT)
MIME-Version: 1.0
References: <20180813161357.GB1199@bombadil.infradead.org> <0100016562b90938-02b97bb7-eddd-412d-8162-7519a70d4103-000000@email.amazonses.com>
 <CA+55aFzN3aq1P8ykE1+XuAR9pbH7nETOyMoBi-N52Ef=WjrFLA@mail.gmail.com>
In-Reply-To: <CA+55aFzN3aq1P8ykE1+XuAR9pbH7nETOyMoBi-N52Ef=WjrFLA@mail.gmail.com>
From: Dan Williams <dan.j.williams@gmail.com>
Date: Wed, 22 Aug 2018 11:23:02 -0700
Message-ID: <CAA9_cmdCj6EqipbxMwy9Mm+Vg+HOPZCRpCpbmvWr=A7En+MUiQ@mail.gmail.com>
Subject: Re: [GIT PULL] XArray for 4.19
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: cl@linux.com, Matthew Wilcox <willy@infradead.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 22, 2018 at 10:43 AM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Wed, Aug 22, 2018 at 10:40 AM Christopher Lameter <cl@linux.com> wrote:
> >
> > Is this going in this cycle? I have a bunch of stuff on top of this to
> > enable slab object migration.
>
> No.
>
> It was based on a buggy branch that isn't getting pulled

To be clear, I don't think the problem you identified can be triggered
in practice. We are under the equivalent of the page lock for dax in
that path, and if ->mapping is NULL we would bail before finding that
the mapping-size helper returns zero.

> so when I
> started looking at it, the pull request was rejected before I got much
> further.

For the record I think skipping the entirety of the libnvdimm pull
request for this cycle due to that misuse of ilog2() is overkill, but
it's not my kernel.

Andrew, I think this means we need to lean on you to merge
dax-memory-failure and Xarray for 4.20 rather than try to coordinate
our own git branches for these specific topics.

At a minimum for 4.19 I think we should disable MADV_HWPOISON for dax
mappings this cycle to at least close that trivial method to crash the
kernel when using dax.

Dave, I recommend dropping dax-memory-failure and sending the other
libnvdimm topics for 4.19 that have been soaking in -next.
