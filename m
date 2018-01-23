Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CBA3800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 10:53:05 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id z16so496393wrb.20
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 07:53:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k30si450093wre.514.2018.01.23.07.53.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Jan 2018 07:53:04 -0800 (PST)
Date: Tue, 23 Jan 2018 16:53:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
Message-ID: <20180123155301.GS1526@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801161814130.28198@chino.kir.corp.google.com>
 <20180117154155.GU3460072@devbig577.frc2.facebook.com>
 <alpine.DEB.2.10.1801171348190.86895@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801191251080.177541@chino.kir.corp.google.com>
 <20180120123251.GB1096857@devbig577.frc2.facebook.com>
 <alpine.DEB.2.10.1801221420120.16871@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1801221420120.16871@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 22-01-18 14:34:39, David Rientjes wrote:
> On Sat, 20 Jan 2018, Tejun Heo wrote:
[...]
> > I don't see any blocker here.  The issue you're raising can and should
> > be handled separately.
> > 
> 
> It can't, because the current patchset locks the system into a single 
> selection criteria that is unnecessary and the mount option would become a 
> no-op after the policy per subtree becomes configurable by the user as 
> part of the hierarchy itself.

This is simply not true! OOM victim selection has changed in the
past and will be always a subject to changes in future. Current
implementation doesn't provide any externally controlable selection
policy and therefore the default can be assumed. Whatever that default
means now or in future. The only contract added here is the kill full
memcg if selected and that can be implemented on _any_ selection policy.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
