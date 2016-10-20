Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id E94E56B0038
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 07:01:17 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id i187so1873303lfe.4
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 04:01:17 -0700 (PDT)
Received: from mail-lf0-x22a.google.com (mail-lf0-x22a.google.com. [2a00:1450:4010:c07::22a])
        by mx.google.com with ESMTPS id h68si218322lfi.343.2016.10.20.04.01.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 04:01:16 -0700 (PDT)
Received: by mail-lf0-x22a.google.com with SMTP id b75so76067503lfg.3
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 04:01:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1610201117380.5073@nanos>
References: <alpine.LRH.2.02.1610191311010.24555@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1610191329500.29288@file01.intranet.prod.int.rdu2.redhat.com>
 <CAJwJo6Z8ZWPqNfT6t-i8GW1MKxQrKDUagQqnZ+0+697=MyVeGg@mail.gmail.com> <alpine.DEB.2.20.1610201117380.5073@nanos>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Thu, 20 Oct 2016 14:00:51 +0300
Message-ID: <CAJwJo6YAgYqtdrPH+Gk5jEse_hSLme8_YwSp7U-CdEWfMZe5eQ@mail.gmail.com>
Subject: Re: x32 is broken in 4.9-rc1 due to "x86/signal: Add
 SA_{X32,IA32}_ABI sa_flags"
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>, open list <linux-kernel@vger.kernel.org>

2016-10-20 12:24 GMT+03:00 Thomas Gleixner <tglx@linutronix.de>:
> On Thu, 20 Oct 2016, Dmitry Safonov wrote:
>> could you give attached patch a shot?
>
> Can you please stop sending attached patches? It's a pain to look at them
> and it makes it hard to reply inline.

Sure, I've planned to resend it after get tested-by or when I test
on x32 by myself. Sorry about attaching and changelog.

> I applied it and rewrote the changelog because the one liner you slapped
> into it is more than useless. Ditto for the completely misleading subject
> line. Please be more careful with that.

Thanks, Thomas!

-- 
             Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
