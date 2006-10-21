Subject: Re: [patch 2/5] mm: fault vs invalidate/truncate race fix
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <452C8613.7080708@yahoo.com.au>
References: <20061010121314.19693.75503.sendpatchset@linux.site>
	 <20061010121332.19693.37204.sendpatchset@linux.site>
	 <20061010221304.6bef249f.akpm@osdl.org>  <452C8613.7080708@yahoo.com.au>
Content-Type: text/plain
Date: Sat, 21 Oct 2006 11:53:25 +1000
Message-Id: <1161395605.10524.227.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Without looking at any code, perhaps we could instead run get_user_pages
> and copy the memory that way.

I have a deep hatred for get_user_pages().... maybe not totally rational
though :) It will also only work with things that are actually backed up
by struct page. Is that ok in your case ?

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
