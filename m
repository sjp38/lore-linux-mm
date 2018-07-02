Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC22F6B0008
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 14:55:38 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d23-v6so18517250qtj.12
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 11:55:38 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w13-v6si705437qtn.401.2018.07.02.11.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 11:55:38 -0700 (PDT)
Reply-To: crecklin@redhat.com
Subject: Re: [PATCH v3] add param that allows bootline control of hardened
 usercopy
References: <1530101255-13988-1-git-send-email-crecklin@redhat.com>
 <CAGXu5jLDULvf-VBhUfBXtSNaSWpq8irgg56LT3nHDft5gZg5Lw@mail.gmail.com>
 <5506a72f-99ac-b47c-4ace-86c43b17b5c5@redhat.com>
 <CAGXu5jL8XDYE+B=a_TBM2K8F-c3f4Jz6zcm3ggacbPNN2wCtpg@mail.gmail.com>
From: Christoph von Recklinghausen <crecklin@redhat.com>
Message-ID: <0076b929-4785-0665-0e08-789c504f6b78@redhat.com>
Date: Mon, 2 Jul 2018 14:55:35 -0400
MIME-Version: 1.0
In-Reply-To: <CAGXu5jL8XDYE+B=a_TBM2K8F-c3f4Jz6zcm3ggacbPNN2wCtpg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@redhat.com>, Paolo Abeni <pabeni@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Peter Zijlstra <peterz@infradead.org>

On 07/02/2018 02:43 PM, Kees Cook wrote:
> On Sat, Jun 30, 2018 at 1:43 PM, Christoph von Recklinghausen
> <crecklin@redhat.com> wrote:
>> The last issue I'm chasing is build failures on ARCH=m68k. The error is
>> atomic_read and friends needed by the jump label code not being found.
>> The config has CONFIG_BROKEN_ON_SMP=y, so the jump label calls I added
>> will only be made #ifndef CONFIG_BROKEN_ON_SMP. Do you think that's
>> worth a mention in the blurb that's added to
>> Documentation/admin-guide/kernel-parameters.txt?
> Uhm, that's weird -- I think the configs on m68k need fixing then? I
> don't want to have to sprinkle that ifdef in generic code.
>
> How are other users of static keys and jump labels dealing with m68k weirdness?
>
> -Kees
>
There's also CONFIG_JUMP_LABEL which is defined in x86_64 but not
defined in the m68k configs. I'll use that instead. In hindsight I
should have spotted that but didn't.

Thanks,

Chris
