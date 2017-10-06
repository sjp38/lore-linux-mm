Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB056B025E
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 02:40:07 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p46so14307134wrb.1
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 23:40:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a14sor304367wrf.13.2017.10.05.23.40.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 23:40:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <a6707959-fe38-0bf6-5281-1c60ba63bc8c@linux.vnet.ibm.com>
References: <20171006010724.186563-1-shakeelb@google.com> <a6707959-fe38-0bf6-5281-1c60ba63bc8c@linux.vnet.ibm.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 5 Oct 2017 23:40:04 -0700
Message-ID: <CALvZod6VUhGk+=vcm4EmH0Op=472BEt0kjTfvu7HNni_uiJo8A@mail.gmail.com>
Subject: Re: [PATCH] kvm, mm: account kvm related kmem slabs to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, x86@kernel.org, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Oct 5, 2017 at 9:28 PM, Anshuman Khandual
<khandual@linux.vnet.ibm.com> wrote:
> On 10/06/2017 06:37 AM, Shakeel Butt wrote:
>> The kvm slabs can consume a significant amount of system memory
>> and indeed in our production environment we have observed that
>> a lot of machines are spending significant amount of memory that
>> can not be left as system memory overhead. Also the allocations
>> from these slabs can be triggered directly by user space applications
>> which has access to kvm and thus a buggy application can leak
>> such memory. So, these caches should be accounted to kmemcg.
>
> But there may be other situations like this where user space can
> trigger allocation from various SLAB objects inside the kernel
> which are accounted as system memory. So how we draw the line
> which ones should be accounted for memcg. Just being curious.
>
Yes, there are indeed other slabs where user space can trigger
allocations. IMO selecting which kmem caches to account is kind of
workload and user specific decision. The ones I am converting are
selected based on the data gathered from our production environment.
However I think it would be useful in general.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
