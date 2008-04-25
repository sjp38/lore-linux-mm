Received: from cpe001d60ad7267-cm001225dbafb6.cpe.net.cable.rogers.com ([99.236.100.208] helo=crashcourse.ca)
	by astoria.ccjclearline.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.68)
	(envelope-from <rpjday@crashcourse.ca>)
	id 1JpQHp-0004gZ-5V
	for linux-mm@kvack.org; Fri, 25 Apr 2008 11:56:33 -0400
Date: Fri, 25 Apr 2008 11:56:31 -0400 (EDT)
From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: a couple used but undefined CONFIG variables in MM
Message-ID: <alpine.LFD.1.10.0804251155230.13236@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> MEMORY_HOTPLUG_RESERVE
mm/page_alloc.c:151:#ifdef CONFIG_MEMORY_HOTPLUG_RESERVE
mm/page_alloc.c:154:#endif /* CONFIG_MEMORY_HOTPLUG_RESERVE */
mm/page_alloc.c:2957:#ifdef CONFIG_MEMORY_HOTPLUG_RESERVE
mm/page_alloc.c:3577:#ifdef CONFIG_MEMORY_HOTPLUG_RESERVE
mm/page_alloc.c:3580:#endif /* CONFIG_MEMORY_HOTPLUG_RESERVE */
>>>>> OUT_OF_LINE_PFN_TO_PAGE
arch/x86/configs/x86_64_defconfig:157:CONFIG_OUT_OF_LINE_PFN_TO_PAGE=y
include/asm-generic/memory_model.h:73:#ifdef CONFIG_OUT_OF_LINE_PFN_TO_PAGE
include/asm-generic/memory_model.h:81:#endif /* CONFIG_OUT_OF_LINE_PFN_TO_PAGE */
mm/page_alloc.c:4381:#ifdef CONFIG_OUT_OF_LINE_PFN_TO_PAGE
mm/page_alloc.c:4392:#endif /* CONFIG_OUT_OF_LINE_PFN_TO_PAGE */

rday
--


========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
