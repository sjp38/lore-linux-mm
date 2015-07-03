Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id A7516280257
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 04:47:44 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so94180064wib.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 01:47:44 -0700 (PDT)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com. [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id gb6si14057026wic.42.2015.07.03.01.47.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jul 2015 01:47:43 -0700 (PDT)
Received: by wgjx7 with SMTP id x7so82498224wgj.2
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 01:47:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1435873760.10531.11.camel@freescale.com>
References: <1433917639-31699-1-git-send-email-wenweitaowenwei@gmail.com>
	<1433917639-31699-7-git-send-email-wenweitaowenwei@gmail.com>
	<1435873760.10531.11.camel@freescale.com>
Date: Fri, 3 Jul 2015 16:47:42 +0800
Message-ID: <CAD=trs9bjbeG=NF0UjFBTvL23rF8rry5myhKi_a-rFL4u=7EuQ@mail.gmail.com>
Subject: Re: [RFC PATCH 6/6] powerpc/kvm: change the condition of identifying
 hugetlb vm
From: wenwei tao <wenweitaowenwei@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Scott Wood <scottwood@freescale.com>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, aarcange@redhat.com, chrisw@sous-sol.org, Hugh Dickins <hughd@google.com>, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org

Hi Scott

Thank you for your comments.

Kernel already has that function: is_vm_hugetlb_page() , but the
original code didn't use it,
in order to keep the coding style of the original code, I didn't use it either.

For the sentence like: "vma->vm_flags & VM_HUGETLB" , hiding it behind
'is_vm_hugetlb_page()' is ok,
but the sentence like: "vma->vm_flags &
(VM_LOCKED|VM_HUGETLB|VM_PFNMAP)" appears in the patch 2/6,
is it better to hide the bit combinations behind the
is_vm_hugetlb_page() ?  In my patch I just replaced it with
"vma->vm_flags & (VM_LOCKED|VM_PFNMAP) ||  (vma->vm_flags &
(VM_HUGETLB|VM_MERGEABLE)) == VM_HUGETLB".

I am a newbie to Linux kernel, do you have any good suggestions on
this situation?

Thank you
Wenwei

2015-07-03 5:49 GMT+08:00 Scott Wood <scottwood@freescale.com>:
> On Wed, 2015-06-10 at 14:27 +0800, Wenwei Tao wrote:
>> Hugetlb VMAs are not mergeable, that means a VMA couldn't have VM_HUGETLB
>> and
>> VM_MERGEABLE been set in the same time. So we use VM_HUGETLB to indicate new
>> mergeable VMAs. Because of that a VMA which has VM_HUGETLB been set is a
>> hugetlb
>> VMA only if it doesn't have VM_MERGEABLE been set in the same time.
>
> Eww.
>
> If you must overload such bit combinations, please hide it behind a
> vm_is_hugetlb() function.
>
> -Scott
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
