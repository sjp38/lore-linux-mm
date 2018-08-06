Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0C06B0005
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 10:41:42 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d12-v6so5646287pgv.12
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 07:41:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p19-v6si12500311pgm.109.2018.08.06.07.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 07:41:41 -0700 (PDT)
Subject: Re: WARNING in try_charge
References: <884de816-671a-44d4-a6a1-2ad7eff53715@I-love.SAKURA.ne.jp>
 <00000000000070698b0572c28ebc@google.com>
 <20180806113212.GK19540@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <39db7dbc-fedf-a86e-3c8b-0192e83d3c8d@i-love.sakura.ne.jp>
Date: Mon, 6 Aug 2018 23:41:22 +0900
MIME-Version: 1.0
In-Reply-To: <20180806113212.GK19540@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>
Cc: cgroups@vger.kernel.org, dvyukov@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com, David Howells <dhowells@redhat.com>

+David Howells

On 2018/08/06 20:32, Michal Hocko wrote:
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
> 

Since I can't find mm related changes between next-20180803 (syzbot can reproduce) and
next-20180806 (syzbot has not reproduced), I can't guess what makes this problem go away.

But since this problem did not occur for 3.5 hours on next-20180806 (when this problem
was occurring once per 60-90 minutes), the reproducer might not be working as intended
due to "kernfs, sysfs, cgroup, intel_rdt: Support fs_context" or something...

  ./kernel/cgroup/cgroup-internal.h                                          |    3
  ./kernel/cgroup/cgroup-v1.c                                                |  211
  ./kernel/cgroup/cgroup.c                                                   |   81
