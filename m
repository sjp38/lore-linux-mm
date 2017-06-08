Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id ACFF76B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 12:00:59 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b74so774636pfj.5
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 09:00:59 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h66si4716110pfa.285.2017.06.08.09.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 09:00:58 -0700 (PDT)
Date: Thu, 8 Jun 2017 16:59:57 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH v2 1/7] mm, oom: refactor select_bad_process() to
 take memcg as an argument
Message-ID: <20170608155957.GA13161@castle>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
 <1496342115-3974-2-git-send-email-guro@fb.com>
 <alpine.DEB.2.10.1706041550290.24226@chino.kir.corp.google.com>
 <20170606162007.GB752@castle>
 <alpine.DEB.2.10.1706061339410.23608@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1706061339410.23608@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jun 06, 2017 at 01:42:29PM -0700, David Rientjes wrote:
> On Tue, 6 Jun 2017, Roman Gushchin wrote:
> 
> > Hi David!
> > 
> > Thank you for sharing this!
> > 
> > It's very interesting, and it looks like,
> > it's not that far from what I've suggested.
> > 
> > So we definitily need to come up with some common solution.
> > 
> 

Hi David,

> Yes, definitely.  I could post a series of patches to do everything that 
> was listed in my email sans the fully inclusive kmem accounting, which may 
> be pursued at a later date, if it would be helpful to see where there is 
> common ground?
> 
> Another question is what you think about userspace oom handling?  We 
> implement our own oom kill policies in userspace for both the system and 
> for user-controlled memcg hierarchies because it often does not match the 
> kernel implementation and there is some action that can be taken other 
> than killing a process.  Have you tried to implement functionality to do 
> userspace oom handling, or are you considering it?  This is the main 
> motivation behind allowing an oom delay to be configured.

cgroup v2 memory controller is built on the idea of preventing OOMs
by using the memory.high limit. This allows an userspace app to get notified
before OOM happens (by looking at memory.events control), so there is (hopefully)
no need in things like oom delay.

Actually, I'm trying to implement some minimal functionality in the kernel,
which will simplify and make more consistent the userspace part of the job.
But, of course, the main goal of the patchset is to fix the unfairness
of the current victim selection.

Thanks!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
