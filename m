Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 82B406B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 15:42:48 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id z81so30592559oif.0
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 12:42:48 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id t15si4395406oie.31.2015.02.10.12.42.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 12:42:47 -0800 (PST)
Message-ID: <1423600952.1128.9.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 5/7] x86, mm: Support huge KVA mappings on x86
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 10 Feb 2015 13:42:32 -0700
In-Reply-To: <54DA54FA.7010707@intel.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
	 <1423521935-17454-6-git-send-email-toshi.kani@hp.com>
	 <54DA54FA.7010707@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com

On Tue, 2015-02-10 at 10:59 -0800, Dave Hansen wrote:
> On 02/09/2015 02:45 PM, Toshi Kani wrote:
> > Implement huge KVA mapping interfaces on x86.  Select
> > HAVE_ARCH_HUGE_VMAP when X86_64 or X86_32 with X86_PAE is set.
> > Without X86_PAE set, the X86_32 kernel has the 2-level page
> > tables and cannot provide the huge KVA mappings.
> 
> Not that it's a big deal, but what's the limitation with the 2-level
> page tables on 32-bit?  We have a 4MB large page size available there
> and we already use it for the kernel linear mapping.

ioremap() calls arch-neutral ioremap_page_range() to set up I/O mappings
with PTEs.  This patch-set enables ioremap_page_range() to set up PUD &
PMD mappings.  With 2-level page table, I do not think this PUD/PMD
mapping code works unless we add some special code.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
