Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id B44AD6B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 15:47:50 -0400 (EDT)
Received: by qkeo142 with SMTP id o142so148007454qke.1
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 12:47:50 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0142.outbound.protection.outlook.com. [157.56.110.142])
        by mx.google.com with ESMTPS id k205si26193976qhc.52.2015.07.07.12.47.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Jul 2015 12:47:49 -0700 (PDT)
Message-ID: <1436298461.2658.39.camel@freescale.com>
Subject: Re: [RFC PATCH 6/6] powerpc/kvm: change the condition of
 identifying hugetlb vm
From: Scott Wood <scottwood@freescale.com>
Date: Tue, 7 Jul 2015 14:47:41 -0500
In-Reply-To: <CAD=trs-c0qrajh1GN3H97FNR-xhVg86MPM8AsWQLR61+2myxFw@mail.gmail.com>
References: <1433917639-31699-1-git-send-email-wenweitaowenwei@gmail.com>
	 <1433917639-31699-7-git-send-email-wenweitaowenwei@gmail.com>
	 <1435873760.10531.11.camel@freescale.com>
	 <CAD=trs9bjbeG=NF0UjFBTvL23rF8rry5myhKi_a-rFL4u=7EuQ@mail.gmail.com>
	 <1436218475.2658.14.camel@freescale.com>
	 <CAD=trs-c0qrajh1GN3H97FNR-xhVg86MPM8AsWQLR61+2myxFw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wenwei tao <wenweitaowenwei@gmail.com>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, aarcange@redhat.com, chrisw@sous-sol.org, Hugh Dickins <hughd@google.com>, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org

On Tue, 2015-07-07 at 16:05 +0800, wenwei tao wrote:
> Hi Scott
> 
> I understand what you said.
> 
> I will use the function 'is_vm_hugetlb_page()' to hide the bit
> combinations according to your comments in the next version of patch
> set.
> 
> But for the situation like below, there isn't an obvious structure
> 'vma', using 'is_vm_hugetlb_page()' maybe costly or even not possible.
> void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
>                 unsigned long end, unsigned long vmflag)
> {
>     ...
> 
>     if (end == TLB_FLUSH_ALL || tlb_flushall_shift == -1
>                     || vmflag & VM_HUGETLB) {
>         local_flush_tlb();
>         goto flush_all;
>     }
> ...
> }

Add a function that operates on the flags directly, then.

-Scott

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
