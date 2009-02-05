Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 438926B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 13:24:00 -0500 (EST)
Message-ID: <498B2EBC.60700@goop.org>
Date: Thu, 05 Feb 2009 10:23:56 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: pud_bad vs pud_bad
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: William Lee Irwin III <wli@holomorphy.com>, Ingo Molnar <mingo@elte.hu>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I'm looking at unifying the 32 and 64-bit versions of pud_bad.

32-bits defines it as:

static inline int pud_bad(pud_t pud)
{
	return (pud_val(pud) & ~(PTE_PFN_MASK | _KERNPG_TABLE | _PAGE_USER)) != 0;
}

and 64 as:

static inline int pud_bad(pud_t pud)
{
	return (pud_val(pud) & ~(PTE_PFN_MASK | _PAGE_USER)) != _KERNPG_TABLE;
}


I'm inclined to go with the 64-bit version, but I'm wondering if there's 
something subtle I'm missing here.

Thoughts?

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
