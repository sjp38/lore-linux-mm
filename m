Date: Tue, 18 Oct 2005 06:45:06 -0500
From: Robin Holt <holt@sgi.com>
Subject: What were your needs for do_no_page calling a driver for a pfn?
Message-ID: <20051018114506.GB20231@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte@de.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Carsten,

On a thread of mine which you recently replied to, it was mentioned
that you had a driver which needed to be able to have do_no_page drop
ina pte for a physical page of memory which did not have a struct page
associated with it.

Can you give me a heads up on your need?

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
