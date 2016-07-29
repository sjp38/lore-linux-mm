Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC8E16B0260
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 11:21:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p129so41633434wmp.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 08:21:15 -0700 (PDT)
Received: from mail-lf0-x22f.google.com (mail-lf0-x22f.google.com. [2a00:1450:4010:c07::22f])
        by mx.google.com with ESMTPS id k134si9078796lfb.396.2016.07.29.08.21.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 08:21:13 -0700 (PDT)
Received: by mail-lf0-x22f.google.com with SMTP id l69so73642183lfg.1
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 08:21:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160729151907.GC29545@codemonkey.org.uk>
References: <20160729150513.GB29545@codemonkey.org.uk> <20160729151907.GC29545@codemonkey.org.uk>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Date: Fri, 29 Jul 2016 18:21:12 +0300
Message-ID: <CAPAsAGxDOvD64+5T4vPiuJgHkdHaaXGRfikFxXGHDRRiW4ivVQ@mail.gmail.com>
Subject: Re: [4.7+] various memory corruption reports.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>, Linux Kernel <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2016-07-29 18:19 GMT+03:00 Dave Jones <davej@codemonkey.org.uk>:
> On Fri, Jul 29, 2016 at 11:05:14AM -0400, Dave Jones wrote:
>  > I've just gotten back into running trinity on daily pulls of master, and it seems pretty horrific
>  > right now.  I can reproduce some kind of memory corruption within a couple minutes runtime.
>  >
>  > ,,,
>  >
>  > I'll work on narrowing down the exact syscalls needed to trigger this.
>
> Even limiting it to do just a simple syscall like execve (which fails most the time in trinity)
> triggers it, suggesting it's not syscall related, but the fact that trinity is forking/killing
> tons of processes at high rate is stressing something more fundamental.
>
> Given how easy this reproduces, I'll see if bisecting gives up something useful.

I suspect this is false positives due to changes in KASAN.
Bisection probably will point to
80a9201a5965f4715d5c09790862e0df84ce0614 ("mm, kasan: switch SLUB to
stackdepot, enable memory quarantine for SLUB)"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
