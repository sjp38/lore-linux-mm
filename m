Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E98486B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 07:38:47 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g71so679827wmg.13
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 04:38:47 -0700 (PDT)
Received: from mail-wr0-f196.google.com (mail-wr0-f196.google.com. [209.85.128.196])
        by mx.google.com with ESMTPS id t26si9925787edf.235.2017.08.07.04.38.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 04:38:46 -0700 (PDT)
Received: by mail-wr0-f196.google.com with SMTP id 12so144976wrb.4
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 04:38:46 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] mm, oom: fix oom_reaper fallouts
Date: Mon,  7 Aug 2017 13:38:37 +0200
Message-Id: <20170807113839.16695-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Argangeli <andrea@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
there are two issues this patch series attempts to fix. First one is
something that has been broken since MMF_UNSTABLE flag introduction
and I guess we should backport it stable trees (patch 1). The other
issue has been brought up by Wenwei Tao and Tetsuo Handa has created
a test case to trigger it very reliably. I am not yet sure this is a
stable material because the test case is rather artificial. If there is
a demand for the stable backport I will prepare it, of course, though.

I hope I've done the second patch correctly but I would definitely
appreciate some more eyes on it. Hence CCing Andrea and Kirill. My
previous attempt with some more context was posted here
http://lkml.kernel.org/r/20170803135902.31977-1-mhocko@kernel.org

My testing didn't show anything unusual with these two applied on top of
the mmotm tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
