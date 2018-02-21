Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 45F9C6B0005
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 17:24:44 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id c40so1674321uae.18
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 14:24:44 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z187sor850412vkf.284.2018.02.21.14.24.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 14:24:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <bd11826b-f3c1-be03-895c-85c08a149045@huawei.com>
References: <20180212165301.17933-1-igor.stoppa@huawei.com>
 <20180212165301.17933-6-igor.stoppa@huawei.com> <CAGXu5j+ZZkgLzsxcwAYgyu=A=11Fkeuj+F_8gCUAbXDmjWFdeg@mail.gmail.com>
 <bd11826b-f3c1-be03-895c-85c08a149045@huawei.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 21 Feb 2018 14:24:42 -0800
Message-ID: <CAGXu5j+ivd0Ys++6hqCjkipx8RFKTAmWf+KbtxEwT3SECD5C6A@mail.gmail.com>
Subject: Re: [PATCH 5/6] Pmalloc: self-test
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Tue, Feb 20, 2018 at 8:40 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>
> On 13/02/18 01:43, Kees Cook wrote:
>> On Mon, Feb 12, 2018 at 8:53 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>
> [...]
>
>>> +obj-$(CONFIG_PROTECTABLE_MEMORY_SELFTEST) += pmalloc-selftest.o
>>
>> Nit: self-test modules are traditionally named "test_$thing.o"
>> (outside of the tools/ directory).
>
> ok
>
> [...]
>
>> I wonder if lkdtm should grow a test too, to validate the RO-ness of
>> the allocations at the right time in API usage?
>
> sorry for being dense ... are you proposing that I do something to
> lkdtm_rodata.c ? An example would probably help me understand.

It would likely live in lkdtm_perms.c (or maybe lkdtm_heap.c). Namely,
use the pmalloc API and then attempt to write to a read-only variable
in the pmalloc region (to prove that the permission adjustment
actually happened). Likely a good example is
lkdtm_WRITE_RO_AFTER_INIT().

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
