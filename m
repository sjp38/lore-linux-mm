Subject: [RFC/PATCH] Shared Page Tables [0/2]
From: Dave McCracken <dmccr@us.ibm.com>
Content-Type: text/plain
Date: Mon, 10 Apr 2006 11:13:08 -0500
Message-Id: <1144685588.570.35.camel@wildcat.int.mccr.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Here's a new cut of the shared page table patch.  I divided it into
two patches.  The first one just fleshes out the
pxd_page/pxd_page_kernel macros across the architectures.  The
second one is the main patch.

This version of the patch should address the concerns Hugh raised.
Hugh, I'd appreciate your feedback again.  Did I get everything?

These patches apply against 2.6.17-rc1.

Dave McCracken


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
