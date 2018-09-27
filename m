Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 547F08E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 11:29:33 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id w196-v6so8193884itb.4
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 08:29:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c126-v6sor755150ioe.106.2018.09.27.08.29.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 08:29:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <010001661b9fad1d-cdbfabdb-5553-446f-bcde-585e42837415-000000@email.amazonses.com>
References: <000000000000e5f76c057664e73d@google.com> <CAKdAkRS7PSXv65MTnvKOewqESxt0_FtKohd86ioOuYR3R0z9dw@mail.gmail.com>
 <CACT4Y+YOb6M=xuPG64PAvd=0bcteicGtwQO60CevN_V67SJ=MQ@mail.gmail.com>
 <010001660c1fafb2-6d0dc7e1-d898-4589-874c-1be1af94e22d-000000@email.amazonses.com>
 <CACT4Y+ayX8vzd2JPrLeFhf3K_Quf4x6SDtmtkNJuwNLyOh67tQ@mail.gmail.com>
 <010001660c4a8bbe-91200766-00df-48bd-bc60-a03da2ccdb7d-000000@email.amazonses.com>
 <20180924184158.GA156847@dtor-ws> <CACT4Y+ZPrngv8GTC-Cw68PBDxZ2T5x1kKMNXL3DmP24Xd0m_5g@mail.gmail.com>
 <01000166110bb882-0b1fa048-fe1c-4139-a1ba-702754bbc267-000000@email.amazonses.com>
 <CACT4Y+aUdAmRmgiV5-KWXF-eGoCUCMhUC+ddLU-heQTQ53PhRA@mail.gmail.com>
 <010001661b631a3e-f398fc0a-127c-4c6e-b6ca-b2bd63bc4a9a-000000@email.amazonses.com>
 <CACT4Y+biYtFUV7hK2ne2RfrbZjMt=4FK4deE0B6WykwT2qSt2g@mail.gmail.com> <010001661b9fad1d-cdbfabdb-5553-446f-bcde-585e42837415-000000@email.amazonses.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 27 Sep 2018 17:29:11 +0200
Message-ID: <CACT4Y+aDFD6O48nV5J9UpXLiNpTPuSFoBQ4HVC+Kg1tM_KFEiQ@mail.gmail.com>
Subject: Re: WARNING: kmalloc bug in input_mt_init_slots
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>, syzbot+87829a10073277282ad1@syzkaller.appspotmail.com, Pekka Enberg <penberg@kernel.org>, "linux-input@vger.kernel.org" <linux-input@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Henrik Rydberg <rydberg@bitmath.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Thu, Sep 27, 2018 at 5:22 PM, Christopher Lameter <cl@linux.com> wrote:
> On Thu, 27 Sep 2018, Dmitry Vyukov wrote:
>
>> On Thu, Sep 27, 2018 at 4:16 PM, Christopher Lameter <cl@linux.com> wrote:
>> > On Thu, 27 Sep 2018, Dmitry Vyukov wrote:
>> >
>> >> On Tue, Sep 25, 2018 at 4:04 PM, Christopher Lameter <cl@linux.com> wrote:
>> >> > On Tue, 25 Sep 2018, Dmitry Vyukov wrote:
>> >> >
>> >> >> Assuming that the size is large enough to fail in all allocators, is
>> >> >> this warning still useful? How? Should we remove it?
>> >> >
>> >> > Remove it. It does not make sense because we check earlier if possible
>> >> > without the warn.
>> >>
>> >> Mailed "mm: don't warn about large allocations for slab" to remove the warning.
>> >>
>> >
>> > Hoe it arrives here at some point.
>>
>> It's here:
>> https://lore.kernel.org/patchwork/patch/992660/
>>
>
> Please post on the mailing list

It is on the  mailing lists:
https://lkml.org/lkml/2018/9/27/802

> and NAK to the patch. Testing against
> KMALLOC_MAX_CACHE_SIZE is not ok.

Why?
