Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8DEC26B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:24:58 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id he1so117743464pac.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:24:58 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id xm3si252400pac.158.2016.06.17.00.24.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 00:24:57 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id i123so2666721pfg.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:24:57 -0700 (PDT)
Subject: Re: [PATCH v1 3/3] mm: per-process reclaim
References: <1465804259-29345-1-git-send-email-minchan@kernel.org>
 <1465804259-29345-4-git-send-email-minchan@kernel.org>
 <20160613150653.GA30642@cmpxchg.org>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <0627865b-e261-d1ba-c9f2-56e8f4479d57@gmail.com>
Date: Fri, 17 Jun 2016 17:24:46 +1000
MIME-Version: 1.0
In-Reply-To: <20160613150653.GA30642@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Sangwoo Park <sangwoo2.park@lge.com>



On 14/06/16 01:06, Johannes Weiner wrote:
> Hi Minchan,
> 
> On Mon, Jun 13, 2016 at 04:50:58PM +0900, Minchan Kim wrote:
>> These day, there are many platforms available in the embedded market
>> and sometime, they has more hints about workingset than kernel so
>> they want to involve memory management more heavily like android's
>> lowmemory killer and ashmem or user-daemon with lowmemory notifier.
>>
>> This patch adds add new method for userspace to manage memory
>> efficiently via knob "/proc/<pid>/reclaim" so platform can reclaim
>> any process anytime.
> 
> Cgroups are our canonical way to control system resources on a per
> process or group-of-processes level. I don't like the idea of adding
> ad-hoc interfaces for single-use cases like this.
> 
> For this particular case, you can already stick each app into its own
> cgroup and use memory.force_empty to target-reclaim them.
> 
> Or better yet, set the soft limits / memory.low to guide physical
> memory pressure, once it actually occurs, toward the least-important
> apps? We usually prefer doing work on-demand rather than proactively.
> 
> The one-cgroup-per-app model would give Android much more control and
> would also remove a *lot* of overhead during task switches, see this:
> https://lkml.org/lkml/2014/12/19/358

Yes, I'd agree. cgroups can group many tasks, but the group size can be
1 as well. Could you try the same test with the recommended approach and
see if it works as desired? 

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
