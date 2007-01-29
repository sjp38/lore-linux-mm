From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070129081905.23584.97878.sendpatchset@linux.site>
Subject: [patch 0/9] buffered write deadlock fix
Date: Mon, 29 Jan 2007 11:31:37 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The following set of patches attempt to fix the buffered write
locking problems (and there are a couple of peripheral patches
and cleanups there too).

Patches against 2.6.20-rc6. I was hoping that 2.6.20-rc6-mm2 would
be an easier diff with the fsaio patches gone, but the readahead
rewrite clashes badly :(

Please apply?

Thanks,
Nick

--
SuSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
