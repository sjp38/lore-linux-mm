Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4727E828E1
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 04:19:12 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a4so54741752lfa.1
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 01:19:12 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id uu10si2902196wjc.286.2016.06.30.01.19.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 01:19:11 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id v199so210480924wmv.0
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 01:19:11 -0700 (PDT)
Date: Thu, 30 Jun 2016 10:19:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mmotm: mm-oom-fortify-task_will_free_mem-fix
Message-ID: <20160630081909.GF18783@dhcp22.suse.cz>
References: <1467201562-6709-1-git-send-email-mhocko@kernel.org>
 <20160629192232.GA19097@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160629192232.GA19097@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vladimir Davydov <vdavydov@parallels.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 29-06-16 21:22:33, Oleg Nesterov wrote:
> On 06/29, Michal Hocko wrote:
> >
> > But it seems that further changes I am
> > planning in this area will benefit from stable task->mm in this path
> 
> Oh, so I hope you will cleanup this later,
> 
> > Just pull the task->mm !=
> > NULL check inside the function.
> 
> OK, but this means it will always return false if the task is a zombie
> leader.
> 
> I am not really arguing and this is not that bad, but this doesn't look
> nice and imo asks for cleanup.

I will keep that in mind and hopefully we can make this less obscure.
Who would like zombie leaders lurking around ;)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
