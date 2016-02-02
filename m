Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 70A8F6B0005
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 17:55:51 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id uo6so1817084pac.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 14:55:51 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id ta9si4539884pab.92.2016.02.02.14.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 14:55:50 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id n128so1832526pfn.3
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 14:55:50 -0800 (PST)
Date: Tue, 2 Feb 2016 14:55:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
In-Reply-To: <201602022048.GCJ04176.tOFFSVFHLMJOQO@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1602021452400.9118@chino.kir.corp.google.com>
References: <1452094975-551-2-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1601271651530.17979@chino.kir.corp.google.com> <20160128214247.GD621@dhcp22.suse.cz> <alpine.DEB.2.10.1602011843250.31751@chino.kir.corp.google.com> <20160202085758.GE19910@dhcp22.suse.cz>
 <201602022048.GCJ04176.tOFFSVFHLMJOQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 2 Feb 2016, Tetsuo Handa wrote:

> Maybe we all agree with introducing OOM reaper without queuing, but I do
> want to see a guarantee for scheduling for next OOM-kill operation before
> trying to build a reliable queuing chain.
> 

The race can be fixed in two ways which I've already enumerated, but the 
scheduling issue is tangential: the oom_reaper kthread is going to run; 
increasing it's priority will only interfere with other innocent processes 
that are not attached to the oom memcg hierarchy, have disjoint cpuset 
mems, or are happily allocating from mempolicy nodes with free memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
