Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id C4F4D6B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 07:29:43 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so8082467wgy.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 04:29:43 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id a9si1746323wie.64.2015.05.06.04.29.41
        for <linux-mm@kvack.org>;
        Wed, 06 May 2015 04:29:42 -0700 (PDT)
Date: Wed, 6 May 2015 14:29:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: TLB flushes on s390
Message-ID: <20150506112939.GA17739@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org

Hi,

I'm looking though s390 code around page table handling and I found that
in many places s390 does tlb flush before changing page table entry.

Let's look for instance on pmdp_clear_flush() implementation on s390.
It's implemented with pmdp_get_and_clear() which does pmdp_flush_direct()
*before* pmd_clear(). That's invert order comparing to generic
pmdp_flush_direct().

The question is what prevents tlb from being re-fill between flushing tlb
and clearing page table entry?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
