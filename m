Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B8A3B6B0253
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 17:48:38 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l68so5970943wml.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 14:48:38 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h8si957555wjq.189.2016.03.09.14.48.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 14:48:37 -0800 (PST)
Date: Wed, 9 Mar 2016 17:48:29 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2]
 oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix
Message-ID: <20160309224829.GA5716@cmpxchg.org>
References: <1457442737-8915-1-git-send-email-mhocko@kernel.org>
 <1457442737-8915-3-git-send-email-mhocko@kernel.org>
 <20160309132142.80d0afbf0ae398df8e2adba8@linux-foundation.org>
 <201603100721.CDC86433.OMFOVOHSJFLFQt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603100721.CDC86433.OMFOVOHSJFLFQt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.com

On Thu, Mar 10, 2016 at 07:21:58AM +0900, Tetsuo Handa wrote:
> Andrew Morton wrote:
> > I found the below patch lying around but I didn't queue it properly. 
> > Is it legit?
> 
> I think that patch wants patch description updated.
> Not testing pure noise, but causing possible livelock.
> http://lkml.kernel.org/r/20160217143917.GP29196@dhcp22.suse.cz

Sorry, I completely missed that. We're drowning in OOM killer fixes!

However, I disagree with your changelog. The scenario you describe is
real, but that the hung task is exiting is also noise. The underlying
problem is that the OOM victim is hung. Instead of OOM_SCAN_ABORT, the
OOM killer could also select some other non-exiting task that has the
mmap_sem held for reading. This patch doesn't fix that bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
