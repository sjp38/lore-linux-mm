Message-ID: <423B6218.6010602@osdl.org>
Date: Fri, 18 Mar 2005 15:19:52 -0800
From: "Randy.Dunlap" <rddunlap@osdl.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] io_remap_pfn_range: add for all arch-es
References: <20050318112545.6f5f7635.rddunlap@osdl.org>	<20050318113352.0baaaf5e.rddunlap@osdl.org> <16955.23669.792362.539790@cargo.ozlabs.ibm.com>
In-Reply-To: <16955.23669.792362.539790@cargo.ozlabs.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------000408070900090309060601"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@osdl.org, davem@davemloft.net, wli@holomorphy.com, riel@redhat.com, kurt@garloff.de, Keir.Fraser@cl.cam.ac.uk, Ian.Pratt@cl.cam.ac.uk, Christian.Limpach@cl.cam.ac.uk
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000408070900090309060601
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Paul Mackerras wrote:
> 
> Just by inspection, this looks like pfn should be changed to
> paddr64 >> PAGE_SHIFT in that last line.
> 
> Paul.

Agreed, thank you.  Patch is attached.

-- 
~Randy

--------------000408070900090309060601
Content-Type: text/x-patch;
 name="ioremap_ppc_shift.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ioremap_ppc_shift.patch"


Fix asm-ppc argument, spotted by Paul Mackerras.

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 include/asm-ppc/pgtable.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -Naurp ./include/asm-ppc/pgtable.h~ioremap_ppc_shift ./include/asm-ppc/pgtable.h
--- ./include/asm-ppc/pgtable.h~ioremap_ppc_shift	2005-03-18 10:20:47.000000000 -0800
+++ ./include/asm-ppc/pgtable.h	2005-03-18 15:15:56.000000000 -0800
@@ -743,7 +743,7 @@ static inline int io_remap_pfn_range(str
 					pgprot_t prot)
 {
 	phys_addr_t paddr64 = fixup_bigphys_addr(pfn << PAGE_SHIFT, size);
-	return remap_pfn_range(vma, vaddr, pfn, size, prot);
+	return remap_pfn_range(vma, vaddr, paddr64 >> PAGE_SHIFT, size, prot);
 }
 #else
 #define io_remap_page_range(vma, vaddr, paddr, size, prot)		\

--------------000408070900090309060601--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
