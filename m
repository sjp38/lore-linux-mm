Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6D95C6B0055
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 09:08:10 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: m32r: define pgprot_noncached
Date: Tue, 23 Jun 2009 15:07:11 +0200
References: <20090614132845.17543.11882.sendpatchset@rx1.opensource.se> <20090622151537.2f8009f7.akpm@linux-foundation.org> <200906231441.37158.arnd@arndb.de>
In-Reply-To: <200906231441.37158.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200906231507.11817.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Hirokazu Takata <takata@linux-m32r.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>, magnus.damm@gmail.com, linux-mm@kvack.org, jayakumar.lkml@gmail.com, Jesper Nilsson <jesper.nilsson@axis.com>, Chris Zankel <chris@zankel.net>, linux-m32r@ml.linux-m32r.org
List-ID: <linux-mm.kvack.org>

On m32r, pgprot_noncached is an inline function and not a macro,
which means that various bits of code that check its presence
with #ifdef never get to call it.
In particular, the asm-generic version of that macro would
override it.

This adds a self-referencing macro like other architectures do
it to make the checks work correctly.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

--- a/arch/m32r/include/asm/pgtable.h
+++ b/arch/m32r/include/asm/pgtable.h
@@ -281,6 +281,7 @@ static inline pgprot_t pgprot_noncached(pgprot_t _prot)
 	return __pgprot(prot);
 }
 
+#define pgprot_noncached(prot) pgprot_noncached(prot)
 #define pgprot_writecombine(prot) pgprot_noncached(prot)
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
