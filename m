Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 35223828DF
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:52:56 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id dx6so82815638pad.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:52:56 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0099.outbound.protection.outlook.com. [104.47.2.99])
        by mx.google.com with ESMTPS id gc5si3212392pac.224.2016.04.15.02.52.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 02:52:55 -0700 (PDT)
Subject: Re: [PATCHv2] x86/vdso: add mremap hook to vm_special_mapping
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com>
 <1460651571-10545-1-git-send-email-dsafonov@virtuozzo.com>
 <CALCETrUhDvdyJV53Am2sgefyMJmHs5u1voOM2N76Si7BTtJWaQ@mail.gmail.com>
 <20160415091859.GA10167@gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <5710B9A7.6080004@virtuozzo.com>
Date: Fri, 15 Apr 2016 12:51:35 +0300
MIME-Version: 1.0
In-Reply-To: <20160415091859.GA10167@gmail.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>

On 04/15/2016 12:18 PM, Ingo Molnar wrote:
> * Andy Lutomirski <luto@amacapital.net> wrote:
>> Instead of ifdef, use the (grossly misnamed) is_ia32_task() helper for
>> this, please.
> Please also let's do the rename.
Does `is_32bit_syscall` sounds right, or shall it be `is_32bit_task`?
I think, `is_compat_task` will be bad-named for X86_32 host.

-- 
Regards,
Dmitry Safonov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
