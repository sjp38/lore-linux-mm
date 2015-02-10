Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7200E6B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 05:45:29 -0500 (EST)
Received: by mail-yk0-f177.google.com with SMTP id 20so1639383yks.8
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 02:45:29 -0800 (PST)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com. [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id h83si2925775ykc.35.2015.02.10.02.45.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 02:45:28 -0800 (PST)
Received: by mail-yk0-f176.google.com with SMTP id q200so13957163ykb.7
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 02:45:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+icZUWLJvuZknXhamKJxyGb+OYdkeD5z0V_jn=BQVtq8F5XUQ@mail.gmail.com>
References: <CA+icZUWLJvuZknXhamKJxyGb+OYdkeD5z0V_jn=BQVtq8F5XUQ@mail.gmail.com>
Date: Tue, 10 Feb 2015 16:15:28 +0530
Message-ID: <CAKTCnz=ABrmbQrAEYJ=D0=s2+fRj9FH4D5oG6aWW-qVMoYLdEA@mail.gmail.com>
Subject: Re: [3.19-final|next-20150204] LTP OOM testsuite causes call-traces
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>

On Tue, Feb 10, 2015 at 3:12 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> Hi,
>
> I first noticed call-traces in next-20150204 and tested on v3.19-final
> out of curiosity.
>
> So, oom3 | oom4 | oom5 from LTP tests produces call-traces in my logs
> in both releases.
> Yesterday, I sent a tarball to linux-mm/Shutemov which has material
> for next-20150204.
> The for-lkml tarball has stuff for v3.19-final.
>
> As an example (please see dmesg files in attached tarball(s)):
> ...
> +[  143.591734] oom03 invoked oom-killer: gfp_mask=0xd0, order=0,
> oom_score_adj=0
> +[  143.591789] oom03 cpuset=/ mems_allowed=0
> +[  143.591828] CPU: 0 PID: 2904 Comm: oom03 Not tainted 3.19.0-1-iniza-small #1
> +[  143.591830] Hardware name: SAMSUNG ELECTRONICS CO., LTD.
> 530U3BI/530U4BI/530U4BH/530U3BI/530U4BI/530U4BH, BIOS 13XK 03/28/2013
> +[  143.591831]  ffff880034a64800 ffff880032c57bf8 ffffffff8175c66c
> 0000000000000008
> +[  143.591835]  ffff8800681a54d0 ffff880032c57c88 ffffffff8175ac3a
> ffff880032c57c28
> +[  143.591838]  ffffffff810c329d 0000000000000206 ffffffff81c74040
> ffff880032c57c38
> +[  143.591841] Call Trace:
> +[  143.591848]  [<ffffffff8175c66c>] dump_stack+0x4c/0x65
> +[  143.591852]  [<ffffffff8175ac3a>] dump_header+0x9e/0x259
> +[  143.591857]  [<ffffffff810c329d>] ? trace_hardirqs_on_caller+0x15d/0x200
> +[  143.591860]  [<ffffffff810c334d>] ? trace_hardirqs_on+0xd/0x10
> +[  143.591863]  [<ffffffff81184cd2>] oom_kill_process+0x1d2/0x3c0
> +[  143.591868]  [<ffffffff811ebf40>] mem_cgroup_oom_synchronize+0x630/0x670
> +[  143.591871]  [<ffffffff811e6ac0>] ? mem_cgroup_reset+0xb0/0xb0
> +[  143.591874]  [<ffffffff81185628>] pagefault_out_of_memory+0x18/0x90
> +[  143.591877]  [<ffffffff8106317d>] mm_fault_error+0x8d/0x190
> +[  143.591879]  [<ffffffff810637a8>] __do_page_fault+0x528/0x600
> +[  143.591883]  [<ffffffff8113a847>] ? __acct_update_integrals+0xb7/0x120
> +[  143.591886]  [<ffffffff81765a1b>] ? _raw_spin_unlock+0x2b/0x40
> +[  143.591889]  [<ffffffff810a8ac1>] ? vtime_account_user+0x91/0xa0
> +[  143.591892]  [<ffffffff8117ff83>] ? context_tracking_user_exit+0xb3/0x110
> +[  143.591895]  [<ffffffff810638b1>] do_page_fault+0x31/0x70
> +[  143.591898]  [<ffffffff817687b8>] page_fault+0x28/0x30
> +[  143.591934] Task in /1 killed as a result of limit of /1
> +[  143.591940] memory: usage 1048576kB, limit 1048576kB, failcnt 24350
> +[  143.591942] memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
> +[  143.591943] kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
> +[  143.591944] Memory cgroup stats for /1: cache:0KB rss:1048576KB
> rss_huge:0KB mapped_file:0KB writeback:12060KB inactive_anon:524284KB
> active_anon:524192KB inactive_file:0KB active_file:0KB unevictable:0KB
> +[  143.592007] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents
> oom_score_adj name
> +[  143.592155] [ 2903]     0  2903     1618      436       9        0
>             0 oom03
> +[  143.592159] [ 2904]     0  2904   788050   245188     616    65535
>             0 oom03
> +[  143.592162] Memory cgroup out of memory: Kill process 2904 (oom03)
> score 921 or sacrifice child
> +[  143.592167] Killed process 2904 (oom03) total-vm:3152200kB,
> anon-rss:979724kB, file-rss:1028kB
> +[  144.526653] oom03 invoked oom-killer: gfp_mask=0xd0, order=0,
> oom_score_adj=0

Looks like we ran out of memory, the limit is 1024MB (1GiB) and we've
hit it with a fail count of 24350. So basically /1 hit the limit and
got OOM killed. Isn't that what you were testing for? How was the
expected victim?

Thanks,
Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
