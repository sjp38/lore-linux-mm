Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 064B26B02DE
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 10:16:43 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w1-v6so10133619plq.8
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 07:16:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id y23-v6si15938128pfb.284.2018.07.09.07.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 07:16:39 -0700 (PDT)
Subject: Re: BUG: corrupted list in cpu_stop_queue_work
References: <00000000000032412205706753b5@google.com>
 <000000000000693c7d057087caf3@google.com>
 <1271c58e-876b-0df3-3224-319d82634663@I-love.SAKURA.ne.jp>
 <20180709133212.GA2662@bombadil.infradead.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <8b258017-8817-8050-14a5-5e55c56bbf18@i-love.sakura.ne.jp>
Date: Mon, 9 Jul 2018 23:15:54 +0900
MIME-Version: 1.0
In-Reply-To: <20180709133212.GA2662@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: syzbot <syzbot+d8a8e42dfba0454286ff@syzkaller.appspotmail.com>, bigeasy@linutronix.de, linux-kernel@vger.kernel.org, matt@codeblueprint.co.uk, mingo@kernel.org, peterz@infradead.org, syzkaller-bugs@googlegroups.com, tglx@linutronix.de, linux-mm <linux-mm@kvack.org>

On 2018/07/09 22:32, Matthew Wilcox wrote:
>> >From d6f24d6eecd79836502527624f8086f4e3e4c331 Mon Sep 17 00:00:00 2001
>> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Date: Mon, 9 Jul 2018 15:58:44 +0900
>> Subject: [PATCH] shmem: Fix crash upon xas_store() failure.
>>
>> syzbot is reporting list corruption [1]. This is because xas_store() from
>> shmem_add_to_page_cache() is not handling memory allocation failure. Fix
>> this by checking xas_error() after xas_store().
> 
> I have no idea why you wrote this patch on Monday when I already said
> I knew what the problem was on Friday, fixed the problem and pushed it
> out to my git tree on Saturday.
> 

Because syzbot found a C reproducer on 2018/07/09 02:29 UTC, and your fix was
not in time for a kernel version syzbot was testing, and you were not listed
as a recipient of this bug, and I didn't know you already fixed this bug.

Anyway, linux-next-20180709 still does not have this fix.
What is the title of your fix you pushed on Saturday?
