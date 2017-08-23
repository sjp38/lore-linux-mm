Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE70C6B04FF
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:30:30 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a2so13017559pfj.12
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 05:30:30 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w23si1032733plk.942.2017.08.23.05.30.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 05:30:29 -0700 (PDT)
Date: Wed, 23 Aug 2017 13:30:04 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v5 1/4] mm, oom: refactor the oom_kill_process() function
Message-ID: <20170823123004.GA10095@castle.dhcp.TheFacebook.com>
References: <20170814183213.12319-1-guro@fb.com>
 <20170822170655.GB13547@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170822170655.GB13547@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 22, 2017 at 01:06:55PM -0400, Johannes Weiner wrote:
> On Mon, Aug 14, 2017 at 07:32:09PM +0100, Roman Gushchin wrote:
> > @@ -817,67 +817,12 @@ static bool task_will_free_mem(struct task_struct *task)
> >  	return ret;
> >  }
> >  
> > -static void oom_kill_process(struct oom_control *oc, const char *message)
> > +static void __oom_kill_process(struct task_struct *victim)
> 
> oom_kill_task()?

Not sure, as it kills all tasks which are sharing mm with the given task.
Also, it will be confusing to have oom_kill_process() and oom_kill_task(),
where the actual difference is in how much verbose they are,
and if it's allowed to perfer a child process.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
