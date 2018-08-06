Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 53EF76B000E
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 07:32:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g11-v6so3924851edi.8
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 04:32:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9-v6si3578330edm.12.2018.08.06.04.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 04:32:14 -0700 (PDT)
Date: Mon, 6 Aug 2018 13:32:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WARNING in try_charge
Message-ID: <20180806113212.GK19540@dhcp22.suse.cz>
References: <884de816-671a-44d4-a6a1-2ad7eff53715@I-love.SAKURA.ne.jp>
 <00000000000070698b0572c28ebc@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000000000070698b0572c28ebc@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>
Cc: cgroups@vger.kernel.org, dvyukov@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penguin-kernel@I-love.SAKURA.ne.jp, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com

On Mon 06-08-18 04:27:02, syzbot wrote:
> Hello,
> 
> syzbot has tested the proposed patch and the reproducer did not trigger
> crash:
> 
> Reported-and-tested-by:
> syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com
> 
> Tested on:
> 
> commit:         8c8399e0a3fb Add linux-next specific files for 20180806
> git tree:       linux-next
> kernel config:  https://syzkaller.appspot.com/x/.config?x=1b6bc1781e49e93e
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> patch:          https://syzkaller.appspot.com/x/patch.diff?x=14fe18e2400000
> 
> Note: testing is done by a robot and is best-effort only.

OK, so this smells like a problem in the previous group oom changes. Or
maybe it is not very easy to reproduce?

-- 
Michal Hocko
SUSE Labs
