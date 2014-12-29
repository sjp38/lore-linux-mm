Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 399D46B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 12:26:10 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id y19so19414378wgg.7
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 09:26:09 -0800 (PST)
Received: from mail-wg0-x22e.google.com (mail-wg0-x22e.google.com. [2a00:1450:400c:c00::22e])
        by mx.google.com with ESMTPS id ft7si17711340wjb.169.2014.12.29.09.26.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Dec 2014 09:26:09 -0800 (PST)
Received: by mail-wg0-f46.google.com with SMTP id x13so19402036wgg.5
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 09:26:09 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 2/3] mm: cma: introduce /proc/cmainfo
In-Reply-To: <54A160B6.5030605@gmail.com>
References: <cover.1419602920.git.s.strogin@partner.samsung.com> <264ce8ad192124f2afec9a71a2fc28779d453ba7.1419602920.git.s.strogin@partner.samsung.com> <xa1tzjaaz9f9.fsf@mina86.com> <54A160B6.5030605@gmail.com>
Date: Mon, 29 Dec 2014 18:26:05 +0100
Message-ID: <xa1tbnmmgyfm.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <stefan.strogin@gmail.com>, "Stefan I. Strogin" <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>

>> On Fri, Dec 26 2014, "Stefan I. Strogin" <s.strogin@partner.samsung.com>=
 wrote:
>>> +		if (ret) {
>>> +			pr_warn("%s(): cma_buffer_list_add() returned %d\n",
>>> +				__func__, ret);
>>> +			cma_release(cma, page, count);
>>> +			page =3D NULL;

> On 12/26/2014 07:02 PM, Michal Nazarewicz wrote:
>> Harsh, but ok, if you want.

On Mon, Dec 29 2014, Stefan Strogin wrote:
> Excuse me, maybe you could suggest how to make a nicer fallback?
> Or sure OK?

I would leave the allocation succeed and print warning that the debug
information is invalid.  You could have a =E2=80=9Cdirty=E2=80=9D flag whic=
h is set if
that happens (or on a partial release discussed earlier) which, if set,
would add =E2=80=9CSome debug information missing=E2=80=9D message at the b=
eginning of
the procfs file.  In my opinion CMA succeeding is more important than
having correct debug information.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
