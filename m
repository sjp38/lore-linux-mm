Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [PATCH] ia64: race flushing icache in COW path
Date: Fri, 14 Jul 2006 10:11:53 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A3CC204@scsmsx411.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jason Baron <jbaron@redhat.com>, torvalds@osdl.org, akpm@osdl.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

@@ -1980,6 +1980,7 @@ static int do_swap_page(struct mm_struct
 	}
 
 	flush_icache_page(vma, page);
+	lazy_mmu_prot_update(pte);
 	set_pte_at(mm, address, page_table, pte);
 	page_add_anon_rmap(page, vma, address);
 

At first sight, this looks redundant ... but then I saw that
on ia64 "flush_icache_page()" is actually a no-op.  Perhaps
we can enter this in the next obfuscated C competition.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
