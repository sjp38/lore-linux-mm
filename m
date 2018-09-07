Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 373666B7DFC
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 07:24:08 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id w19-v6so7456362pfa.14
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 04:24:08 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 64-v6si8499368pfs.7.2018.09.07.04.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 04:24:07 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: Introduce time limit for dump_tasks duration.
References: <CACT4Y+Yp6ZbusCWg5C1zaJpcS8=XnGPboKgWfyxVk1axQA2nbw@mail.gmail.com>
 <201809060553.w865rmpj036017@www262.sakura.ne.jp>
 <CACT4Y+YKJWJr-5rBQidt6nY7+VF=BAsvHyh+XTaf8spwNy3qPA@mail.gmail.com>
 <58aa0543-86d0-b2ad-7fb9-9bed7c6a1f6c@i-love.sakura.ne.jp>
 <20180906112306.GO14951@dhcp22.suse.cz>
 <1611e45d-235e-67e9-26e3-d0228255fa2f@i-love.sakura.ne.jp>
 <20180906115320.GS14951@dhcp22.suse.cz>
 <7f50772a-f2ef-d16e-4d09-7f34f4bf9227@i-love.sakura.ne.jp>
 <20180906143905.GC14951@dhcp22.suse.cz>
 <32c58019-5e2d-b3a1-a6ad-ea374ccd8b60@i-love.sakura.ne.jp>
 <20180907082745.GB19621@dhcp22.suse.cz>
 <CACT4Y+bS+kqf+8fp11qSpQ4WtaZt_sVYmvwi_9LFX_=Dwk1N4A@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <f9f75daf-beb1-0f74-9ff3-dcea3fae44ed@i-love.sakura.ne.jp>
Date: Fri, 7 Sep 2018 19:49:42 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bS+kqf+8fp11qSpQ4WtaZt_sVYmvwi_9LFX_=Dwk1N4A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>, 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, linux-mm <linux-mm@kvack.org>

On 2018/09/07 18:36, Dmitry Vyukov wrote:
> But I am still concerned as to what has changed recently. Potentially
> this happens only on linux-next, at least that's where I saw all
> existing reports.
> New tasks seem to be added to the tail of the tasks list, but this
> part does not seem to be changed recently in linux-next..
> 

As far as dump_tasks() is saying, these tasks are alive. Thus, I want to know
what these tasks are doing (i.e. SysRq-t output). Since this is occurring in
linux-next, we can try CONFIG_DEBUG_AID_FOR_SYZBOT=y case like
https://lkml.org/lkml/2018/9/3/353 does. 
