Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 519A46B0035
	for <linux-mm@kvack.org>; Thu, 18 Sep 2014 23:58:13 -0400 (EDT)
Received: by mail-yk0-f181.google.com with SMTP id 9so144620ykp.26
        for <linux-mm@kvack.org>; Thu, 18 Sep 2014 20:58:13 -0700 (PDT)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id 45si443497yhf.160.2014.09.18.20.58.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Sep 2014 20:58:12 -0700 (PDT)
Received: by mail-yk0-f174.google.com with SMTP id q200so509499ykb.19
        for <linux-mm@kvack.org>; Thu, 18 Sep 2014 20:58:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140919003207.GA4296@kernel>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
	<1410976308-7683-1-git-send-email-andreslc@google.com>
	<20140918002917.GA3921@kernel>
	<20140918061326.GC30733@minantech.com>
	<20140919003207.GA4296@kernel>
Date: Thu, 18 Sep 2014 20:58:12 -0700
Message-ID: <CAJu=L5_SPcqca0sBYcCLjt4hv6RQwa+QV8Fhi6t3mxz0+X=KSA@mail.gmail.com>
Subject: Re: [PATCH v2] kvm: Faults which trigger IO release the mmap_sem
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@linux.intel.com>
Cc: Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Sep 18, 2014 at 5:32 PM, Wanpeng Li <wanpeng.li@linux.intel.com> wrote:
> On Thu, Sep 18, 2014 at 09:13:26AM +0300, Gleb Natapov wrote:
>>On Thu, Sep 18, 2014 at 08:29:17AM +0800, Wanpeng Li wrote:
>>> Hi Andres,
>>> On Wed, Sep 17, 2014 at 10:51:48AM -0700, Andres Lagar-Cavilla wrote:
>>> [...]
>>> > static inline int check_user_page_hwpoison(unsigned long addr)
>>> > {
>>> >    int rc, flags = FOLL_TOUCH | FOLL_HWPOISON | FOLL_WRITE;
> Got it, thanks for your pointing out.
>
> Reviewed-by: Wanpeng Li <wanpeng.li@linux.intel.com>
>
> Regards,
> Wanpeng Li
>
Thanks.

Paolo, should I recut including the recent Reviewed-by's?

Thanks
Andres
ps: shrunk cc

>>
>>>        kvm_get_user_page_io
>>>
>>> page will always be ready after kvm_get_user_page_io which leads to APF
>>> don't need to work any more.
>>>
>>> Regards,
>>> Wanpeng Li
>>>
>>> >    if (npages != 1)
>>> >            return npages;
>>> >
>>> >--
>>> >2.1.0.rc2.206.gedb03e5
>>> >
>>> >--
>>> >To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> >the body to majordomo@kvack.org.  For more info on Linux MM,
>>> >see: http://www.linux-mm.org/ .
>>> >Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>>--
>>                       Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
