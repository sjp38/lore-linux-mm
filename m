Received: from il.marvell.com ([10.2.1.184])
	by mail.galileo.co.il (8.12.6/8.12.6) with ESMTP id hA6G8iGn018892
	for <linux-mm@kvack.org>; Thu, 6 Nov 2003 18:08:45 +0200 (IST)
Message-ID: <3FAA7237.1030006@il.marvell.com>
Date: Thu, 06 Nov 2003 18:09:27 +0200
From: Mark Mokryn <markm@il.marvell.com>
MIME-Version: 1.0
Subject: Highmem SCSI driver
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We are trying to test 64-bit PCI DMA for a SCSI driver on a Xeon box,

RH9 2.4.20-8 bigmem kernel, 6GB RAM.
The machine shows 6GB in top, we set highmem_io in the driver, PCI DMA 
mask covers 64-bit range, etc.

Of course we're trying to make sure that the system does not create 
bounce buffers unnecessarily. On a 64-bit box (AMD64) everything works 
as expected. On the Xeon, no matter what we try, we never see I/Os 
mapped above 4GB.

Any ideas on how we can drive I/Os mapped above 4GB down to our driver?

Thanks,
-Mark



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
