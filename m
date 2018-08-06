Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE8666B000D
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 10:58:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b25-v6so4283735eds.17
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 07:58:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g8-v6si968970edg.399.2018.08.06.07.58.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 07:58:34 -0700 (PDT)
Date: Mon, 6 Aug 2018 16:58:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WARNING in try_charge
Message-ID: <20180806145833.GA8607@dhcp22.suse.cz>
References: <884de816-671a-44d4-a6a1-2ad7eff53715@I-love.SAKURA.ne.jp>
 <00000000000070698b0572c28ebc@google.com>
 <20180806113212.GK19540@dhcp22.suse.cz>
 <39db7dbc-fedf-a86e-3c8b-0192e83d3c8d@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39db7dbc-fedf-a86e-3c8b-0192e83d3c8d@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, dvyukov@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com, David Howells <dhowells@redhat.com>

On Mon 06-08-18 23:41:22, Tetsuo Handa wrote:
> +David Howells
> 
> On 2018/08/06 20:32, Michal Hocko wrote:
> > On Mon 06-08-18 04:27:02, syzbot wrote:
> >> Hello,
> >>
> >> syzbot has tested the proposed patch and the reproducer did not trigger
> >> crash:
> >>
> >> Reported-and-tested-by:
> >> syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com
> >>
> >> Tested on:
> >>
> >> commit:         8c8399e0a3fb Add linux-next specific files for 20180806
> >> git tree:       linux-next
> >> kernel config:  https://syzkaller.appspot.com/x/.config?x=1b6bc1781e49e93e
> >> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> >> patch:          https://syzkaller.appspot.com/x/patch.diff?x=14fe18e2400000
> >>
> >> Note: testing is done by a robot and is best-effort only.
> > 
> > OK, so this smells like a problem in the previous group oom changes. Or
> > maybe it is not very easy to reproduce?
> > 
> 
> Since I can't find mm related changes between next-20180803 (syzbot can reproduce) and
> next-20180806 (syzbot has not reproduced), I can't guess what makes this problem go away.

Hmm, but original report was against 4.18.0-rc6-next-20180725+ kernel.
And that one had the old group oom code. /me confused.
-- 
Michal Hocko
SUSE Labs
