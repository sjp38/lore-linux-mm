Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F27C6B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 06:41:19 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id e2-v6so17904300oii.20
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 03:41:19 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k77-v6si5906469oib.353.2018.06.04.03.41.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 03:41:17 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
References: <20180525083118.GI11881@dhcp22.suse.cz>
 <201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
 <20180525114213.GJ11881@dhcp22.suse.cz>
 <201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp>
 <20180528124313.GC27180@dhcp22.suse.cz>
 <201805290557.BAJ39558.MFLtOJVFOHFOSQ@I-love.SAKURA.ne.jp>
 <20180529060755.GH27180@dhcp22.suse.cz>
 <20180529160700.dbc430ebbfac301335ac8cf4@linux-foundation.org>
 <20180601152801.GH15278@dhcp22.suse.cz>
 <20180601141110.34915e0a1fdbd07d25cc15cc@linux-foundation.org>
 <20180604070419.GG19202@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <30c750b4-2c65-5737-3172-bddc666d0a8f@i-love.sakura.ne.jp>
Date: Mon, 4 Jun 2018 19:41:01 +0900
MIME-Version: 1.0
In-Reply-To: <20180604070419.GG19202@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On 2018/06/04 16:04, Michal Hocko wrote:
> On Fri 01-06-18 14:11:10, Andrew Morton wrote:
>> On Fri, 1 Jun 2018 17:28:01 +0200 Michal Hocko <mhocko@kernel.org> wrote:
>>
>>> On Tue 29-05-18 16:07:00, Andrew Morton wrote:
>>>> On Tue, 29 May 2018 09:17:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:
>>>>
>>>>>> I suggest applying
>>>>>> this patch first, and then fix "mm, oom: cgroup-aware OOM killer" patch.
>>>>>
>>>>> Well, I hope the whole pile gets merged in the upcoming merge window
>>>>> rather than stall even more.
>>>>
>>>> I'm more inclined to drop it all.  David has identified significant
>>>> shortcomings and I'm not seeing a way of addressing those shortcomings
>>>> in a backward-compatible fashion.  Therefore there is no way forward
>>>> at present.
>>>
>>> Well, I thought we have argued about those "shortcomings" back and forth
>>> and expressed that they are not really a problem for workloads which are
>>> going to use the feature. The backward compatibility has been explained
>>> as well AFAICT.
>>
>> Feel free to re-explain.  It's the only way we'll get there.
> 
> OK, I will go and my points to the last version of the patchset.
> 
>> David has proposed an alternative patchset.  IIRC Roman gave that a
>> one-line positive response but I don't think it has seen a lot of
>> attention?
> 
> I plan to go and revisit that. My preliminary feedback is that a more
> generic policy API is really tricky and the patchset has many holes
> there. But I will come with a more specific feedback in the respective
> thread.
> 
Is current version of "mm, oom: cgroup-aware OOM killer" patchset going to be
dropped for now? I want to know which state should I use for baseline for my patch.
