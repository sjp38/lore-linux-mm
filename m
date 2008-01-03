Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 00 of 11] oom deadlock fixes
Message-Id: <patchbomb.1199326146@v2.random>
Date: Thu, 03 Jan 2008 03:09:06 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Hello,

I rebased the patchset that fixes certain oom deadlocks that are still
reproducible with mainline.

I removed the global VM_is_OOM to keep the fixes to the minimum required to not
be kernel-crashing, I adapted to the introduction of the zone-oom-lock bitflag,
so with this update I hopefully have a better chance for merging.

Despite the lack of VM_is_OOM perfect oom-killing serialization, and the need
to avoid waiting forever on TIF_MEMDIE to prevent deadlocks, in practice with
swap it seem not to generate bad spurious kills and it avoids the deadlock as
well as my older patchset. We can always perfect this later with feedback
coming from do_exit.

Thanks.
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
