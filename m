Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5EEB46B02A1
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:28:56 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id y36so7434238plh.10
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:28:56 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p9sor5454601pls.122.2017.12.19.05.28.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 05:28:55 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [resend PATCH 0/2] fix VFS register_shrinker fixup 
Date: Tue, 19 Dec 2017 14:28:42 +0100
Message-Id: <20171219132844.28354-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Aliaksei Karaliou <akaraliou.dev@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
Tetsuo has posted patch 1 already [1]. I had some minor concenrs about
the changelog but the approach was already OK. Aliaksei came with an
alternative patch [2] which also handles double unregistration. I have
updated the changelog and moved the syzbot report to the 2nd patch
because it is more related to the change there. The patch 1 is
prerequisite. Maybe we should just merge those two. I've kept Tetsuo's
s-o-b and his original authorship, but let me know if you disagree with
the new wording or the additional change, Tetsuo.

The patch 2 is based on Al's suggestion [3] and it fixes sget_userns
shrinker registration code.

Both of these stalled so can we have them merged finally?

[1] http://lkml.kernel.org/r/1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
[2] http://lkml.kernel.org/r/20171216192937.13549-1-akaraliou.dev@gmail.com
[3] http://lkml.kernel.org/r/20171123145540.GB21978@ZenIV.linux.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
