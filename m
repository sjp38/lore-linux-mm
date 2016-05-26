Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id F2F6E6B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 10:56:10 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 132so11196474lfz.3
        for <linux-mm@kvack.org>; Thu, 26 May 2016 07:56:10 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id xx3si18897422wjc.200.2016.05.26.07.56.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 07:56:09 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q62so6214343wmg.3
        for <linux-mm@kvack.org>; Thu, 26 May 2016 07:56:09 -0700 (PDT)
Date: Thu, 26 May 2016 16:56:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/6] mm, oom: fortify task_will_free_mem
Message-ID: <20160526145608.GE23675@dhcp22.suse.cz>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <1464266415-15558-7-git-send-email-mhocko@kernel.org>
 <201605262311.FFF64092.FFQVtOLOOMJSFH@I-love.SAKURA.ne.jp>
 <20160526142317.GC23675@dhcp22.suse.cz>
 <201605262341.GFE48463.OOtLFFMQSVFHOJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605262341.GFE48463.OOtLFFMQSVFHOJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Thu 26-05-16 23:41:54, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > +/*
> > + * Checks whether the given task is dying or exiting and likely to
> > + * release its address space. This means that all threads and processes
> > + * sharing the same mm have to be killed or exiting.
> > + */
> > +static inline bool task_will_free_mem(struct task_struct *task)
> > +{
> > +	struct mm_struct *mm = NULL;
> > +	struct task_struct *p;
> > +	bool ret = false;
> 
> If atomic_read(&p->mm->mm_users) <= get_nr_threads(p), this returns "false".
> According to previous version, I think this is "bool ret = true;".

true. Thanks for catching this. Fixed locally.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
