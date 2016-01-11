Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id DA228828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 12:01:17 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l65so219507728wmf.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 09:01:17 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gf10si200383064wjb.142.2016.01.11.09.01.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 09:01:16 -0800 (PST)
Date: Mon, 11 Jan 2016 12:00:47 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm,oom: do not loop !__GFP_FS allocation if the OOM
 killer is disabled.
Message-ID: <20160111170047.GB32132@cmpxchg.org>
References: <1452488836-6772-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452488836-6772-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.cz, rientjes@google.com, linux-mm@kvack.org

On Mon, Jan 11, 2016 at 02:07:16PM +0900, Tetsuo Handa wrote:
> After the OOM killer is disabled during suspend operation,
> any !__GFP_NOFAIL && __GFP_FS allocations are forced to fail.
> Thus, any !__GFP_NOFAIL && !__GFP_FS allocations should be
> forced to fail as well.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Why? We had to acknowledge that !__GFP_FS allocations can not fail
even when they can't invoke the OOM killer. They are NOFAIL. Just like
an explicit __GFP_NOFAIL they should trigger a warning when they occur
after the OOM killer has been disabled and then keep looping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
