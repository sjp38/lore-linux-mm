Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 970CA8E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 11:18:47 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id s14-v6so40638188ioc.0
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 08:18:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k17-v6sor3793934iti.133.2018.09.24.08.18.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 08:18:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <010001660c1fafb2-6d0dc7e1-d898-4589-874c-1be1af94e22d-000000@email.amazonses.com>
References: <000000000000e5f76c057664e73d@google.com> <CAKdAkRS7PSXv65MTnvKOewqESxt0_FtKohd86ioOuYR3R0z9dw@mail.gmail.com>
 <CACT4Y+YOb6M=xuPG64PAvd=0bcteicGtwQO60CevN_V67SJ=MQ@mail.gmail.com> <010001660c1fafb2-6d0dc7e1-d898-4589-874c-1be1af94e22d-000000@email.amazonses.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 24 Sep 2018 17:18:25 +0200
Message-ID: <CACT4Y+ayX8vzd2JPrLeFhf3K_Quf4x6SDtmtkNJuwNLyOh67tQ@mail.gmail.com>
Subject: Re: WARNING: kmalloc bug in input_mt_init_slots
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>, syzbot+87829a10073277282ad1@syzkaller.appspotmail.com, Pekka Enberg <penberg@kernel.org>, "linux-input@vger.kernel.org" <linux-input@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Henrik Rydberg <rydberg@bitmath.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Mon, Sep 24, 2018 at 5:08 PM, Christopher Lameter <cl@linux.com> wrote:
> On Sun, 23 Sep 2018, Dmitry Vyukov wrote:
>
>> What was the motivation behind that WARNING about large allocations in
>> kmalloc? Why do we want to know about them? Is the general policy that
>> kmalloc calls with potentially large size requests need to use NOWARN?
>> If this WARNING still considered useful? Or we should change it to
>> pr_err?
>
> In general large allocs should be satisfied by the page allocator. The
> slab allocators are used for allocating and managing small objects. The
> page allocator has mechanisms to deal with large objects (compound pages,
> multiple page sized allocs etc).

I am asking more about the status of this warning. If it fires in
input_mt_init_slots(), does it mean that input_mt_init_slots() needs
to be fixed? If not, then we need to change this warning to something
else.
