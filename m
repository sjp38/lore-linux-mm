Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 982AC6B0082
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 16:08:58 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH 12/18] Additional macros for pmd operations
Date: Thu, 16 Feb 2012 15:31:39 +0100
Message-Id: <1329402705-25454-12-git-send-email-mail@smogura.eu>
In-Reply-To: <1329402705-25454-1-git-send-email-mail@smogura.eu>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

Macros for operating on pmd in simillar way like for pte.

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 arch/x86/include/asm/pgtable.h |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 49afb3f..38fd008 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -265,6 +265,11 @@ static inline pmd_t pmd_wrprotect(pmd_t pmd)
 	return pmd_clear_flags(pmd, _PAGE_RW);
 }
 
+static inline int pmd_dirty(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_DIRTY;
+}
+
 static inline pmd_t pmd_mkdirty(pmd_t pmd)
 {
 	return pmd_set_flags(pmd, _PAGE_DIRTY);
@@ -285,6 +290,11 @@ static inline pmd_t pmd_mkwrite(pmd_t pmd)
 	return pmd_set_flags(pmd, _PAGE_RW);
 }
 
+static inline pmd_t pmd_writeprotect(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_RW);
+}
+
 static inline pmd_t pmd_mknotpresent(pmd_t pmd)
 {
 	return pmd_clear_flags(pmd, _PAGE_PRESENT);
@@ -731,6 +741,17 @@ static inline int pmd_write(pmd_t pmd)
 	return pmd_flags(pmd) & _PAGE_RW;
 }
 
+#define __HAVE_ARCH_PMD_EXEC
+static inline int pmd_exec(pmd_t pmd)
+{
+	return !(pmd_flags(pmd) & _PAGE_NX);
+}
+
+static inline void pmd_mkexec(pmd_t pmd)
+{
+	pmd_clear_flags(pmd, _PAGE_NX);
+}
+
 #define __HAVE_ARCH_PMDP_GET_AND_CLEAR
 static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm, unsigned long addr,
 				       pmd_t *pmdp)
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
