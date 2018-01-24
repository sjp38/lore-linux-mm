Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 040C8800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 17:18:12 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id f16so8191052qth.20
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 14:18:11 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 53sor3031985qtr.114.2018.01.24.14.18.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jan 2018 14:18:11 -0800 (PST)
Date: Wed, 24 Jan 2018 14:18:03 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
Message-ID: <20180124221803.GC17457@devbig577.frc2.facebook.com>
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
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, Andrew.

On Wed, Jan 24, 2018 at 02:08:05PM -0800, Andrew Morton wrote:
> Can we please try to narrow the scope of this issue by concentrating on
> the userspace interfaces?  David believes that the mount option and
> memory.oom_group will disappear again in the near future, others
> disagree.

I'm confident that the interface is gonna age fine.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
