Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 3F2CB6B0044
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 17:50:19 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 03:16:20 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id DBC6F125804F
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:21:37 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39Lo8dC57475320
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:20:08 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39LoAkF000460
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:50:11 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 08/15] bitops: Document the difference in indexing
 between fls() and __fls()
Date: Wed, 10 Apr 2013 03:17:38 +0530
Message-ID: <20130409214735.4500.29838.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

fls() indexes the bits starting with 1, ie., from 1 to BITS_PER_LONG
whereas __fls() uses a zero-based indexing scheme (0 to BITS_PER_LONG - 1).
Add comments to document this important difference.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/x86/include/asm/bitops.h      |    4 ++++
 include/asm-generic/bitops/__fls.h |    5 +++++
 2 files changed, 9 insertions(+)

diff --git a/arch/x86/include/asm/bitops.h b/arch/x86/include/asm/bitops.h
index 6dfd019..25e6fdc 100644
--- a/arch/x86/include/asm/bitops.h
+++ b/arch/x86/include/asm/bitops.h
@@ -380,6 +380,10 @@ static inline unsigned long ffz(unsigned long word)
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
