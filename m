Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5756B0695
	for <linux-mm@kvack.org>; Fri, 18 May 2018 18:03:30 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b3-v6so3243075pga.6
        for <linux-mm@kvack.org>; Fri, 18 May 2018 15:03:30 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c74-v6si8951166pfc.224.2018.05.18.15.03.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 15:03:29 -0700 (PDT)
Received: from mail-wr0-f181.google.com (mail-wr0-f181.google.com [209.85.128.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9085320867
	for <linux-mm@kvack.org>; Fri, 18 May 2018 22:03:28 +0000 (UTC)
Received: by mail-wr0-f181.google.com with SMTP id a15-v6so3279424wrm.0
        for <linux-mm@kvack.org>; Fri, 18 May 2018 15:03:28 -0700 (PDT)
MIME-Version: 1.0
References: <20180517233510.24996-1-dima@arista.com> <1526600442.28243.39.camel@arista.com>
In-Reply-To: <1526600442.28243.39.camel@arista.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 18 May 2018 15:03:15 -0700
Message-ID: <CALCETrUDX=4FHU0e8SZ9Rr_AnAes+5jjzKCrrVmS1mddHQyeVQ@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: Drop TS_COMPAT on 64-bit exec() syscall
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dima@arista.com>
Cc: LKML <linux-kernel@vger.kernel.org>, izbyshev@ispras.ru, Alexander Monakov <amonakov@ispras.ru>, Andrew Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Dmitry Safonov <0x7f454c46@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, stable <stable@vger.kernel.org>

On Thu, May 17, 2018 at 4:40 PM Dmitry Safonov <dima@arista.com> wrote:
> Some selftests are failing, but the same way as before the patch
> (ITOW, it's not regression):
> [root@localhost self]# grep FAIL out
> [FAIL]  Reg 1 mismatch: requested 0x0; got 0x3
> [FAIL]  Reg 15 mismatch: requested 0x8badf00d5aadc0de; got
> 0xffffff425aadc0de
> [FAIL]  Reg 15 mismatch: requested 0x8badf00d5aadc0de; got
> 0xffffff425aadc0de
> [FAIL]  Reg 15 mismatch: requested 0x8badf00d5aadc0de; got
> 0xffffff425aadc0de

Are you on AMD?  Can you try this patch:

https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/commit/?h=x86/fixes&id=c88aa6d53840e48970c54f9ef70c79415033b32d

and give me a Tested-by if it fixes it for you?

> [FAIL]  f[u]comi[p] errors: 1
> [FAIL]  fisttp errors: 1'

I don't know about these.

> [FAIL]  R8 has changed:0000000000000000
> [FAIL]  R9 has changed:0000000000000000
> [FAIL]  R10 has changed:0000000000000000
> [FAIL]  R11 has changed:0000000000000000
> [FAIL]  R8 has changed:0000000000000000
> [FAIL]  R9 has changed:0000000000000000
> [FAIL]  R10 has changed:0000000000000000
> [FAIL]  R11 has changed:0000000000000000

The patch that added these test lines was the same patch that should have
made them pass.  Are you sure your tests match your running kernel?  You
need commit 8bb2610bc4967f19672444a7b0407367f1540028.

If you still have failures, can you send me the complete output from the
test_syscall_vdso test?

--Andy
