Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 80AFB6B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 16:02:11 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id j10so41209147wjb.3
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 13:02:11 -0800 (PST)
Received: from mail-wj0-x231.google.com (mail-wj0-x231.google.com. [2a00:1450:400c:c01::231])
        by mx.google.com with ESMTPS id jd4si1832564wjb.273.2016.12.01.13.02.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 13:02:10 -0800 (PST)
Received: by mail-wj0-x231.google.com with SMTP id mp19so216036995wjc.1
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 13:02:10 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: drm/radeon spamming alloc_contig_range: [xxx, yyy) PFNs busy busy
In-Reply-To: <20161201161117.GD20966@dhcp22.suse.cz>
References: <20161130092239.GD18437@dhcp22.suse.cz> <xa1ty4012k0f.fsf@mina86.com> <20161130132848.GG18432@dhcp22.suse.cz> <robbat2-20161130T195244-998539995Z@orbis-terrarum.net> <robbat2-20161130T195846-190979177Z@orbis-terrarum.net> <20161201071507.GC18272@dhcp22.suse.cz> <20161201072119.GD18272@dhcp22.suse.cz> <9f2aa4e4-d7d5-e24f-112e-a4b43f0a0ccc@suse.cz> <20161201141125.GB20966@dhcp22.suse.cz> <xa1t37i7ocuv.fsf@mina86.com> <20161201161117.GD20966@dhcp22.suse.cz>
Date: Thu, 01 Dec 2016 22:02:07 +0100
Message-ID: <xa1twpfjmkhc.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Robin H. Johnson" <robbat2@gentoo.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, Joonsoo Kim <js1304@gmail.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, Dec 01 2016, Michal Hocko wrote:
> I am not familiar with this code so I cannot really argue but a quick
> look at rmem_cma_setup doesn't suggest any speicific placing or
> anything...

early_cma parses =E2=80=98cma=E2=80=99 command line argument which can spec=
ify where
exactly the default CMA area is to be located.  Furthermore, CMA areas
can be assigned per-device (via the Device Tree IIRC).

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
