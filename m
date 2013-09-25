Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6518F6B003D
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:20:14 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so307059pbc.8
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:20:14 -0700 (PDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 09:20:09 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 000A42BB0052
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:20:07 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNJumH65077500
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:19:56 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8PNK6J6014113
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:20:07 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 10/40] bitops: Document the difference in indexing
 between fls() and __fls()
Date: Thu, 26 Sep 2013 04:45:56 +0530
Message-ID: <20130925231554.26184.87472.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

fls() indexes the bits starting with 1, ie., from 1 to BITS_PER_LONG
whereas __fls() uses a zero-based indexing scheme (0 to BITS_PER_LONG - 1).
Add comments to document this important difference.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/x86/include/asm/bitops.h      |    4 ++++
 include/asm-generic/bitops/__fls.h |    5 +++++
 2 files changed, 9 insertions(+)

diff --git a/arch/x86/include/asm/bitops.h b/arch/x86/include/asm/bitops.h
index 41639ce..9186e4a 100644
--- a/arch/x86/include/asm/bitops.h
+++ b/arch/x86/include/asm/bitops.h
@@ -388,6 +388,10 @@ static inline unsigned long ffz(unsigned long word)
  * @word: The word to search
  *
  * Undefined if no set bit exists, so code should check against 0 first.
+ *
+ * Note: __fls(x) is equivalent to fls(x) - 1. That is, __fls() uses
+ * a zero-based indexing scheme (0 to BITS_PER_LONG - 1), where
+ * __fls(1) = 0, __fls(2) = 1, and so on.
  */
 static inline unsigned long __fls(unsigned long word)
 {
diff --git a/include/asm-generic/bitops/__fls.h b/include/asm-generic/bitops/__fls.h
index a60a7cc..ae908a5 100644
--- a/include/asm-generic/bitops/__fls.h
+++ b/include/asm-generic/bitops/__fls.h
@@ -8,6 +8,11 @@
  * @word: the word to search
  *
  * Undefined if no set bit exists, so code should check against 0 first.
+ *
+ * Note: __fls(x) is equivalent to fls(x) - 1. That is, __fls() uses
+ * a zero-based indexing scheme (0 to BITS_PER_LONG - 1), where
+ * __fls(1) = 0, __fls(2) = 1, and so on.
+ *
  */
 static __always_inline unsigned long __fls(unsigned long word)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
