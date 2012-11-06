Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id EAD496B0062
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 17:38:36 -0500 (EST)
Date: Tue, 6 Nov 2012 14:38:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 11/16] mm: use vm_unmapped_area() on arm architecture
Message-Id: <20121106143835.3e321da4.akpm@linux-foundation.org>
In-Reply-To: <1352155633-8648-12-git-send-email-walken@google.com>
References: <1352155633-8648-1-git-send-email-walken@google.com>
	<1352155633-8648-12-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, x86@kernel.org, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Mon,  5 Nov 2012 14:47:08 -0800
Michel Lespinasse <walken@google.com> wrote:

> Update the arm arch_get_unmapped_area[_topdown] functions to make
> use of vm_unmapped_area() instead of implementing a brute force search.

Again,

--- a/arch/arm/mm/mmap.c~mm-use-vm_unmapped_area-on-arm-architecture-fix
+++ a/arch/arm/mm/mmap.c
@@ -11,18 +11,6 @@
 #include <linux/random.h>
 #include <asm/cachetype.h>
 
-static inline unsigned long COLOUR_ALIGN_DOWN(unsigned long addr,
-					      unsigned long pgoff)
-{
-	unsigned long base = addr & ~(SHMLBA-1);
-	unsigned long off = (pgoff << PAGE_SHIFT) & (SHMLBA-1);
-
-	if (base + off <= addr)
-		return base + off;
-
-	return base - off;
-}
-
 #define COLOUR_ALIGN(addr,pgoff)		\
 	((((addr)+SHMLBA-1)&~(SHMLBA-1)) +	\
 	 (((pgoff)<<PAGE_SHIFT) & (SHMLBA-1)))
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
