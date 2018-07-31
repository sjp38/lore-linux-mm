Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 980396B0007
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:30:32 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id u74-v6so13523805oie.16
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 04:30:32 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id c184-v6si9749491oib.137.2018.07.31.04.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 04:30:31 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
References: <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp>
 <20180730144647.GX24267@dhcp22.suse.cz>
 <20180730145425.GE1206094@devbig004.ftw2.facebook.com>
 <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp>
 <20180730154424.GG1206094@devbig004.ftw2.facebook.com>
 <20180730185110.GB24267@dhcp22.suse.cz>
 <20180730191005.GC24267@dhcp22.suse.cz>
 <6f433d59-4a56-b698-e119-682bb8bf6713@i-love.sakura.ne.jp>
 <20180731050928.GA4557@dhcp22.suse.cz>
 <b03f09c2-f749-9c80-b4f6-d0b4a9634013@i-love.sakura.ne.jp>
 <20180731111519.GH4557@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <08292e78-9a28-12ec-4164-2934cde5be51@i-love.sakura.ne.jp>
Date: Tue, 31 Jul 2018 20:30:08 +0900
MIME-Version: 1.0
In-Reply-To: <20180731111519.GH4557@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/07/31 20:15, Michal Hocko wrote:
>>> I will send the patch to Andrew if the patch is ok. 
>>
>> Andrew, can we send the "we used to have a sleeping point in the oom path but this has
>> been removed recently" patch to linux.git ?
> 
> This can really wait for the next merge window IMHO.
> 

"mm, oom: cgroup-aware OOM killer" in linux-next.git is reviving that sleeping point.
Current "mm, oom: cgroup-aware OOM killer" will not be sent to linux.git in the next
merge window? I'm confused...
