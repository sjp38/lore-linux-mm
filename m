Subject: Re: [patch 0/3] 2.6.20 fix for PageUptodate memorder problem (try
	2)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0702090027580.29905@blonde.wat.veritas.com>
References: <20070208111421.30513.77904.sendpatchset@linux.site>
	 <Pine.LNX.4.64.0702090027580.29905@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Fri, 09 Feb 2007 12:41:35 +1100
Message-Id: <1170985295.2620.389.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Fix threaded user page write memory ordering
> 
> Make sure we order the writes to a newly created page
> with the page table update that potentially exposes the
> page to another CPU.
> 
> This is a no-op on any architecture where getting the
> page table spinlock will already do the ordering (notably
> x86), but other architectures can care.


Ah yes, the clear_* ones I knew about as I'm the one who tracked down
that bug on power :-) I though the ones Nick pointed out were different
tho.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
