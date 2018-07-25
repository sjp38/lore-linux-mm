Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FF306B0003
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 20:10:25 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id r144-v6so3318364ywg.9
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 17:10:25 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id n18-v6si3125268ybp.122.2018.07.24.17.10.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 17:10:24 -0700 (PDT)
Date: Tue, 24 Jul 2018 17:10:04 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180725001001.GA30802@castle.DHCP.thefacebook.com>
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
 <9ef76b45-d50f-7dc6-d224-683ab23efdb0@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <9ef76b45-d50f-7dc6-d224-683ab23efdb0@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, mhocko@kernel.org, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Tue, Jul 24, 2018 at 08:59:58PM +0900, Tetsuo Handa wrote:
> Roman, will you check this cleanup patch? This patch applies on top of next-20180724.
> I assumed that your series do not kill processes which current thread should not
> wait for termination.

Hi Tetsuo!

> 
> From 86ba99fbf73a9eda0df5ee4ae70c075781e83f81 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Tue, 24 Jul 2018 14:00:45 +0900
> Subject: [PATCH] mm,oom: Check pending victims earlier in out_of_memory().
> 
> The "mm, oom: cgroup-aware OOM killer" patchset introduced INFLIGHT_VICTIM
> in order to replace open-coded ((void *)-1UL). But (regarding CONFIG_MMU=y
> case) we have a list of inflight OOM victim threads which are connected to
> oom_reaper_list. Thus we can check whether there are inflight OOM victims
> before starting process/memcg list traversal. Since it is likely that only
> few threads are linked to oom_reaper_list, checking all victims' OOM domain
> will not matter.

I have a couple of top-level concerns:
1) You're doubling the size of oom_reaper memory footprint in task_struct.
   I doubt, that code cleanup really worth it. If it's absolutely necessary
   to resolve the lockup, which you mentioned, it should be explained
   explicitly.

2) There are several cosmetic changes in this patch, which makes reviewing
   harder. Can you, please, split it into several parts.


Thanks!
