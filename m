Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77FE88E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 11:47:51 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k10-v6so2608314qtb.8
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 08:47:51 -0700 (PDT)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id w138-v6si1597024qka.122.2018.09.27.08.47.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Sep 2018 08:47:50 -0700 (PDT)
Date: Thu, 27 Sep 2018 15:47:50 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: WARNING: kmalloc bug in input_mt_init_slots
In-Reply-To: <CACT4Y+aDFD6O48nV5J9UpXLiNpTPuSFoBQ4HVC+Kg1tM_KFEiQ@mail.gmail.com>
Message-ID: <010001661bb70227-d4c9d54f-3870-403f-8103-0296caf0b76d-000000@email.amazonses.com>
References: <000000000000e5f76c057664e73d@google.com> <CACT4Y+YOb6M=xuPG64PAvd=0bcteicGtwQO60CevN_V67SJ=MQ@mail.gmail.com> <010001660c1fafb2-6d0dc7e1-d898-4589-874c-1be1af94e22d-000000@email.amazonses.com> <CACT4Y+ayX8vzd2JPrLeFhf3K_Quf4x6SDtmtkNJuwNLyOh67tQ@mail.gmail.com>
 <010001660c4a8bbe-91200766-00df-48bd-bc60-a03da2ccdb7d-000000@email.amazonses.com> <20180924184158.GA156847@dtor-ws> <CACT4Y+ZPrngv8GTC-Cw68PBDxZ2T5x1kKMNXL3DmP24Xd0m_5g@mail.gmail.com> <01000166110bb882-0b1fa048-fe1c-4139-a1ba-702754bbc267-000000@email.amazonses.com>
 <CACT4Y+aUdAmRmgiV5-KWXF-eGoCUCMhUC+ddLU-heQTQ53PhRA@mail.gmail.com> <010001661b631a3e-f398fc0a-127c-4c6e-b6ca-b2bd63bc4a9a-000000@email.amazonses.com> <CACT4Y+biYtFUV7hK2ne2RfrbZjMt=4FK4deE0B6WykwT2qSt2g@mail.gmail.com>
 <010001661b9fad1d-cdbfabdb-5553-446f-bcde-585e42837415-000000@email.amazonses.com> <CACT4Y+aDFD6O48nV5J9UpXLiNpTPuSFoBQ4HVC+Kg1tM_KFEiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>, syzbot+87829a10073277282ad1@syzkaller.appspotmail.com, Pekka Enberg <penberg@kernel.org>, "linux-input@vger.kernel.org" <linux-input@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Henrik Rydberg <rydberg@bitmath.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Thu, 27 Sep 2018, Dmitry Vyukov wrote:

> > Please post on the mailing list
>
> It is on the  mailing lists:
> https://lkml.org/lkml/2018/9/27/802


Ok then lets continue the discussion there.
