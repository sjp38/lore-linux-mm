Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 702C9280254
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 11:03:55 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y16so58003898wmd.6
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 08:03:55 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id k15si1219343wmi.37.2016.12.01.08.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 08:03:54 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id a197so303341789wmd.0
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 08:03:54 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: drm/radeon spamming alloc_contig_range: [xxx, yyy) PFNs busy busy
In-Reply-To: <20161201141125.GB20966@dhcp22.suse.cz>
References: <robbat2-20161129T223723-754929513Z@orbis-terrarum.net> <20161130092239.GD18437@dhcp22.suse.cz> <xa1ty4012k0f.fsf@mina86.com> <20161130132848.GG18432@dhcp22.suse.cz> <robbat2-20161130T195244-998539995Z@orbis-terrarum.net> <robbat2-20161130T195846-190979177Z@orbis-terrarum.net> <20161201071507.GC18272@dhcp22.suse.cz> <20161201072119.GD18272@dhcp22.suse.cz> <9f2aa4e4-d7d5-e24f-112e-a4b43f0a0ccc@suse.cz> <20161201141125.GB20966@dhcp22.suse.cz>
Date: Thu, 01 Dec 2016 17:03:52 +0100
Message-ID: <xa1t37i7ocuv.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: "Robin H. Johnson" <robbat2@gentoo.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, Joonsoo Kim <js1304@gmail.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, Dec 01 2016, Michal Hocko wrote:
> Let's also CC Marek
>
> On Thu 01-12-16 08:43:40, Vlastimil Babka wrote:
>> On 12/01/2016 08:21 AM, Michal Hocko wrote:
>> > Forgot to CC Joonsoo. The email thread starts more or less here
>> > http://lkml.kernel.org/r/20161130092239.GD18437@dhcp22.suse.cz
>> >=20
>> > On Thu 01-12-16 08:15:07, Michal Hocko wrote:
>> > > On Wed 30-11-16 20:19:03, Robin H. Johnson wrote:
>> > > [...]
>> > > > alloc_contig_range: [83f2a3, 83f2a4) PFNs busy
>> > >=20
>> > > Huh, do I get it right that the request was for a _single_ page? Why=
 do
>> > > we need CMA for that?
>>=20
>> Ugh, good point. I assumed that was just the PFNs that it failed to migr=
ate
>> away, but it seems that's indeed the whole requested range. Yeah sounds =
some
>> part of the dma-cma chain could be smarter and attempt CMA only for e.g.
>> costly orders.
>
> Is there any reason why the DMA api doesn't try the page allocator first
> before falling back to the CMA? I simply have a hard time to see why the
> CMA should be used (and fragment) for small requests size.

There actually may be reasons to always go with CMA even if small
regions are requested.  CMA areas may be defined to map to particular
physical addresses and given device may require allocations from those
addresses.  This may be more than just a matter of DMA address space.
I cannot give you specific examples though and I might be talking
nonsense.

> --=20
> Michal Hocko
> SUSE Labs

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
