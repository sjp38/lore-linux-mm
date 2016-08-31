Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB9A76B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 16:00:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a143so5776836pfa.0
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 13:00:29 -0700 (PDT)
Received: from mail-ua0-x22d.google.com (mail-ua0-x22d.google.com. [2607:f8b0:400c:c08::22d])
        by mx.google.com with ESMTPS id i64si855443vkd.66.2016.08.31.13.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 13:00:28 -0700 (PDT)
Received: by mail-ua0-x22d.google.com with SMTP id m60so108086886uam.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 13:00:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160831135936.2281-3-dsafonov@virtuozzo.com>
References: <20160831135936.2281-1-dsafonov@virtuozzo.com> <20160831135936.2281-3-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 31 Aug 2016 13:00:08 -0700
Message-ID: <CALCETrWmjM3y9FO_bbeHDOoLtRxDbFfSKrz7atS_oVsDYUcaCA@mail.gmail.com>
Subject: Re: [PATCHv4 2/6] x86/vdso: replace calculate_addr in map_vdso() with addr
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Andrew Lutomirski <luto@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>

On Wed, Aug 31, 2016 at 6:59 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> That will allow to specify address where to map vDSO blob.
> For the randomized vDSO mappings introduce map_vdso_randomized()
> which will simplify calls to map_vdso.

Still Acked-by: Andy Lutomirski <luto@kernel.org>

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
