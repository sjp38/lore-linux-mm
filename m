Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC65B6B7734
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 01:54:00 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bh1-v6so5033502plb.15
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 22:54:00 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w66-v6si4619617pfi.88.2018.09.05.22.53.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 22:53:59 -0700 (PDT)
Message-Id: <201809060553.w865rmpj036017@www262.sakura.ne.jp>
Subject: Re: INFO: task hung in =?ISO-2022-JP?B?ZXh0NF9kYV9nZXRfYmxvY2tfcHJlcA==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 06 Sep 2018 14:53:48 +0900
References: <0252ad5d-46e6-0d7f-ef91-4e316657a83d@i-love.sakura.ne.jp> <CACT4Y+Yp6ZbusCWg5C1zaJpcS8=XnGPboKgWfyxVk1axQA2nbw@mail.gmail.com>
In-Reply-To: <CACT4Y+Yp6ZbusCWg5C1zaJpcS8=XnGPboKgWfyxVk1axQA2nbw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>, 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

Dmitry Vyukov wrote:
> > Also, another notable thing is that the backtrace for some reason includes
> >
> > [ 1048.211540]  ? oom_killer_disable+0x3a0/0x3a0
> >
> > line. Was syzbot testing process freezing functionality?
> 
> What's the API for this?
> 

I'm not a user of suspend/hibernation. But it seems that usage of the API
is to write one of words listed in /sys/power/state into /sys/power/state .

# echo suspend > /sys/power/state
