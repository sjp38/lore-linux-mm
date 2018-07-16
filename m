Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 379FF6B0006
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 17:14:18 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s200-v6so54173463oie.6
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 14:14:18 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p131-v6si21220316oic.105.2018.07.16.14.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 14:14:16 -0700 (PDT)
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
References: <20171130152824.1591-1-guro@fb.com>
 <20180605114729.GB19202@dhcp22.suse.cz>
 <alpine.DEB.2.21.1807131438380.194789@chino.kir.corp.google.com>
 <0a86d2a7-b78e-7e69-f628-aa2c75d91ff0@i-love.sakura.ne.jp>
Message-ID: <0d018c7e-a3de-a23a-3996-bed8b28b1e4a@i-love.sakura.ne.jp>
Date: Tue, 17 Jul 2018 06:13:47 +0900
MIME-Version: 1.0
In-Reply-To: <0a86d2a7-b78e-7e69-f628-aa2c75d91ff0@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>, linux-mm@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

No response from Roman and David...

Andrew, will you once drop Roman's cgroup-aware OOM killer and David's patches?
Roman's series has a bug which I mentioned and which can be avoided by my patch.
David's patch is using MMF_UNSTABLE incorrectly such that it might start selecting
next OOM victim without trying to reclaim any memory.

Since they are not responding to my mail, I suggest once dropping from linux-next.

https://www.spinics.net/lists/linux-mm/msg153212.html
https://lore.kernel.org/lkml/201807130620.w6D6KiAJ093010@www262.sakura.ne.jp/T/#u

On 2018/07/14 10:55, Tetsuo Handa wrote:
> On 2018/07/14 6:59, David Rientjes wrote:
>> I'm not trying to preclude the cgroup-aware oom killer from being merged,
>> I'm the only person actively trying to get it merged.
> 
> Before merging the cgroup-aware oom killer, can we merge OOM lockup fixes
> and my cleanup? The gap between linux.git and linux-next.git keeps us unable
> to use agreed baseline.
> 
