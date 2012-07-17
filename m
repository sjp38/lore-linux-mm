Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 926936B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 09:16:47 -0400 (EDT)
Received: by eaan1 with SMTP id n1so184229eaa.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2012 06:16:46 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 3/3] mm: fix return value in
 __alloc_contig_migrate_range()
References: <1342455272-32703-1-git-send-email-js1304@gmail.com>
 <1342455272-32703-3-git-send-email-js1304@gmail.com>
 <871ukbr4d3.fsf@erwin.mina86.com>
 <CAAmzW4MpWsxd2nG-xsdw_D89-Prx7PPuWSEbuS7Nw0rTmcChig@mail.gmail.com>
Date: Tue, 17 Jul 2012 15:16:42 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.whldt4a73l0zgt@mpn-glaptop>
In-Reply-To: <CAAmzW4MpWsxd2nG-xsdw_D89-Prx7PPuWSEbuS7Nw0rTmcChig@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan
 Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>

On Mon, 16 Jul 2012 20:40:56 +0200, JoonSoo Kim <js1304@gmail.com> wrote=
:

> 2012/7/17 Michal Nazarewicz <mina86@mina86.com>:
>> Joonsoo Kim <js1304@gmail.com> writes:
>>
>>> migrate_pages() would return positive value in some failure case,
>>> so 'ret > 0 ? 0 : ret' may be wrong.
>>> This fix it and remove one dead statement.
>>>
>>> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
>>> Cc: Michal Nazarewicz <mina86@mina86.com>
>>> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
>>> Cc: Minchan Kim <minchan@kernel.org>
>>> Cc: Christoph Lameter <cl@linux.com>
>>
>> Have you actually encountered this problem?  If migrate_pages() fails=

>> with a positive value, the code that you are removing kicks in and
>> -EBUSY is assigned to ret (now that I look at it, I think that in the=

>> current code the "return ret > 0 ? 0 : ret;" statement could be reduc=
ed
>> to "return ret;").  Your code seems to be cleaner, but the commit
>> message does not look accurate to me.
>>
>
> I don't encounter this problem yet.
>
> If migrate_pages() with offlining false meets KSM page, then migration=
 failed.
> In this case, failed page is removed from cc.migratepage list and
> return failed count.

Good point.

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
