Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 118B26B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 04:17:12 -0400 (EDT)
Received: by wijp15 with SMTP id p15so7469585wij.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 01:17:11 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id dq1si1852054wid.88.2015.08.25.01.17.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 01:17:10 -0700 (PDT)
Date: Tue, 25 Aug 2015 10:16:33 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 3/10] x86/asm: Fix pud/pmd interfaces to handle large
 PAT bit
In-Reply-To: <1438811013-30983-4-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.11.1508251015180.15006@nanos>
References: <1438811013-30983-1-git-send-email-toshi.kani@hp.com> <1438811013-30983-4-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com

On Wed, 5 Aug 2015, Toshi Kani wrote:

> The PAT bit gets relocated to bit 12 when PUD and PMD mappings are
> used.  This bit 12, however, is not covered by PTE_FLAGS_MASK, which
> is corrently used for masking pfn and flags for all cases.
> 
> Fix pud/pmd interfaces to handle pfn and flags properly by using
> P?D_PAGE_MASK when PUD/PMD mappings are used, i.e. PSE bit is set.

Can you please split that into a patch introducing and describing the
new mask helper functions and a second one making use of it?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
