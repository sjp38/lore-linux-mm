Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6CC600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:29 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Message-Id: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [0/31] HWPOISON 2.6.33 pre-merge posting
Date: Tue,  8 Dec 2009 22:16:16 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


These are the hwpoison updates for 2.6.33
I plan to send the following patchkit to Linus in a few days.
Any additional review would be appreciated.

Major new features:
- Be more aggressive at flushing caches to get access to a page
- Various fixes for the core memory_failure path
- Handle free memory better by detecting higher-order buddy pages
reliably too.
- Reliable return value for memory_failure. This allows to implement
some other functionality later on.
- New soft offlining feature:
Offline a page without killing a process.
This allows to implement predictive failure analysis for memory, by
watching error trends per page and offlining a page that has too many
corrected errors.  The policy is all in user space; the kernel just 
offlines the page and reports the errors.
The current git mcelog has support for using this interface.
- Provide a new sysfs interface for both hard and soft offlining.
The existing debugfs interface is still there.
- unpoison support
Unpoison a page. This is mainly for testing, it does not do unpoisioning
on the hardware level.
- hwpoison filter
Various filters to the hwpoison PFN error injection, including 
memcg, page type, block device and others.
This is used by the mce-test stress suite to protect the test suite itself
and

This touches some code outside hwpoison, mostly for the memcg support
and for the page types. All these changes are straight-forward,
are in linux-next and have been posted before.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
