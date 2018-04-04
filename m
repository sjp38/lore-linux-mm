Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 614706B0006
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 03:42:54 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id o33-v6so11192793plb.16
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 00:42:54 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id j5si3565886pff.178.2018.04.04.00.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 00:42:53 -0700 (PDT)
Date: Wed, 4 Apr 2018 15:42:27 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [RFC PATCH] x86/pti: pti_clone_pmds can be static
Message-ID: <20180404074227.GA20188@lkp-sb04>
References: <20180404011011.82027E0C@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180404011011.82027E0C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com


Fixes: a7e2701bf2b2 ("x86/pti: leave kernel text global for !PCID")
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 pti.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index 3ee9ceb..057c8ff 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -282,7 +282,7 @@ static void __init pti_setup_vsyscall(void)
 static void __init pti_setup_vsyscall(void) { }
 #endif
 
-void
+static void
 pti_clone_pmds(unsigned long start, unsigned long end, pmdval_t clear)
 {
 	unsigned long addr;
