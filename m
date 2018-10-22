Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 020616B0006
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 03:13:42 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f132-v6so10583704pgc.21
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 00:13:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t15-v6sor18989135pgl.20.2018.10.22.00.13.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 00:13:40 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
Date: Mon, 22 Oct 2018 09:13:21 +0200
Message-Id: <20181022071323.9550-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi,
this is a follow up for [1] which has been nacked mostly because Tetsuo
was able to find a simple workload which can trigger a race where
no-eligible task is reported without a good reason. I believe the patch2
addresses that issue and we do not have to play dirty games with
throttling just because of the race. I still believe that patch proposed
in [1] is a useful one but this can be addressed later.

This series comprises 2 patch. The first one is something I meant to do
loooong time ago, I just never have time to do that. We need it here to
handle CLONE_VM without CLONE_SIGHAND cases. The second patch closes the
race.

I didn't get to test this throughly so it is posted as an RFC.

Feedback is appreciated of course.

[1] http://lkml.kernel.org/r/20181010151135.25766-1-mhocko@kernel.org
