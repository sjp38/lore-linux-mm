Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 347256B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 07:56:34 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id rd14so166240260obb.3
        for <linux-mm@kvack.org>; Thu, 05 May 2016 04:56:34 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0146.outbound.protection.outlook.com. [157.56.112.146])
        by mx.google.com with ESMTPS id 197si3658075oia.13.2016.05.05.04.56.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 May 2016 04:56:33 -0700 (PDT)
Subject: Re: [PATCHv8 1/2] x86/vdso: add mremap hook to vm_special_mapping
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com>
 <1461584223-9418-1-git-send-email-dsafonov@virtuozzo.com>
 <CALCETrVJhooHkMMVY_702p88-jYRJibXi38WB+fAizAt6S3PjQ@mail.gmail.com>
 <e0a10957-ddf7-1bc4-fad6-8b5836628fce@virtuozzo.com>
 <20160505115240.GA29616@gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <70acdc9f-8980-0488-2d52-49a90c4b6a59@virtuozzo.com>
Date: Thu, 5 May 2016 14:55:12 +0300
MIME-Version: 1.0
In-Reply-To: <20160505115240.GA29616@gmail.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>

On 05/05/2016 02:52 PM, Ingo Molnar wrote:
>
> * Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>
>> On 04/26/2016 12:38 AM, Andy Lutomirski wrote:
>>> On Mon, Apr 25, 2016 at 4:37 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>>>> Add possibility for userspace 32-bit applications to move
>>>> vdso mapping. Previously, when userspace app called
>>>> mremap for vdso, in return path it would land on previous
>>>> address of vdso page, resulting in segmentation violation.
>>>> Now it lands fine and returns to userspace with remapped vdso.
>>>> This will also fix context.vdso pointer for 64-bit, which does not
>>>> affect the user of vdso after mremap by now, but this may change.
>>>>
>>>> As suggested by Andy, return EINVAL for mremap that splits vdso image.
>>>>
>>>> Renamed and moved text_mapping structure declaration inside
>>>> map_vdso, as it used only there and now it complement
>>>> vvar_mapping variable.
>>>>
>>>> There is still problem for remapping vdso in glibc applications:
>>>> linker relocates addresses for syscalls on vdso page, so
>>>> you need to relink with the new addresses. Or the next syscall
>>>> through glibc may fail:
>>>>   Program received signal SIGSEGV, Segmentation fault.
>>>>   #0  0xf7fd9b80 in __kernel_vsyscall ()
>>>>   #1  0xf7ec8238 in _exit () from /usr/lib32/libc.so.6
>>> Acked-by: Andy Lutomirski <luto@kernel.org>
>>>
>>> Ingo, can you apply this?
>>
>> Hm, so I'm not sure - should I resend those two?
>> Or just ping?
>
> Please send a clean series with updated Acked-by's, etc.


Thanks, Ingo, will do.
Sorry for html in the last email - mail agent got an
update and I overlooked html composing become turned on.

-- 
Regards,
Dmitry Safonov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
