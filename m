Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id C6A126B025E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 10:05:13 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p85so37487598lfg.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 07:05:13 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id j66si4257431wma.45.2016.08.31.07.05.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 07:05:12 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id d196so3750728wmd.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 07:05:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160831135936.2281-4-dsafonov@virtuozzo.com>
References: <20160831135936.2281-1-dsafonov@virtuozzo.com> <20160831135936.2281-4-dsafonov@virtuozzo.com>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Wed, 31 Aug 2016 17:04:52 +0300
Message-ID: <CAJwJo6bh3fZXjOCZSGC4-=MHCs_2KrpGcEAibvNMZLE5_Wi=Eg@mail.gmail.com>
Subject: Re: [PATCHv4 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>
Cc: linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, X86 ML <x86@kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>

Hi Andy,
can I have your acks for 2-3 patches, or should I fix something else
in those patches?

2016-08-31 16:59 GMT+03:00 Dmitry Safonov <dsafonov@virtuozzo.com>:
> Add API to change vdso blob type with arch_prctl.
> As this is usefull only by needs of CRIU, expose
> this interface under CONFIG_CHECKPOINT_RESTORE.
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

Thanks,
             Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
