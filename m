From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 6/9] This patch exports zap_page_range as it is
	needed by XPMEM.
Date: Tue, 01 Apr 2008 13:55:37 -0700
Message-ID: <20080401205637.025425911@sgi.com>
References: <20080401205531.986291575@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline; filename=xpmem_v003_export-zap_page_range
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel@lists.sourceforge.net>
List-Help: <mailto:kvm-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: kvm-devel-bounces@lists.sourceforge.net
Errors-To: kvm-devel-bounces@lists.sourceforge.net
To: Hugh Dickins <hugh@veritas.com>
Cc: Steve Wise <swise@opengridcomputing.com>, Andrea Arcangeli <andrea@qumranet.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, general@lists.openfabrics.org, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, Dean Nelson <dcn@sgi.com>, steiner@sgi.com
List-Id: linux-mm.kvack.org

XPMEM would have used sys_madvise() except that madvise_dontneed()
returns an -EINVAL if VM_PFNMAP is set, which is always true for the pages
XPMEM imports from other partitions and is also true for uncached pages
allocated locally via the mspec allocator.  XPMEM needs zap_page_range()
functionality for these types of pages as well as 'normal' pages.

Signed-off-by: Dean Nelson <dcn@sgi.com>

---
 mm/memory.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2008-04-01 13:02:43.902651345 -0700
+++ linux-2.6/mm/memory.c	2008-04-01 13:04:43.720691616 -0700
@@ -901,6 +901,7 @@ unsigned long zap_page_range(struct vm_a
 
 	return unmap_vmas(vma, address, end, &nr_accounted, details);
 }
+EXPORT_SYMBOL_GPL(zap_page_range);
 
 /*
  * Do a quick page-table lookup for a single page.

-- 

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
