Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 607F16B0003
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 11:35:17 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n1-v6so28505895qtb.17
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 08:35:17 -0700 (PDT)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id j68-v6si3868761qke.173.2018.10.17.08.35.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 Oct 2018 08:35:16 -0700 (PDT)
Date: Wed, 17 Oct 2018 15:35:15 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: WARNING: kmalloc bug in input_mt_init_slots
In-Reply-To: <20181017000955.GG230131@dtor-ws>
Message-ID: <0100016682aaae79-d1382d3d-83f8-4972-b4b9-6220367f4f65-000000@email.amazonses.com>
References: <000000000000e5f76c057664e73d@google.com> <CAKdAkRS7PSXv65MTnvKOewqESxt0_FtKohd86ioOuYR3R0z9dw@mail.gmail.com> <CACT4Y+YOb6M=xuPG64PAvd=0bcteicGtwQO60CevN_V67SJ=MQ@mail.gmail.com> <010001660c1fafb2-6d0dc7e1-d898-4589-874c-1be1af94e22d-000000@email.amazonses.com>
 <CACT4Y+ayX8vzd2JPrLeFhf3K_Quf4x6SDtmtkNJuwNLyOh67tQ@mail.gmail.com> <010001660c4a8bbe-91200766-00df-48bd-bc60-a03da2ccdb7d-000000@email.amazonses.com> <20180924184158.GA156847@dtor-ws> <20180927143537.GB19006@bombadil.infradead.org>
 <20181017000955.GG230131@dtor-ws>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, syzbot+87829a10073277282ad1@syzkaller.appspotmail.com, Pekka Enberg <penberg@kernel.org>, "linux-input@vger.kernel.org" <linux-input@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Henrik Rydberg <rydberg@bitmath.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Tue, 16 Oct 2018, Dmitry Torokhov wrote:

> On Thu, Sep 27, 2018 at 07:35:37AM -0700, Matthew Wilcox wrote:
> > On Mon, Sep 24, 2018 at 11:41:58AM -0700, Dmitry Torokhov wrote:
> > > > How large is the allocation? AFACIT nRequests larger than KMALLOC_MAX_SIZE
> > > > are larger than the maximum allowed by the page allocator. Thus the warning
> > > > and the NULL return.
> > >
> > > The size in this particular case is being derived from a value passed
> > > from userspace. Input core does not care about any limits on size of
> > > memory kmalloc() can support and is perfectly happy with getting NULL
> > > and telling userspace to go away with their silly requests by returning
> > > -ENOMEM.
> > >
> > > For the record: I definitely do not want to pre-sanitize size neither in
> > > uinput nor in input core.
> >
> > Probably should be using kvzalloc then.
>
> No. No sane input device can track so many contacts so we need to use
> kvzalloc(). Failing to allocate memory is proper response here.

What is a "contact" here? Are we talking about SG segments?
