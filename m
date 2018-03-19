Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12F546B0003
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 03:15:19 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d18so9028444wre.6
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 00:15:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p192sor1877339wmg.21.2018.03.19.00.15.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Mar 2018 00:15:17 -0700 (PDT)
From: Lukas Bulwahn <lukas.bulwahn@gmail.com>
Date: Mon, 19 Mar 2018 08:15:03 +0100 (CET)
Subject: Re: clang fails on linux-next since commit 8bf705d13039
In-Reply-To: <CACT4Y+aLqY6wUfRMto_CZxPRSyvPKxK8ucvAmAY-aR_gq8fOAg@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1803190758010.30965@alpaca>
References: <alpine.DEB.2.20.1803171208370.21003@alpaca> <CACT4Y+aLqY6wUfRMto_CZxPRSyvPKxK8ucvAmAY-aR_gq8fOAg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Lukas Bulwahn <lukas.bulwahn@gmail.com>, Nick Desaulniers <ndesaulniers@google.com>, Greg Hackmann <ghackmann@google.com>, Luis Lozano <llozano@google.com>, Matthias Kaehlcke <mka@google.com>, Michael Davidson <md@google.com>, Sami Tolvanen <samitolvanen@google.com>, Paul Lawrence <paullawrence@google.com>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>, llvmlinux@lists.linuxfoundation.org, sil2review@lists.osadl.org


Hi Dmitry,

On Mon, 19 Mar 2018, Dmitry Vyukov wrote:
> 
> Also, Lukas what's your version of clang? Potentially there are some
> fixes for kernel in the very latest versions of clang.
> 

I tested it on clang-5.0 and clang-6.0 in a debian buster distribution.
I  just reconfirmed that it also appears on clang-7 (version 
1:7~svn327768-1 [1]) in a debian sid distribution.

I also forget to mention that I simply use defconfig.

[1] https://packages.debian.org/sid/clang-7

Lukas
