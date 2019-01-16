Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14D658E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 02:52:41 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id j24-v6so1374998lji.20
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 23:52:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r10sor1903994lfi.28.2019.01.15.23.52.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 23:52:38 -0800 (PST)
MIME-Version: 1.0
References: <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <20190116063430.GA22938@nautica>
In-Reply-To: <20190116063430.GA22938@nautica>
From: Josh Snyder <joshs@netflix.com>
Date: Tue, 15 Jan 2019 23:52:25 -0800
Message-ID: <CA+t-nXTfdo07EBvVo+mu8SRhrVyB=mEPLDQikHfpJue1jALJtQ@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue, Jan 15, 2019 at 10:34 PM Dominique Martinet <asmadeus@codewreck.org>
wrote:
>
> There is a difference with your previous patch though, that used to list no
> page in core when it didn't know; this patch lists pages as in core when it
> refuses to tell. I don't think that's very important, though.

Is there a reason not to return -EPERM in this case?

>
> If anything, the 0400 user-owner file might be a problem in some edge
> case (e.g. if you're preloading git directories, many objects are 0444);
> should we *also* check ownership?...

Yes, this seems valuable. Some databases with immutable files (e.g. git, as
you've mentioned) conceivably operate this way.

Josh
