Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id D2F256B005C
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 09:02:35 -0400 (EDT)
Received: by eekc50 with SMTP id c50so173446eek.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2012 06:02:34 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 2/3] mm: fix possible incorrect return value of
 migrate_pages() syscall
References: <1342455272-32703-1-git-send-email-js1304@gmail.com>
 <1342455272-32703-2-git-send-email-js1304@gmail.com>
 <87394rr4dl.fsf@erwin.mina86.com>
 <CAAmzW4OZZgPKrffdvMmEgpzF=7C9mJTkEhBfjJ5G7Q15xLzv2g@mail.gmail.com>
Date: Tue, 17 Jul 2012 15:02:31 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.whlc6hjn3l0zgt@mpn-glaptop>
In-Reply-To: <CAAmzW4OZZgPKrffdvMmEgpzF=7C9mJTkEhBfjJ5G7Q15xLzv2g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@tlen.pl>, JoonSoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <levinsasha928@gmail.com>, Christoph
 Lameter <cl@linux.com>

On Mon, 16 Jul 2012 19:59:18 +0200, JoonSoo Kim <js1304@gmail.com> wrote=
:

> 2012/7/17 Michal Nazarewicz <mina86@tlen.pl>:
>> Joonsoo Kim <js1304@gmail.com> writes:
>>> do_migrate_pages() can return the number of pages not migrated.
>>> Because migrate_pages() syscall return this value directly,
>>> migrate_pages() syscall may return the number of pages not migrated.=

>>> In fail case in migrate_pages() syscall, we should return error valu=
e.
>>> So change err to -EIO
>>>
>>> Additionally, Correct comment above do_migrate_pages()
>>>
>>> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
>>> Cc: Sasha Levin <levinsasha928@gmail.com>
>>> Cc: Christoph Lameter <cl@linux.com>
>>
>> Acked-by: Michal Nazarewicz <mina86@mina86.com>
>
> Thanks.
>
> When I resend with changing -EIO to -EBUSY,
> could I include "Acked-by: Michal Nazarewicz <mina86@mina86.com>"?

Sure thing.

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
