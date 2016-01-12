Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 46965828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 16:00:37 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id u188so272403070wmu.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 13:00:37 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id m132si33859149wmd.38.2016.01.12.13.00.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 13:00:36 -0800 (PST)
Received: by mail-wm0-f50.google.com with SMTP id f206so270428828wmf.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 13:00:35 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC 0/3] oom: few enahancements
Date: Tue, 12 Jan 2016 22:00:22 +0100
Message-Id: <1452632425-20191-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>

Hi,
based on the recent discussions I have accumulated the following three
patches. I haven't tested them yet but I would like to hear your
opinion. The first patch only affects sysrq+f OOM killer.  I believe it
should be relatively uncontroversial.

The patch 2 tweaks how we handle children tasks standing for the parent
oom victim. This should help the test case Tetsuo shown [1].

The patch 3 is just a rough idea. I can see objections there but this is
mainly to start discussion about ho to deal with small children which
basically do not sit on any memory. Maybe we do not need anything like
that at all and realy on multiple OOM invocations as a safer option. I
dunno but I would like to hear your opinions.

---
[1] http://lkml.kernel.org/r/201512292258.ABF87505.OFOSJLHMFVOQFt%40I-love.SAKURA.ne.jp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
