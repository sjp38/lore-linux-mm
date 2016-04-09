Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0D4B06B0253
	for <linux-mm@kvack.org>; Sat,  9 Apr 2016 10:04:34 -0400 (EDT)
Received: by mail-io0-f180.google.com with SMTP id g185so162052672ioa.2
        for <linux-mm@kvack.org>; Sat, 09 Apr 2016 07:04:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id uz15si8141369igb.12.2016.04.09.07.04.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 09 Apr 2016 07:04:33 -0700 (PDT)
Subject: Re: [PATCH 5/6] mm,oom: Re-enable OOM killer using timers.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
	<201602171934.DGG57308.FOSFMQVLOtJFHO@I-love.SAKURA.ne.jp>
	<20160217132052.GI29196@dhcp22.suse.cz>
	<201604092300.BDI39040.FFSQLJOMHOOVtF@I-love.SAKURA.ne.jp>
In-Reply-To: <201604092300.BDI39040.FFSQLJOMHOOVtF@I-love.SAKURA.ne.jp>
Message-Id: <201604092304.DBF69231.OFQHJFVMFLStOO@I-love.SAKURA.ne.jp>
Date: Sat, 9 Apr 2016 23:04:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, oleg@redhat.com

Tetsuo Handa wrote:
> There is no reason to add this patch which handles the slowpath right now.
Oops.
There is no reason _not_ to add this patch which handles the slowpath right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
