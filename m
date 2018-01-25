Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 09C30800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 03:11:38 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 82so5351102pfs.8
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 00:11:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9-v6si1563994plp.783.2018.01.25.00.11.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 00:11:37 -0800 (PST)
Date: Thu, 25 Jan 2018 09:11:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
Message-ID: <20180125081134.GL28465@dhcp22.suse.cz>
References: <20180117154155.GU3460072@devbig577.frc2.facebook.com>
 <alpine.DEB.2.10.1801171348190.86895@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801191251080.177541@chino.kir.corp.google.com>
 <20180120123251.GB1096857@devbig577.frc2.facebook.com>
 <alpine.DEB.2.10.1801221420120.16871@chino.kir.corp.google.com>
 <20180123155301.GS1526@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801231416330.254281@chino.kir.corp.google.com>
 <20180124082041.GD1526@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801241340310.24330@chino.kir.corp.google.com>
 <20180124140805.b4eb437c6fe9dadb67a32e8a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180124140805.b4eb437c6fe9dadb67a32e8a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 24-01-18 14:08:05, Andrew Morton wrote:
[...]
> Can we please try to narrow the scope of this issue by concentrating on
> the userspace interfaces?  David believes that the mount option and
> memory.oom_group will disappear again in the near future, others
> disagree.

Mount option is the cgroups maintainers call. And they seemed to be OK
with it.
I've tried to explain that oom_group is something that is semantically
sane and something we want to support because there are workloads which
simply do not work properly when only a subset is torn down. As such it
is not an API hazard AFAICS.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
