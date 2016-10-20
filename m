Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F57C6B0038
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 05:26:31 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id n3so27354348lfn.5
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 02:26:31 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id br5si60219333wjb.189.2016.10.20.02.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 02:26:30 -0700 (PDT)
Date: Thu, 20 Oct 2016 11:24:02 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: x32 is broken in 4.9-rc1 due to "x86/signal: Add SA_{X32,IA32}_ABI
 sa_flags"
In-Reply-To: <CAJwJo6Z8ZWPqNfT6t-i8GW1MKxQrKDUagQqnZ+0+697=MyVeGg@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1610201117380.5073@nanos>
References: <alpine.LRH.2.02.1610191311010.24555@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1610191329500.29288@file01.intranet.prod.int.rdu2.redhat.com> <CAJwJo6Z8ZWPqNfT6t-i8GW1MKxQrKDUagQqnZ+0+697=MyVeGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <0x7f454c46@gmail.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>, open list <linux-kernel@vger.kernel.org>

On Thu, 20 Oct 2016, Dmitry Safonov wrote:
> could you give attached patch a shot?

Can you please stop sending attached patches? It's a pain to look at them
and it makes it hard to reply inline.

I applied it and rewrote the changelog because the one liner you slapped
into it is more than useless. Ditto for the completely misleading subject
line. Please be more careful with that. 

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
