Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2EKtgl4000560
	for <linux-mm@kvack.org>; Wed, 14 Mar 2007 16:55:42 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2EKtgTD314990
	for <linux-mm@kvack.org>; Wed, 14 Mar 2007 16:55:42 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2EKtgPb032023
	for <linux-mm@kvack.org>; Wed, 14 Mar 2007 16:55:42 -0400
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca>
References: <Pine.GSO.4.64.0703081612290.1080@cpu102.cs.uwaterloo.ca>
	 <20070312142012.GH30777@atrey.karlin.mff.cuni.cz>
	 <20070312143900.GB6016@wotan.suse.de> <20070312151355.GB23532@duck.suse.cz>
	 <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca>
	 <20070312173500.GF23532@duck.suse.cz>
	 <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca>
	 <20070313185554.GA5105@duck.suse.cz>
	 <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca>
Content-Type: text/plain
Date: Wed, 14 Mar 2007 15:55:41 -0500
Message-Id: <1173905741.8763.36.camel@kleikamp.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ashif Harji <asharji@cs.uwaterloo.ca>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-03-14 at 15:58 -0400, Ashif Harji wrote:
> This patch unconditionally calls mark_page_accessed to prevent pages, 
> especially for small files, from being evicted from the page cache despite 
> frequent access.

I guess the downside to this is if a reader is reading a large file, or
several files, sequentially with a small read size (smaller than
PAGE_SIZE), the pages will be marked active after just one read pass.
My gut says the benefits of this patch outweigh the cost.  I would
expect real-world backup apps, etc. to read at least PAGE_SIZE.

Shaggy
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
