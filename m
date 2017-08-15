Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 634796B02B4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 08:20:28 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d24so1395200wmi.0
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 05:20:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x88si1192128wma.200.2017.08.15.05.20.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Aug 2017 05:20:27 -0700 (PDT)
Subject: Re: [v5 2/4] mm, oom: cgroup-aware OOM killer
References: <20170814183213.12319-1-guro@fb.com>
 <20170814183213.12319-3-guro@fb.com>
 <alpine.DEB.2.10.1708141532300.63207@chino.kir.corp.google.com>
 <20170815121558.GA15892@castle.dhcp.TheFacebook.com>
From: Aleksa Sarai <asarai@suse.de>
Message-ID: <f769d03d-5743-b794-a249-bb52b408ab0e@suse.de>
Date: Tue, 15 Aug 2017 22:20:18 +1000
MIME-Version: 1.0
In-Reply-To: <20170815121558.GA15892@castle.dhcp.TheFacebook.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On 08/15/2017 10:15 PM, Roman Gushchin wrote:
> Generally, oom_score_adj should have a meaning only on a cgroup level,
> so extending it to the system level doesn't sound as a good idea.

But wasn't the original purpose of oom_score (and oom_score_adj) to work 
on a system level, aka "normal" OOM? Is there some peculiarity about 
memcg OOM that I'm missing?

-- 
Aleksa Sarai
Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
