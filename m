Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CAECB6B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 12:57:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a143so68865353pfa.0
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 09:57:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 1si28242057itj.120.2016.09.01.09.57.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 09:57:00 -0700 (PDT)
Date: Thu, 1 Sep 2016 18:56:24 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCHv4 6/6] x86/signal: add SA_{X32,IA32}_ABI sa_flags
Message-ID: <20160901165624.GB13138@redhat.com>
References: <20160831135936.2281-1-dsafonov@virtuozzo.com> <20160831135936.2281-7-dsafonov@virtuozzo.com> <CAJwJo6YZEN75XB8YaMS26rbFAR0x77B-gfLKv37ib_eB_OLMBg@mail.gmail.com> <20160901122744.GA7438@redhat.com> <20160901124522.GK23045@uranus.lan> <CAJwJo6aL5vG1k=WTtBJQZeD5esUU=6StiTPtYxLAt5Q40xDMOg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJwJo6aL5vG1k=WTtBJQZeD5esUU=6StiTPtYxLAt5Q40xDMOg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <0x7f454c46@gmail.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, X86 ML <x86@kernel.org>, Pavel Emelyanov <xemul@virtuozzo.com>

On 09/01, Dmitry Safonov wrote:
>
> And the biggest problem in this approach would be not the size of
> code changes to CRIU (which are already quite large with this
> patches set), but AFAICS, it will have big performance penalty:
> we would need to bounce process tree, processes properties
> from parent-CRIU to child-CRIU after exec() call and down on
> the processes hierarchy, recreating processes while synchronizing
> process's data from images.
>
> As for now, we already have time-critical problems in D!RIU and
> we try to reduce the number of system calls, while it's still slow
> at some places. But that approach will lead to:
> o exec different CRIU
> o initialize it (i.e, parse /proc/self/maps to know it's vmas)
> o transphere process tree, for each process it's properties with IPC
>    after exec()
> It will all go for a large number of syscalls in total.

I do not really understand why it has to be so complicated, but
I can be easily wrong.

> And this arch_prctl() API is visible under CHECKPOINT_RESTORE
> config option, so will not bother anyone.

I mostly dislike 6/6. This new feauture looks a bit strange to me.

Nevermind, let me repeat once again, I am not trying to argue with
this series. No objections from me.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
