Date: Sun, 21 Mar 2004 17:34:32 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: where's the hugepage destructor still used?
Message-ID: <20040321163432.GA22647@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

put_page() has some code to call a destructor for hugepages, but I can't
find where we actually set that one.  Is it still used somewhere and I
totally missed the user?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
