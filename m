Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D42C6B000E
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 11:43:42 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f4-v6so27403374pff.2
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 08:43:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p18-v6sor7952284pgd.43.2018.10.17.08.43.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Oct 2018 08:43:41 -0700 (PDT)
Date: Wed, 17 Oct 2018 08:43:30 -0700
In-Reply-To: <0100016682aaae79-d1382d3d-83f8-4972-b4b9-6220367f4f65-000000@email.amazonses.com>
References: <000000000000e5f76c057664e73d@google.com> <CAKdAkRS7PSXv65MTnvKOewqESxt0_FtKohd86ioOuYR3R0z9dw@mail.gmail.com> <CACT4Y+YOb6M=xuPG64PAvd=0bcteicGtwQO60CevN_V67SJ=MQ@mail.gmail.com> <010001660c1fafb2-6d0dc7e1-d898-4589-874c-1be1af94e22d-000000@email.amazonses.com> <CACT4Y+ayX8vzd2JPrLeFhf3K_Quf4x6SDtmtkNJuwNLyOh67tQ@mail.gmail.com> <010001660c4a8bbe-91200766-00df-48bd-bc60-a03da2ccdb7d-000000@email.amazonses.com> <20180924184158.GA156847@dtor-ws> <20180927143537.GB19006@bombadil.infradead.org> <20181017000955.GG230131@dtor-ws> <0100016682aaae79-d1382d3d-83f8-4972-b4b9-6220367f4f65-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: WARNING: kmalloc bug in input_mt_init_slots
From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Message-ID: <CE3D3608-F320-4DAB-8BEB-3EFDDB54F97E@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, syzbot+87829a10073277282ad1@syzkaller.appspotmail.com, Pekka Enberg <penberg@kernel.org>, "linux-input@vger.kernel.org" <linux-input@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Henrik Rydberg <rydberg@bitmath.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On October 17, 2018 8:35:15 AM PDT, Christopher Lameter <cl@linux=2Ecom> wr=
ote:
>On Tue, 16 Oct 2018, Dmitry Torokhov wrote:
>
>> On Thu, Sep 27, 2018 at 07:35:37AM -0700, Matthew Wilcox wrote:
>> > On Mon, Sep 24, 2018 at 11:41:58AM -0700, Dmitry Torokhov wrote:
>> > > > How large is the allocation? AFACIT nRequests larger than
>KMALLOC_MAX_SIZE
>> > > > are larger than the maximum allowed by the page allocator=2E Thus
>the warning
>> > > > and the NULL return=2E
>> > >
>> > > The size in this particular case is being derived from a value
>passed
>> > > from userspace=2E Input core does not care about any limits on size
>of
>> > > memory kmalloc() can support and is perfectly happy with getting
>NULL
>> > > and telling userspace to go away with their silly requests by
>returning
>> > > -ENOMEM=2E
>> > >
>> > > For the record: I definitely do not want to pre-sanitize size
>neither in
>> > > uinput nor in input core=2E
>> >
>> > Probably should be using kvzalloc then=2E
>>
>> No=2E No sane input device can track so many contacts so we need to use
>> kvzalloc()=2E Failing to allocate memory is proper response here=2E
>
>What is a "contact" here? Are we talking about SG segments?

No, we are talking about maximum number of fingers a person can have=2E De=
vices don't usually track more than 10 distinct contacts on the touch surfa=
ce at a time=2E


Thanks=2E

--=20
Dmitry
