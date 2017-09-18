Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 913406B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 08:14:24 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id h16so313400wrf.0
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 05:14:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a21sor1008269wme.40.2017.09.18.05.14.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Sep 2017 05:14:23 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/3] mm, memory_hotplug: fix few soft lockups in memory hotadd
Date: Mon, 18 Sep 2017 14:14:07 +0200
Message-Id: <20170918121410.24466-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Johannes Thumshirn <jthumshirn@suse.de>, Michal Hocko <mhocko@suse.com>

Hi,
Johannes has noticed few soft lockups when adding a large nvdimm
device. All of them were caused by a long loop without any explicit
cond_resched which is a problem for !PREEMPT kernels. The fix is quite
straightforward. Just make sure that cond_resched gets called from time
to time.

Could you consider these for merging?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
