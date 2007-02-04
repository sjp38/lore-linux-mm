From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070204063707.23659.20741.sendpatchset@linux.site>
Subject: [patch 0/9] buffered write deadlock fix
Date: Sun,  4 Feb 2007 09:49:41 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Have fixed a few issues since last time:
- better comments for the SetPageUptodate race
- actually fix the nobh problem rather than adding a comment
- use kmap_atomic instead of kmap

Patches against 2.6.20-rc7.

Thanks,
Nick

--
SuSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
