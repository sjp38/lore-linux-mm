Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2A4FF6B00D0
	for <linux-mm@kvack.org>; Mon,  5 May 2014 19:31:26 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so3189314pdj.8
        for <linux-mm@kvack.org>; Mon, 05 May 2014 16:31:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id xx4si10053465pac.314.2014.05.05.16.31.24
        for <linux-mm@kvack.org>;
        Mon, 05 May 2014 16:31:24 -0700 (PDT)
Date: Mon, 5 May 2014 16:31:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] mm: pgtable -- Require X86_64 for soft-dirty
 tracker
Message-Id: <20140505163123.65e6f8853cdf0646f26bd5b4@linux-foundation.org>
In-Reply-To: <20140425082042.848656782@openvz.org>
References: <20140425081030.185969086@openvz.org>
	<20140425082042.848656782@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, mgorman@suse.de, hpa@zytor.com, mingo@kernel.org, steven@uplinklabs.net, riel@redhat.com, david.vrabel@citrix.com, peterz@infradead.org, xemul@parallels.com

On Fri, 25 Apr 2014 12:10:32 +0400 Cyrill Gorcunov <gorcunov@openvz.org> wrote:

> Tracking dirty status on 2 level pages requires very ugly macros
> and taking into account how old the machines who can operate
> without PAE mode only are, lets drop soft dirty tracker from
> them for code simplicity (note I can't drop all the macros
> from 2 level pages by now since _PAGE_BIT_PROTNONE and
> _PAGE_BIT_FILE are still used even without tracker).
> 
> Linus proposed to completely rip off softdirty support on
> x86-32 (even with PAE) and since for CRIU we're not planning
> to support native x86-32 mode, lets do that.
> 
> (Softdirty tracker is relatively new feature which mostly used
>  by CRIU so I don't expect if such API change would cause problems
>  on userspace).

i386 allnoconfig:

In file included from /usr/src/25/arch/x86/include/asm/pgtable.h:886,
                 from include/linux/mm.h:51,
                 from include/linux/suspend.h:8,
                 from arch/x86/kernel/asm-offsets.c:12:
include/asm-generic/pgtable.h:414: error: redefinition of 'pte_soft_dirty'
/usr/src/25/arch/x86/include/asm/pgtable.h:300: note: previous definition of 'pte_soft_dirty' was here
include/asm-generic/pgtable.h:419: error: redefinition of 'pmd_soft_dirty'
/usr/src/25/arch/x86/include/asm/pgtable.h:305: note: previous definition of 'pmd_soft_dirty' was here
include/asm-generic/pgtable.h:424: error: redefinition of 'pte_mksoft_dirty'
/usr/src/25/arch/x86/include/asm/pgtable.h:310: note: previous definition of 'pte_mksoft_dirty' was here
include/asm-generic/pgtable.h:429: error: redefinition of 'pmd_mksoft_dirty'
/usr/src/25/arch/x86/include/asm/pgtable.h:315: note: previous definition of 'pmd_mksoft_dirty' was here
include/asm-generic/pgtable.h:434: error: redefinition of 'pte_swp_mksoft_dirty'
/usr/src/25/arch/x86/include/asm/pgtable.h:868: note: previous definition of 'pte_swp_mksoft_dirty' was here
include/asm-generic/pgtable.h:439: error: redefinition of 'pte_swp_soft_dirty'
/usr/src/25/arch/x86/include/asm/pgtable.h:874: note: previous definition of 'pte_swp_soft_dirty' was here
include/asm-generic/pgtable.h:444: error: redefinition of 'pte_swp_clear_soft_dirty'
/usr/src/25/arch/x86/include/asm/pgtable.h:880: note: previous definition of 'pte_swp_clear_soft_dirty' was here
include/asm-generic/pgtable.h:449: error: redefinition of 'pte_file_clear_soft_dirty'
/usr/src/25/arch/x86/include/asm/pgtable.h:320: note: previous definition of 'pte_file_clear_soft_dirty' was here
include/asm-generic/pgtable.h:454: error: redefinition of 'pte_file_mksoft_dirty'
/usr/src/25/arch/x86/include/asm/pgtable.h:325: note: previous definition of 'pte_file_mksoft_dirty' was here
include/asm-generic/pgtable.h:459: error: redefinition of 'pte_file_soft_dirty'
/usr/src/25/arch/x86/include/asm/pgtable.h:330: note: previous definition of 'pte_file_soft_dirty' was here

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
