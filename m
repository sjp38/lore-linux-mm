Message-Id: <20061019101722.805147000@chello.nl>
Date: Thu, 19 Oct 2006 12:17:22 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 0/4] on do_page_fault() and *copy*_inatomic
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

In light of the recent work on fault handlers and generic_file_buffered_write()
I've gone over some of the arch specific stuff that supports this work.

The following four patches are the result...

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
