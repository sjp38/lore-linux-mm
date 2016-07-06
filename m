Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1486F828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 10:36:35 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id l125so207455265ywb.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 07:36:35 -0700 (PDT)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id m35si1379089uam.186.2016.07.06.07.36.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 07:36:34 -0700 (PDT)
Received: by mail-vk0-x230.google.com with SMTP id t66so23147322vka.1
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 07:36:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160629105736.15017-7-dsafonov@virtuozzo.com>
References: <20160629105736.15017-1-dsafonov@virtuozzo.com> <20160629105736.15017-7-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 6 Jul 2016 07:36:14 -0700
Message-ID: <CALCETrWdkG26n=rK5C4GPs1U=Xq_f1JtdsNTaMufurpdNJzRdw@mail.gmail.com>
Subject: Re: [PATCHv2 6/6] x86/signal: add SA_{X32,IA32}_ABI sa_flags
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, xemul@virtuozzo.com, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>

On Wed, Jun 29, 2016 at 3:57 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> Introduce new flags that defines which ABI to use on creating sigframe.
> Those flags kernel will set according to sigaction syscall ABI,
> which set handler for the signal being delivered.
>
> So that will drop the dependency on TIF_IA32/TIF_X32 flags on signal deliver.
> Those flags will be used only under CONFIG_COMPAT.
>
> Similar way ARM uses sa_flags to differ in which mode deliver signal
> for 26-bit applications (look at SA_THIRYTWO).

Reviewed-by: Andy Lutomirski <luto@kernel.org>

>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Pavel Emelyanov <xemul@virtuozzo.com>
> Cc: x86@kernel.org
> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
