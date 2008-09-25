Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m8PMVJ32013040
	for <linux-mm@kvack.org>; Thu, 25 Sep 2008 18:31:19 -0400
From: David Howells <dhowells@redhat.com>
Subject: A question about alloc_pages()
Date: Thu, 25 Sep 2008 23:31:16 +0100
Message-ID: <15178.1222381876@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: dhowells@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

When alloc_pages() is asked to allocate a block of pages (order > 0), should I
be able to expect that page_count(pages[0]) will be 1, and page_count() for
all the other pages will be 0?

As far as I can see, nothing in the allocator alters what's in the page count
for pages beyond the first when pages are freed, and checks are made that
these are 0 upon freeing, so it looks to me like this ought to be the case.

However, I have a report that sometimes this isn't true, and I'm wondering if
the allocator can't be relied on in this way, or whether there's a bug
somewhere keeping a reference to a released page.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
