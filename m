Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RLlJRh029376
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:47:19 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RLlJfN155080
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:47:19 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RLlIbZ025286
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:47:19 -0400
Subject: Re: [patch 20/23] powerpc: scan device tree for gigantic pages
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080525143454.237665000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
	 <20080525143454.237665000@nick.local0.net>
Content-Type: text/plain
Date: Tue, 27 May 2008 16:47:17 -0500
Message-Id: <1211924838.12036.54.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi-suse@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Jon Tollefson <kniht@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> plain text document attachment
> (powerpc-scan-device-tree-and-save-gigantic-page-locations.patch)
> The 16G huge pages have to be reserved in the HMC prior to boot. The
> location of the pages are placed in the device tree.   This patch adds
> code to scan the device tree during very early boot and save these page
> locations until hugetlbfs is ready for them.
> 
> Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
> Signed-off-by: Nick Piggin <npiggin@suse.de>

I am not really qualified to pass judgment on the device tree-specific
parts of this patch, but as for the rest:

Acked-by: Adam Litke <agl@us.ibm.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
