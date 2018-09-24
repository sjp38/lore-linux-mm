Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 97CE48E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 11:08:16 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x144-v6so7164701qkb.4
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 08:08:16 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id o9-v6si2191442qvl.100.2018.09.24.08.08.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Sep 2018 08:08:15 -0700 (PDT)
Date: Mon, 24 Sep 2018 15:08:15 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: WARNING: kmalloc bug in input_mt_init_slots
In-Reply-To: <CACT4Y+YOb6M=xuPG64PAvd=0bcteicGtwQO60CevN_V67SJ=MQ@mail.gmail.com>
Message-ID: <010001660c1fafb2-6d0dc7e1-d898-4589-874c-1be1af94e22d-000000@email.amazonses.com>
References: <000000000000e5f76c057664e73d@google.com> <CAKdAkRS7PSXv65MTnvKOewqESxt0_FtKohd86ioOuYR3R0z9dw@mail.gmail.com> <CACT4Y+YOb6M=xuPG64PAvd=0bcteicGtwQO60CevN_V67SJ=MQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>, syzbot+87829a10073277282ad1@syzkaller.appspotmail.com, Pekka Enberg <penberg@kernel.org>, "linux-input@vger.kernel.org" <linux-input@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Henrik Rydberg <rydberg@bitmath.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Sun, 23 Sep 2018, Dmitry Vyukov wrote:

> What was the motivation behind that WARNING about large allocations in
> kmalloc? Why do we want to know about them? Is the general policy that
> kmalloc calls with potentially large size requests need to use NOWARN?
> If this WARNING still considered useful? Or we should change it to
> pr_err?

In general large allocs should be satisfied by the page allocator. The
slab allocators are used for allocating and managing small objects. The
page allocator has mechanisms to deal with large objects (compound pages,
multiple page sized allocs etc).
