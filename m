Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67B416B7879
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:55:21 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o16-v6so5420849pgv.21
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:55:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id u18-v6si5102303pgo.142.2018.09.06.04.55.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 04:55:20 -0700 (PDT)
Subject: [PATCH] mm, oom: Introduce time limit for dump_tasks duration.
References: <0252ad5d-46e6-0d7f-ef91-4e316657a83d@i-love.sakura.ne.jp>
 <CACT4Y+Yp6ZbusCWg5C1zaJpcS8=XnGPboKgWfyxVk1axQA2nbw@mail.gmail.com>
 <201809060553.w865rmpj036017@www262.sakura.ne.jp>
 <CACT4Y+YKJWJr-5rBQidt6nY7+VF=BAsvHyh+XTaf8spwNy3qPA@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <58aa0543-86d0-b2ad-7fb9-9bed7c6a1f6c@i-love.sakura.ne.jp>
Date: Thu, 6 Sep 2018 19:58:25 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+YKJWJr-5rBQidt6nY7+VF=BAsvHyh+XTaf8spwNy3qPA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>, 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, linux-mm <linux-mm@kvack.org>

On 2018/09/06 18:54, Dmitry Vyukov wrote:
> On Thu, Sep 6, 2018 at 7:53 AM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> Dmitry Vyukov wrote:
>>>> Also, another notable thing is that the backtrace for some reason includes
>>>>
>>>> [ 1048.211540]  ? oom_killer_disable+0x3a0/0x3a0
>>>>
>>>> line. Was syzbot testing process freezing functionality?
>>>
>>> What's the API for this?
>>>
>>
>> I'm not a user of suspend/hibernation. But it seems that usage of the API
>> is to write one of words listed in /sys/power/state into /sys/power/state .
>>
>> # echo suspend > /sys/power/state
> 
> syzkaller should not write to /sys/power/state. The only mention of
> "power" is in some selinux contexts.
> 

OK. Then, I have no idea.
Anyway, I think we can apply this patch.
