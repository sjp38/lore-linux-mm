Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4B06B0255
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 11:18:11 -0500 (EST)
Received: by lbbkw15 with SMTP id kw15so98902195lbb.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 08:18:10 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id a3si9345435lfd.115.2015.11.23.08.18.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 08:18:10 -0800 (PST)
Date: Mon, 23 Nov 2015 11:17:54 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: fix memory.high target
Message-ID: <20151123161754.GA13000@cmpxchg.org>
References: <1448281351-15103-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448281351-15103-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 23, 2015 at 03:22:31PM +0300, Vladimir Davydov wrote:
> When the memory.high threshold is exceeded, try_charge() schedules a
> task_work to reclaim the excess. The reclaim target is set to the number
> of pages requested by try_charge(). This is wrong, because try_charge()
> usually charges more pages than requested (batch > nr_pages) in order to
> refill per cpu stocks. As a result, a process in a cgroup can easily
> exceed memory.high significantly when doing a lot of charges w/o
> returning to userspace (e.g. reading a file in big chunks).
> 
> Fix this issue by assuring that when exceeding memory.high a process
> reclaims as many pages as were actually charged (i.e. batch).
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
