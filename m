Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 516F66B002C
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 09:37:15 -0500 (EST)
Received: by eaag11 with SMTP id g11so2432393eaa.14
        for <linux-mm@kvack.org>; Sun, 05 Feb 2012 06:37:13 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 08/15] mm: mmzone: MIGRATE_CMA migration type added
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
 <1328271538-14502-9-git-send-email-m.szyprowski@samsung.com>
 <CAJd=RBByc_wLEJTK66J4eY03CWnCoCRiwAeEYjXCZ5xEZhp3ag@mail.gmail.com>
 <op.v830ygma3l0zgt@mpn-glaptop>
 <CAJd=RBD765rmiCDiCz87Vf8vf8Wp-AiW=gZ3Nw5LjTPw70ZO7g@mail.gmail.com>
Date: Sun, 05 Feb 2012 15:37:07 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v87mv5ca3l0zgt@mpn-glaptop>
In-Reply-To: <CAJd=RBD765rmiCDiCz87Vf8vf8Wp-AiW=gZ3Nw5LjTPw70ZO7g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

>>>> +static inline bool migrate_async_suitable(int migratetype)

>> On Fri, 03 Feb 2012 15:19:54 +0100, Hillf Danton <dhillf@gmail.com> w=
rote:
>>> Just nitpick, since the helper is not directly related to what async=

>>> means, how about migrate_suitable(int migrate_type) ?

> 2012/2/3 Michal Nazarewicz <mina86@mina86.com>:
>> I feel current name is better suited since it says that it's OK to sc=
an this
>> block if it's an asynchronous compaction run.

On Sat, 04 Feb 2012 10:09:02 +0100, Hillf Danton <dhillf@gmail.com> wrot=
e:
> The input is the migrate type of page considered, and the async is onl=
y one
> of the modes that compaction should be carried out. Plus the helper is=

> also used in other cases where async is entirely not concerned.
>
> That said, the naming is not clear, if not misleading.

In the first version the function was called is_migrate_cma_or_movable()=
 which
described what the function checked.  Mel did not like it though, hence =
the
change to migrate_async_suitable().  Honestly, I'm not sure what would b=
e the
best name for function.

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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
