Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 474766B0032
	for <linux-mm@kvack.org>; Thu, 25 Dec 2014 07:13:54 -0500 (EST)
Received: by mail-la0-f51.google.com with SMTP id ms9so7910897lab.38
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 04:13:53 -0800 (PST)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com. [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id k12si28513948laa.24.2014.12.25.04.13.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Dec 2014 04:13:53 -0800 (PST)
Received: by mail-lb0-f178.google.com with SMTP id f15so8588521lbj.37
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 04:13:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPAsAGwn=KcWOgrTHeWCS18jWq2wK0JGJxYDT1Y4RUpim6=OuQ@mail.gmail.com>
References: <CAPAsAGwn=KcWOgrTHeWCS18jWq2wK0JGJxYDT1Y4RUpim6=OuQ@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 25 Dec 2014 16:13:32 +0400
Message-ID: <CACT4Y+bsDMiNA+UnyvR6E2vg9NAqL-rcFfxta4o+ZB6o=kXcQA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] The kernel address sanitizer
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>, kasan-dev <kasan-dev@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>

+some more people

On Thu, Dec 25, 2014 at 3:01 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
> Hello
>
> I'm working on the kernel address sanitizer (KASan) -
> http://thread.gmane.org/gmane.linux.kernel.mm/120041
> KASan is runtime memory debugger designed to find use-after-free and
> out-of-bounds accesses.
>
> Seems we've come to agreement that KASan is useful and deserves to be
> in mainline, yet the feedback on patches is poor.
> It seems like they are stalled, so I would like to discuss the future
> of it. I hope this will help in pushing it forward.
>
> Besides we have ideas for further improvements, like:
>
>  * Detecting reads of uninitialized memory.
>  * Quarantine - delaying reallocation of freed memory to increase
> chance of catching use after free bugs.
>                     In combination with DEBUG_PAGEALLOC or slab
> poisoning it's useful even without KASan.
>  * and some more...
>
> Perhaps it's worth to discuss them as well. I'll be able to come up
> with some prototype until summit if needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
