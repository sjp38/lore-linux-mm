Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 86AA96B0292
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:04:07 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z48so32579143wrc.4
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:04:07 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 2si15250125wro.472.2017.07.27.02.04.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 02:04:06 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r123so13553066wmb.5
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 02:04:06 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] mm, oom: do not grant oom victims full memory reserves access
Date: Thu, 27 Jul 2017 11:03:55 +0200
Message-Id: <20170727090357.3205-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
this is a part of a larger series I posted back in Oct last year [1]. I
have dropped patch 3 because it was incorrect and patch 4 is not
applicable without it.

The primary reason to apply patch 1 is to remove a risk of the complete
memory depletion by oom victims. While this is a theoretical risk right
now there is a demand for memcg aware oom killer which might kill all
processes inside a memcg which can be a lot of tasks. That would make
the risk quite real.

This issue is addressed by limiting access to memory reserves. We no
longer use TIF_MEMDIE to grant the access and use tsk_is_oom_victim
instead. See Patch 1 for more details. Patch 2 is a trivial follow up
cleanup.

I would still like to get rid of TIF_MEMDIE completely but I do not have
time to do it now and it is not a pressing issue.

[1] http://lkml.kernel.org/r/20161004090009.7974-1-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
