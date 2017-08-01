Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B49276B0533
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:24:15 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id o85so3972002lff.0
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:24:15 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 26si12253754ljt.143.2017.08.01.05.24.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 05:24:14 -0700 (PDT)
Date: Tue, 1 Aug 2017 13:23:44 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 0/2] mm, oom: do not grant oom victims full memory
 reserves access
Message-ID: <20170801122344.GA8457@castle.DHCP.thefacebook.com>
References: <20170727090357.3205-1-mhocko@kernel.org>
 <20170801121643.GI15774@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170801121643.GI15774@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 01, 2017 at 02:16:44PM +0200, Michal Hocko wrote:
> On Thu 27-07-17 11:03:55, Michal Hocko wrote:
> > Hi,
> > this is a part of a larger series I posted back in Oct last year [1]. I
> > have dropped patch 3 because it was incorrect and patch 4 is not
> > applicable without it.
> > 
> > The primary reason to apply patch 1 is to remove a risk of the complete
> > memory depletion by oom victims. While this is a theoretical risk right
> > now there is a demand for memcg aware oom killer which might kill all
> > processes inside a memcg which can be a lot of tasks. That would make
> > the risk quite real.
> > 
> > This issue is addressed by limiting access to memory reserves. We no
> > longer use TIF_MEMDIE to grant the access and use tsk_is_oom_victim
> > instead. See Patch 1 for more details. Patch 2 is a trivial follow up
> > cleanup.
> 
> Any comments, concerns? Can we merge it?

I've rebased the cgroup-aware OOM killer and ran some tests.
Everything works well.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
