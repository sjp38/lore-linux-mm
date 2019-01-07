Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CBDB8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 09:39:42 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f31so371641edf.17
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 06:39:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f2sor37817818ede.19.2019.01.07.06.39.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 06:39:40 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
Date: Mon,  7 Jan 2019 15:38:00 +0100
Message-Id: <20190107143802.16847-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi,
I have posted this as an RFC previously [1]. Tetsuo has pointed out some
issues with the patch 1 which I have fixed hopefully. Other than that
this is just a rebase on top of Linus tree.

The original cover:
this is a follow up for [2] which has been nacked mostly because Tetsuo
was able to find a simple workload which can trigger a race where
no-eligible task is reported without a good reason. I believe the patch2
addresses that issue and we do not have to play dirty games with
throttling just because of the race. I still believe that patch proposed
in [2] is a useful one but this can be addressed later.

This series comprises 2 patch. The first one is something I meant to do
loooong time ago, I just never have time to do that. We need it here to
handle CLONE_VM without CLONE_SIGHAND cases. The second patch closes the
race.

Feedback is appreciated of course.

[1] http://lkml.kernel.org/r/20181022071323.9550-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20181010151135.25766-1-mhocko@kernel.org
