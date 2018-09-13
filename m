Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8214F8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 20:45:19 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g36-v6so1786242plb.5
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 17:45:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b3-v6si2467753plc.502.2018.09.12.17.45.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 12 Sep 2018 17:45:16 -0700 (PDT)
Subject: Re: mmotm 2018-09-12-16-40 uploaded (psi)
References: <20180912234039.Xa5RS%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <a9bef471-ac93-2983-618b-ffee65f01e0b@infradead.org>
Date: Wed, 12 Sep 2018 17:45:08 -0700
MIME-Version: 1.0
In-Reply-To: <20180912234039.Xa5RS%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On 9/12/18 4:40 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2018-09-12-16-40 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.

Multiple build errors when CONFIG_SMP is not set: (this is on i386 fwiw)

in the psi (pressure) patches, I guess:

In file included from ../kernel/sched/sched.h:1367:0,
                 from ../kernel/sched/core.c:8:
../kernel/sched/stats.h: In function 'psi_task_tick':
../kernel/sched/stats.h:135:33: error: 'struct rq' has no member named 'cpu'
   psi_memstall_tick(rq->curr, rq->cpu);


-- 
~Randy
