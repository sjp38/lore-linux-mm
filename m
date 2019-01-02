Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 814C78E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 12:07:08 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 74so32984395pfk.12
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 09:07:08 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o195si13494927pfg.106.2019.01.02.09.07.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 09:07:07 -0800 (PST)
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
References: <0000000000007beca9057e4c8c14@google.com>
 <CACT4Y+Yx4BJw=F_PMx9a8AjPKzEwhzLnzt9K-dgkBoNkKQj2+g@mail.gmail.com>
 <ef2508c9-d069-2143-09a6-a90b9ef12568@I-love.SAKURA.ne.jp>
 <CACT4Y+YYwYDnqFmMwfSg6UNXnrbh46bo0jp7ijbej8nkDDmBXQ@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <eeb95c52-5bf8-d3ce-d32b-269aa86bcd93@i-love.sakura.ne.jp>
Date: Thu, 3 Jan 2019 02:06:58 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+YYwYDnqFmMwfSg6UNXnrbh46bo0jp7ijbej8nkDDmBXQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>, David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>

On 2018/12/31 17:24, Dmitry Vyukov wrote:
>>> Since this involves OOMs and looks like a one-off induced memory corruption:
>>>
>>> #syz dup: kernel panic: corrupted stack end in wb_workfn
>>>
>>
>> Why?
>>
>> RCU stall in this case is likely to be latency caused by flooding of printk().
> 
> Just a hypothesis. OOMs lead to arbitrary memory corruptions, so can
> cause stalls as well. But can be what you said too. I just thought
> that cleaner dashboard is more useful than a large assorted pile of
> crashes. If you think it's actionable in some way, feel free to undup.
> 

We don't know why bpf tree is hitting this problem.
Let's continue monitoring this problem.

#syz undup
