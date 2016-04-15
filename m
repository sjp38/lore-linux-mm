Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 99C006B025E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 08:09:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u190so183214645pfb.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:09:19 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0139.outbound.protection.outlook.com. [157.56.112.139])
        by mx.google.com with ESMTPS id my7si3766270pab.146.2016.04.15.05.09.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 05:09:18 -0700 (PDT)
Subject: Re: [PATCHv2] x86/vdso: add mremap hook to vm_special_mapping
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com>
 <1460651571-10545-1-git-send-email-dsafonov@virtuozzo.com>
 <CALCETrUhDvdyJV53Am2sgefyMJmHs5u1voOM2N76Si7BTtJWaQ@mail.gmail.com>
 <20160415091859.GA10167@gmail.com> <5710B9A7.6080004@virtuozzo.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <5710D9AC.3040401@virtuozzo.com>
Date: Fri, 15 Apr 2016 15:08:12 +0300
MIME-Version: 1.0
In-Reply-To: <5710B9A7.6080004@virtuozzo.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>

On 04/15/2016 12:51 PM, Dmitry Safonov wrote:
> On 04/15/2016 12:18 PM, Ingo Molnar wrote:
>> * Andy Lutomirski <luto@amacapital.net> wrote:
>>> Instead of ifdef, use the (grossly misnamed) is_ia32_task() helper for
>>> this, please.
>> Please also let's do the rename.
> Does `is_32bit_syscall` sounds right, or shall it be `is_32bit_task`?
> I think, `is_compat_task` will be bad-named for X86_32 host.
>
Or maybe, better:
is_x32_task => in_x32_syscall
is_ia32_task => in_ia32_syscall
as existing in_compat_syscall().

Looks good?

-- 
Regards,
Dmitry Safonov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
