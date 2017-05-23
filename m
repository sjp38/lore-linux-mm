Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BFE36B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 03:49:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n75so155152251pfh.0
        for <linux-mm@kvack.org>; Tue, 23 May 2017 00:49:33 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j191sor671139pgd.15.2017.05.23.00.49.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 May 2017 00:49:32 -0700 (PDT)
Date: Tue, 23 May 2017 00:49:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/oom_kill: count global and memory cgroup oom kills
In-Reply-To: <ecd4a7ea-06c0-f549-a1bf-6d2d3c0af719@yandex-team.ru>
Message-ID: <alpine.DEB.2.10.1705230044590.50796@chino.kir.corp.google.com>
References: <149520375057.74196.2843113275800730971.stgit@buzz> <CALo0P1123MROxgveCdX6YFpWDwG4qrAyHu3Xd1F+ckaFBnF4dQ@mail.gmail.com> <ecd4a7ea-06c0-f549-a1bf-6d2d3c0af719@yandex-team.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Roman Guschin <guroan@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, hannes@cmpxchg.org

On Mon, 22 May 2017, Konstantin Khlebnikov wrote:

> Nope, they are different. I think we should rephase documentation somehow
> 
> low - count of reclaims below low level
> high - count of post-allocation reclaims above high level
> max - count of direct reclaims
> oom - count of failed direct reclaims
> oom_kill - count of oom killer invocations and killed processes
> 

In our kernel, we've maintained counts of oom kills per memcg for years as 
part of memory.oom_control for memcg v1, but we've also found it helpful 
to complement that with another count that specifies the number of 
processes oom killed that were attached to that exact memcg.

In your patch, oom_kill in memory.oom_control specifies that number of oom 
events that resulted in an oom kill of a process from that hierarchy, but 
not the number of processes killed from a specific memcg (the difference 
between oc->memcg and mem_cgroup_from_task(victim)).  Not sure if you 
would also find it helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
