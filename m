From: "Jalajadevi Ganapathy" <jganapat@Storage.com>
Message-ID: <85256A15.00692E23.00@alpha2.storage.com>
Date: Tue, 20 Mar 2001 14:11:50 -0500
Subject: kmalloc with GFP_DMA, or get_free_pages!!!
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

To allocate memory for DMA operations, i can use kmalloc (,,GFP_DMA.. ). In
which case I need to use get_free_pages? Both the above gives me the
contiguous memory. I understand that get_free_pages gives me in terms of
pages. So it would be more than the memory which i asked for. I am not sure
watz the exact difference between these two.

Could anyone plz lemme know about this?

Thanks
Jalaja


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
