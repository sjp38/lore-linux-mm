Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1F19003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 04:12:12 -0400 (EDT)
Received: by pacan13 with SMTP id an13so10829371pac.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 01:12:12 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id dd6si18850226pdb.8.2015.07.24.01.12.06
        for <linux-mm@kvack.org>;
        Fri, 24 Jul 2015 01:12:07 -0700 (PDT)
Date: Fri, 24 Jul 2015 16:11:02 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [PATCH mmotm] kexec: arch_kexec_apply_relocations can be static
Message-ID: <20150724081102.GA239929@lkp-ib04>
References: <201507241644.XJlodOnm%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201507241644.XJlodOnm%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "dyoung@redhat.com" <dyoung@redhat.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 kexec_file.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
index caf47e9..91e9e9d 100644
--- a/kernel/kexec_file.c
+++ b/kernel/kexec_file.c
@@ -122,7 +122,7 @@ arch_kexec_apply_relocations_add(const Elf_Ehdr *ehdr, Elf_Shdr *sechdrs,
 }
 
 /* Apply relocations of type REL */
-int __weak
+static int __weak
 arch_kexec_apply_relocations(const Elf_Ehdr *ehdr, Elf_Shdr *sechdrs,
 			     unsigned int relsec)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
