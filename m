Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A36C36B027D
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 14:08:48 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r20-v6so5922618pgv.20
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 11:08:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n137-v6si6653940pfd.177.2018.08.06.11.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 11:08:47 -0700 (PDT)
Date: Mon, 6 Aug 2018 11:08:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: memcg: update memcg OOM messages on cgroup2
Message-Id: <20180806110845.f2cc110df0341b8cbd54d16c@linux-foundation.org>
In-Reply-To: <20180806161529.GA410235@devbig004.ftw2.facebook.com>
References: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
	<20180806161529.GA410235@devbig004.ftw2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Mon, 6 Aug 2018 09:15:29 -0700 Tejun Heo <tj@kernel.org> wrote:

> mem_cgroup_print_oom_info() currently prints the same info for cgroup1
> and cgroup2 OOMs.  It doesn't make much sense on cgroup2, which
> doesn't use memsw or separate kmem accounting - the information
> reported is both superflous and insufficient.  This patch updates the
> memcg OOM messages on cgroup2 so that
> 
> * It prints memory and swap usages and limits used on cgroup2.
> 
> * It shows the same information as memory.stat.
> 
> I took out the recursive printing for cgroup2 because the amount of
> output could be a lot and the benefits aren't clear.  An example dump
> follows.

This conflicts rather severely with Shakeel's "memcg: reduce memcg tree
traversals for stats collection".  Can we please park this until after
4.19-rc1?
