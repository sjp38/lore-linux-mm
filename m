Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25C4F8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 16:46:02 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id r191so22167277ybr.12
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 13:46:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c14sor10616757ybi.194.2019.01.02.13.46.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 13:46:01 -0800 (PST)
MIME-Version: 1.0
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com> <1546459533-36247-3-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1546459533-36247-3-git-send-email-yang.shi@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 2 Jan 2019 13:45:49 -0800
Message-ID: <CALvZod7X6FOMnZT48Q9Joh_nha6NMXntL3XqMDqRYFZ1ULgh=w@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: memcontrol: do not try to do swap when force empty
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 2, 2019 at 12:06 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
> The typical usecase of force empty is to try to reclaim as much as
> possible memory before offlining a memcg.  Since there should be no
> attached tasks to offlining memcg, the tasks anonymous pages would have
> already been freed or uncharged.

Anon pages can come from tmpfs files as well.

> Even though anonymous pages get
> swapped out, but they still get charged to swap space.  So, it sounds
> pointless to do swap for force empty.
>

I understand that force_empty is typically used before rmdir'ing a
memcg but it might be used differently by some users. We use this
interface to test memory reclaim behavior (anon and file).

Anyways, I am not against changing the behavior, we can adapt
internally but there might be other users using this interface
differently.

thanks,
Shakeel
