Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8PLwuZm005680
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 17:58:56 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8PLwu56477622
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 15:58:56 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8PLwt5C011226
	for <linux-mm@kvack.org>; Tue, 25 Sep 2007 15:58:56 -0600
Subject: Re: 2.6.23-rc8-mm1 - powerpc memory hotplug link failure
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <46F968C2.7080900@linux.vnet.ibm.com>
References: <20070925014625.3cd5f896.akpm@linux-foundation.org>
	 <46F968C2.7080900@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Tue, 25 Sep 2007 15:01:54 -0700
Message-Id: <1190757715.13955.40.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, kamezawa.hiroyu@jp.fujitsu.com, Andy Whitcroft <apw@shadowen.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-09-26 at 01:30 +0530, Kamalesh Babulal wrote:
> Hi Andrew,
> 
> The 2.6.23-rc8-mm1 kernel linking fails on the powerpc (P5+) box
> 
>   CC      init/version.o
>   LD      init/built-in.o
>   LD      .tmp_vmlinux1
> drivers/built-in.o: In function `memory_block_action':
> /root/scrap/linux-2.6.23-rc8/drivers/base/memory.c:188: undefined reference to `.remove_memory'
> make: *** [.tmp_vmlinux1] Error 1
> 

I ran into the same thing earlier. Here is the fix I made.

Thanks,
Badari

Memory hotplug remove is currently supported only on IA64

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>

Index: linux-2.6.23-rc8/mm/Kconfig
===================================================================
--- linux-2.6.23-rc8.orig/mm/Kconfig	2007-09-25 14:44:03.000000000 -0700
+++ linux-2.6.23-rc8/mm/Kconfig	2007-09-25 14:44:48.000000000 -0700
@@ -143,6 +143,7 @@ config MEMORY_HOTREMOVE
 	bool "Allow for memory hot remove"
 	depends on MEMORY_HOTPLUG
 	depends on MIGRATION
+	depends on (IA64)
 
 # Heavily threaded applications may benefit from splitting the mm-wide
 # page_table_lock, so that faults on different parts of the user address


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
