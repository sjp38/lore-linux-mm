Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 679086B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 03:26:31 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id j12so51130707lbo.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 00:26:31 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id go9si42935946wjb.213.2016.05.30.00.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 00:26:30 -0700 (PDT)
Received: by mail-wm0-f49.google.com with SMTP id a136so72623865wme.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 00:26:30 -0700 (PDT)
Date: Mon, 30 May 2016 09:26:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: fix possible css ref leak on oom
Message-ID: <20160530072628.GG22928@dhcp22.suse.cz>
References: <1464019330-7579-1-git-send-email-vdavydov@virtuozzo.com>
 <20160527173629.GE2531@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160527173629.GE2531@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 27-05-16 13:36:29, Johannes Weiner wrote:
> On Mon, May 23, 2016 at 07:02:10PM +0300, Vladimir Davydov wrote:
> > mem_cgroup_oom may be invoked multiple times while a process is handling
> > a page fault, in which case current->memcg_in_oom will be overwritten
> > leaking the previously taken css reference.
> 
> There is a task_in_memcg_oom() check before calling mem_cgroup_oom().
> 
> How can this happen?

Ble, I have missed that... Thanks for pointing that out

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
