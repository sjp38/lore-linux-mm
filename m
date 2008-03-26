Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2QLIxKt007929
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 17:18:59 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2QLKUf3189844
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 15:20:30 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2QLKUJA030334
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 15:20:30 -0600
Message-ID: <47EABE2D.7080400@linux.vnet.ibm.com>
Date: Wed, 26 Mar 2008 16:20:45 -0500
From: Jon Tollefson <kniht@linux.vnet.ibm.com>
Reply-To: kniht@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: [PATCH 0/4] 16G huge page support for powerpc
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@ozlabs.org>
Cc: Andi Kleen <andi@firstfloor.org>, Paul Mackerras <paulus@samba.org>, Adam Litke <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch set builds on Andi Kleen's patches for GB pages for hugetlb
posted on March 16th.  This set adds support for 16G huge pages on
ppc64.  Supporting multiple huge page sizes on ppc64 as defined in
Andi's patches is not a part of this set; that will be included in a
future patch.

The first patch here adds an arch callback since the 16G pages are not
allocated from bootmem.  The 16G pages have to be reserved prior to
boot-time.  The location of these pages are indicated in the device tree.

Support for 16G pages requires a POWER5+ or later machine and a little
bit of memory.

Jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
