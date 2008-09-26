Message-ID: <48DD073D.9080109@linux-foundation.org>
Date: Fri, 26 Sep 2008 11:01:01 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: A question about alloc_pages()
References: <15178.1222381876@redhat.com>
In-Reply-To: <15178.1222381876@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Howells wrote:

> When alloc_pages() is asked to allocate a block of pages (order > 0), should I
> be able to expect that page_count(pages[0]) will be 1, and page_count() for
> all the other pages will be 0?

Correct.

> However, I have a report that sometimes this isn't true, and I'm wondering if
> the allocator can't be relied on in this way, or whether there's a bug
> somewhere keeping a reference to a released page.

Must be a bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
