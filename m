Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 65FA56B0038
	for <linux-mm@kvack.org>; Mon,  5 Sep 2016 13:02:14 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id i32so398922731uai.0
        for <linux-mm@kvack.org>; Mon, 05 Sep 2016 10:02:14 -0700 (PDT)
Received: from mail-ua0-x233.google.com (mail-ua0-x233.google.com. [2607:f8b0:400c:c08::233])
        by mx.google.com with ESMTPS id 143si8836947vkp.77.2016.09.05.10.02.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Sep 2016 10:02:13 -0700 (PDT)
Received: by mail-ua0-x233.google.com with SMTP id 49so46623798uat.3
        for <linux-mm@kvack.org>; Mon, 05 Sep 2016 10:02:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160905133308.28234-4-dsafonov@virtuozzo.com>
References: <20160905133308.28234-1-dsafonov@virtuozzo.com> <20160905133308.28234-4-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 5 Sep 2016 10:01:52 -0700
Message-ID: <CALCETrVZ+jArk-FW5AcxJ2Z+0KaxpZBymFFrg1WOfc2zJiSFPQ@mail.gmail.com>
Subject: Re: [PATCHv5 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Andrew Lutomirski <luto@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>

On Mon, Sep 5, 2016 at 6:33 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> Add API to change vdso blob type with arch_prctl.
> As this is usefull only by needs of CRIU, expose
> this interface under CONFIG_CHECKPOINT_RESTORE.

Acked-by: Andy Lutomirski <luto@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
