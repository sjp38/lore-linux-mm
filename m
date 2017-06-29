Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF3416B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 14:45:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 86so93638813pfq.11
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 11:45:34 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 1si4629210plk.129.2017.06.29.11.45.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 11:45:33 -0700 (PDT)
Date: Thu, 29 Jun 2017 14:45:13 -0400
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v3 5/6] mm, oom: don't mark all oom victims tasks with
 TIF_MEMDIE
Message-ID: <20170629184513.GA27714@castle>
References: <1498079956-24467-1-git-send-email-guro@fb.com>
 <1498079956-24467-6-git-send-email-guro@fb.com>
 <20170629085357.GF31603@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170629085357.GF31603@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 29, 2017 at 10:53:57AM +0200, Michal Hocko wrote:
> On Wed 21-06-17 22:19:15, Roman Gushchin wrote:
> > We want to limit the number of tasks which are having an access
> > to the memory reserves. To ensure the progress it's enough
> > to have one such process at the time.
> > 
> > If we need to kill the whole cgroup, let's give an access to the
> > memory reserves only to the first process in the list, which is
> > (usually) the biggest process.
> > This will give us good chances that all other processes will be able
> > to quit without an access to the memory reserves.
> 
> I don't like this to be honest. Is there any reason to go the reduced
> memory reserves access to oom victims I was suggesting earlier [1]?
> 
> [1] http://lkml.kernel.org/r/http://lkml.kernel.org/r/1472723464-22866-2-git-send-email-mhocko@kernel.org

I've nothing against your approach. What's the state of this patchset?
Do you plan to bring it upstream?

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
