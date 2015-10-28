Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 37B5A82F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 22:41:34 -0400 (EDT)
Received: by iofz202 with SMTP id z202so242006274iof.2
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 19:41:34 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id u21si25776860iou.198.2015.10.27.19.41.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 27 Oct 2015 19:41:33 -0700 (PDT)
Message-Id: <20151028024114.370693277@linux.com>
Date: Tue, 27 Oct 2015 21:41:14 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [patch 0/3] vmstat: Various enhancements
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <htejun@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

This addresses a couple of issues that came up last week in
the discussion about issues related to the blocking of
the execution of vmstat updates.

1. It makes vmstat updates execution deferrable again so that
   no special tick is generated for vmstat execution. vmstat
   is quieted down when a processor enters idle mode. This
   means that no differentials exist anymore when a processor
   is in idle mode.

2. Create a separate workqueue so that the vmstat updater
   is not blocked by other work requeusts. This creates a
   new kernel thread <sigh> and avoids the issue of
   differentials not folded in a timely fashion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
