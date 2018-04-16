Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCB46B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:09:06 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id v14-v6so11077968ybq.20
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 16:09:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r13-v6sor4121180ybm.34.2018.04.16.16.09.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 16:09:04 -0700 (PDT)
Date: Mon, 16 Apr 2018 16:09:01 -0700
From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET v2] mm, memcontrol: Implement memory.swap.events
Message-ID: <20180416230901.GG1911913@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

Hello,

Rebased on top of e27be240df53 ("mm: memcg: make sure memory.events is
uptodate when waking pollers").

This patchset implements memory.swap.events which contains max and
fail events so that userland can monitor and respond to swap running
out.  It contains the following two patches.

 0001-mm-memcontrol-Move-swap-charge-handling-into-get_swa.patch
 0002-mm-memcontrol-Implement-memory.swap.events.patch

This patchset is on top of the current linus#master
(a27fc14219f2e3c4a46ba9177b04d9b52c875532).

Thanks.

-- 
tejun
