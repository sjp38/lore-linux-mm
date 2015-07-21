Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 304159003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 04:05:52 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so112637004wib.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 01:05:51 -0700 (PDT)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id cb5si17721259wib.5.2015.07.21.01.05.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 01:05:50 -0700 (PDT)
Received: by wgbcc4 with SMTP id cc4so56089309wgb.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 01:05:49 -0700 (PDT)
Date: Tue, 21 Jul 2015 10:05:44 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 0/4] x86, mm: Handle large PAT bit in pud/pmd
 interfaces
Message-ID: <20150721080544.GA28118@gmail.com>
References: <1436977435-31826-1-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436977435-31826-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com


* Toshi Kani <toshi.kani@hp.com> wrote:

> The PAT bit gets relocated to bit 12 when PUD and PMD mappings are used.
> This bit 12, however, is not covered by PTE_FLAGS_MASK, which is corrently
> used for masking pfn and flags for all cases.
> 
> Patch 1/4-2/4 make changes necessary for patch 3/4 to use P?D_PAGE_MASK.
> 
> Patch 3/4 fixes pud/pmd interfaces to handle the PAT bit when PUD and PMD
> mappings are used.
> 
> Patch 3/4 fixes /sys/kernel/debug/kernel_page_tables to show the PAT bit
> properly.
> 
> Note, the PAT bit is first enabled in 4.2-rc1 with WT mappings.

Are patches 1-3 only needed to fix /sys/kernel/debug/kernel_page_tables output, or 
are there other things fixed as well? The patches do not tell us any of that 
information ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
