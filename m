Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCD6830C9
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 13:18:49 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so138137107pab.1
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 10:18:49 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0136.outbound.protection.outlook.com. [104.47.0.136])
        by mx.google.com with ESMTPS id t12si22116937pfj.221.2016.08.26.10.18.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Aug 2016 10:18:48 -0700 (PDT)
Subject: Re: [PATCHv3 6/6] x86/signal: add SA_{X32,IA32}_ABI sa_flags
References: <20160826171317.3944-1-dsafonov@virtuozzo.com>
 <20160826171317.3944-7-dsafonov@virtuozzo.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <8ae805a7-69c0-811f-0b16-8f1130ecbc10@virtuozzo.com>
Date: Fri, 26 Aug 2016 20:16:33 +0300
MIME-Version: 1.0
In-Reply-To: <20160826171317.3944-7-dsafonov@virtuozzo.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, luto@kernel.org, oleg@redhat.com, tglx@linutronix.de, hpa@zytor.com, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, gorcunov@openvz.org, xemul@virtuozzo.com

On 08/26/2016 08:13 PM, Dmitry Safonov wrote:
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

Oh, accidentally missed this on patches preparation, excuses:
Reviewed-by: Andy Lutomirski <luto@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
