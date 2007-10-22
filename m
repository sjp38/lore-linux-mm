Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9MAhpA8014641
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:51 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MAlTxD212336
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:47:29 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MAhcoO009817
	for <linux-mm@kvack.org>; Mon, 22 Oct 2007 20:43:39 +1000
Message-Id: <20071022104518.985992030@linux.vnet.ibm.com>>
Date: Mon, 22 Oct 2007 16:15:19 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: [PATCH/RFC 0/9] VMA lookup with RCU
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Alexis Bruemmer <alexisb@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

This is forward port of Peter Zijlstra's RCU based 
VMA lookup patch set to kernel version 2.6.23.1

Reference:
http://programming.kicks-ass.net/kernel-patches/vma_lookup/

The patch set still needs some cleanup.  I am sending this out 
for anybody to review and try more experiments.

I have been posting results based on this patch set at linux-mm
http://marc.info/?l=linux-mm&m=119186241210311&w=2

--Vaidy

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
