Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 577A26B0271
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 17:18:36 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id f18so19193692iof.8
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 14:18:36 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r77sor2529178ioe.287.2018.01.17.14.18.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 14:18:35 -0800 (PST)
Date: Wed, 17 Jan 2018 14:18:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
In-Reply-To: <20180117160004.GH2900@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1801171415200.86895@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com> <alpine.DEB.2.10.1801161814130.28198@chino.kir.corp.google.com> <20180117154155.GU3460072@devbig577.frc2.facebook.com> <20180117160004.GH2900@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 17 Jan 2018, Michal Hocko wrote:

> Absolutely agreed! And moreover, there are not all that many ways what
> to do as an action. You just kill a logical entity - be it a process or
> a logical group of processes. But you have way too many policies how
> to select that entity. Do you want to chose the youngest process/group
> because all the older ones have been computing real stuff and you would
> lose days of your cpu time? Or should those who pay more should be
> protected (aka give them static priorities), or you name it...
> 

That's an argument for making the interface extensible, yes.

> I am sorry, I still didn't grasp the full semantic of the proposed
> soluton but the mere fact it is starting by conflating selection and the
> action is a no go and a wrong API. This is why I've said that what you
> (David) outlined yesterday is probably going to suffer from a much
> longer discussion and most likely to be not acceptable. Your patchset
> proves me correct...

I'm very happy to change the API if there are better suggestions.  That 
may end up just being an memory.oom_policy file, as this implements, and 
separating out a new memory.oom_action that isn't a boolean value to 
either do a full group kill or only a single process.  Or it could be what 
I suggested in my mail to Tejun, such as "hierarchy killall" written to
memory.oom_policy, which would specify a single policy and then an 
optional mechanism.  With my proposed patchset, there would then be three 
policies: "none", "cgroup", and "tree" and one possible optional 
mechanism: "killall".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
