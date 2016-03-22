Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id DB7A36B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 18:08:23 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id x3so328024550pfb.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 15:08:23 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id ry2si20147062pab.159.2016.03.22.15.08.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 15:08:23 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id 4so197034408pfd.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 15:08:23 -0700 (PDT)
Date: Tue, 22 Mar 2016 15:08:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/9] oom reaper v6
In-Reply-To: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1603221507150.22638@chino.kir.corp.google.com>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Vladimir Davydov <vdavydov@virtuozzo.com>

On Tue, 22 Mar 2016, Michal Hocko wrote:

> Hi,
> I am reposting the whole patchset on top of the current Linus tree which should
> already contain big pile of Andrew's mm patches. This should serve an easier
> reviewability and I also hope that this core part of the work can go to 4.6.
> 
> The previous version was posted here [1] Hugh and David have suggested to
> drop [2] because the munlock path currently depends on the page lock and
> it is better if the initial version was conservative and prevent from
> any potential lockups even though it is not clear whether they are real
> - nobody has seen oom_reaper stuck on the page lock AFAICK. Me or Hugh
> will have a look and try to make the munlock path not depend on the page
> lock as a follow up work.
> 
> Apart from that the feedback revealed one bug for a very unusual
> configuration (sysctl_oom_kill_allocating_task) and that has been fixed
> by patch 8 and one potential mis interaction with the pm freezer fixed by
> patch 7.
> 
> I think the current code base is already very useful for many situations.
> The rest of the feedback was mostly about potential enhancements of the
> current code which I would really prefer to build on top of the current
> series. I plan to finish my mmap_sem killable for write in the upcoming
> release cycle and hopefully have it merged in the next merge window.
> I believe more extensions will follow.
> 
> This code has been sitting in the mmotm (thus linux-next) for a while.
> Are there any fundamental objections to have this part merged in this
> merge window?
> 

Tetsuo, have you been able to run your previous test cases on top of this 
version and do you have any concerns about it or possible extensions that 
could be made?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
