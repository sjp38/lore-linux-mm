Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF556B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:33:58 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id b65so4070395qkc.5
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 09:33:58 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j184sor10133487qkc.47.2017.12.19.09.33.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 09:33:57 -0800 (PST)
Date: Tue, 19 Dec 2017 09:33:54 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH] mm: memcontrol: memory+swap accounting for cgroup-v2
Message-ID: <20171219173354.GQ3919388@devbig577.frc2.facebook.com>
References: <20171219000131.149170-1-shakeelb@google.com>
 <20171219124908.GS2787@dhcp22.suse.cz>
 <CALvZod5jU9vPoJaf44TVT0_HQpEESiELJU5MD_DDRbcOkPNQbg@mail.gmail.com>
 <20171219152444.GP3919388@devbig577.frc2.facebook.com>
 <CALvZod5sWWBX69QovOeLBSx9vij7=5cmoSocdTUvh2Uq8=noyQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod5sWWBX69QovOeLBSx9vij7=5cmoSocdTUvh2Uq8=noyQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Li Zefan <lizefan@huawei.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org

Hello,

On Tue, Dec 19, 2017 at 09:23:29AM -0800, Shakeel Butt wrote:
> To provide consistent memory usage history using the current
> cgroup-v2's 'swap' interface, an additional metric expressing the
> intersection of memory and swap has to be exposed. Basically memsw is
> the union of memory and swap. So, if that additional metric can be

Exposing anonymous pages with swap backing sounds pretty trivial.

> used to find the union. However for consistent memory limit
> enforcement, I don't think there is an easy way to use current 'swap'
> interface.

Can you please go into details on why this is important?  I get that
you can't do it as easily w/o memsw but I don't understand why this is
a critical feature.  Why is that?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
