Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E55A86B0007
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 07:27:03 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e6-v6so8459324itc.7
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 04:27:03 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id n185-v6sor2431486ite.2.2018.08.06.04.27.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 04:27:02 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 06 Aug 2018 04:27:02 -0700
In-Reply-To: <884de816-671a-44d4-a6a1-2ad7eff53715@I-love.SAKURA.ne.jp>
Message-ID: <00000000000070698b0572c28ebc@google.com>
Subject: Re: WARNING in try_charge
From: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, dvyukov@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, penguin-kernel@I-love.SAKURA.ne.jp, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com

Hello,

syzbot has tested the proposed patch and the reproducer did not trigger  
crash:

Reported-and-tested-by:  
syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com

Tested on:

commit:         8c8399e0a3fb Add linux-next specific files for 20180806
git tree:       linux-next
kernel config:  https://syzkaller.appspot.com/x/.config?x=1b6bc1781e49e93e
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
patch:          https://syzkaller.appspot.com/x/patch.diff?x=14fe18e2400000

Note: testing is done by a robot and is best-effort only.
