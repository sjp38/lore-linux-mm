Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5D33428033A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 11:18:32 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so92018918ykd.2
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 08:18:32 -0700 (PDT)
Received: from mail-yk0-x231.google.com (mail-yk0-x231.google.com. [2607:f8b0:4002:c07::231])
        by mx.google.com with ESMTPS id d123si8216158ywb.112.2015.07.17.08.18.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jul 2015 08:18:30 -0700 (PDT)
Received: by ykdu72 with SMTP id u72so92018152ykd.2
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 08:18:30 -0700 (PDT)
Date: Fri, 17 Jul 2015 11:18:27 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/5] memcg: export struct mem_cgroup
Message-ID: <20150717151827.GB15934@mtj.duckdns.org>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
 <1436958885-18754-2-git-send-email-mhocko@kernel.org>
 <20150715135711.1778a8c08f2ea9560a7c1f6f@linux-foundation.org>
 <20150716071948.GC3077@dhcp22.suse.cz>
 <20150716143433.e43554a19b1c89a8524020cb@linux-foundation.org>
 <20150716225639.GA11131@cmpxchg.org>
 <20150716160358.de3404c44ba29dc132032bbc@linux-foundation.org>
 <20150717122819.GA14895@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150717122819.GA14895@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hello,

On Fri, Jul 17, 2015 at 08:28:19AM -0400, Johannes Weiner wrote:
> > Meaning a new mm/memcontrol.h?  That's a bit better I suppose.
> 
> I meant as opposed to being private to memcontrol.c.  I'm not sure I
> quite see the problem of having these definitions in include/linux, as
> long as we keep the stuff that is genuinely only used in memcontrol.c
> private to that file.  But mm/memcontrol.h would probably work too.

cgroup writeback support interacts with writeback, memcg and blkcg, so
if we do that we'd end up doing #include "../mm/memcontrol.h" from fs
and prolly block.  This is pretty much the definition of
cross-subsystem definitions which should go under include/linux.

mem_cgroup contains common fields which are useful across multiple
subsystems and there currently are quite a few silly accessors getting
in the way obscuring things.  I get that we don't want to expose when
we don't have to but at the same time under situations like this we
usually expose the definition and try to mark public and internal
fields clearly.  Maybe there are details to be improved but I think
it's about time mem_cgroup definition gets published.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
