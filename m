Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 50FD46B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 10:56:05 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id z37so3844641qtz.16
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 07:56:05 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id a24si3922123qkj.286.2017.11.17.07.56.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 07:56:04 -0800 (PST)
Date: Fri, 17 Nov 2017 15:55:16 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm/shmem: set default tmpfs size according to memcg limit
Message-ID: <20171117155509.GA920@castle>
References: <1510888199-5886-1-git-send-email-laoar.shao@gmail.com>
 <CALvZod7AY=J3i0NL-VuWWOxjdVmWh7VnpcQhdx7+Jt-Hnqrk+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CALvZod7AY=J3i0NL-VuWWOxjdVmWh7VnpcQhdx7+Jt-Hnqrk+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Yafang Shao <laoar.shao@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@suse.com>, Tejun Heo <tj@kernel.org>, khlebnikov@yandex-team.ru, mka@chromium.org, Hugh Dickins <hughd@google.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Nov 16, 2017 at 08:43:17PM -0800, Shakeel Butt wrote:
> On Thu, Nov 16, 2017 at 7:09 PM, Yafang Shao <laoar.shao@gmail.com> wrote:
> > Currently the default tmpfs size is totalram_pages / 2 if mount tmpfs
> > without "-o size=XXX".
> > When we mount tmpfs in a container(i.e. docker), it is also
> > totalram_pages / 2 regardless of the memory limit on this container.
> > That may easily cause OOM if tmpfs occupied too much memory when swap is
> > off.
> > So when we mount tmpfs in a memcg, the default size should be limited by
> > the memcg memory.limit.
> >
> 
> The pages of the tmpfs files are charged to the memcg of allocators
> which can be in memcg different from the memcg in which the mount
> operation happened. So, tying the size of a tmpfs mount where it was
> mounted does not make much sense.

Also, memory limit is adjustable, and using a particular limit value
at a moment of tmpfs mounting doesn't provide any warranties further.

Is there a reason why the userspace app which is mounting tmpfs can't
set the size based on memory.limit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
