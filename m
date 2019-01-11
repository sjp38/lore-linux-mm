Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id C48AD8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 02:08:29 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id h11so969998lfc.9
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:08:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13-v6sor45513079ljj.25.2019.01.10.23.08.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 23:08:27 -0800 (PST)
Received: from mail-lf1-f49.google.com (mail-lf1-f49.google.com. [209.85.167.49])
        by smtp.gmail.com with ESMTPSA id q6sm14280660lfh.52.2019.01.10.23.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 23:08:24 -0800 (PST)
Received: by mail-lf1-f49.google.com with SMTP id c16so10076630lfj.8
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:08:24 -0800 (PST)
MIME-Version: 1.0
References: <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard> <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
 <20190111040434.GN27534@dastard>
In-Reply-To: <20190111040434.GN27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 10 Jan 2019 23:08:07 -0800
Message-ID: <CAHk-=wh-kegfnPC_dmw0A72Sdk4B9tvce-cOR=jEfHDU1-4Eew@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 10, 2019 at 8:04 PM Dave Chinner <david@fromorbit.com> wrote:
>
> So it will only read the single page we tried to access and won't
> perturb the rest of the message encoded into subsequent pages in
> file.

Dave, you're being intentionally obtuse, aren't you?

It's only that single page that *matters*. That's the page that the
probe reveals the status of - but it's also the page that the probe
then *changes* the status of.

See?

Think of it as "the act of measurement changes that which is
measured". And that makes the measurement pointless.

              Linus
