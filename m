Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9D195828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 10:32:47 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so113172110wma.3
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 07:32:47 -0700 (PDT)
Received: from mail-vk0-x233.google.com (mail-vk0-x233.google.com. [2607:f8b0:400c:c05::233])
        by mx.google.com with ESMTPS id j33si186980uad.214.2016.07.06.07.32.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 07:32:46 -0700 (PDT)
Received: by mail-vk0-x233.google.com with SMTP id t66so22992162vka.1
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 07:32:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160629105736.15017-6-dsafonov@virtuozzo.com>
References: <20160629105736.15017-1-dsafonov@virtuozzo.com> <20160629105736.15017-6-dsafonov@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 6 Jul 2016 07:32:26 -0700
Message-ID: <CALCETrXDZDfc2iGsn_UAgVsyGsUh5yj76E+=h3g9sK8LW5kE_A@mail.gmail.com>
Subject: Re: [PATCHv2 5/6] x86/ptrace: down with test_thread_flag(TIF_IA32)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>, Pedro Alves <palves@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, xemul@virtuozzo.com, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>

On Wed, Jun 29, 2016 at 3:57 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> As the task isn't executing at the moment of {GET,SET}REGS,
> return regset that corresponds to code selector, rather than
> value of TIF_IA32 flag.
> I.e. if we ptrace i386 elf binary that has just changed it's
> code selector to __USER_CS, than GET_REGS will return
> full x86_64 register set.

Pedro, I think this will cause gdb to be a little less broken than it
is now.  Am I right?  Will this break anything?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
