Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED948E0001
	for <linux-mm@kvack.org>; Sun,  6 Jan 2019 08:47:44 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id h10so30021400plk.12
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 05:47:44 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g11si4574942pgn.32.2019.01.06.05.47.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Jan 2019 05:47:43 -0800 (PST)
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
References: <0000000000007beca9057e4c8c14@google.com>
 <CACT4Y+Yx4BJw=F_PMx9a8AjPKzEwhzLnzt9K-dgkBoNkKQj2+g@mail.gmail.com>
 <ef2508c9-d069-2143-09a6-a90b9ef12568@I-love.SAKURA.ne.jp>
 <CACT4Y+YYwYDnqFmMwfSg6UNXnrbh46bo0jp7ijbej8nkDDmBXQ@mail.gmail.com>
 <eeb95c52-5bf8-d3ce-d32b-269aa86bcd93@i-love.sakura.ne.jp>
 <8cdbcb63-d2f7-cace-0eda-d73255fd47e7@i-love.sakura.ne.jp>
 <CACT4Y+Y5cdD=optF2k4a0W7vriVnzmzLU0SPGEJoOHRMi_bsZA@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <ea2bc542-38b2-8218-9eb7-4c4a05da36ea@i-love.sakura.ne.jp>
Date: Sun, 6 Jan 2019 22:47:19 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Y5cdD=optF2k4a0W7vriVnzmzLU0SPGEJoOHRMi_bsZA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>, David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>

On 2019/01/06 22:24, Dmitry Vyukov wrote:
>> A report at 2019/01/05 10:08 from "no output from test machine (2)"
>> ( https://syzkaller.appspot.com/text?tag=CrashLog&x=1700726f400000 )
>> says that there are flood of memory allocation failure messages.
>> Since continuous memory allocation failure messages itself is not
>> recognized as a crash, we might be misunderstanding that this problem
>> is not occurring recently. It will be nice if we can run testcases
>> which are executed on bpf-next tree.
> 
> What exactly do you mean by running test cases on bpf-next tree?
> syzbot tests bpf-next, so it executes lots of test cases on that tree.
> One can also ask for patch testing on bpf-next tree to test a specific
> test case.

syzbot ran "some tests" before getting this report, but we can't find from
this report what the "some tests" are. If we could record all tests executed
in syzbot environments before getting this report, we could rerun the tests
(with manually examining where the source of memory consumption is) in local
environments.

Since syzbot is now using memcg, maybe we can test with sysctl_panic_on_oom == 1.
Any memory consumption that triggers global OOM killer could be considered as
a problem (e.g. memory leak or uncontrolled memory allocation).
