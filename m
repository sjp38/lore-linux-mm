Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id AA59C6B005C
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 11:23:32 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id uq10so1129024igb.5
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 08:23:32 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id k7si14856654icu.135.2014.04.16.08.23.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 08:23:32 -0700 (PDT)
Received: by mail-ie0-f170.google.com with SMTP id rd18so10635988iec.15
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 08:23:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140416092245.GD12866@dhcp22.suse.cz>
References: <1397149868-30401-1-git-send-email-nasa4836@gmail.com> <20140416092245.GD12866@dhcp22.suse.cz>
From: Zhan Jianyu <nasa4836@gmail.com>
Date: Wed, 16 Apr 2014 23:22:51 +0800
Message-ID: <CAHz2CGXiRnBuza6ByvuDZpuxB4sP3wDBZ2OiLTACEX7ZMAuvXw@mail.gmail.com>
Subject: Re: [PATCH] mm/memcontrol.c: make mem_cgroup_read_stat() read all
 interested stat item in one go
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 16, 2014 at 5:22 PM, Michal Hocko <mhocko@suse.cz> wrote:
> cannot say I like the new code much more than the previous one and
> I've never seen the old one being a bottleneck. So I am not entirely
> fond of optimization without a good reason. (Hint, if you are optimizing
> something always show us numbers which support the optimization)

Hmm, actually I now have no workload to support this optimizaton, I will
refine patch if I have one.  Thanks for all your comments.

Thanks,
Jianyu Zhan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
