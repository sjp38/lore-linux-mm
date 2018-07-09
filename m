Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E92086B02FD
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 12:16:24 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 70-v6so10438589plc.1
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 09:16:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f3-v6sor4423114pld.40.2018.07.09.09.16.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 09:16:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <010001647fcab0b9-1154d4da-94f8-404e-8898-b8acdf366592-000000@email.amazonses.com>
References: <000000000000afa87d05708af289@google.com> <010001647fcab0b9-1154d4da-94f8-404e-8898-b8acdf366592-000000@email.amazonses.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 9 Jul 2018 18:16:02 +0200
Message-ID: <CACT4Y+ZiVLw4pEt_GXV0DDo95eER5LuwXRo_fjFLwP8fUXzcrQ@mail.gmail.com>
Subject: Re: kernel BUG at mm/slab.c:LINE! (2)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, netdev <netdev@vger.kernel.org>
Cc: syzbot <syzbot+885bda95271928dc24eb@syzkaller.appspotmail.com>, Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>

On Mon, Jul 9, 2018 at 6:05 PM, Christopher Lameter <cl@linux.com> wrote:
> On Sun, 8 Jul 2018, syzbot wrote:
>
>> kernel BUG at mm/slab.c:4421!
>
> Classic location that indicates memory corruption. Can we rerun this with
> CONFIG_SLAB_DEBUG? Alternatively use SLUB debugging for better debugging
> without rebuilding.

This runs with KASAN which is way more powerful than slab/slub debug.

There two other recent crashes in bpf_test_finish which has more info:

https://syzkaller.appspot.com/bug?id=f831c88feddf5f4de09b846bbe53e5b8c06e5c02
https://syzkaller.appspot.com/bug?id=059cee5623ce519359e7440ba6d0d6af8b82694e
