Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C67D6B0261
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:10:13 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id m60so108906648uam.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:10:13 -0700 (PDT)
Received: from mail-ua0-x229.google.com (mail-ua0-x229.google.com. [2607:f8b0:400c:c08::229])
        by mx.google.com with ESMTPS id 38si222406uav.46.2016.08.31.08.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 08:10:13 -0700 (PDT)
Received: by mail-ua0-x229.google.com with SMTP id m60so93639354uam.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:10:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160826171317.3944-3-dsafonov@virtuozzo.com>
References: <20160826171317.3944-1-dsafonov@virtuozzo.com> <20160826171317.3944-3-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 31 Aug 2016 08:09:52 -0700
Message-ID: <CALCETrVHmKXG1S4XAEMo4n6_z4f=WYbzQ3xrmyS+McT94NuO0g@mail.gmail.com>
Subject: Re: [PATCHv3 2/6] x86/vdso: replace calculate_addr in map_vdso() with addr
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Andrew Lutomirski <luto@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>

On Fri, Aug 26, 2016 at 10:13 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> That will allow to specify address where to map vDSO blob.
> For the randomized vDSO mappings introduce map_vdso_randomized()
> which will simplify calls to map_vdso.

Nice.

Acked-by: Andy Lutomirski <luto@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
