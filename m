Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id D2CE06B003A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 08:42:29 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 30 Aug 2013 08:42:28 -0400
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 84D0E38C804A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 08:42:25 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7UCgPYT25690150
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 12:42:25 GMT
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7UCgN21021355
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 09:42:25 -0300
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 12/35] bitops: Document the difference in indexing
 between fls() and __fls()
Date: Fri, 30 Aug 2013 18:08:26 +0530
Message-ID: <20130830123809.24352.89088.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830123303.24352.18732.stgit@srivatsabhat.in.ibm.com>
References: <20130830123303.24352.18732.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
