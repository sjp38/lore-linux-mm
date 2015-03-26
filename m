Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id A1DBC6B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 23:34:43 -0400 (EDT)
Received: by igcau2 with SMTP id au2so6279304igc.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:34:43 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id gz20si3887386icb.97.2015.03.25.20.34.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 20:34:43 -0700 (PDT)
Received: by igbud6 with SMTP id ud6so119644596igb.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 20:34:43 -0700 (PDT)
Date: Wed, 25 Mar 2015 20:34:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 02/12] mm: oom_kill: clean up victim marking and exiting
 interfaces
In-Reply-To: <1427264236-17249-3-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1503252032250.16714@chino.kir.corp.google.com>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org> <1427264236-17249-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

On Wed, 25 Mar 2015, Johannes Weiner wrote:

> Rename unmark_oom_victim() to exit_oom_victim().  Marking and
> unmarking are related in functionality, but the interface is not
> symmetrical at all: one is an internal OOM killer function used during
> the killing, the other is for an OOM victim to signal its own death on
> exit later on.  This has locking implications, see follow-up changes.
> 
> While at it, rename mark_tsk_oom_victim() to mark_oom_victim(), which
> is easier on the eye.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David Rientjes <rientjes@google.com>

I like exit_oom_victim() better since it follows the format of other 
do_exit() functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
