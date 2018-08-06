Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A08486B0271
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 11:28:12 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o18-v6so10641182qtm.11
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 08:28:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f25-v6sor5600513qve.99.2018.08.06.08.28.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 08:28:09 -0700 (PDT)
Date: Mon, 6 Aug 2018 11:31:07 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: WARNING in try_charge
Message-ID: <20180806153107.GD9888@cmpxchg.org>
References: <0000000000005e979605729c1564@google.com>
 <20180806091552.GE19540@dhcp22.suse.cz>
 <CACT4Y+Ystnwv4M6Uh+HBKbdADAnJ6otfR0GoA20crzqV+b2onQ@mail.gmail.com>
 <20180806094827.GH19540@dhcp22.suse.cz>
 <CACT4Y+ZJsDo1gjzHvbFVqHcrL=tFJXTAAWLs9mAJSv3+LiCdmA@mail.gmail.com>
 <20180806110224.GI19540@dhcp22.suse.cz>
 <CACT4Y+awxBatn3GQc7EWHVfHqMLKC9eVKjQMbJkCk0Po-X4VDQ@mail.gmail.com>
 <20180806142124.GP19540@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180806142124.GP19540@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Dmitry Torokhov <dtor@google.com>

On Mon, Aug 06, 2018 at 04:21:24PM +0200, Michal Hocko wrote:
> On Mon 06-08-18 13:57:38, Dmitry Vyukov wrote:
> > On Mon, Aug 6, 2018 at 1:02 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > > If you have a strong reason to believe that this is an abuse of WARN I
> > > am all happy to change that. But I haven't heard any yet, to be honest.
> > 
> > WARN must not be used for anything that is not kernel bugs. If this is
> > not kernel bug, WARN must not be used here.
> 
> This is rather strong wording without any backing arguments. I strongly
> doubt 90% of existing WARN* match this expectation. WARN* has
> traditionally been a way to tell that something suspicious is going on.
> Those situation are mostly likely not fatal but it is good to know they
> are happening.

I have to agree with Dmitry here. WARN should indicate a real kernel
issue, not user input that knowingly triggers undesirable behavior in
the kernel. It's our assert() for states we don't think are possible.

I would wager that MOST developers and users understand it that way.
