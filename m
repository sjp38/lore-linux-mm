From: Andi Kleen <andi@firstfloor.org>
References: <20080318209.039112899@firstfloor.org>
In-Reply-To: <20080318209.039112899@firstfloor.org>
Subject: [PATCH prototype] [1/8] Give ELF shdr types a name
Message-Id: <20080318010935.4467B1B41E1@basil.firstfloor.org>
Date: Tue, 18 Mar 2008 02:09:35 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The pbitmap code is the first code in Linux to know
about ELF shdrs. They were already in the include files, but
not given a suitable type name. Fix that.

Signed-off-by: Andi Kleen <andi@firstfloor.org>

---
 include/linux/elf.h |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: linux/include/linux/elf.h
===================================================================
--- linux.orig/include/linux/elf.h
+++ linux/include/linux/elf.h
@@ -286,7 +286,7 @@ typedef struct elf64_phdr {
 #define SHN_COMMON	0xfff2
 #define SHN_HIRESERVE	0xffff
  
-typedef struct {
+typedef struct elf32_shdr {
   Elf32_Word	sh_name;
   Elf32_Word	sh_type;
   Elf32_Word	sh_flags;
@@ -382,6 +382,7 @@ extern Elf32_Dyn _DYNAMIC [];
 #define elf_phdr	elf32_phdr
 #define elf_note	elf32_note
 #define elf_addr_t	Elf32_Off
+#define elf_shdr	elf32_shdr
 
 #else
 
@@ -390,6 +391,7 @@ extern Elf64_Dyn _DYNAMIC [];
 #define elf_phdr	elf64_phdr
 #define elf_note	elf64_note
 #define elf_addr_t	Elf64_Off
+#define elf_shdr	elf64_shdr
 
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
