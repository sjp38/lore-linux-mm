Message-Id: <20061129030655.941148000@menage.corp.google.com>
Date: Tue, 28 Nov 2006 19:06:55 -0800
From: menage@google.com
Subject: [RFC][PATCH 0/1] Node-based reclaim/migration
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@osdl.org
List-ID: <linux-mm.kvack.org>

--

We're trying to use NUMA node isolation as a form of job resource
control at Google, and the existing page migration APIs are all bound
to individual processes and so are a bit clunky to use when you just
want to affect all the pages on a given node.

How about an API to allow userspace to direct page migration (and page
reclaim) on a per-node basis? This patch provides such an API, based
around sysfs; a system call approach would certainly be possible too.

It sort of overlaps with memory hot-unplug, but is simpler since it's
not so bad if we miss a few pages.

Comments? Also, can anyone clarify whether I need any locking when
sacnning the pages in a pgdat? As far as I can see, even with memory
hotplug this number can only increase, not decrease.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
