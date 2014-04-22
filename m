Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4FE6B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 06:17:50 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id hn18so2788103igb.5
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:17:49 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id rv8si11451111igb.32.2014.04.22.03.17.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 03:17:49 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id tp5so4983503ieb.40
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:17:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140422094759.GC29311@dhcp22.suse.cz>
References: <1397861935-31595-1-git-send-email-nasa4836@gmail.com> <20140422094759.GC29311@dhcp22.suse.cz>
From: Jianyu Zhan <nasa4836@gmail.com>
Date: Tue, 22 Apr 2014 18:17:09 +0800
Message-ID: <CAHz2CGWrk3kuR=BLt2vT-8gxJVtJcj6h17ase9=1CoWXwK6a3w@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/memcontrol.c: remove meaningless while loop in mem_cgroup_iter()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, kamezawa.hiroyu@jp.fujitsu.com, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 22, 2014 at 5:47 PM, Michal Hocko <mhocko@suse.cz> wrote:
> What about
>   3. last_visited == last_node in the tree
>
> __mem_cgroup_iter_next returns NULL and the iterator would return
> without visiting anything.

Hi,  Michal,

yep,  if 3 last_visited == last_node, then this means we have done a round-trip,
thus __mem_cgroup_iter_next returns NULL, in turn mem_cgroup_iter() return NULL.

This is what comments above mem_cgroup_iter() says:

>Returns references to children of the hierarchy below @root, or
>* @root itself, or %NULL after a full round-trip.

Actually, this condition could be reduced to conditon 2.1

Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
