Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4176B7E82
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 09:21:24 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id h5-v6so20475123itb.3
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 06:21:24 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 68-v6si5717916itu.143.2018.09.07.06.21.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 06:21:22 -0700 (PDT)
Subject: [PATCH v2] syzbot: Dump all threads upon global OOM.
References: <1536319423-9344-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <CACT4Y+ZN9ZccjgzUy=8gBntWdau5H1wtLxsh6ZautaTNdMvieQ@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <312c642d-559b-92c7-0377-d98ec416e0bd@i-love.sakura.ne.jp>
Date: Fri, 7 Sep 2018 22:21:06 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZN9ZccjgzUy=8gBntWdau5H1wtLxsh6ZautaTNdMvieQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On 2018/09/07 21:57, Dmitry Vyukov wrote:
>> @@ -446,6 +447,10 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>>                 if (is_dump_unreclaim_slabs())
>>                         dump_unreclaimable_slab();
>>         }
>> +#ifdef CONFIG_DEBUG_AID_FOR_SYZBOT
>> +       show_state();
>> +       panic("Out of memory");
> 
> won't this panic on every oom?
> we have lots of oom's, especially inside of cgroups, but probably global too
> it would be bad if we crash all machines this way
> 
> 

OK. Here is updated patch.
