Received: from westrelay03.boulder.ibm.com (westrelay03.boulder.ibm.com [9.17.195.12])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j0Q0NGaQ506090
	for <linux-mm@kvack.org>; Tue, 25 Jan 2005 19:23:16 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay03.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j0Q0NGpp308458
	for <linux-mm@kvack.org>; Tue, 25 Jan 2005 17:23:16 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j0Q0NGnx020026
	for <linux-mm@kvack.org>; Tue, 25 Jan 2005 17:23:16 -0700
Subject: [RFC][PATCH 0/5] consolidate i386 NUMA init code
From: Dave Hansen <haveblue@us.ibm.com>
Content-Type: text/plain
Date: Tue, 25 Jan 2005 16:23:05 -0800
Message-Id: <1106698985.6093.39.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The following five patches reorganize and consolidate some of the i386
NUMA/discontigmem code.  They grew out of some observations as we
produced the memory hotplug patches.

Only the first one is really necessary, as it makes the implementation
of one of the hotplug components much simpler and smaller.  2 and 3 came
from just looking at the effects on the code after 1.

4 and 5 aren't absolutely required for hotplug either, but do allow
sharing a bunch of code between the normal boot-time init and hotplug
cases.  

These are all on top of 2.6.11-rc2-mm1.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
