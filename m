Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7A2436B0179
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 18:00:24 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so1948030wib.15
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 15:00:23 -0700 (PDT)
Received: from mail-wg0-x233.google.com (mail-wg0-x233.google.com [2a00:1450:400c:c00::233])
        by mx.google.com with ESMTPS id jp7si44006311wjc.62.2014.06.11.15.00.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 15:00:23 -0700 (PDT)
Received: by mail-wg0-f51.google.com with SMTP id x12so376122wgg.22
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 15:00:22 -0700 (PDT)
Subject: Re: kmemleak: Unable to handle kernel paging request
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset=windows-1252
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <CAOJe8K1TgTDX5=LdE9r6c0ami7TRa7zr0hL_uu6YpiWrsePAgQ@mail.gmail.com>
Date: Wed, 11 Jun 2014 23:00:18 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <B01EB0A1-992B-49F4-93AE-71E4BA707795@arm.com>
References: <CAOJe8K3fy3XFxDdVc3y1hiMAqUCPmkUhECU7j5TT=E=gxwBqHg@mail.gmail.com> <20140611173851.GA5556@MacBook-Pro.local> <CAOJe8K1TgTDX5=LdE9r6c0ami7TRa7zr0hL_uu6YpiWrsePAgQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denis Kirjanov <kda@linux-powerpc.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 11 Jun 2014, at 21:04, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> On 6/11/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
>> On Wed, Jun 11, 2014 at 04:13:07PM +0400, Denis Kirjanov wrote:
>>> I got a trace while running 3.15.0-08556-gdfb9454:
>>>=20
>>> [  104.534026] Unable to handle kernel paging request for data at
>>> address 0xc00000007f000000
>>=20
>> Were there any kmemleak messages prior to this, like "kmemleak
>> disabled"? There could be a race when kmemleak is disabled because of
>> some fatal (for kmemleak) error while the scanning is taking place
>> (which needs some more thinking to fix properly).
>=20
> No. I checked for the similar problem and didn't find anything =
relevant.
> I'll try to bisect it.

Does this happen soon after boot? I guess it=92s the first scan
(scheduled at around 1min after boot). Something seems to be telling
kmemleak that there is a valid memory block at 0xc00000007f000000.

Catalin=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
