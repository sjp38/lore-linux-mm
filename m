Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id F07F78E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 03:24:28 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id f24so31224488ioh.21
        for <linux-mm@kvack.org>; Mon, 31 Dec 2018 00:24:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v20sor31247342ita.10.2018.12.31.00.24.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 31 Dec 2018 00:24:28 -0800 (PST)
MIME-Version: 1.0
References: <0000000000007beca9057e4c8c14@google.com> <CACT4Y+Yx4BJw=F_PMx9a8AjPKzEwhzLnzt9K-dgkBoNkKQj2+g@mail.gmail.com>
 <ef2508c9-d069-2143-09a6-a90b9ef12568@I-love.SAKURA.ne.jp>
In-Reply-To: <ef2508c9-d069-2143-09a6-a90b9ef12568@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 31 Dec 2018 09:24:16 +0100
Message-ID: <CACT4Y+YYwYDnqFmMwfSg6UNXnrbh46bo0jp7ijbej8nkDDmBXQ@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>, David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Dec 31, 2018 at 9:17 AM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2018/12/31 16:49, Dmitry Vyukov wrote:
> > On Mon, Dec 31, 2018 at 8:42 AM syzbot
> > <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com> wrote:
> >>
> >> Hello,
> >>
> >> syzbot found the following crash on:
> >>
> >> HEAD commit:    ef4ab8447aa2 selftests: bpf: install script with_addr.sh
> >> git tree:       bpf-next
> >> console output: https://syzkaller.appspot.com/x/log.txt?x=14a28b6e400000
> >> kernel config:  https://syzkaller.appspot.com/x/.config?x=7e7e2279c0020d5f
> >> dashboard link: https://syzkaller.appspot.com/bug?extid=ea7d9cb314b4ab49a18a
> >> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> >>
> >> Unfortunately, I don't have any reproducer for this crash yet.
> >>
> >> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> >> Reported-by: syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com
> >
> > Since this involves OOMs and looks like a one-off induced memory corruption:
> >
> > #syz dup: kernel panic: corrupted stack end in wb_workfn
> >
>
> Why?
>
> RCU stall in this case is likely to be latency caused by flooding of printk().

Just a hypothesis. OOMs lead to arbitrary memory corruptions, so can
cause stalls as well. But can be what you said too. I just thought
that cleaner dashboard is more useful than a large assorted pile of
crashes. If you think it's actionable in some way, feel free to undup.
