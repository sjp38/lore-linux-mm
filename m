Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1F69A6B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 04:22:02 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id n6so164742971qtn.2
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 01:22:02 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10091.outbound.protection.outlook.com. [40.107.1.91])
        by mx.google.com with ESMTPS id x20si4465172pal.165.2016.09.01.01.22.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 01 Sep 2016 01:22:00 -0700 (PDT)
Subject: Re: [PATCHv4 0/6] x86: 32-bit compatible C/R on x86_64
References: <20160831135936.2281-1-dsafonov@virtuozzo.com>
 <20160901061846.GA22552@gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <e729f38a-e7d0-3bec-03bf-ddff9d9719fe@virtuozzo.com>
Date: Thu, 1 Sep 2016 11:19:49 +0300
MIME-Version: 1.0
In-Reply-To: <20160901061846.GA22552@gmail.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, tglx@linutronix.de, hpa@zytor.com, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, gorcunov@openvz.org, xemul@virtuozzo.com

On 09/01/2016 09:18 AM, Ingo Molnar wrote:
>
> * Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>
>> Changes from v3:
>> - proper ifdefs around vdso_image_32
>> - missed Reviewed-by tag
>
>>  arch/x86/entry/vdso/vma.c         | 81 +++++++++++++++++++++++++++------------
>>  arch/x86/ia32/ia32_signal.c       |  2 +-
>>  arch/x86/include/asm/compat.h     |  8 ++--
>>  arch/x86/include/asm/fpu/signal.h |  6 +++
>>  arch/x86/include/asm/signal.h     |  4 ++
>>  arch/x86/include/asm/vdso.h       |  2 +
>>  arch/x86/include/uapi/asm/prctl.h |  6 +++
>>  arch/x86/kernel/process_64.c      | 25 ++++++++++++
>>  arch/x86/kernel/ptrace.c          |  2 +-
>>  arch/x86/kernel/signal.c          | 20 +++++-----
>>  arch/x86/kernel/signal_compat.c   | 34 ++++++++++++++--
>>  fs/binfmt_elf.c                   | 23 ++++-------
>>  kernel/signal.c                   |  7 ++++
>>  13 files changed, 162 insertions(+), 58 deletions(-)
>
> Ok, this series looks good to me - does anyone have any objections?

Thanks, Ingo!

There is a nitpick from Andy about checking both vm_ops and
vm_private_data to avoid (unlikely) confusion with some other VMA
in map_vdso_once().
I'll fix that for the next version, which will be ready to be applied,
if no one has any other objections.

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
