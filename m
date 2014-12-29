Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 594286B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 16:03:04 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id z20so998644igj.4
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 13:03:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id be3si72620586wjb.76.2014.12.29.04.32.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Dec 2014 04:32:27 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 0/2] oom and TIF_MEMDIE setting to mm-less tasks fixes
Date: Mon, 29 Dec 2014 13:32:05 +0100
Message-Id: <1419856327-673-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
could you pick up these two fixes which came out of a longer discussion
started here: http://marc.info/?l=linux-mm&m=141839249819519. The thread
became quite confusing as multiple issues were discussed there so I think
reposting them in a new thread will make more sense.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
