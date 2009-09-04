Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 073896B0083
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 16:55:13 -0400 (EDT)
Subject: [PATCH 0/4] Safely removing mmaped files
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 04 Sep 2009 12:24:44 -0700
Message-ID: <m1fxb2wm0z.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>


Currently when mmaped files are removed I have not found a single
instance in the kernel where we handle it correctly.  Frequently after
a hot remove we will either leak a file (with weird ensuing
consequences) or we will goof and not call vm_ops->close() which can
cause leaks.

It turns out this problem isn't too bad to actually fix and this
patchset is my generic solution.  Tested against 2.6.31-rc8 with a
process that mmaped /sys/*/*/resource0 and /proc/bus/pci/*/*.

I'm not certain what the best way to carry these patches is to get
them merged.  Andrew can you carry this patchset?


Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
