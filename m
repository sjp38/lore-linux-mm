From: Nick Piggin <npiggin@suse.de>
Message-Id: <20061004123018.5637.93004.sendpatchset@linux.site>
Subject: [patch 0/4] lockless pagecache for 2.6.18-mm3
Date: Wed,  4 Oct 2006 16:36:58 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Updated lockless patchset against 2.6.18-mm3. Boots and survives basic
stress testing so far.

I have decided not to implement the tweak Hugh suggested yet, for reasons
outlined in the patch description. I still think it is a promising
approach, I just haven't been able to convince myself of correctness
in some paths yet.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
