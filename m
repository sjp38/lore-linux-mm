Date: Thu, 7 Sep 2006 12:00:53 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: invalidate_complete_page()
Message-Id: <20060907120053.ccb6bb63.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is buggy, isn't it?  If someone faults the page into pagetables after
invalidate_mapping_pages() checked page_mapped(), the faulter-inner gets an
anonymous, not-up-to-date page which he didn't expect.

Locking the page in the pagefault handler will fix that, but meanwhile I
think we need to be checking page_count() in invalidate_complete_page(),
after taking tree_lock?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
