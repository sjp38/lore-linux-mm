Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC0886B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:24:47 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id v30so14961756qtg.9
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:24:47 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x47sor6284330qtx.160.2017.12.19.07.24.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 07:24:46 -0800 (PST)
Date: Tue, 19 Dec 2017 07:24:44 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH] mm: memcontrol: memory+swap accounting for cgroup-v2
Message-ID: <20171219152444.GP3919388@devbig577.frc2.facebook.com>
References: <20171219000131.149170-1-shakeelb@google.com>
 <20171219124908.GS2787@dhcp22.suse.cz>
 <CALvZod5jU9vPoJaf44TVT0_HQpEESiELJU5MD_DDRbcOkPNQbg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod5jU9vPoJaf44TVT0_HQpEESiELJU5MD_DDRbcOkPNQbg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Li Zefan <lizefan@huawei.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org

Hello,

On Tue, Dec 19, 2017 at 07:12:19AM -0800, Shakeel Butt wrote:
> Yes, there are pros & cons, therefore we should give users the option
> to select the API that is better suited for their use-cases and

Heh, that's not how API decisions should be made.  The long term
outcome would be really really bad.

> environment. Both approaches are not interchangeable. We use memsw
> internally for use-cases I mentioned in commit message. This is one of
> the main blockers for us to even consider cgroup-v2 for memory
> controller.

Let's concentrate on the use case.  I couldn't quite understand what
was missing from your description.  You said that it'd make things
easier for the centralized monitoring system which isn't really a
description of a use case.  Can you please go into more details
focusing on the eventual goals (rather than what's currently
implemented)?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
