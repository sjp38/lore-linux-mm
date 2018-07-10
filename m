Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6BE6B000A
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 17:12:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h14-v6so14772496pfi.19
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 14:12:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b3-v6sor5809239plb.139.2018.07.10.14.12.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Jul 2018 14:12:30 -0700 (PDT)
Date: Tue, 10 Jul 2018 14:12:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, oom: remove sleep from under oom_lock
In-Reply-To: <alpine.DEB.2.21.1807101152410.9234@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.21.1807101411480.29772@chino.kir.corp.google.com>
References: <20180709074706.30635-1-mhocko@kernel.org> <alpine.DEB.2.21.1807091548280.125566@chino.kir.corp.google.com> <20180710094341.GD14284@dhcp22.suse.cz> <alpine.DEB.2.21.1807101152410.9234@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 10 Jul 2018, David Rientjes wrote:

> I think it's better, thanks.  However, does it address the question about 
> why __oom_reap_task_mm() needs oom_lock protection?  Perhaps it would be 
> helpful to mention synchronization between reaping triggered from 
> oom_reaper and by exit_mmap().
> 

Actually, can't we remove the need to take oom_lock in exit_mmap() if 
__oom_reap_task_mm() can do a test and set on MMF_UNSTABLE and, if already 
set, bail out immediately?
