Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E39156B0300
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 12:30:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f13-v6so15923093wmb.4
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 09:30:55 -0700 (PDT)
Received: from www62.your-server.de (www62.your-server.de. [213.133.104.62])
        by mx.google.com with ESMTPS id h30-v6si12751097wrh.248.2018.07.09.09.30.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 09:30:54 -0700 (PDT)
Subject: Re: kernel BUG at mm/slab.c:LINE! (2)
References: <000000000000afa87d05708af289@google.com>
 <010001647fcab0b9-1154d4da-94f8-404e-8898-b8acdf366592-000000@email.amazonses.com>
 <CACT4Y+ZiVLw4pEt_GXV0DDo95eER5LuwXRo_fjFLwP8fUXzcrQ@mail.gmail.com>
From: Daniel Borkmann <daniel@iogearbox.net>
Message-ID: <35087252-a5fa-c162-efb2-aa2b6a30515a@iogearbox.net>
Date: Mon, 9 Jul 2018 18:30:47 +0200
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZiVLw4pEt_GXV0DDo95eER5LuwXRo_fjFLwP8fUXzcrQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Christopher Lameter <cl@linux.com>, Alexei Starovoitov <ast@kernel.org>, netdev <netdev@vger.kernel.org>
Cc: syzbot <syzbot+885bda95271928dc24eb@syzkaller.appspotmail.com>, Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>

On 07/09/2018 06:16 PM, Dmitry Vyukov wrote:
> On Mon, Jul 9, 2018 at 6:05 PM, Christopher Lameter <cl@linux.com> wrote:
>> On Sun, 8 Jul 2018, syzbot wrote:
>>
>>> kernel BUG at mm/slab.c:4421!
>>
>> Classic location that indicates memory corruption. Can we rerun this with
>> CONFIG_SLAB_DEBUG? Alternatively use SLUB debugging for better debugging
>> without rebuilding.
> 
> This runs with KASAN which is way more powerful than slab/slub debug.
> 
> There two other recent crashes in bpf_test_finish which has more info:
> 
> https://syzkaller.appspot.com/bug?id=f831c88feddf5f4de09b846bbe53e5b8c06e5c02
> https://syzkaller.appspot.com/bug?id=059cee5623ce519359e7440ba6d0d6af8b82694e

Fyi, looking into the two today as well.
