Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A3F392802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 04:25:55 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u110so37662996wrb.14
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 01:25:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 17si5787253wrt.177.2017.06.30.01.25.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 01:25:54 -0700 (PDT)
Date: Fri, 30 Jun 2017 10:25:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v3 5/6] mm, oom: don't mark all oom victims tasks with
 TIF_MEMDIE
Message-ID: <20170630082551.GB22917@dhcp22.suse.cz>
References: <1498079956-24467-1-git-send-email-guro@fb.com>
 <1498079956-24467-6-git-send-email-guro@fb.com>
 <20170629085357.GF31603@dhcp22.suse.cz>
 <20170629184513.GA27714@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170629184513.GA27714@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 29-06-17 14:45:13, Roman Gushchin wrote:
> On Thu, Jun 29, 2017 at 10:53:57AM +0200, Michal Hocko wrote:
> > On Wed 21-06-17 22:19:15, Roman Gushchin wrote:
> > > We want to limit the number of tasks which are having an access
> > > to the memory reserves. To ensure the progress it's enough
> > > to have one such process at the time.
> > > 
> > > If we need to kill the whole cgroup, let's give an access to the
> > > memory reserves only to the first process in the list, which is
> > > (usually) the biggest process.
> > > This will give us good chances that all other processes will be able
> > > to quit without an access to the memory reserves.
> > 
> > I don't like this to be honest. Is there any reason to go the reduced
> > memory reserves access to oom victims I was suggesting earlier [1]?
> > 
> > [1] http://lkml.kernel.org/r/http://lkml.kernel.org/r/1472723464-22866-2-git-send-email-mhocko@kernel.org
> 
> I've nothing against your approach. What's the state of this patchset?
> Do you plan to bring it upstream?

Just the specific patch I have linked should be sufficient for what you
need here. The patchset had some issues which I didn't have time to fix
and as such the need for the above patch was not a high priority as
well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
