Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A28BA2803C1
	for <linux-mm@kvack.org>; Fri, 19 May 2017 07:26:14 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id x64so56262843pgd.6
        for <linux-mm@kvack.org>; Fri, 19 May 2017 04:26:14 -0700 (PDT)
Received: from mail-pg0-f66.google.com (mail-pg0-f66.google.com. [74.125.83.66])
        by mx.google.com with ESMTPS id b2si8156450pgc.211.2017.05.19.04.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 04:26:13 -0700 (PDT)
Received: by mail-pg0-f66.google.com with SMTP id s62so9505762pgc.0
        for <linux-mm@kvack.org>; Fri, 19 May 2017 04:26:13 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] fix premature OOM killer
Date: Fri, 19 May 2017 13:26:02 +0200
Message-Id: <20170519112604.29090-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
this is a follow up for [1]. The first patch is what Tetsuo suggested
[2], I've just added a changelog for it. This one should be merged
as soon as possible. The second patch is still an RFC. I _believe_
that it is the right thing to do but I haven't checked all the PF paths
which return VM_FAULT_OOM to be sure that there is nobody who would return
this error when not doing a real allocation.

[1] http://lkml.kernel.org/r/1495034780-9520-1-git-send-email-guro@fb.com
[2] http://lkml.kernel.org/r/201705182257.HJJ52185.OQStFLFMHVOJOF@I-love.SAKURA.ne.jp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
