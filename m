Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id C1E8E6B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 08:28:21 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id j4so172483068uaj.2
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 05:28:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t68si3985303qkc.215.2016.09.01.05.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 05:28:20 -0700 (PDT)
Date: Thu, 1 Sep 2016 14:27:44 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCHv4 6/6] x86/signal: add SA_{X32,IA32}_ABI sa_flags
Message-ID: <20160901122744.GA7438@redhat.com>
References: <20160831135936.2281-1-dsafonov@virtuozzo.com> <20160831135936.2281-7-dsafonov@virtuozzo.com> <CAJwJo6YZEN75XB8YaMS26rbFAR0x77B-gfLKv37ib_eB_OLMBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJwJo6YZEN75XB8YaMS26rbFAR0x77B-gfLKv37ib_eB_OLMBg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <0x7f454c46@gmail.com>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, X86 ML <x86@kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>

On 08/31, Dmitry Safonov wrote:
>
> Hi Oleg,
> can I have your acks or reviewed-by tags for 4-5-6 patches in the series,
> or there is something left to fix?

Well yes... Although let me repeat, I am not sure I personally like
the very idea of 3/6 and 6/6. But as I already said I do not feel I
understand the problem space enough, so I won't argue.

However, let me ask again. Did you consider another option? Why criu
can't exec a dummy 32-bit binary before anything else?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
