Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D3E7280310
	for <linux-mm@kvack.org>; Sun, 20 Aug 2017 20:41:28 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m133so221471288pga.2
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 17:41:28 -0700 (PDT)
Received: from mail-pg0-x233.google.com (mail-pg0-x233.google.com. [2607:f8b0:400e:c05::233])
        by mx.google.com with ESMTPS id s8si2767919pgc.825.2017.08.20.17.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Aug 2017 17:41:27 -0700 (PDT)
Received: by mail-pg0-x233.google.com with SMTP id n4so25846130pgn.1
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 17:41:27 -0700 (PDT)
Date: Sun, 20 Aug 2017 17:41:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v5 4/4] mm, oom, docs: describe the cgroup-aware OOM killer
In-Reply-To: <20170817121647.GA26107@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.10.1708201740140.117182@chino.kir.corp.google.com>
References: <20170814183213.12319-1-guro@fb.com> <20170814183213.12319-5-guro@fb.com> <alpine.DEB.2.10.1708141544280.63207@chino.kir.corp.google.com> <20170815141350.GA4510@castle.DHCP.thefacebook.com> <alpine.DEB.2.10.1708151349280.104516@chino.kir.corp.google.com>
 <20170817121647.GA26107@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 17 Aug 2017, Roman Gushchin wrote:

> Hi David!
> 
> Please, find an updated version of docs patch below.
> 

Looks much better, thanks!  I think the only pending issue is discussing 
the relationship of memory.oom_kill_all_tasks with /proc/pid/oom_score_adj 
== OOM_SCORE_ADJ_MIN.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
