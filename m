Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 34ED46B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 06:28:03 -0500 (EST)
Received: by wmvv187 with SMTP id v187so22267485wmv.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 03:28:02 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id hh4si10714515wjc.172.2015.12.03.03.28.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 03:28:02 -0800 (PST)
Received: by wmec201 with SMTP id c201so17844577wme.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 03:28:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu9oboT_Lk8heJWRcM=oxRW=EWioVCvZLH7N0YCkfU5tJw@mail.gmail.com>
References: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
 <1448886507-3216-2-git-send-email-ard.biesheuvel@linaro.org> <CAKv+Gu9oboT_Lk8heJWRcM=oxRW=EWioVCvZLH7N0YCkfU5tJw@mail.gmail.com>
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Date: Thu, 3 Dec 2015 17:27:42 +0600
Message-ID: <CANCZXo7rdYooBq3NV5xo8u+EpbbPjGDq3oTv=Yy0U9SDAReB9g@mail.gmail.com>
Subject: Re: [PATCH v4 01/13] mm/memblock: add MEMBLOCK_NOMAP attribute to
 memblock memory table
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ryan Harkin <ryan.harkin@linaro.org>, Grant Likely <grant.likely@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Leif Lindholm <leif.lindholm@linaro.org>

Hello Ard,

On Thu, Dec 3, 2015 at 4:55 PM, Ard Biesheuvel
<ard.biesheuvel@linaro.org> wrote:
> On 30 November 2015 at 13:28, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>> This introduces the MEMBLOCK_NOMAP attribute and the required plumbing
>> to make it usable as an indicator that some parts of normal memory
>> should not be covered by the kernel direct mapping. It is up to the
>> arch to actually honor the attribute when laying out this mapping,
>> but the memblock code itself is modified to disregard these regions
>> for allocations and other general use.
>>....
> May I kindly ask team-mm/Andrew/Alexander to chime in here, and
> indicate whether you are ok with this patch going in for 4.5? If so,
> could you please provide your ack so the patch can be kept together
> with the rest of the series, which depends on it?
>
> I should note that this change should not affect any memblock users
> that never set the MEMBLOCK_NOMAP flag, but please, if you see any
> issues beyond 'this may conflict with other stuff we have queued for
> 4.5', please do let me know.

Just tested the kernel with this patch with qemu and real hardware and it
works, nothing does not brake for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
