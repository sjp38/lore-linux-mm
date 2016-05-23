Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 906FB6B0253
	for <linux-mm@kvack.org>; Mon, 23 May 2016 06:29:01 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r11so18416579itd.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 03:29:01 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0123.outbound.protection.outlook.com. [157.55.234.123])
        by mx.google.com with ESMTPS id r2si14446680oig.36.2016.05.23.03.29.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 May 2016 03:29:00 -0700 (PDT)
Date: Mon, 23 May 2016 13:28:52 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] memcg: fix mem_cgroup_out_of_memory() return value.
Message-ID: <20160523102852.GA7917@esperanza>
References: <1463753327-5170-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1463753327-5170-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Fri, May 20, 2016 at 11:08:47PM +0900, Tetsuo Handa wrote:
> mem_cgroup_out_of_memory() is returning "true" if it finds a TIF_MEMDIE
> task after an eligible task was found, "false" if it found a TIF_MEMDIE
> task before an eligible task is found.
> 
> This difference confuses memory_max_write() which checks the return value
> of mem_cgroup_out_of_memory(). Since memory_max_write() wants to continue
> looping, mem_cgroup_out_of_memory() should return "true" in this case.
> 
> This patch sets a dummy pointer in order to return "true".
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
