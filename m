Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4D26B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 18:43:26 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so7400655pdb.3
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 15:43:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i4si798222pdd.147.2015.03.24.15.43.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 15:43:25 -0700 (PDT)
Date: Tue, 24 Mar 2015 15:43:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 0/7] mtrr, mm, x86: Enhance MTRR checks for huge I/O
 mapping
Message-Id: <20150324154324.f9ca557127f7bc7aed45a86b@linux-foundation.org>
In-Reply-To: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
References: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

On Tue, 24 Mar 2015 16:08:34 -0600 Toshi Kani <toshi.kani@hp.com> wrote:

> This patchset enhances MTRR checks for the kernel huge I/O mapping,
> which was enabled by the patchset below:
>   https://lkml.org/lkml/2015/3/3/589
> 
> The following functional changes are made in patch 7/7.
>  - Allow pud_set_huge() and pmd_set_huge() to create a huge page
>    mapping to a range covered by a single MTRR entry of any memory
>    type.
>  - Log a pr_warn() message when a specified PMD map range spans more
>    than a single MTRR entry.  Drivers should make a mapping request
>    aligned to a single MTRR entry when the range is covered by MTRRs.
> 

OK, I grabbed these after barely looking at them, to get them a bit of
runtime testing.

I'll await guidance from the x86 maintainers regarding next steps?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
