Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 07FDA828EB
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 17:54:57 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id uo6so311498662pac.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 14:54:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y15si31410303pfi.232.2016.01.11.14.54.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 14:54:56 -0800 (PST)
Date: Mon, 11 Jan 2016 14:54:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-Id: <20160111145455.51e183aed810f7d366ea50a0@linux-foundation.org>
In-Reply-To: <1452094975-551-2-git-send-email-mhocko@kernel.org>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
	<1452094975-551-2-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed,  6 Jan 2016 16:42:54 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> - use subsys_initcall instead of module_init - Paul Gortmaker

That's pretty much the only change between what-i-have and
what-you-sent, so I'll just do this as a delta:


--- a/mm/oom_kill.c~mm-oom-introduce-oom-reaper-v4
+++ a/mm/oom_kill.c
@@ -32,12 +32,11 @@
 #include <linux/mempolicy.h>
 #include <linux/security.h>
 #include <linux/ptrace.h>
-#include <linux/delay.h>
 #include <linux/freezer.h>
 #include <linux/ftrace.h>
 #include <linux/ratelimit.h>
 #include <linux/kthread.h>
-#include <linux/module.h>
+#include <linux/init.h>
 
 #include <asm/tlb.h>
 #include "internal.h"
@@ -542,7 +541,7 @@ static int __init oom_init(void)
 	}
 	return 0;
 }
-module_init(oom_init)
+subsys_initcall(oom_init)
 #else
 static void wake_oom_reaper(struct mm_struct *mm)
 {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
