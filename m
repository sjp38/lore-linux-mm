Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 663686B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 08:32:23 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id ig19so10863420igb.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:32:23 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id hh15si3130357igb.69.2016.03.11.05.32.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Mar 2016 05:32:20 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
	<201603111945.FHI64215.JVOFLHQFOMOSFt@I-love.SAKURA.ne.jp>
	<20160311130847.GP27701@dhcp22.suse.cz>
In-Reply-To: <20160311130847.GP27701@dhcp22.suse.cz>
Message-Id: <201603112232.AEJ78150.LOHQJtMFSVOFOF@I-love.SAKURA.ne.jp>
Date: Fri, 11 Mar 2016 22:32:02 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 11-03-16 19:45:29, Tetsuo Handa wrote:
> > (Posting as a reply to this thread.)
> 
> I really do not see how this is related to this thread.

All allocating tasks are looping at

                        /*
                         * If we didn't make any progress and have a lot of
                         * dirty + writeback pages then we should wait for
                         * an IO to complete to slow down the reclaim and
                         * prevent from pre mature OOM
                         */
                        if (!did_some_progress && 2*(writeback + dirty) > reclaimable) {
                                congestion_wait(BLK_RW_ASYNC, HZ/10);
                                return true;
                        }

in should_reclaim_retry().

should_reclaim_retry() was added by OOM detection rework, wan't it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
