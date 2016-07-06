Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEB9828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 10:17:15 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id l125so206534679ywb.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 07:17:15 -0700 (PDT)
Received: from mail-vk0-x236.google.com (mail-vk0-x236.google.com. [2607:f8b0:400c:c05::236])
        by mx.google.com with ESMTPS id h35si764163uah.240.2016.07.06.07.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 07:17:14 -0700 (PDT)
Received: by mail-vk0-x236.google.com with SMTP id b192so6714994vke.0
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 07:17:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160629105736.15017-2-dsafonov@virtuozzo.com>
References: <20160629105736.15017-1-dsafonov@virtuozzo.com> <20160629105736.15017-2-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 6 Jul 2016 07:16:55 -0700
Message-ID: <CALCETrWYY-Os=9WPu0xAeZs1cc-j2ywZNzqE4Fs=3gGSP7SMCg@mail.gmail.com>
Subject: Re: [PATCHv2 1/6] x86/vdso: unmap vdso blob on vvar mapping failure
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, xemul@virtuozzo.com, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>

On Wed, Jun 29, 2016 at 3:57 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> If remapping of vDSO blob failed on vvar mapping,
> we need to unmap previously mapped vDSO blob.

Acked-by: Andy Lutomirski <luto@kernel.org>

Although you should probably also update the failure code to clear out
context.vdso_image a few lines down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
