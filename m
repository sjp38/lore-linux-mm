Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id D00A36B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 12:56:30 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hb4so139357708pac.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:56:30 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0112.outbound.protection.outlook.com. [157.56.112.112])
        by mx.google.com with ESMTPS id hs10si4087105pad.75.2016.04.15.09.56.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 09:56:29 -0700 (PDT)
Subject: Re: [PATCHv3 2/2] x86: rename is_{ia32,x32}_task to
 in_{ia32,x32}_syscall
References: <1460388169-13340-1-git-send-email-dsafonov@virtuozzo.com>
 <1460726412-1724-1-git-send-email-dsafonov@virtuozzo.com>
 <1460726412-1724-2-git-send-email-dsafonov@virtuozzo.com>
 <CALCETrWsF9ODLog3inw149MQSHo+z2XqhwvHvnQJt+BREJdPfw@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <57111CFA.7050400@virtuozzo.com>
Date: Fri, 15 Apr 2016 19:55:22 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrWsF9ODLog3inw149MQSHo+z2XqhwvHvnQJt+BREJdPfw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>

On 04/15/2016 07:52 PM, Andy Lutomirski wrote:
> Acked-by: Andy Lutomirski <luto@kernel.org>
>
> But if you resubmit, please consider making this patch 1 so Ingo can
> apply it directly.
I resubmitted it already :-[
https://lkml.org/lkml/2016/4/15/431

If there will be v5 version, I'll submit this first.
Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
