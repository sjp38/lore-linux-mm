Subject: [PATCH 0/2][RFC] New version of shared page tables
From: Dave McCracken <dmccr@us.ibm.com>
Content-Type: text/plain
Date: Wed, 03 May 2006 10:43:24 -0500
Message-Id: <1146671004.24422.20.camel@wildcat.int.mccr.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

I've done some cleanup and some bugfixing.  Hugh, please review
this version instead of the old one.  I like my locking mechanism
for unsharing on this one a lot better.  It works on an address
range instead of depending on a vma, which more closely reflects
the way it's used.

The first patch just standardizes the pxd_page/pxd_page_kernel macros
for all architectures.

The second patch is the heart of shared page tables.

This version of the patches is against 2.6.17-rc3.

Dave McCracken



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
