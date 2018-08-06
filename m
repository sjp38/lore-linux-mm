Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 956496B0008
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 07:58:47 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w18-v6so8434897plp.3
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 04:58:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n15-v6sor3664879pfg.28.2018.08.06.04.58.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 04:58:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180806113212.GK19540@dhcp22.suse.cz>
References: <884de816-671a-44d4-a6a1-2ad7eff53715@I-love.SAKURA.ne.jp>
 <00000000000070698b0572c28ebc@google.com> <20180806113212.GK19540@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 6 Aug 2018 13:58:25 +0200
Message-ID: <CACT4Y+ZY6u9qqx6FofECrAZ6TmbcqZ=b4GVwHsxV6hZtNsypgQ@mail.gmail.com>
Subject: Re: WARNING in try_charge
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon, Aug 6, 2018 at 1:32 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 06-08-18 04:27:02, syzbot wrote:
>> Hello,
>>
>> syzbot has tested the proposed patch and the reproducer did not trigger
>> crash:
>>
>> Reported-and-tested-by:
>> syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com
>>
>> Tested on:
>>
>> commit:         8c8399e0a3fb Add linux-next specific files for 20180806
>> git tree:       linux-next
>> kernel config:  https://syzkaller.appspot.com/x/.config?x=1b6bc1781e49e93e
>> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>> patch:          https://syzkaller.appspot.com/x/patch.diff?x=14fe18e2400000
>>
>> Note: testing is done by a robot and is best-effort only.
>
> OK, so this smells like a problem in the previous group oom changes. Or
> maybe it is not very easy to reproduce?

It's possible to ask syzbot to test on a particular tree/commit too.
