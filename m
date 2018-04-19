Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 949F66B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 15:14:07 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f3-v6so3519321plf.1
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 12:14:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y15sor1036167pgr.193.2018.04.19.12.14.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Apr 2018 12:14:06 -0700 (PDT)
Date: Thu, 19 Apr 2018 12:14:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper
 unmap
In-Reply-To: <201804191945.BBF87517.FVMLOQFOHSFJOt@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.21.1804191212530.157851@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1804171928040.100886@chino.kir.corp.google.com> <alpine.DEB.2.21.1804171951440.105401@chino.kir.corp.google.com> <20180418075051.GO17484@dhcp22.suse.cz> <alpine.DEB.2.21.1804181159020.227784@chino.kir.corp.google.com>
 <20180419063556.GK17484@dhcp22.suse.cz> <201804191945.BBF87517.FVMLOQFOHSFJOt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Apr 2018, Tetsuo Handa wrote:

> current code has a possibility that the OOM reaper is disturbed by
> unpredictable dependencies, like I worried that
> 
>   I think that there is a possibility that the OOM reaper tries to reclaim
>   mlocked pages as soon as exit_mmap() cleared VM_LOCKED flag by calling
>   munlock_vma_pages_all().
> 
> when current approach was proposed.

That's exactly the issue that this patch is fixing, yes.  If you brought 
that possibility up then I'm sorry that it was ignored.
