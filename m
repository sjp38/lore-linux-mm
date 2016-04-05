Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB1E828F3
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 19:37:36 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id f198so51306487wme.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 16:37:36 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id y9si103613wje.220.2016.04.05.16.37.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 16:37:35 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id i204so8562297wmd.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 16:37:35 -0700 (PDT)
Subject: Re: [PATCH 17/31] kvm: teach kvm to map page teams as huge pages.
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051439340.5965@eggly.anvils>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <57044C3A.7060109@redhat.com>
Date: Wed, 6 Apr 2016 01:37:30 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1604051439340.5965@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org



On 05/04/2016 23:41, Hugh Dickins wrote:
> +/*
> + * We are holding kvm->mmu_lock, serializing against mmu notifiers.
> + * We have a ref on page.
> ...
> +static bool is_huge_tmpfs(struct kvm_vcpu *vcpu,
> +			  unsigned long address, struct page *page)

vcpu is only used to access vcpu->kvm->mm.  If it's still possible to
give a sensible rule for locking, I wouldn't mind if is_huge_tmpfs took
the mm directly and was moved out of KVM.  Otherwise, it would be quite
easy for people touch mm code to miss it.

Apart from this, both patches look good.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
