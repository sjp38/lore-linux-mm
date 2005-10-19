Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9JMGEF3014844
	for <linux-mm@kvack.org>; Wed, 19 Oct 2005 18:16:14 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9JMGELk528048
	for <linux-mm@kvack.org>; Wed, 19 Oct 2005 16:16:14 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9JMGExR003784
	for <linux-mm@kvack.org>; Wed, 19 Oct 2005 16:16:14 -0600
Subject: MADV_FREE ?
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Wed, 19 Oct 2005 15:15:39 -0700
Message-Id: <1129760139.8716.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I was wondering if someone knew what MADV_FREE is supposed
or intended to do ? I see it sparc* headers. I don't see any
code to implement it or for any other architecture.

./include/asm-sparc64/mman.h:#define MADV_FREE  0x5             
	/* (Solaris) contents can be freed  */
./include/asm-sparc/mman.h:#define MADV_FREE    0x5             
	/* (Solaris) contents can be freed  */

Is this carry over from old days ?

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
