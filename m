Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 76DF86B02B4
	for <linux-mm@kvack.org>; Tue, 23 May 2017 07:29:45 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r63so106377652itc.2
        for <linux-mm@kvack.org>; Tue, 23 May 2017 04:29:45 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x13si531674ite.18.2017.05.23.04.29.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 May 2017 04:29:44 -0700 (PDT)
Subject: Re: [PATCH] mm/oom_kill: count global and memory cgroup oom kills
References: <149520375057.74196.2843113275800730971.stgit@buzz>
 <20170523072704.GJ12813@dhcp22.suse.cz>
 <f05c5a6d-27df-4080-a0b5-68694d8e4165@yandex-team.ru>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <a22d088c-8a3a-ba15-ca7f-08e0de71eb25@I-love.SAKURA.ne.jp>
Date: Tue, 23 May 2017 20:29:25 +0900
MIME-Version: 1.0
In-Reply-To: <f05c5a6d-27df-4080-a0b5-68694d8e4165@yandex-team.ru>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On 2017/05/23 20:05, Konstantin Khlebnikov wrote:
> On 23.05.2017 10:27, Michal Hocko wrote:
>> On Fri 19-05-17 17:22:30, Konstantin Khlebnikov wrote:
>>> Show count of global oom killer invocations in /proc/vmstat and
>>> count of oom kills inside memory cgroup in knob "memory.events"
>>> (in memory.oom_control for v1 cgroup).
>>>
>>> Also describe difference between "oom" and "oom_kill" in memory
>>> cgroup documentation. Currently oom in memory cgroup kills tasks
>>> iff shortage has happened inside page fault.
>>>
>>> These counters helps in monitoring oom kills - for now
>>> the only way is grepping for magic words in kernel log.
>>
>> Have you considered adding memcg's oom alternative for the global case
>> as well. It would be useful to see how many times we hit the OOM
>> condition without killing anything. That could help debugging issues
>> when the OOM killer cannot be invoked (e.g. GFP_NO{FS,IO} contextx)
>> and the system cannot get out of the oom situation.
> 
> I think present warn_alloc() should be enough for debugging,
> maybe it should taint kernel in some cases to give a hint for future warnings/bugs.
> 

I don't think warn_alloc() is enough. We can fail to warn using warn_alloc(), see
http://lkml.kernel.org/r/1495331504-12480-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
