Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j34Ho84I574944
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 13:50:08 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j34Ho7wV190884
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 11:50:07 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j34Ho7Y2008691
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 11:50:07 -0600
Subject: [PATCH 0/4] create mm/Kconfig to detangle NUMA/DISCONTIG
From: Dave Hansen <haveblue@us.ibm.com>
Content-Type: text/plain
Date: Mon, 04 Apr 2005 10:50:04 -0700
Message-Id: <1112637004.27328.24.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

The end goal of these particular patches is to allow us to get some
small bits of global mm/ code compiled for either NUMA or DISCONTIGMEM. 

Obviously, this alone doesn't justify messing with each architecture's
Kconfig file.  Think of the 4th patch as one example of how this new
file can be used.  We'll also be using it shortly for all of the page
migration and memory hotplug options.  It just starts to look silly when
you have a patch to add the exact same Kconfig option to four or five
different architectures.

Compile tested for 27 different .config configurations on 5 different
architectures.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
