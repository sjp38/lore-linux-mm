Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id DD1F482F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 20:13:59 -0500 (EST)
Received: by iodd200 with SMTP id d200so73970155iod.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 17:13:59 -0800 (PST)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id n7si21530402igj.86.2015.11.04.17.13.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 17:13:59 -0800 (PST)
Received: by igpw7 with SMTP id w7so659015igp.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 17:13:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLdZ_xFyokoXW5ZhUdTXf-O1MBLk83cG_AM_51PxXbH5A@mail.gmail.com>
References: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
	<CAGXu5jLdZ_xFyokoXW5ZhUdTXf-O1MBLk83cG_AM_51PxXbH5A@mail.gmail.com>
Date: Wed, 4 Nov 2015 17:13:59 -0800
Message-ID: <CAGXu5jK69kytOxp1xaojsGO2JXcZ+u0iHuKWD9sis_LFaCUC9Q@mail.gmail.com>
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Nov 4, 2015 at 5:06 PM, Kees Cook <keescook@chromium.org> wrote:
> On Wed, Nov 4, 2015 at 5:00 PM, Laura Abbott <labbott@fedoraproject.org> wrote:
>> Currently, read only permissions are not being applied even
>> when CONFIG_DEBUG_RODATA is set. This is because section_update
>> uses current->mm for adjusting the page tables. current->mm
>> need not be equivalent to the kernel version. Use pgd_offset_k
>> to get the proper page directory for updating.
>>
>> Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
>> ---
>> I found this while trying to convince myself of something.
>> Dumping the page table via debugfs and writing to kernel text were both
>> showing the lack of mappings. This was observed on QEMU. Maybe it's just a
>> QEMUism but if not it probably should go to stable.
>
> Well that's weird! debugfs showed the actual permissions that lacked
> RO? I wonder what changed. I tested this both with debugfs and lkdtm's
> KERN_WRITE test when the patches originally landed.

The comment will need adjusting too. I have a memory of needing to use
current->mm to deal with some crazy errata and handling TLB flushes...

-Kees

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
