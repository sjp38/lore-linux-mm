Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.10/8.12.9) with ESMTP id iA50eosZ599198
	for <linux-mm@kvack.org>; Thu, 4 Nov 2004 19:40:54 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iA50eoG2288012
	for <linux-mm@kvack.org>; Thu, 4 Nov 2004 19:40:50 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iA50eoQP027700
	for <linux-mm@kvack.org>; Thu, 4 Nov 2004 19:40:50 -0500
Subject: Re: fix iounmap and a pageattr memleak (x86 and x86-64)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1099612923.1022.10.camel@localhost>
References: <4187FA6D.3070604@us.ibm.com>
	 <20041102220720.GV3571@dualathlon.random> <41880E0A.3000805@us.ibm.com>
	 <4188118A.5050300@us.ibm.com> <20041103013511.GC3571@dualathlon.random>
	 <418837D1.402@us.ibm.com> <20041103022606.GI3571@dualathlon.random>
	 <418846E9.1060906@us.ibm.com>  <20041103030558.GK3571@dualathlon.random>
	 <1099612923.1022.10.camel@localhost>
Content-Type: multipart/mixed; boundary="=-qpSuqkGakgG19YBwJKiG"
Message-Id: <1099615248.5819.0.camel@localhost>
Mime-Version: 1.0
Date: Thu, 04 Nov 2004 16:40:48 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@novell.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

--=-qpSuqkGakgG19YBwJKiG
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I attached the wrong patch.

Here's what I meant to send.

-- Dave

--=-qpSuqkGakgG19YBwJKiG
Content-Disposition: attachment; filename=Z0-leaks_only_on_negative.patch
Content-Type: text/x-patch; name=Z0-leaks_only_on_negative.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit



---

 memhotplug1-dave/arch/i386/mm/pageattr.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/i386/mm/pageattr.c~Z0-leaks_only_on_negative arch/i386/mm/pageattr.c
--- memhotplug1/arch/i386/mm/pageattr.c~Z0-leaks_only_on_negative	2004-11-04 15:57:28.000000000 -0800
+++ memhotplug1-dave/arch/i386/mm/pageattr.c	2004-11-04 15:58:50.000000000 -0800
@@ -135,7 +135,7 @@ __change_page_attr(struct page *page, pg
 		BUG();
 
 	/* memleak and potential failed 2M page regeneration */
-	BUG_ON(!page_count(kpte_page));
+	BUG_ON(page_count(kpte_page) < 0);
 
 	if (cpu_has_pse && (page_count(kpte_page) == 1)) {
 		list_add(&kpte_page->lru, &df_list);
_

--=-qpSuqkGakgG19YBwJKiG--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
