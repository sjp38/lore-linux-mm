Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 650DC6B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 13:38:37 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id q17so57593785lbn.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:38:37 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p137si13285742wmg.68.2016.05.27.10.38.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 10:38:36 -0700 (PDT)
Date: Fri, 27 May 2016 13:36:29 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: fix possible css ref leak on oom
Message-ID: <20160527173629.GE2531@cmpxchg.org>
References: <1464019330-7579-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464019330-7579-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 23, 2016 at 07:02:10PM +0300, Vladimir Davydov wrote:
> mem_cgroup_oom may be invoked multiple times while a process is handling
> a page fault, in which case current->memcg_in_oom will be overwritten
> leaking the previously taken css reference.

There is a task_in_memcg_oom() check before calling mem_cgroup_oom().

How can this happen?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
