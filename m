Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 919B96B0315
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 16:42:33 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id d13so5791815pgf.12
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 13:42:33 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z24sor3955574pfd.34.2017.06.06.13.42.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Jun 2017 13:42:32 -0700 (PDT)
Date: Tue, 6 Jun 2017 13:42:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH v2 1/7] mm, oom: refactor select_bad_process() to
 take memcg as an argument
In-Reply-To: <20170606162007.GB752@castle>
Message-ID: <alpine.DEB.2.10.1706061339410.23608@chino.kir.corp.google.com>
References: <1496342115-3974-1-git-send-email-guro@fb.com> <1496342115-3974-2-git-send-email-guro@fb.com> <alpine.DEB.2.10.1706041550290.24226@chino.kir.corp.google.com> <20170606162007.GB752@castle>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 6 Jun 2017, Roman Gushchin wrote:

> Hi David!
> 
> Thank you for sharing this!
> 
> It's very interesting, and it looks like,
> it's not that far from what I've suggested.
> 
> So we definitily need to come up with some common solution.
> 

Hi Roman,

Yes, definitely.  I could post a series of patches to do everything that 
was listed in my email sans the fully inclusive kmem accounting, which may 
be pursued at a later date, if it would be helpful to see where there is 
common ground?

Another question is what you think about userspace oom handling?  We 
implement our own oom kill policies in userspace for both the system and 
for user-controlled memcg hierarchies because it often does not match the 
kernel implementation and there is some action that can be taken other 
than killing a process.  Have you tried to implement functionality to do 
userspace oom handling, or are you considering it?  This is the main 
motivation behind allowing an oom delay to be configured.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
