Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3426B0003
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 15:12:04 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 22-v6so9351201ita.3
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 12:12:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id x11-v6sor2907828itx.11.2018.08.06.12.12.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 12:12:02 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 06 Aug 2018 12:12:02 -0700
In-Reply-To: <20180806185554.GG10003@dhcp22.suse.cz>
Message-ID: <0000000000006986c30572c90de3@google.com>
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

commit:         116b181bb646 Add linux-next specific files for 20180803
git tree:        
git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
kernel config:  https://syzkaller.appspot.com/x/.config?x=b4f38be7c2c519d5
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
patch:          https://syzkaller.appspot.com/x/patch.diff?x=147b3a72400000

Note: testing is done by a robot and is best-effort only.
