From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070113011159.9449.4327.sendpatchset@linux.site>
Subject: [patch 0/10] buffered write deadlock fix
Date: Sat, 13 Jan 2007 04:24:15 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

The following set of patches attempt to fix the buffered write
locking problems (and there are a couple of peripheral patches
and cleanups there too).

This does pass the write deadlock tests that otherwise fail.

Has survived a few hours of fsx-linux on ext2 and 3.

Patches against 2.6.20-rc4. I didn't have the heart to attempt
to rebase them on -mm, at least until I get some feedback ;)

Thanks,
Nick

--
SuSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
