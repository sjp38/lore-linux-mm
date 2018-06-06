Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id E49936B0007
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 09:38:11 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id a25-v6so4058125otf.2
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 06:38:11 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g41-v6si228576ote.66.2018.06.06.06.38.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jun 2018 06:38:10 -0700 (PDT)
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
 <30c750b4-2c65-5737-3172-bddc666d0a8f@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1806060155120.104813@chino.kir.corp.google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <bb08ebf7-e950-f3e2-d794-bff289fb22a9@i-love.sakura.ne.jp>
Date: Wed, 6 Jun 2018 22:37:42 +0900
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1806060155120.104813@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, guro@fb.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On 2018/06/06 18:02, David Rientjes wrote:
> On Mon, 4 Jun 2018, Tetsuo Handa wrote:
> 
>> Is current version of "mm, oom: cgroup-aware OOM killer" patchset going to be
>> dropped for now? I want to know which state should I use for baseline for my patch.
>>
> 
> My patchset to fix the issues with regard to the cgroup-aware oom killer 
> to fix its calculations (current version in -mm is completey buggy for 
> oom_score_adj, fixed in my patch 4/6), its context based errors 
> (discounting mempolicy oom kills, fixed in my patch 6/6) and make it 
> generally useful beyond highly specialized usecases in a backwards 
> compatible way was posted on March 22 at 
> https://marc.info/?l=linux-kernel&m=152175564104466.
> 
> The base patchset is seemingly abandoned in -mm, unfortunately, so I think 
> all oom killer patches should be based on Linus's tree.
> 
OK. I will use linux.git as a base.

By the way, does "[RFC] Getting rid of INFLIGHT_VICTIM" simplify or break
your cgroup-aware oom killer? If it simplifies your work, I'd like to apply
it as well.
