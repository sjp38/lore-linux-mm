Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5F38E0001
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 08:24:36 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id p4so45616769iod.17
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 05:24:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o185sor9570281ito.8.2019.01.06.05.24.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 06 Jan 2019 05:24:34 -0800 (PST)
MIME-Version: 1.0
References: <0000000000007beca9057e4c8c14@google.com> <CACT4Y+Yx4BJw=F_PMx9a8AjPKzEwhzLnzt9K-dgkBoNkKQj2+g@mail.gmail.com>
 <ef2508c9-d069-2143-09a6-a90b9ef12568@I-love.SAKURA.ne.jp>
 <CACT4Y+YYwYDnqFmMwfSg6UNXnrbh46bo0jp7ijbej8nkDDmBXQ@mail.gmail.com>
 <eeb95c52-5bf8-d3ce-d32b-269aa86bcd93@i-love.sakura.ne.jp> <8cdbcb63-d2f7-cace-0eda-d73255fd47e7@i-love.sakura.ne.jp>
In-Reply-To: <8cdbcb63-d2f7-cace-0eda-d73255fd47e7@i-love.sakura.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 6 Jan 2019 14:24:23 +0100
Message-ID: <CACT4Y+Y5cdD=optF2k4a0W7vriVnzmzLU0SPGEJoOHRMi_bsZA@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>, David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>

On Sat, Jan 5, 2019 at 11:49 AM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/01/03 2:06, Tetsuo Handa wrote:
> > On 2018/12/31 17:24, Dmitry Vyukov wrote:
> >>>> Since this involves OOMs and looks like a one-off induced memory corruption:
> >>>>
> >>>> #syz dup: kernel panic: corrupted stack end in wb_workfn
> >>>>
> >>>
> >>> Why?
> >>>
> >>> RCU stall in this case is likely to be latency caused by flooding of printk().
> >>
> >> Just a hypothesis. OOMs lead to arbitrary memory corruptions, so can
> >> cause stalls as well. But can be what you said too. I just thought
> >> that cleaner dashboard is more useful than a large assorted pile of
> >> crashes. If you think it's actionable in some way, feel free to undup.
> >>
> >
> > We don't know why bpf tree is hitting this problem.
> > Let's continue monitoring this problem.
> >
> > #syz undup
> >
>
> A report at 2019/01/05 10:08 from "no output from test machine (2)"
> ( https://syzkaller.appspot.com/text?tag=CrashLog&x=1700726f400000 )
> says that there are flood of memory allocation failure messages.
> Since continuous memory allocation failure messages itself is not
> recognized as a crash, we might be misunderstanding that this problem
> is not occurring recently. It will be nice if we can run testcases
> which are executed on bpf-next tree.

What exactly do you mean by running test cases on bpf-next tree?
syzbot tests bpf-next, so it executes lots of test cases on that tree.
One can also ask for patch testing on bpf-next tree to test a specific
test case.
