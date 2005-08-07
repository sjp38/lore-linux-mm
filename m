Message-ID: <42F57FCA.9040805@yahoo.com.au>
Date: Sun, 07 Aug 2005 13:28:10 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [RFC][patch 0/2] mm: remove PageReserved
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Hi,

I'll be looking to send these off to Andrew after 2.6.14 opens,
with the aim of having them merged by 2.6.15 hopefully.

It doesn't look like they'll be able to easily free up a page
flag for 2 reasons. First, PageReserved will probably be kept
around for at least one release. Second, swsusp and some arch
code (ioremap) wants to know about struct pages that don't point
to valid RAM - currently they use PageReserved, but we'll probably
just introduce a PageValidRAM or something when PageReserved goes.

I believe this makes memory management cleaner and easier to
understand. My other reason behind this is that the lockless
pagecache patches needs it for sane page refcounting.

If anyone has an issue with the patches or my merge plan, let's
get some discussion going.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
