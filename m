Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D059E6B0035
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 07:18:21 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so1489310pdj.26
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 04:18:21 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id xc3si2033562pab.114.2014.07.17.04.18.20
        for <linux-mm@kvack.org>;
        Thu, 17 Jul 2014 04:18:20 -0700 (PDT)
Date: Thu, 17 Jul 2014 19:17:51 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 6807/7059] fs/proc/vmcore.c:343:5: sparse: symbol
 'remap_oldmem_pfn_checked' was not declared. Should it be static?
Message-ID: <53c7b0df.yqSb/wPd+JtR6bKk%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_53c7b0df.DuHCEbMEAif6gynJV86n/Im2j1OAqMzy3HcnRWizr6jDSH1c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

This is a multi-part message in MIME format.

--=_53c7b0df.DuHCEbMEAif6gynJV86n/Im2j1OAqMzy3HcnRWizr6jDSH1c
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   b395397b3a268e96061feca8dbed5e70f777e9a2
commit: 456979f56a5872619f70f7ab5ceaa65f1b0cc3dc [6807/7059] mmap_vmcore-skip-non-ram-pages-reported-by-hypervisors-v4
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> fs/proc/vmcore.c:343:5: sparse: symbol 'remap_oldmem_pfn_checked' was not declared. Should it be static?
>> fs/proc/vmcore.c:394:5: sparse: symbol 'vmcore_remap_oldmem_pfn' was not declared. Should it be static?

Please consider folding the attached diff :-)

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--=_53c7b0df.DuHCEbMEAif6gynJV86n/Im2j1OAqMzy3HcnRWizr6jDSH1c
Content-Type: text/x-diff;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="make-it-static-456979f56a5872619f70f7ab5ceaa65f1b0cc3dc.diff"

From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH next] remap_oldmem_pfn_checked() can be static
TO: Vitaly Kuznetsov <vkuznets@redhat.com>
CC: linux-kernel@vger.kernel.org 

CC: Vitaly Kuznetsov <vkuznets@redhat.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 vmcore.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index 405a409..566e6f0 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -340,7 +340,7 @@ static inline char *alloc_elfnotes_buf(size_t notes_sz)
  *
  * Returns zero on success, -EAGAIN on failure.
  */
-int remap_oldmem_pfn_checked(struct vm_area_struct *vma, unsigned long from,
+static int remap_oldmem_pfn_checked(struct vm_area_struct *vma, unsigned long from,
 			     unsigned long pfn, unsigned long size,
 			     pgprot_t prot)
 {
@@ -391,7 +391,7 @@ fail:
 	return -EAGAIN;
 }
 
-int vmcore_remap_oldmem_pfn(struct vm_area_struct *vma,
+static int vmcore_remap_oldmem_pfn(struct vm_area_struct *vma,
 			    unsigned long from, unsigned long pfn,
 			    unsigned long size, pgprot_t prot)
 {

--=_53c7b0df.DuHCEbMEAif6gynJV86n/Im2j1OAqMzy3HcnRWizr6jDSH1c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
