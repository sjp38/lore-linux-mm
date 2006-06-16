Received: from wip-ec-wd.wipro.com (localhost.wipro.com [127.0.0.1])
	by localhost (Postfix) with ESMTP id 2E9C3205FE
	for <linux-mm@kvack.org>; Fri, 16 Jun 2006 15:41:56 +0530 (IST)
Received: from blr-ec-bh02.wipro.com (blr-ec-bh02.wipro.com [10.201.50.92])
	by wip-ec-wd.wipro.com (Postfix) with ESMTP id 192CC205E7
	for <linux-mm@kvack.org>; Fri, 16 Jun 2006 15:41:56 +0530 (IST)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: Memory Leak Detection and Kernel Memory monitoring tool
Date: Fri, 16 Jun 2006 15:43:58 +0530
Message-ID: <05B7784238A51247A0A9FB4B348CECAE01D7686A@PNE-HJN-MBX01.wipro.com>
From: <kaustav.majumdar@wipro.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
    My team is developing a device driver for a PCMCIA based USB device. We're currently trying to test the performance of our driver. However we're unable to figure out a reliable method of detecting memory leaks caused by our driver code. Neither have we been able to find a tool which shows % utilization of kernel memory used by our driver. I suppose applying kmemleak patch is a good way of detecting these leaks. But there is no patch available for kernel 2.6.15.4 (on fedora core 4). 
 
About the memory monitoring, there are quite a few tools available at the application level (like free and top which are available with the operating system itself). But none for the kernel level. 
 
Please suggest other feasible ways of detecting leaks and monitoring kernel memory utilization.
 
Regards
Kaustav Majumdar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
