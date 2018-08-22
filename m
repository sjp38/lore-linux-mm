Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE7946B2590
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 13:43:17 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k9-v6so2083482iob.16
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 10:43:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v13-v6sor117999ioh.294.2018.08.22.10.43.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 10:43:17 -0700 (PDT)
MIME-Version: 1.0
References: <20180813161357.GB1199@bombadil.infradead.org> <0100016562b90938-02b97bb7-eddd-412d-8162-7519a70d4103-000000@email.amazonses.com>
In-Reply-To: <0100016562b90938-02b97bb7-eddd-412d-8162-7519a70d4103-000000@email.amazonses.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 22 Aug 2018 10:43:05 -0700
Message-ID: <CA+55aFzN3aq1P8ykE1+XuAR9pbH7nETOyMoBi-N52Ef=WjrFLA@mail.gmail.com>
Subject: Re: [GIT PULL] XArray for 4.19
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Aug 22, 2018 at 10:40 AM Christopher Lameter <cl@linux.com> wrote:
>
> Is this going in this cycle? I have a bunch of stuff on top of this to
> enable slab object migration.

No.

It was based on a buggy branch that isn't getting pulled, so when I
started looking at it, the pull request was rejected before I got much
further.

               Linus
