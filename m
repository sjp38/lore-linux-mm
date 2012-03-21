Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 3839C6B00F1
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 02:57:10 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so872729bkw.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 23:57:09 -0700 (PDT)
Subject: [PATCH 13/16] mm/parisc: use vm_flags_t for vma flags
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 21 Mar 2012 10:57:06 +0400
Message-ID: <20120321065706.13852.68934.stgit@zurg>
In-Reply-To: <20120321065140.13852.52315.stgit@zurg>
References: <20120321065140.13852.52315.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Helge Deller <deller@gmx.de>, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, "James E.J. Bottomley" <jejb@parisc-linux.org>

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
Cc: linux-parisc@vger.kernel.org
---
 arch/parisc/mm/fault.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index 18162ce..0d3680a 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -49,7 +49,7 @@ DEFINE_PER_CPU(struct exception_data, exception_data);
  *   VM_WRITE if write operation
  *   VM_EXEC  if execute operation
  */
-static unsigned long
+static vm_flags_t
 parisc_acctyp(unsigned long code, unsigned int inst)
 {
 	if (code == 6 || code == 16)
@@ -173,7 +173,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 	struct vm_area_struct *vma, *prev_vma;
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
-	unsigned long acc_type;
+	vm_flags_t acc_type;
 	int fault;
 
 	if (in_atomic() || !mm)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
