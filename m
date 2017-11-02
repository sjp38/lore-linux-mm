Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA0F6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 05:36:30 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id q127so2643525wmd.1
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 02:36:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r29sor1769303edi.35.2017.11.02.02.36.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Nov 2017 02:36:29 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC 0/2] do not depend on cpuhotplug logs in lru_add_drain_all 
Date: Thu,  2 Nov 2017 10:36:11 +0100
Message-Id: <20171102093613.3616-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>

Hi,
this is an RFC to drop get_online_cpus from lru_add_drain_all ad this
has caused a very subtle lockdep splats recently [1]. I didn't get even
to properly test this yet and I am sending it early to check whether the
thinking behind is sound. I am basically following the same pattern we
have used for removing get_online_cpus from drain_all_pages which should
be the similar case.

Does anybody see any obvious problem?

[1] http://lkml.kernel.org/r/089e0825eec8955c1f055c83d476@google.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
