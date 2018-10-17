Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9ECC86B0005
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 11:53:59 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id u28-v6so29279816qtu.3
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 08:53:59 -0700 (PDT)
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id 14-v6si3340869qtw.283.2018.10.17.08.53.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 Oct 2018 08:53:58 -0700 (PDT)
Date: Wed, 17 Oct 2018 15:53:58 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: WARNING: kmalloc bug in input_mt_init_slots
In-Reply-To: <CE3D3608-F320-4DAB-8BEB-3EFDDB54F97E@gmail.com>
Message-ID: <0100016682bbce08-fad65518-19e4-4fa2-a482-0bfdacd3fb42-000000@email.amazonses.com>
References: <000000000000e5f76c057664e73d@google.com> <CAKdAkRS7PSXv65MTnvKOewqESxt0_FtKohd86ioOuYR3R0z9dw@mail.gmail.com> <CACT4Y+YOb6M=xuPG64PAvd=0bcteicGtwQO60CevN_V67SJ=MQ@mail.gmail.com> <010001660c1fafb2-6d0dc7e1-d898-4589-874c-1be1af94e22d-000000@email.amazonses.com>
 <CACT4Y+ayX8vzd2JPrLeFhf3K_Quf4x6SDtmtkNJuwNLyOh67tQ@mail.gmail.com> <010001660c4a8bbe-91200766-00df-48bd-bc60-a03da2ccdb7d-000000@email.amazonses.com> <20180924184158.GA156847@dtor-ws> <20180927143537.GB19006@bombadil.infradead.org> <20181017000955.GG230131@dtor-ws>
 <0100016682aaae79-d1382d3d-83f8-4972-b4b9-6220367f4f65-000000@email.amazonses.com> <CE3D3608-F320-4DAB-8BEB-3EFDDB54F97E@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, syzbot+87829a10073277282ad1@syzkaller.appspotmail.com, Pekka Enberg <penberg@kernel.org>, "linux-input@vger.kernel.org" <linux-input@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Henrik Rydberg <rydberg@bitmath.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Wed, 17 Oct 2018, Dmitry Torokhov wrote:

> >What is a "contact" here? Are we talking about SG segments?
>
> No, we are talking about maximum number of fingers a person can have. Devices don't usually track more than 10 distinct contacts on the touch surface at a time.

Ohh... Way off my usual contexts of development. Sorry.

Ok you have my blessing.
