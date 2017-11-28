Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57D1B6B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 15:09:26 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id a107so609615wrc.11
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 12:09:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k5sor106108wmg.19.2017.11.28.12.09.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 12:09:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171128200005.67grhk2arm2ivgug@dhcp22.suse.cz>
References: <20171128161941.20931-1-shakeelb@google.com> <20171128200005.67grhk2arm2ivgug@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 28 Nov 2017 12:09:23 -0800
Message-ID: <CALvZod6AK08kugQveutunDsOUabSZ0PUKEeb+-a2RdQ16+uO4Q@mail.gmail.com>
Subject: Re: [PATCH] mm, memcg: fix mem_cgroup_swapout() for THPs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Huang Ying <ying.huang@intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, stable@vger.kernel.org

On Tue, Nov 28, 2017 at 12:00 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 28-11-17 08:19:41, Shakeel Butt wrote:
>> The commit d6810d730022 ("memcg, THP, swap: make mem_cgroup_swapout()
>> support THP") changed mem_cgroup_swapout() to support transparent huge
>> page (THP). However the patch missed one location which should be
>> changed for correctly handling THPs. The resulting bug will cause the
>> memory cgroups whose THPs were swapped out to become zombies on
>> deletion.
>
> Very well spotted! Have you seen this triggering or you found it by the
> code inspection?
>

By code inspection.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
