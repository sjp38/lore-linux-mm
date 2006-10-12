From: Nick Piggin <npiggin@suse.de>
Message-Id: <20061012120102.29671.31163.sendpatchset@linux.site>
Subject: [rfc][patch 0/5] 2.6.19-rc1: oom killer fixes
Date: Thu, 12 Oct 2006 16:09:34 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

I've been prompted to take another look through the OOM killer because it
turns out it is killing tasks that have had their oom_adj set to -17 (which
is supposed to make them unkillable).

So there are a number of problems, firstly, the child and sibling thread
killing routines do not account for -17 children/siblings.

Secondly, most architecture specific pagefault handlers do a direct kill
of the current process if it takes a VM_FAULT_OOM. This is a pretty rare
thing to happen, because there isn't a lot of higher order allocations
happening, but it is not impossible. I think we can just call into the
OOM killer here, and return to userspace... but I'd like comments about
this.

Thanks,
Nick
--
SuSE Labs
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
