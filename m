Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 369AF6B025E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 10:07:36 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d196so18360259wmd.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 07:07:36 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id ib1si49678wjb.248.2016.08.31.07.07.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 07:07:35 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id d196so3759920wmd.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 07:07:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160831135936.2281-7-dsafonov@virtuozzo.com>
References: <20160831135936.2281-1-dsafonov@virtuozzo.com> <20160831135936.2281-7-dsafonov@virtuozzo.com>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Wed, 31 Aug 2016 17:07:14 +0300
Message-ID: <CAJwJo6YZEN75XB8YaMS26rbFAR0x77B-gfLKv37ib_eB_OLMBg@mail.gmail.com>
Subject: Re: [PATCHv4 6/6] x86/signal: add SA_{X32,IA32}_ABI sa_flags
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>, Oleg Nesterov <oleg@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, X86 ML <x86@kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>

Hi Oleg,
can I have your acks or reviewed-by tags for 4-5-6 patches in the series,
or there is something left to fix?

2016-08-31 16:59 GMT+03:00 Dmitry Safonov <dsafonov@virtuozzo.com>:
> Introduce new flags that defines which ABI to use on creating sigframe.
> Those flags kernel will set according to sigaction syscall ABI,
> which set handler for the signal being delivered.
>
> So that will drop the dependency on TIF_IA32/TIF_X32 flags on signal deliver.
> Those flags will be used only under CONFIG_COMPAT.
>
> Similar way ARM uses sa_flags to differ in which mode deliver signal
> for 26-bit applications (look at SA_THIRYTWO).
>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: x86@kernel.org
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Pavel Emelyanov <xemul@virtuozzo.com>
> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
> Reviewed-by: Andy Lutomirski <luto@kernel.org>

Thanks,
             Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
