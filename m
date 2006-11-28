Received: from [192.168.1.2] (CPE-65-30-169-162.wi.res.rr.com [65.30.169.162])
	by ms-smtp-02.rdc-kc.rr.com (8.13.6/8.13.6) with ESMTP id kASE2fma022113
	for <linux-mm@kvack.org>; Tue, 28 Nov 2006 08:02:41 -0600 (CST)
Message-ID: <456C4182.4020302@yahoo.com>
Date: Tue, 28 Nov 2006 08:02:42 -0600
From: John Fusco <fusco_john@yahoo.com>
MIME-Version: 1.0
Subject: Making PCI Memory Cachable
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have numerous custom PCI devices that implement SRAM or DRAM on the 
PCI bus. I would like to explore making this memory cachable in the 
hopes that writes to memory can be done from user space and will be done 
in bursts rather than single cycles.

Is this crazy or what? I assumed that the VM_IO flag in remap_pfn_range 
controls this, but that doesn't appear to be the case.

A simple test from user space is the following:
    ptr = mmap(...)
    memset(ptr, 'a', size)


The driver gets the pointer with remap_pfn_range, but I always see 
64-bit writes to memory (this is x86_64 architecture). If this were 
cachable and the HW waqs cooperative, I would expect to see cache line 
bursts (e.g. 128 bytes).

I think one of two things is happening:
    a) The kernel is not making this memory cachable
    b) The memory is cachable, but the chipset is throttling the bursts

Can someone enlighten me?

Thanks,
John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
