Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id BC1B16B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 13:59:08 -0500 (EST)
Received: by pdjy10 with SMTP id y10so10293687pdj.13
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 10:59:08 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qs6si27690315pbc.100.2015.02.10.10.59.07
        for <linux-mm@kvack.org>;
        Tue, 10 Feb 2015 10:59:08 -0800 (PST)
Message-ID: <54DA54FA.7010707@intel.com>
Date: Tue, 10 Feb 2015 10:59:06 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/7] x86, mm: Support huge KVA mappings on x86
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com> <1423521935-17454-6-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1423521935-17454-6-git-send-email-toshi.kani@hp.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com

On 02/09/2015 02:45 PM, Toshi Kani wrote:
> Implement huge KVA mapping interfaces on x86.  Select
> HAVE_ARCH_HUGE_VMAP when X86_64 or X86_32 with X86_PAE is set.
> Without X86_PAE set, the X86_32 kernel has the 2-level page
> tables and cannot provide the huge KVA mappings.

Not that it's a big deal, but what's the limitation with the 2-level
page tables on 32-bit?  We have a 4MB large page size available there
and we already use it for the kernel linear mapping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
