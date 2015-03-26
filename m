Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 139636B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 16:05:07 -0400 (EDT)
Received: by igcau2 with SMTP id au2so2272802igc.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 13:05:06 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id py6si5686646icb.94.2015.03.26.13.05.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 13:05:06 -0700 (PDT)
Received: by igcxg11 with SMTP id xg11so2289181igc.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 13:05:06 -0700 (PDT)
Date: Thu, 26 Mar 2015 13:05:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 01/12] mm: oom_kill: remove unnecessary locking in
 oom_enable()
In-Reply-To: <1427264236-17249-2-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1503261304540.9410@chino.kir.corp.google.com>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org> <1427264236-17249-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

On Wed, 25 Mar 2015, Johannes Weiner wrote:

> Setting oom_killer_disabled to false is atomic, there is no need for
> further synchronization with ongoing allocations trying to OOM-kill.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
