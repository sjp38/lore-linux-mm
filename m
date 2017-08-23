Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD942803FE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 19:13:30 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b8so18936146pgn.10
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 16:13:30 -0700 (PDT)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id m80si1745420pfj.129.2017.08.23.16.13.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 16:13:29 -0700 (PDT)
Received: by mail-pg0-x234.google.com with SMTP id 83so6806609pgb.3
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 16:13:29 -0700 (PDT)
Date: Wed, 23 Aug 2017 16:13:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v5 2/4] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20170823174603.GA26190@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.10.1708231611390.68096@chino.kir.corp.google.com>
References: <20170814183213.12319-1-guro@fb.com> <20170814183213.12319-3-guro@fb.com> <20170822170344.GA13547@cmpxchg.org> <20170823162031.GA13578@castle.dhcp.TheFacebook.com> <20170823172441.GA29085@cmpxchg.org>
 <20170823174603.GA26190@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 23 Aug 2017, Roman Gushchin wrote:

> > It's better to have newbies consult the documentation once than making
> > everybody deal with long and cumbersome names for the rest of time.
> > 
> > Like 'ls' being better than 'read_and_print_directory_contents'.
> 
> I don't think it's a good argument here: realistically, nobody will type
> the knob's name often. Your option is shorter only by 3 characters :)
> 
> Anyway, I'm ok with memory.oom_group too, if everybody else prefer it.
> Michal, David?
> What's your opinion?
> 

I'm probably the worst person in the world for succinctly naming stuff, 
but I at least think the knob should have the word "kill" in it to 
describe the behavior.  ("oom_group", out of memory group, what exactly is 
that?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
