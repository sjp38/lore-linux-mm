Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 205056B0253
	for <linux-mm@kvack.org>; Sun, 29 May 2016 05:11:44 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id q18so69673335igr.2
        for <linux-mm@kvack.org>; Sun, 29 May 2016 02:11:44 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0107.outbound.protection.outlook.com. [157.55.234.107])
        by mx.google.com with ESMTPS id h19si13142579oib.19.2016.05.29.02.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 29 May 2016 02:11:42 -0700 (PDT)
Date: Sun, 29 May 2016 12:11:33 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: fix possible css ref leak on oom
Message-ID: <20160529091133.GG26059@esperanza>
References: <1464019330-7579-1-git-send-email-vdavydov@virtuozzo.com>
 <20160527173629.GE2531@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160527173629.GE2531@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 27, 2016 at 01:36:29PM -0400, Johannes Weiner wrote:
> On Mon, May 23, 2016 at 07:02:10PM +0300, Vladimir Davydov wrote:
> > mem_cgroup_oom may be invoked multiple times while a process is handling
> > a page fault, in which case current->memcg_in_oom will be overwritten
> > leaking the previously taken css reference.
> 
> There is a task_in_memcg_oom() check before calling mem_cgroup_oom().
> 
> How can this happen?

Oops, I overlooked that check. Scratch this patch then.

Sorry for the noise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
