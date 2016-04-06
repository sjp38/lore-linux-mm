Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0916B026E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:58:24 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id v188so37118860wme.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:58:24 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id i4si19063007wmd.11.2016.04.06.14.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 14:58:22 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id i204so16715352wmd.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:58:22 -0700 (PDT)
Date: Wed, 6 Apr 2016 23:58:19 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 10/10] arch: fix has_transparent_hugepage()
Message-ID: <20160406215819.GA25650@gmail.com>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051355280.5965@eggly.anvils>
 <20160406065806.GC3078@gmail.com>
 <57050111.3070507@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57050111.3070507@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Arnd Bergman <arnd@arndb.de>, Ralf Baechle <ralf@linux-mips.org>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@arm.linux.org.uk>, Will Deacon <will.deacon@arm.com>, Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org


* Chris Metcalf <cmetcalf@mellanox.com> wrote:

> On 4/6/2016 2:58 AM, Ingo Molnar wrote:
> >* Hugh Dickins <hughd@google.com> wrote:
> >
> >>--- a/arch/x86/include/asm/pgtable.h
> >>+++ b/arch/x86/include/asm/pgtable.h
> >>@@ -181,6 +181,7 @@ static inline int pmd_trans_huge(pmd_t p
> >>  	return (pmd_val(pmd) & (_PAGE_PSE|_PAGE_DEVMAP)) == _PAGE_PSE;
> >>  }
> >>+#define has_transparent_hugepage has_transparent_hugepage
> >>  static inline int has_transparent_hugepage(void)
> >>  {
> >>  	return cpu_has_pse;
> >Small nit, just writing:
> >
> >   #define has_transparent_hugepage
> >
> >ought to be enough, right?
> 
> No, since then in hugepage_init() the has_transparent_hugepage() call site
> would be left with just a stray pair of parentheses instead of a call.

Yes, indeed ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
