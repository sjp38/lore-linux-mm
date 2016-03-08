Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4446B0253
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 08:12:28 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id n186so130865985wmn.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:12:28 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id a129si20791151wmf.119.2016.03.08.05.12.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 05:12:27 -0800 (PST)
Received: by mail-wm0-f51.google.com with SMTP id p65so149117615wmp.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:12:27 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH -mm 0/2] oom_reaper: missing parts
Date: Tue,  8 Mar 2016 14:12:15 +0100
Message-Id: <1457442737-8915-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
there are two following left overs which are missing in your tree
right now. Could you add them please?

Thanks to Tetsuo for pointing it out http://lkml.kernel.org/r/201603082010.EEE43272.QVJFOFOHtMSLOF@I-love.SAKURA.ne.jp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
