From: David Howells <dhowells@redhat.com>
In-Reply-To: <20050124165412.GL31455@parcelfarce.linux.theplanet.co.uk> 
References: <20050124165412.GL31455@parcelfarce.linux.theplanet.co.uk> 
Subject: Re: [PATCH] Make slab use alloc_pages directly 
Date: Mon, 24 Jan 2005 17:03:58 +0000
Message-ID: <24391.1106586238@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org, manfred@colorfullife.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Matthew Wilcox <matthew@wil.cx> wrote:

> __get_free_pages() calls alloc_pages, finds the page_address() and
> throws away the struct page *.  Slab then calls virt_to_page to get it
> back again.  Much more efficient for slab to call alloc_pages itself,
> as well as making the NUMA and non-NUMA cases more similarr to each other.

Looks reasonable. Should also work in the NOMMU case.

David
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
