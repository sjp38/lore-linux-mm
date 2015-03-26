Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id D561D6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 15:30:39 -0400 (EDT)
Received: by ieclw3 with SMTP id lw3so54760376iec.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 12:30:39 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id qc2si139406igb.27.2015.03.26.12.30.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 12:30:39 -0700 (PDT)
Received: by igcau2 with SMTP id au2so19235528igc.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 12:30:39 -0700 (PDT)
Date: Thu, 26 Mar 2015 12:30:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 01/12] mm: oom_kill: remove unnecessary locking in
 oom_enable()
In-Reply-To: <20150326131839.GI15257@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1503261229350.9410@chino.kir.corp.google.com>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org> <1427264236-17249-2-git-send-email-hannes@cmpxchg.org> <alpine.DEB.2.10.1503251744290.32157@chino.kir.corp.google.com> <20150326115140.GC15257@dhcp22.suse.cz>
 <20150326131839.GI15257@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Thu, 26 Mar 2015, Michal Hocko wrote:

> I am wrong here! pagefault_out_of_memory takes the lock and so the whole
> mem_cgroup_out_of_memory is called under the same lock.

If all userspace processes are frozen by the time oom_killer_disable() is 
called, then there shouldn't be any race with the android lmk calling 
mark_tsk_oom_victim() either, so I assume that you're acking this patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
