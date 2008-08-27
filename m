Message-ID: <48B5A4B0.9050308@goop.org>
Date: Wed, 27 Aug 2008 12:02:08 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Definition of x86 _PAGE_SPECIAL and sharing _PAGE_UNUSED1
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ingo Molnar <mingo@elte.hu>, Hugh Dickens <hugh@veritas.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

_PAGE_SPECIAL is overloading _PAGE_UNUSED1.  Does it really leave
_PAGE_UNUSED1 available for other uses, or does it become an exclusive
user of that flag.  Under what circumstances can they be shared?

arch/x86/mm/pageattr-test.c is now using _PAGE_UNUSED1 as the flag used
to make sure that huge pages are shattered properly (previously it used
_PAGE_GLOBAL).  Is that going to clash with _PAGE_SPECIAL?

In other words, should we drop _PAGE_UNUSED1 altogether, or at least
define how the its different users can coexist?

Am I right in supposing that _PAGE_SPECIAL can only be set on user pages?

(Also, "SPECIAL" is awfully generic.  Was there really no more
descriptive name for this?)

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
