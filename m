Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 29CA76B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 18:25:54 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n5so9078419pgq.3
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 15:25:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d30-v6sor5689889pld.59.2018.04.24.15.25.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 15:25:53 -0700 (PDT)
Date: Tue, 24 Apr 2018 15:25:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper
 unmap
In-Reply-To: <201804250657.GFI21363.StOJHOQFOMFVFL@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.21.1804241525280.238665@chino.kir.corp.google.com>
References: <201804221248.CHE35432.FtOMOLSHOFJFVQ@I-love.SAKURA.ne.jp> <alpine.DEB.2.21.1804231706340.18716@chino.kir.corp.google.com> <201804240511.w3O5BY4o090598@www262.sakura.ne.jp> <alpine.DEB.2.21.1804232231020.82340@chino.kir.corp.google.com>
 <201804250657.GFI21363.StOJHOQFOMFVFL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 25 Apr 2018, Tetsuo Handa wrote:

> > One of the reasons that I extracted __oom_reap_task_mm() out of the new 
> > oom_reap_task_mm() is to avoid the checks that would be unnecessary when 
> > called from exit_mmap().  In this case, we can ignore the 
> > mm_has_blockable_invalidate_notifiers() check because exit_mmap() has 
> > already done mmu_notifier_release().  So I don't think there's a concern 
> > about __oom_reap_task_mm() blocking while holding oom_lock.  Unless you 
> > are referring to something else?
> 
> Oh, mmu_notifier_release() made mm_has_blockable_invalidate_notifiers() == false. OK.
> 
> But I want comments why it is safe; I will probably miss that dependency
> when we move that code next time.
> 

Ok, makes sense.  I'll send a v3 to update the comment.
