Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 99AF96B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 19:07:03 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id b36-v6so10196188pli.2
        for <linux-mm@kvack.org>; Tue, 29 May 2018 16:07:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o3-v6si33468026pld.50.2018.05.29.16.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 16:07:02 -0700 (PDT)
Date: Tue, 29 May 2018 16:07:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-Id: <20180529160700.dbc430ebbfac301335ac8cf4@linux-foundation.org>
In-Reply-To: <20180529060755.GH27180@dhcp22.suse.cz>
References: <20180525083118.GI11881@dhcp22.suse.cz>
	<201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
	<20180525114213.GJ11881@dhcp22.suse.cz>
	<201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp>
	<20180528124313.GC27180@dhcp22.suse.cz>
	<201805290557.BAJ39558.MFLtOJVFOHFOSQ@I-love.SAKURA.ne.jp>
	<20180529060755.GH27180@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On Tue, 29 May 2018 09:17:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> > I suggest applying
> > this patch first, and then fix "mm, oom: cgroup-aware OOM killer" patch.
> 
> Well, I hope the whole pile gets merged in the upcoming merge window
> rather than stall even more.

I'm more inclined to drop it all.  David has identified significant
shortcomings and I'm not seeing a way of addressing those shortcomings
in a backward-compatible fashion.  Therefore there is no way forward
at present.
