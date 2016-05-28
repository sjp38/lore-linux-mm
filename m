Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADF796B007E
	for <linux-mm@kvack.org>; Sat, 28 May 2016 10:04:25 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id g6so217156626obn.0
        for <linux-mm@kvack.org>; Sat, 28 May 2016 07:04:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t95si7076976ota.67.2016.05.28.07.04.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 28 May 2016 07:04:24 -0700 (PDT)
Subject: Re: [PATCH 0/5] Handle oom bypass more gracefully
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
	<20160527160026.GA29337@dhcp22.suse.cz>
In-Reply-To: <20160527160026.GA29337@dhcp22.suse.cz>
Message-Id: <201605282304.DJC04167.SHLtVQMOOFFOFJ@I-love.SAKURA.ne.jp>
Date: Sat, 28 May 2016 23:04:08 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

Michal Hocko wrote:
> JFYI, I plan to repost the series early next week after I review all the
> pieces again properly with a clean head. If some parts are not sound or
> completely unacceptable in principle then let me know of course.

I don't think we can apply this series.

  [PATCH 1/6] is unreliable and will be dropped.

  [PATCH 2/6] would be OK as a clean up.

  [PATCH 3/6] will change user visible part. We deprecated /proc/pid/oom_adj
  in Aug 2010 (nearly 6 years ago) by commit 51b1bd2ace1595b7 ("oom: deprecate
  oom_adj tunable") but we still preserve that behavior, don't we? I think
  [PATCH 3/6] will need 5 to 10 years of get-acquainted period in order to
  make sure that no end users will depend on current behavior. This is not
  something we can change now.

  [PATCH 4/6] is unsafe as Vladimir commented.

  [PATCH 5/6] will also change user visible part. We need get-acquainted period.
  This is not something we can change now.

  [PATCH 6/6] seems to be unsafe as I commented on a different thread
  ( http://lkml.kernel.org/r/201605282122.HAD09894.SFOFHtOVJLOQMF@I-love.SAKURA.ne.jp ).

You are trying to make the OOM killer as per mm_struct operation. But
I think we need to tolerate the OOM killer as per signal_struct operation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
