Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C82616B0266
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 07:25:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t17-v6so5273946edr.21
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 04:25:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x42-v6si640564edm.81.2018.08.07.04.25.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 04:25:24 -0700 (PDT)
Date: Tue, 7 Aug 2018 13:25:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WARNING in try_charge
Message-ID: <20180807112522.GA10003@dhcp22.suse.cz>
References: <20180806181339.GD10003@dhcp22.suse.cz>
 <0000000000002ec4580572c85e46@google.com>
 <20180806185554.GG10003@dhcp22.suse.cz>
 <CACT4Y+Zg3DhAnKWBAyJ-Y-3XVL+jCQy1U2iWR8mdraX6w23X_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Zg3DhAnKWBAyJ-Y-3XVL+jCQy1U2iWR8mdraX6w23X_Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue 07-08-18 13:18:00, Dmitry Vyukov wrote:
[...]
> Great we are making progress here!
> 
> So if it's something to fix in kernel we just leave WARN alone. It
> served its intended purpose of notifying kernel developers about
> something to fix in kernel.

Yes, agreed! And the way how your syzbot automation works made it so
much easier so thanks a lot!

The patch has been posted http://lkml.kernel.org/r/20180807072553.14941-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs
