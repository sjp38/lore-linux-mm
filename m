From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070113011526.9479.79596.sendpatchset@linux.site>
Subject: [patch 0/7] fault vs truncate/invalidate race fix
Date: Sat, 13 Jan 2007 04:27:42 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, Dave Airlie <airlied@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, thomas@tungstengraphics.com
List-ID: <linux-mm.kvack.org>

The following set of patches fix the fault vs invalidate and fault
vs truncate_range race for filemap_nopage mappings, plus those and
fault vs truncate race for nonlinear mappings.

Hasn't changed since I last submitted it, when it was rejected because
it made one of the buffered write deadlocks easier to hit. I'll try
again.

Patches based on 2.6.20-rc4. Comments?

Thanks,
Nick

--
SuSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
