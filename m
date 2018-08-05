Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A84D96B0005
	for <linux-mm@kvack.org>; Sun,  5 Aug 2018 07:33:30 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id t5-v6so1877890pgp.17
        for <linux-mm@kvack.org>; Sun, 05 Aug 2018 04:33:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id y92-v6si7787298plb.378.2018.08.05.04.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Aug 2018 04:33:29 -0700 (PDT)
Subject: Re: WARNING in try_charge
References: <0000000000005e979605729c1564@google.com>
 <4660f164-b3e3-28a0-9898-718c5fa6b84d@I-love.SAKURA.ne.jp>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <3d4ca33d-54cb-ca5d-95cc-034fe62e5a35@I-love.SAKURA.ne.jp>
Date: Sun, 5 Aug 2018 20:33:11 +0900
MIME-Version: 1.0
In-Reply-To: <4660f164-b3e3-28a0-9898-718c5fa6b84d@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, David Rientjes <rientjes@google.com>
Cc: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com

On 2018/08/04 22:45, Tetsuo Handa wrote:
> syzbot is hitting WARN(1) because of mem_cgroup_out_of_memory() == false.

Since syzbot found a syz reproducer, I asked syzbot to try two patches.

Setting MMF_OOM_SKIP under oom_lock to prevent from races
( https://syzkaller.appspot.com/x/patch.diff?x=10fb3fd0400000 ) was not sufficient.

Waiting until __mmput() completes (with timeout using OOM score feedback)
( https://syzkaller.appspot.com/x/patch.diff?x=101e449c400000 ) solved this race.
