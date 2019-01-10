Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3408E8E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 05:12:40 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id x82so10479387ita.9
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 02:12:40 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f64si41432844ioa.156.2019.01.10.02.12.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 02:12:39 -0800 (PST)
Subject: Re: [PATCH] lockdep: Add debug printk() for downgrade_write()
 warning.
References: <1546771139-9349-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <e1a38e21-d5fe-dee3-7081-bc1a12965a68@i-love.sakura.ne.jp>
 <20190106201941.49f6dc4a4d2e9d15b575f88a@linux-foundation.org>
 <CACT4Y+Y=V-yRQN6YV_wXT0gejbQKTtUu7wrRmuPVojaVv6NFsQ@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <146b28b0-e69c-cf3d-2b0c-0c78110e3718@i-love.sakura.ne.jp>
Date: Thu, 10 Jan 2019 19:12:06 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Y=V-yRQN6YV_wXT0gejbQKTtUu7wrRmuPVojaVv6NFsQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
Cc: Linux-MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>

On 2019/01/07 14:58, Dmitry Vyukov wrote:
> On Mon, Jan 7, 2019 at 5:19 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>> I tossed it in there.
>>
>> But I wonder if anyone is actually running this code.  Because
>>
>> --- a/lib/Kconfig.debug~info-task-hung-in-generic_file_write_iter
>> +++ a/lib/Kconfig.debug
>> @@ -2069,6 +2069,12 @@ config IO_STRICT_DEVMEM
>>
>>           If in doubt, say Y.
>>
>> +config DEBUG_AID_FOR_SYZBOT
>> +       bool "Additional debug code for syzbot"
>> +       default n
>> +       help
>> +         This option is intended for testing by syzbot.
>> +
> 
> 
> Yes, syzbot always defines this option:
> 
> https://github.com/google/syzkaller/blob/master/dashboard/config/upstream-kasan.config#L14
> https://github.com/google/syzkaller/blob/master/dashboard/config/upstream-kmsan.config#L9
> 
> It's meant specifically for such cases.
> 
> Tetsuo already got some useful information for past bugs using this feature.
> 

Andrew, you can drop this patch, for a patch that fixes this problem is already available
at https://lkml.kernel.org/r/1547093005-26085-1-git-send-email-longman@redhat.com .
Peter, please apply the fix from Waiman Long.
