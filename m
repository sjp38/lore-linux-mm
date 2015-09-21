Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 862956B0038
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 17:53:19 -0400 (EDT)
Received: by padbj2 with SMTP id bj2so2656248pad.3
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 14:53:19 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id aa9si40757890pbd.56.2015.09.21.14.53.17
        for <linux-mm@kvack.org>;
        Mon, 21 Sep 2015 14:53:18 -0700 (PDT)
Date: Tue, 22 Sep 2015 07:52:41 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm, vmscan: Warn about possible deadlock at
 shirink_inactive_list
Message-ID: <20150921215241.GA19114@dastard>
References: <1442833794-23117-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442833794-23117-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org

On Mon, Sep 21, 2015 at 08:09:54PM +0900, Tetsuo Handa wrote:
> This is a difficult-to-trigger silent hang up bug.
> 
> The kswapd is allowed to bypass too_many_isolated() check in
> shrink_inactive_list(). But the kswapd can be blocked by locks in
> shrink_page_list() in shrink_inactive_list(). If the task which is
> blocking the kswapd is trying to allocate memory with the locks held,
> it forms memory reclaim deadlock.

It's a known problem in XFS and I'm currently working on patches to
fix it by hoisting the memory allocations outside of the CIL context
lock.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
