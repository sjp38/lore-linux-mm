Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5B66B7811
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 05:54:25 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f32-v6so5296050pgm.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 02:54:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q7-v6sor965881pgv.155.2018.09.06.02.54.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Sep 2018 02:54:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201809060553.w865rmpj036017@www262.sakura.ne.jp>
References: <0252ad5d-46e6-0d7f-ef91-4e316657a83d@i-love.sakura.ne.jp>
 <CACT4Y+Yp6ZbusCWg5C1zaJpcS8=XnGPboKgWfyxVk1axQA2nbw@mail.gmail.com> <201809060553.w865rmpj036017@www262.sakura.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 6 Sep 2018 11:54:02 +0200
Message-ID: <CACT4Y+YKJWJr-5rBQidt6nY7+VF=BAsvHyh+XTaf8spwNy3qPA@mail.gmail.com>
Subject: Re: INFO: task hung in ext4_da_get_block_prep
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>, 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On Thu, Sep 6, 2018 at 7:53 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Dmitry Vyukov wrote:
>> > Also, another notable thing is that the backtrace for some reason includes
>> >
>> > [ 1048.211540]  ? oom_killer_disable+0x3a0/0x3a0
>> >
>> > line. Was syzbot testing process freezing functionality?
>>
>> What's the API for this?
>>
>
> I'm not a user of suspend/hibernation. But it seems that usage of the API
> is to write one of words listed in /sys/power/state into /sys/power/state .
>
> # echo suspend > /sys/power/state

syzkaller should not write to /sys/power/state. The only mention of
"power" is in some selinux contexts.
