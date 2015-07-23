Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC879003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 12:55:34 -0400 (EDT)
Received: by padck2 with SMTP id ck2so159957006pad.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 09:55:34 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id tk2si13405667pac.116.2015.07.23.09.55.33
        for <linux-mm@kvack.org>;
        Thu, 23 Jul 2015 09:55:33 -0700 (PDT)
Message-ID: <55B11C85.5070900@intel.com>
Date: Thu, 23 Jul 2015 09:55:33 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Flush the TLB for a single address in a huge page
References: <1437585214-22481-1-git-send-email-catalin.marinas@arm.com> <alpine.DEB.2.10.1507221436350.21468@chino.kir.corp.google.com> <CAHkRjk7=VMG63VfZdWbZqYu8FOa9M+54Mmdro661E2zt3WToog@mail.gmail.com> <55B021B1.5020409@intel.com> <20150723104938.GA27052@e104818-lin.cambridge.arm.com> <20150723141303.GB23799@redhat.com> <55B0FD14.8050501@intel.com> <20150723161644.GG27052@e104818-lin.cambridge.arm.com>
In-Reply-To: <20150723161644.GG27052@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 07/23/2015 09:16 AM, Catalin Marinas wrote:
> Anyway, if you want to keep the option of a full TLB flush for x86 on
> huge pages, I'm happy to repost a v2 with a separate
> flush_tlb_pmd_huge_page that arch code can define as it sees fit.

I think your patch is fine on x86.  We need to keep an eye out for any
regressions, but I think it's OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
