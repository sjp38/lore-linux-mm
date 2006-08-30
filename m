Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7U3h7eR031727
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 23:43:07 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7U3h5ww260422
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 23:43:07 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7U3h5w1026116
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 23:43:05 -0400
Message-ID: <44F50940.1010204@cn.ibm.com>
Date: Wed, 30 Aug 2006 11:42:56 +0800
From: Yao Fei Zhu <walkinair@cn.ibm.com>
Reply-To: walkinair@cn.ibm.com
MIME-Version: 1.0
Subject: Swap file or device can't be recognized by kernel built with 64K
 pages.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, havelblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

Problem description:
swap file or device can't be recognized by kernel built with 64K pages.

Hardware Environment:
    Machine type (p650, x235, SF2, etc.): B70+
    Cpu type (Power4, Power5, IA-64, etc.): POWER5+
Software Environment:
    OS : SLES10 GMC
    Kernel: 2.6.18-rc5
Additional info:

tc1:~ # uname -r
2.6.18-rc5-ppc64

tc1:~ # zcat /proc/config.gz | grep 64K
CONFIG_PPC_64K_PAGES=y

tc1:~ # mkswap ./swap.file
Assuming pages of size 65536 (not 4096)
Setting up swapspace version 0, size = 4294901 kB

tc1:~ # swapon ./swap.file
swapon: ./swap.file: Invalid argument


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
