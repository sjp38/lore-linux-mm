Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B43CE6B027A
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 14:06:53 -0500 (EST)
Received: by pabur14 with SMTP id ur14so108617960pab.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 11:06:53 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id la15si11637192pab.205.2015.12.14.11.06.34
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 11:06:34 -0800 (PST)
Subject: [PATCH 32/32] x86, pkeys: Documentation
From: Dave Hansen <dave@sr71.net>
Date: Mon, 14 Dec 2015 11:06:34 -0800
References: <20151214190542.39C4886D@viggo.jf.intel.com>
In-Reply-To: <20151214190542.39C4886D@viggo.jf.intel.com>
Message-Id: <20151214190634.426BEE41@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>


Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/Documentation/x86/protection-keys.txt |   27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff -puN /dev/null Documentation/x86/protection-keys.txt
--- /dev/null	2015-12-10 15:28:13.322405854 -0800
+++ b/Documentation/x86/protection-keys.txt	2015-12-14 10:43:30.185926457 -0800
@@ -0,0 +1,27 @@
+Memory Protection Keys for Userspace (PKU aka PKEYs) is a CPU feature
+which will be found on future Intel CPUs.
+
+Memory Protection Keys provides a mechanism for enforcing page-based
+protections, but without requiring modification of the page tables
+when an application changes protection domains.  It works by
+dedicating 4 previously ignored bits in each page table entry to a
+"protection key", giving 16 possible keys.
+
+There is also a new user-accessible register (PKRU) with two separate
+bits (Access Disable and Write Disable) for each key.  Being a CPU
+register, PKRU is inherently thread-local, potentially giving each
+thread a different set of protections from every other thread.
+
+There are two new instructions (RDPKRU/WRPKRU) for reading and writing
+to the new register.  The feature is only available in 64-bit mode,
+even though there is theoretically space in the PAE PTEs.  These
+permissions are enforced on data access only and have no effect on
+instruction fetches.
+
+=========================== Config Option ===========================
+
+This config option adds approximately 1.5kb of text. and 50 bytes of
+data to the executable.  A workload which does large O_DIRECT reads
+of holes in XFS files was run to exercise get_user_pages_fast().  No
+performance delta was observed with the config option
+enabled or disabled.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
