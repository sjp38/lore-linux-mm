Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 50DA62802C8
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 17:34:47 -0400 (EDT)
Received: by qkei195 with SMTP id i195so127152666qke.3
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 14:34:47 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0145.outbound.protection.outlook.com. [65.55.169.145])
        by mx.google.com with ESMTPS id h137si22372690qhc.38.2015.07.06.14.34.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Jul 2015 14:34:46 -0700 (PDT)
Message-ID: <1436218475.2658.14.camel@freescale.com>
Subject: Re: [RFC PATCH 6/6] powerpc/kvm: change the condition of
 identifying hugetlb vm
From: Scott Wood <scottwood@freescale.com>
Date: Mon, 6 Jul 2015 16:34:35 -0500
In-Reply-To: <CAD=trs9bjbeG=NF0UjFBTvL23rF8rry5myhKi_a-rFL4u=7EuQ@mail.gmail.com>
References: <1433917639-31699-1-git-send-email-wenweitaowenwei@gmail.com>
	 <1433917639-31699-7-git-send-email-wenweitaowenwei@gmail.com>
	 <1435873760.10531.11.camel@freescale.com>
	 <CAD=trs9bjbeG=NF0UjFBTvL23rF8rry5myhKi_a-rFL4u=7EuQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wenwei tao <wenweitaowenwei@gmail.com>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, aarcange@redhat.com, chrisw@sous-sol.org, Hugh Dickins <hughd@google.com>, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org

On Fri, 2015-07-03 at 16:47 +0800, wenwei tao wrote:
> Hi Scott
> 
> Thank you for your comments.
> 
> Kernel already has that function: is_vm_hugetlb_page() , but the
> original code didn't use it,
> in order to keep the coding style of the original code, I didn't use it 
> either.
>
> For the sentence like: "vma->vm_flags & VM_HUGETLB" , hiding it behind
> 'is_vm_hugetlb_page()' is ok,
> but the sentence like: "vma->vm_flags &
> (VM_LOCKED|VM_HUGETLB|VM_PFNMAP)" appears in the patch 2/6,
> is it better to hide the bit combinations behind the
> is_vm_hugetlb_page() ?  In my patch I just replaced it with
> "vma->vm_flags & (VM_LOCKED|VM_PFNMAP) ||  (vma->vm_flags &
> (VM_HUGETLB|VM_MERGEABLE)) == VM_HUGETLB".

If you're going to do non-obvious things with the flags, it should be done in 
one place rather than throughout the code.  Why would you do the above and 
not "vma->vm_flags & (VM_LOCKED | VM_PFNMAP) || is_vm_hugetlb_page(vma)"?

-Scott

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
