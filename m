Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 09BB26B025F
	for <linux-mm@kvack.org>; Fri, 27 May 2016 13:23:00 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h68so20423708lfh.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:22:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i14si27300736wjn.237.2016.05.27.10.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 10:22:58 -0700 (PDT)
Date: Fri, 27 May 2016 13:20:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm: oom: add memcg to oom_control
Message-ID: <20160527172055.GC2531@cmpxchg.org>
References: <40e03fd7aaf1f55c75d787128d6d17c5a71226c2.1464358556.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <40e03fd7aaf1f55c75d787128d6d17c5a71226c2.1464358556.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 27, 2016 at 05:17:41PM +0300, Vladimir Davydov wrote:
> It's a part of oom context just like allocation order and nodemask, so
> let's move it to oom_control instead of passing it in the argument list.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
