Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B983C6B025E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:04:37 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s63so13228468wme.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:04:37 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id u188si25129425wmb.4.2016.04.26.07.04.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 07:04:36 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n3so5360269wmn.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:04:36 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] last pile of oom_reaper patches for now
Date: Tue, 26 Apr 2016 16:04:28 +0200
Message-Id: <1461679470-8364-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
these two patches poped out during previous discussions and they are not
in the mmomt tree yet. Both of them should be really cosmetic and catch
few more corner cases with a relatively small risk.

Let me know if you prefer the whole pile currently sitting in the mmotm
to be resent in one patchset.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
