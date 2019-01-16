Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14C2C8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 23:55:12 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id v24-v6so1277290ljj.10
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 20:55:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v6-v6sor3713338ljh.37.2019.01.15.20.55.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 20:55:09 -0800 (PST)
Received: from mail-lf1-f48.google.com (mail-lf1-f48.google.com. [209.85.167.48])
        by smtp.gmail.com with ESMTPSA id z64sm946035lff.39.2019.01.15.20.55.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 20:55:07 -0800 (PST)
Received: by mail-lf1-f48.google.com with SMTP id v5so3829616lfe.7
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 20:55:06 -0800 (PST)
MIME-Version: 1.0
References: <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard> <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
 <20190111040434.GN27534@dastard> <CAHk-=wh-kegfnPC_dmw0A72Sdk4B9tvce-cOR=jEfHDU1-4Eew@mail.gmail.com>
 <20190111073606.GP27534@dastard> <CAHk-=wj+xyz_GKjgKpU6SF3qeqouGmRoR8uFxzg_c1VpeGEJMw@mail.gmail.com>
 <20190115234510.GA6173@dastard>
In-Reply-To: <20190115234510.GA6173@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 16 Jan 2019 16:54:49 +1200
Message-ID: <CAHk-=wjc2inOae8+9-DK4jFK78-7ZpNR=TEyZg0Dj57SYwP-ng@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 16, 2019 at 11:45 AM Dave Chinner <david@fromorbit.com> wrote:
>
> I'm assuming that you can invalidate the page cache reliably by a
> means that does not repeated require probing to detect invalidation
> has occurred. I've mentioned one method in this discussion
> already...

Yes. And it was made clear to you that it was a bug in xfs dio and
what the right thing to do was.

And you ignored that, and claimed it was a feature.

Why do you then bother arguing this thing? We absolutely agree that
xfs has an information leak. If you don't care, just _say_ so. Don't
try to argue against other people who are trying to fix things.

We can easily just say "ok, xfs people don't care", and ignore the xfs
invalidation issue. That's fine.

But don't try to make it a big deal for other filesystems that _don't_
have the bug. I even pointed out how ext4 does the page cache flushing
correcrly. You pooh-poohed it.

You can't have it both ways.

Either you care or you don't. If you don't care (and so far everything
you said seems to imply you don't), then why are you even discussing
this? Just admit you don't care, and we're done.

                  Linus
