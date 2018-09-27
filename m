Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 304528E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 10:35:46 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i6-v6so2685455pfo.18
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 07:35:46 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n14-v6si1998919plp.315.2018.09.27.07.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Sep 2018 07:35:45 -0700 (PDT)
Date: Thu, 27 Sep 2018 07:35:37 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: WARNING: kmalloc bug in input_mt_init_slots
Message-ID: <20180927143537.GB19006@bombadil.infradead.org>
References: <000000000000e5f76c057664e73d@google.com>
 <CAKdAkRS7PSXv65MTnvKOewqESxt0_FtKohd86ioOuYR3R0z9dw@mail.gmail.com>
 <CACT4Y+YOb6M=xuPG64PAvd=0bcteicGtwQO60CevN_V67SJ=MQ@mail.gmail.com>
 <010001660c1fafb2-6d0dc7e1-d898-4589-874c-1be1af94e22d-000000@email.amazonses.com>
 <CACT4Y+ayX8vzd2JPrLeFhf3K_Quf4x6SDtmtkNJuwNLyOh67tQ@mail.gmail.com>
 <010001660c4a8bbe-91200766-00df-48bd-bc60-a03da2ccdb7d-000000@email.amazonses.com>
 <20180924184158.GA156847@dtor-ws>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180924184158.GA156847@dtor-ws>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Cc: Christopher Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, syzbot+87829a10073277282ad1@syzkaller.appspotmail.com, Pekka Enberg <penberg@kernel.org>, "linux-input@vger.kernel.org" <linux-input@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Henrik Rydberg <rydberg@bitmath.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Mon, Sep 24, 2018 at 11:41:58AM -0700, Dmitry Torokhov wrote:
> > How large is the allocation? AFACIT nRequests larger than KMALLOC_MAX_SIZE
> > are larger than the maximum allowed by the page allocator. Thus the warning
> > and the NULL return.
> 
> The size in this particular case is being derived from a value passed
> from userspace. Input core does not care about any limits on size of
> memory kmalloc() can support and is perfectly happy with getting NULL
> and telling userspace to go away with their silly requests by returning
> -ENOMEM.
> 
> For the record: I definitely do not want to pre-sanitize size neither in
> uinput nor in input core.

Probably should be using kvzalloc then.
