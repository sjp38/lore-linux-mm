Message-ID: <42BA5F37.6070405@yahoo.com.au>
Date: Thu, 23 Jun 2005 17:05:27 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch][rfc] 0/5: remove PageReserved
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
Cc: Hugh Dickins <hugh@veritas.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi,
The following set of patches removes PageReserved from core kernel
code, and clears the way for the page flag to be completely removed
when it is removed from all arch/ code. Drivers are mostly fairly
trivial, but will need auditing.

Arch maintainers and driver writers will need to help get that done.

Actually, only patches 4 and 5 are really required - the first 3 are
very minor things I noticed along the way (but I'm putting them in
this series because they have clashes).

Not quite ready for merging yet, although probably after the next
round of comments it will be. It boots and runs on i386, ppc64, ia64
and not tested elsewhere.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
