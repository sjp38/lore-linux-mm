Received: from fujitsu2.fujitsu.com (localhost [127.0.0.1])
	by fujitsu2.fujitsu.com (8.12.10/8.12.9) with ESMTP id i7GMwZrH022741
	for <linux-mm@kvack.org>; Mon, 16 Aug 2004 15:58:37 -0700 (PDT)
Date: Mon, 16 Aug 2004 15:58:19 -0700
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: Fw: [Lhms-devel] Making hotremovable attribute with memory section[4/4]
Message-Id: <20040816155335.E6FF.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mbligh@aracnet.com
List-ID: <linux-mm.kvack.org>

Forwarded by Yasunori Goto <ygoto@us.fujitsu.com>
----------------------- Original Message -----------------------
 From:    Yasunori Goto <ygoto@us.fujitsu.com>
 To:      lhms-devel@lists.sourceforge.net
 Date:    Mon, 16 Aug 2004 14:37:34 -0700
 Subject: [Lhms-devel] Making hotremovable attribute with memory section[4/4]
----

This is just for test removable/un-removable section.

Note:
  hot-removable or un-removable attribute will be arch/platform
  dependent.
  

---

 hotremovable-goto/mm/nonlinear.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletion(-)

diff -puN mm/nonlinear.c~test_sec_removable mm/nonlinear.c
--- hotremovable/mm/nonlinear.c~test_sec_removable	Fri Aug 13 16:24:52 2004
+++ hotremovable-goto/mm/nonlinear.c	Fri Aug 13 16:24:52 2004
@@ -41,11 +41,14 @@ setup_memsections(void)
 	for (index = 0; index < NR_SECTIONS; index++) {
 		mem_section[index].phys_section = INVALID_SECTION;
 		mem_section[index].mem_map = NULL;
+		mem_section[index].flags = 0;
 	}
 	for (index = 0; index < NR_PHYS_SECTIONS; index++)
 		phys_section[index] = INVALID_PHYS_SECTION;
 }
 
+extern unsigned int highmem_start_page;
+
 void
 alloc_memsections(unsigned long start_pfn,
 		  unsigned long start_phys_pfn,
@@ -64,7 +67,10 @@ alloc_memsections(unsigned long start_pf
 	physid = pfn_to_section(start_phys_pfn);
 	for (; index < limit; index++, physid++) {
 		mem_section[index].phys_section = physid;
-		printk("set mem_section[%d].phys_section: %d\n", index, mem_section[index].phys_section);
+		if (section_to_pfn(index) > highmem_start_page)
+			mem_section[index].flags = SECTION_REMOVABLE;
+
+		printk("set mem_section[%d].phys_section: %d :flags=%02x\n", index, mem_section[index].phys_section);
 	}
 
 	index = pfn_to_section(start_phys_pfn);
_

-- 
Yasunori Goto <ygoto at us.fujitsu.com>




-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
Lhms-devel mailing list
Lhms-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/lhms-devel

--------------------- Original Message Ends --------------------

-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
