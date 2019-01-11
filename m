Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 218798E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 02:11:45 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id x18-v6so3485478lji.0
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:11:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a16sor19942555lfi.3.2019.01.10.23.11.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 23:11:43 -0800 (PST)
Received: from mail-lf1-f49.google.com (mail-lf1-f49.google.com. [209.85.167.49])
        by smtp.gmail.com with ESMTPSA id h12-v6sm15501227ljb.80.2019.01.10.23.11.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 23:11:40 -0800 (PST)
Received: by mail-lf1-f49.google.com with SMTP id z13so10069395lfe.11
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:11:40 -0800 (PST)
MIME-Version: 1.0
References: <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111045750.GA27333@nautica>
In-Reply-To: <20190111045750.GA27333@nautica>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 10 Jan 2019 23:11:23 -0800
Message-ID: <CAHk-=wiqfAdmmE+pR3O5zs=xtkd6A6ShyyCwpwSZ+341L=zVYw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 10, 2019 at 8:58 PM Dominique Martinet
<asmadeus@codewreck.org> wrote:
>
> I get on average over a few queries approximately a real time of 350ms,
> 230ms and 220ms immediately after drop cache and service restart, and
> 150ms, 60ms and 60ms after a prefetch (hand-wavy average over 3 runs, I
> didn't have the patience to do proper testing).
> (In both cases, user/sys are less than 10ms; I don't see much difference
> there)

But those numbers aren't about the mincore() change. That's just from
dropping caches.

Now, what's the difference with the mincore change, and without? Is it
actually measurable?

Because that's all that matters: is the mincore change something you
can even notice? Is it a big regression?

The fact that things are slower when they are cold in the cache isn't
the issue. The issue is whether the change to mincore semantics makes
any difference to real loads.

                Linus
