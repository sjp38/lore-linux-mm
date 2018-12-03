Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 035016B6B4C
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 17:04:46 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id i3so12345762pfj.4
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 14:04:45 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w2sor18600843pgo.65.2018.12.03.14.04.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 14:04:44 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: Number of arguments in vmalloc.c
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20181203161352.GP10377@bombadil.infradead.org>
Date: Mon, 3 Dec 2018 14:04:41 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <4F09425C-C9AB-452F-899C-3CF3D4B737E1@gmail.com>
References: <20181128140136.GG10377@bombadil.infradead.org>
 <3264149f-e01e-faa2-3bc8-8aa1c255e075@suse.cz>
 <20181203161352.GP10377@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

> On Dec 3, 2018, at 8:13 AM, Matthew Wilcox <willy@infradead.org> =
wrote:
>=20
> On Mon, Dec 03, 2018 at 02:59:36PM +0100, Vlastimil Babka wrote:
>> On 11/28/18 3:01 PM, Matthew Wilcox wrote:
>>> Some of the functions in vmalloc.c have as many as nine arguments.
>>> So I thought I'd have a quick go at bundling the ones that make =
sense
>>> into a struct and pass around a pointer to that struct.  Well, it =
made
>>> the generated code worse,
>>=20
>> Worse in which metric?
>=20
> More instructions to accomplish the same thing.
>=20
>>> so I thought I'd share my attempt so nobody
>>> else bothers (or soebody points out that I did something stupid).
>>=20
>> I guess in some of the functions the args parameter could be const?
>> Might make some difference.
>>=20
>> Anyway this shouldn't be a fast path, so even if the generated code =
is
>> e.g. somewhat larger, then it still might make sense to reduce the
>> insane parameter lists.
>=20
> It might ... I'm not sure it's even easier to program than the =
original
> though.

My intuition is that if all the fields of vm_args were initialized =
together
(in the same function), and a 'const struct vm_args *' was provided as
an argument to other functions, code would be better (at least better =
than
what you got right now).

I=E2=80=99m not saying it is easily applicable in this use-case (since I =
didn=E2=80=99t
check).
