Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B7EC38E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 05:49:23 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p15so38882731pfk.7
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 02:49:23 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d9si53687655pgv.123.2019.01.05.02.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 02:49:22 -0800 (PST)
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
References: <0000000000007beca9057e4c8c14@google.com>
 <CACT4Y+Yx4BJw=F_PMx9a8AjPKzEwhzLnzt9K-dgkBoNkKQj2+g@mail.gmail.com>
 <ef2508c9-d069-2143-09a6-a90b9ef12568@I-love.SAKURA.ne.jp>
 <CACT4Y+YYwYDnqFmMwfSg6UNXnrbh46bo0jp7ijbej8nkDDmBXQ@mail.gmail.com>
 <eeb95c52-5bf8-d3ce-d32b-269aa86bcd93@i-love.sakura.ne.jp>
Message-ID: <8cdbcb63-d2f7-cace-0eda-d73255fd47e7@i-love.sakura.ne.jp>
Date: Sat, 5 Jan 2019 19:49:11 +0900
MIME-Version: 1.0
In-Reply-To: <eeb95c52-5bf8-d3ce-d32b-269aa86bcd93@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>, David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>

On 2019/01/03 2:06, Tetsuo Handa wrote:
> On 2018/12/31 17:24, Dmitry Vyukov wrote:
>>>> Since this involves OOMs and looks like a one-off induced memory corruption:
>>>>
>>>> #syz dup: kernel panic: corrupted stack end in wb_workfn
>>>>
>>>
>>> Why?
>>>
>>> RCU stall in this case is likely to be latency caused by flooding of printk().
>>
>> Just a hypothesis. OOMs lead to arbitrary memory corruptions, so can
>> cause stalls as well. But can be what you said too. I just thought
>> that cleaner dashboard is more useful than a large assorted pile of
>> crashes. If you think it's actionable in some way, feel free to undup.
>>
> 
> We don't know why bpf tree is hitting this problem.
> Let's continue monitoring this problem.
> 
> #syz undup
> 

A report at 2019/01/05 10:08 from "no output from test machine (2)"
( https://syzkaller.appspot.com/text?tag=CrashLog&x=1700726f400000 )
says that there are flood of memory allocation failure messages.
Since continuous memory allocation failure messages itself is not
recognized as a crash, we might be misunderstanding that this problem
is not occurring recently. It will be nice if we can run testcases
which are executed on bpf-next tree.
