Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 93B0B8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 09:46:04 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id p124so3345372itd.8
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 06:46:04 -0800 (PST)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id d194sor8302622iof.116.2019.01.22.06.46.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Jan 2019 06:46:03 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 22 Jan 2019 06:46:03 -0800
In-Reply-To: <CACT4Y+bEsav4r82z5rE1b0rH==VpU7FEK7DzuqTu3AV+w0Ve9g@mail.gmail.com>
Message-ID: <0000000000005609bd05800d09e9@google.com>
Subject: Re: possible deadlock in shmem_fallocate (2)
From: syzbot <syzbot+4b8b031b89e6b96c4b2e@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arve@android.com, dvyukov@google.com, hughd@google.com, joelaf@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penguin-kernel@i-love.sakura.ne.jp, syzkaller-bugs@googlegroups.com, tkjos@google.com, willy@infradead.org, xieyisheng1@huawei.com

Hello,

syzbot has tested the proposed patch and the reproducer did not trigger  
crash:

Reported-and-tested-by:  
syzbot+4b8b031b89e6b96c4b2e@syzkaller.appspotmail.com

Tested on:

commit:         48b161983ae5 Merge tag 'xarray-5.0-rc3' of git://git.infra..
git tree:       upstream
kernel config:  https://syzkaller.appspot.com/x/.config?x=864ab9949c515a07
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
patch:          https://syzkaller.appspot.com/x/patch.diff?x=1064a9a0c00000

Note: testing is done by a robot and is best-effort only.
