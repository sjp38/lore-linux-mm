Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f50.google.com (mail-oa0-f50.google.com [209.85.219.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2238A900002
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 03:39:12 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id n16so935294oag.37
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 00:39:11 -0700 (PDT)
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
        by mx.google.com with ESMTPS id d13si219942oes.38.2014.06.12.00.39.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 00:39:11 -0700 (PDT)
Received: by mail-oa0-f44.google.com with SMTP id i7so949072oag.3
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 00:39:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <B01EB0A1-992B-49F4-93AE-71E4BA707795@arm.com>
References: <CAOJe8K3fy3XFxDdVc3y1hiMAqUCPmkUhECU7j5TT=E=gxwBqHg@mail.gmail.com>
	<20140611173851.GA5556@MacBook-Pro.local>
	<CAOJe8K1TgTDX5=LdE9r6c0ami7TRa7zr0hL_uu6YpiWrsePAgQ@mail.gmail.com>
	<B01EB0A1-992B-49F4-93AE-71E4BA707795@arm.com>
Date: Thu, 12 Jun 2014 11:39:11 +0400
Message-ID: <CAOJe8K3LDhhPWbtdaWt23mY+2vnw5p05+eyk2D8fovOxC10cgA@mail.gmail.com>
Subject: Re: kmemleak: Unable to handle kernel paging request
From: Denis Kirjanov <kda@linux-powerpc.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 6/12/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On 11 Jun 2014, at 21:04, Denis Kirjanov <kda@linux-powerpc.org> wrote:
>> On 6/11/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
>>> On Wed, Jun 11, 2014 at 04:13:07PM +0400, Denis Kirjanov wrote:
>>>> I got a trace while running 3.15.0-08556-gdfb9454:
>>>>
>>>> [  104.534026] Unable to handle kernel paging request for data at
>>>> address 0xc00000007f000000
>>>
>>> Were there any kmemleak messages prior to this, like "kmemleak
>>> disabled"? There could be a race when kmemleak is disabled because of
>>> some fatal (for kmemleak) error while the scanning is taking place
>>> (which needs some more thinking to fix properly).
>>
>> No. I checked for the similar problem and didn't find anything relevant.
>> I'll try to bisect it.
>
> Does this happen soon after boot? I guess it=E2=80=99s the first scan
> (scheduled at around 1min after boot). Something seems to be telling
> kmemleak that there is a valid memory block at 0xc00000007f000000.

Yeah, it happens after a while with a booted system so that's the
first kmemleak scan.

> Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
