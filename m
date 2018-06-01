Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC9046B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 17:11:13 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id d4-v6so15956876plr.17
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 14:11:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k16-v6si42563497pli.171.2018.06.01.14.11.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jun 2018 14:11:12 -0700 (PDT)
Date: Fri, 1 Jun 2018 14:11:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-Id: <20180601141110.34915e0a1fdbd07d25cc15cc@linux-foundation.org>
In-Reply-To: <20180601152801.GH15278@dhcp22.suse.cz>
References: <20180525083118.GI11881@dhcp22.suse.cz>
	<201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
	<20180525114213.GJ11881@dhcp22.suse.cz>
	<201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp>
	<20180528124313.GC27180@dhcp22.suse.cz>
	<201805290557.BAJ39558.MFLtOJVFOHFOSQ@I-love.SAKURA.ne.jp>
	<20180529060755.GH27180@dhcp22.suse.cz>
	<20180529160700.dbc430ebbfac301335ac8cf4@linux-foundation.org>
	<20180601152801.GH15278@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On Fri, 1 Jun 2018 17:28:01 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 29-05-18 16:07:00, Andrew Morton wrote:
> > On Tue, 29 May 2018 09:17:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > > I suggest applying
> > > > this patch first, and then fix "mm, oom: cgroup-aware OOM killer" patch.
> > > 
> > > Well, I hope the whole pile gets merged in the upcoming merge window
> > > rather than stall even more.
> > 
> > I'm more inclined to drop it all.  David has identified significant
> > shortcomings and I'm not seeing a way of addressing those shortcomings
> > in a backward-compatible fashion.  Therefore there is no way forward
> > at present.
> 
> Well, I thought we have argued about those "shortcomings" back and forth
> and expressed that they are not really a problem for workloads which are
> going to use the feature. The backward compatibility has been explained
> as well AFAICT.

Feel free to re-explain.  It's the only way we'll get there.

David has proposed an alternative patchset.  IIRC Roman gave that a
one-line positive response but I don't think it has seen a lot of
attention?
