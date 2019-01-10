Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2E2D8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 20:18:42 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id v74-v6so2290658lje.6
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 17:18:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x66-v6sor42680003ljb.20.2019.01.09.17.18.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 17:18:40 -0800 (PST)
Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com. [209.85.208.170])
        by smtp.gmail.com with ESMTPSA id p10-v6sm15007636ljh.59.2019.01.09.17.18.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 17:18:38 -0800 (PST)
Received: by mail-lj1-f170.google.com with SMTP id t18-v6so8202115ljd.4
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 17:18:38 -0800 (PST)
MIME-Version: 1.0
References: <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard>
In-Reply-To: <20190110004424.GH27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 9 Jan 2019 17:18:21 -0800
Message-ID: <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 9, 2019 at 4:44 PM Dave Chinner <david@fromorbit.com> wrote:
>
> I wouldn't look at ext4 as an example of a reliable, problem free
> direct IO implementation because, historically speaking, it's been a
> series of nasty hacks (*cough* mount -o dioread_nolock *cough*) and
> been far worse than XFS from data integrity, performance and
> reliability perspectives.

That's some big words from somebody who just admitted to much worse hacks.

Seriously. XFS is buggy in this regard, ext4 apparently isn't.

Thinking that it's better to just invalidate the cache  for direct IO
reads is all kinds of odd.

                Linus
