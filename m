Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 543B68E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 09:08:21 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id 204-v6so7904699itf.1
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 06:08:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c11-v6sor863575jaa.131.2018.09.27.06.08.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 06:08:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <01000166110bb882-0b1fa048-fe1c-4139-a1ba-702754bbc267-000000@email.amazonses.com>
References: <000000000000e5f76c057664e73d@google.com> <CAKdAkRS7PSXv65MTnvKOewqESxt0_FtKohd86ioOuYR3R0z9dw@mail.gmail.com>
 <CACT4Y+YOb6M=xuPG64PAvd=0bcteicGtwQO60CevN_V67SJ=MQ@mail.gmail.com>
 <010001660c1fafb2-6d0dc7e1-d898-4589-874c-1be1af94e22d-000000@email.amazonses.com>
 <CACT4Y+ayX8vzd2JPrLeFhf3K_Quf4x6SDtmtkNJuwNLyOh67tQ@mail.gmail.com>
 <010001660c4a8bbe-91200766-00df-48bd-bc60-a03da2ccdb7d-000000@email.amazonses.com>
 <20180924184158.GA156847@dtor-ws> <CACT4Y+ZPrngv8GTC-Cw68PBDxZ2T5x1kKMNXL3DmP24Xd0m_5g@mail.gmail.com>
 <01000166110bb882-0b1fa048-fe1c-4139-a1ba-702754bbc267-000000@email.amazonses.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 27 Sep 2018 15:07:59 +0200
Message-ID: <CACT4Y+aUdAmRmgiV5-KWXF-eGoCUCMhUC+ddLU-heQTQ53PhRA@mail.gmail.com>
Subject: Re: WARNING: kmalloc bug in input_mt_init_slots
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>, syzbot+87829a10073277282ad1@syzkaller.appspotmail.com, Pekka Enberg <penberg@kernel.org>, "linux-input@vger.kernel.org" <linux-input@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Henrik Rydberg <rydberg@bitmath.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Tue, Sep 25, 2018 at 4:04 PM, Christopher Lameter <cl@linux.com> wrote:
> On Tue, 25 Sep 2018, Dmitry Vyukov wrote:
>
>> Assuming that the size is large enough to fail in all allocators, is
>> this warning still useful? How? Should we remove it?
>
> Remove it. It does not make sense because we check earlier if possible
> without the warn.

Mailed "mm: don't warn about large allocations for slab" to remove the warning.
