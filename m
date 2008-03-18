From: Andi Kleen <andi@firstfloor.org>
References: <20080318209.039112899@firstfloor.org>
In-Reply-To: <20080318209.039112899@firstfloor.org>
Subject: [PATCH prototype] [5/8] Add ELF constants for pbitmaps
Message-Id: <20080318010939.566791B41E1@basil.firstfloor.org>
Date: Tue, 18 Mar 2008 02:09:39 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I made up some numbers for the present bitmap phdrs and shdrs.

For serious use this would probably require an allocation somewhere.


Signed-off-by: Andi Kleen <andi@firstfloor.org>

---
 include/linux/elf.h |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux/include/linux/elf.h
===================================================================
--- linux.orig/include/linux/elf.h
+++ linux/include/linux/elf.h
@@ -49,6 +49,7 @@ typedef __s64	Elf64_Sxword;
 #define PT_GNU_EH_FRAME		0x6474e550
 
 #define PT_GNU_STACK	(PT_LOOS + 0x474e551)
+#define PT_PRESENT_BITMAP (PT_GNU_STACK + 1)
 
 /* These constants define the different elf file types */
 #define ET_NONE   0
@@ -230,6 +231,8 @@ typedef struct elf64_hdr {
 #define PF_W		0x2
 #define PF_X		0x1
 
+#define PF_PLEASE_LOAD_SHDRS		0x8 /* hack. checked on PT_GNU_STACK */
+
 typedef struct elf32_phdr{
   Elf32_Word	p_type;
   Elf32_Off	p_offset;
@@ -270,6 +273,7 @@ typedef struct elf64_phdr {
 #define SHT_HIPROC	0x7fffffff
 #define SHT_LOUSER	0x80000000
 #define SHT_HIUSER	0xffffffff
+#define SHT_PRESENT_BITMAP (SHT_LOPROC - 1000)
 
 /* sh_flags */
 #define SHF_WRITE	0x1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
