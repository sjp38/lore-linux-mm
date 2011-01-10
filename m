Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 90BC36B0087
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 13:04:35 -0500 (EST)
Date: Mon, 10 Jan 2011 19:04:25 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH -mm] fix powerpc/sparc build
Message-ID: <20110110180425.GK9506@random.random>
References: <201101070014.p070Egpo023959@imap1.linux-foundation.org>
 <20110108104208.ca085298.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110108104208.ca085298.sfr@canb.auug.org.au>
Sender: owner-linux-mm@kvack.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This would become
thp-add-pmd-mangling-generic-functions-fix-pgtableh-build-for-um-2.patch

=====
Subject: thp: build fix for pmdp_get_and_clear

From: Andrea Arcangeli <aarcange@redhat.com>

__pmd should return a valid pmd_t for every arch.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---


diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -93,7 +93,7 @@ static inline pmd_t pmdp_get_and_clear(s
 				       pmd_t *pmdp)
 {
 	BUG();
-	return (pmd_t){ 0 };
+	return __pmd(0);
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
