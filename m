Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED0DB6B0010
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 02:18:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o60-v6so1478409edd.13
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 23:18:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m46-v6si1118282edm.387.2018.08.02.23.18.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 23:18:18 -0700 (PDT)
Date: Fri, 3 Aug 2018 08:18:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm:memcg: skip memcg of current in
 mem_cgroup_soft_limit_reclaim
Message-ID: <20180803061817.GC27245@dhcp22.suse.cz>
References: <1533275285-12387-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <CAGWkznE_Z+eJ+81eZN_KT7KXSFyCxfoafeMFSzirT7OaL+vbRA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGWkznE_Z+eJ+81eZN_KT7KXSFyCxfoafeMFSzirT7OaL+vbRA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org

On Fri 03-08-18 14:11:26, Zhaoyang Huang wrote:
> On Fri, Aug 3, 2018 at 1:48 PM Zhaoyang Huang <huangzhaoyang@gmail.com> wrote:
> >
> > for the soft_limit reclaim has more directivity than global reclaim, we40960
> > have current memcg be skipped to avoid potential page thrashing.
> >
> The patch is tested in our android system with 2GB ram.  The case
> mainly focus on the smooth slide of pictures on a gallery, which used
> to stall on the direct reclaim for over several hundred
> millionseconds. By further debugging, we find that the direct reclaim
> spend most of time to reclaim pages on its own with softlimit set to
> 40960KB. I add a ftrace event to verify that the patch can help
> escaping such scenario. Furthermore, we also measured the major fault
> of this process(by dumpsys of android). The result is the patch can
> help to reduce 20% of the major fault during the test.

I have asked already asked. Why do you use the soft limit in the first
place? It is known to cause excessive reclaim and long stalls.
-- 
Michal Hocko
SUSE Labs
