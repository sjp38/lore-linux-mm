Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDC6F8E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 03:17:33 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id m3so28716159pfj.14
        for <linux-mm@kvack.org>; Mon, 31 Dec 2018 00:17:33 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k13si27279327pgb.343.2018.12.31.00.17.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Dec 2018 00:17:32 -0800 (PST)
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
References: <0000000000007beca9057e4c8c14@google.com>
 <CACT4Y+Yx4BJw=F_PMx9a8AjPKzEwhzLnzt9K-dgkBoNkKQj2+g@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <ef2508c9-d069-2143-09a6-a90b9ef12568@I-love.SAKURA.ne.jp>
Date: Mon, 31 Dec 2018 17:17:17 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Yx4BJw=F_PMx9a8AjPKzEwhzLnzt9K-dgkBoNkKQj2+g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>
Cc: David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>

On 2018/12/31 16:49, Dmitry Vyukov wrote:
> On Mon, Dec 31, 2018 at 8:42 AM syzbot
> <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com> wrote:
>>
>> Hello,
>>
>> syzbot found the following crash on:
>>
>> HEAD commit:    ef4ab8447aa2 selftests: bpf: install script with_addr.sh
>> git tree:       bpf-next
>> console output: https://syzkaller.appspot.com/x/log.txt?x=14a28b6e400000
>> kernel config:  https://syzkaller.appspot.com/x/.config?x=7e7e2279c0020d5f
>> dashboard link: https://syzkaller.appspot.com/bug?extid=ea7d9cb314b4ab49a18a
>> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>>
>> Unfortunately, I don't have any reproducer for this crash yet.
>>
>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>> Reported-by: syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com
> 
> Since this involves OOMs and looks like a one-off induced memory corruption:
> 
> #syz dup: kernel panic: corrupted stack end in wb_workfn
> 

Why?

RCU stall in this case is likely to be latency caused by flooding of printk().
