Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D87936B007E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 08:22:07 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id fs8so7628573obb.2
        for <linux-mm@kvack.org>; Tue, 24 May 2016 05:22:07 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0117.outbound.protection.outlook.com. [157.56.112.117])
        by mx.google.com with ESMTPS id e12si1788438otd.48.2016.05.24.05.22.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 05:22:06 -0700 (PDT)
Date: Tue, 24 May 2016 15:21:58 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: oom: do not reap task if there are live threads in
 threadgroup
Message-ID: <20160524122158.GK7917@esperanza>
References: <1464087628-7318-1-git-send-email-vdavydov@virtuozzo.com>
 <20160524114612.GG8259@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160524114612.GG8259@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 24, 2016 at 01:46:12PM +0200, Michal Hocko wrote:
> On Tue 24-05-16 14:00:28, Vladimir Davydov wrote:
> > If the current process is exiting, we don't invoke oom killer, instead
> > we give it access to memory reserves and try to reap its mm in case
> > nobody is going to use it. There's a mistake in the code performing this
> > check - we just ignore any process of the same thread group no matter if
> > it is exiting or not - see try_oom_reaper. Fix it.
> 
> This is not a problem with the current code because of 98748bd72200
> ("oom: consider multi-threaded tasks in task_will_free_mem") which got
> merged later on, however.

True, I missed that patch.

> 
> The check is not needed so we can indeed drop it.
> 
> Fixes: 3ef22dfff239 ("oom, oom_reaper: try to reap tasks which skip
> regular OOM killer path")
> 
> Just in case somebody wants to backport only 3ef22dfff239.
> 
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
