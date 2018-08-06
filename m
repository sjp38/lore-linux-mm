Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B73CE6B026A
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 07:00:03 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id c5-v6so9642192ioi.13
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 04:00:03 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id o21-v6sor4457528jad.160.2018.08.06.04.00.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 04:00:02 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 06 Aug 2018 04:00:02 -0700
In-Reply-To: <CACT4Y+ZEAoPWxEJ2yAf6b5cSjAm+MPx1yrk70BWHRrnDYdyb_A@mail.gmail.com>
Message-ID: <000000000000dfe4710572c22d67@google.com>
Subject: Re: WARNING in try_charge
From: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, dvyukov@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com

Hello,

syzbot has tested the proposed patch and the reproducer did not trigger  
crash:

Reported-and-tested-by:  
syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com

Tested on:

commit:         1ffaddd029c8 Linux 4.18-rc8
git tree:       upstream
kernel config:  https://syzkaller.appspot.com/x/.config?x=3bdb367561cb7285
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
patch:          https://syzkaller.appspot.com/x/patch.diff?x=146f9830400000

Note: testing is done by a robot and is best-effort only.
