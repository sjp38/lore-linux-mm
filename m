Received: from [10.10.0.38] (timur.austin.ammasso.com [10.10.0.38])
	by emachine.austin.ammasso.com (8.12.8/8.12.8) with ESMTP id i83FcUKY005504
	for <linux-mm@kvack.org>; Fri, 3 Sep 2004 10:38:31 -0500
Message-ID: <41389078.1080900@ammasso.com>
Date: Fri, 03 Sep 2004 10:40:40 -0500
From: Timur Tabi <timur.tabi@ammasso.com>
Reply-To: linux-mm@kvack.org
MIME-Version: 1.0
Subject: Don't understand vm_page_prot
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm reading about vm_area_struct in Mel Gorman's book on the Linux VM, 
and he says that the vm_page_prot field in structure vm_area_struct 
contains "protection flags that are set for each PTE in this VMA". These 
are the _PAGE_xxx flags in pgtable.h.

The problem I have is that these flags describe individual pages.  For 
instance, _PAGE_DIRTY says that this particular page is dirty.  So what 
does it mean if _PAGE_DIRTY is set in vm_page_prot?  Does that mean that 
every page in this VMA is dirty?  What if only some of the pages are dirty?


-- 
Timur Tabi
Staff Software Engineer
timur.tabi@ammasso.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
