Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j7CElBUB005335
	for <linux-mm@kvack.org>; Fri, 12 Aug 2005 10:47:11 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j7CElBZv145280
	for <linux-mm@kvack.org>; Fri, 12 Aug 2005 10:47:11 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j7CElA9Y008435
	for <linux-mm@kvack.org>; Fri, 12 Aug 2005 10:47:10 -0400
Subject: [RFC][PATCH 00/12] memory hotplug
From: Dave Hansen <haveblue@us.ibm.com>
Content-Type: text/plain
Date: Fri, 12 Aug 2005 07:47:06 -0700
Message-Id: <1123858026.30202.5.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

The following patches are apply to 2.6.13-rc6, or to 2.6.13-rc5-mm1 (if
you back out the existing sparsemem-extreme.patch and apply the stuff I
posted yesterday).  Barring any serious objections, I think they're just
about ready for a run in -mm.

The following series implements memory hot-add for ppc64 and i386.
There are x86_64 and ia64 implementations that will be submitted shortly
as well.

There are some debugging patches that I use on i386 to do "fake"
hotplug, so I can share those if anybody wants to just play around with
it.

BTW, thanks to everybody who has sent code in and contributed little
bits and pieces to this.  Too numerous to name, but there were certainly
a lot more people than just me.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
