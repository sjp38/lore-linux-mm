From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060219020140.9923.43378.sendpatchset@linux.site>
Subject: [patch 0/3] lockless pagecache
Date: Tue,  4 Apr 2006 11:31:42 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I'd like to submit the lockless pagecache for -mm. A scan through -mm
reveals that there shouldn't be any problems, except for reiser4, which
looks like it has a broken ->releasepage (it shouldn't be removing the
page from pagecache itself).

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
