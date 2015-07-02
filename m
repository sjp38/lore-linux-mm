Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8CB280244
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 17:49:47 -0400 (EDT)
Received: by qkbp125 with SMTP id p125so61609331qkb.2
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 14:49:47 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0116.outbound.protection.outlook.com. [65.55.169.116])
        by mx.google.com with ESMTPS id 145si7974704qhx.10.2015.07.02.14.49.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Jul 2015 14:49:46 -0700 (PDT)
Message-ID: <1435873760.10531.11.camel@freescale.com>
Subject: Re: [RFC PATCH 6/6] powerpc/kvm: change the condition of
 identifying hugetlb vm
From: Scott Wood <scottwood@freescale.com>
Date: Thu, 2 Jul 2015 16:49:20 -0500
In-Reply-To: <1433917639-31699-7-git-send-email-wenweitaowenwei@gmail.com>
References: <1433917639-31699-1-git-send-email-wenweitaowenwei@gmail.com>
	 <1433917639-31699-7-git-send-email-wenweitaowenwei@gmail.com>
Content-Type: text/plain; charset="UTF-8"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wenwei Tao <wenweitaowenwei@gmail.com>
Cc: izik.eidus@ravellosystems.com, aarcange@redhat.com, chrisw@sous-sol.org, hughd@google.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org

On Wed, 2015-06-10 at 14:27 +0800, Wenwei Tao wrote:
> Hugetlb VMAs are not mergeable, that means a VMA couldn't have VM_HUGETLB 
> and
> VM_MERGEABLE been set in the same time. So we use VM_HUGETLB to indicate new
> mergeable VMAs. Because of that a VMA which has VM_HUGETLB been set is a 
> hugetlb
> VMA only if it doesn't have VM_MERGEABLE been set in the same time.

Eww.

If you must overload such bit combinations, please hide it behind a 
vm_is_hugetlb() function.

-Scott

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
