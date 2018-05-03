Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D04256B0005
	for <linux-mm@kvack.org>; Thu,  3 May 2018 10:05:57 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f9-v6so10863392iob.14
        for <linux-mm@kvack.org>; Thu, 03 May 2018 07:05:57 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.15])
        by mx.google.com with ESMTPS id a129-v6si11382126ite.1.2018.05.03.07.05.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 07:05:56 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [PATCH] include/linux/gfp.h: use unsigned int in gfp_zone
Date: Thu, 3 May 2018 14:05:28 +0000
Message-ID: <HK2PR03MB16841DAECCD847FDEB812D6A92870@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525319098-91429-1-git-send-email-yehs1@lenovo.com>
 <20180503074327.GA4535@dhcp22.suse.cz>
In-Reply-To: <20180503074327.GA4535@dhcp22.suse.cz>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>

 > On Thu 03-05-18 11:44:58, Huaisheng Ye wrote:
> > Suggest using unsigned int instead of int for bit within gfp_zone.
> >
> > The value of bit comes from flags, which's type is gfp_t. And it
> > indicates the number of bits in the right shift for GFP_ZONE_TABLE.
> >
> > Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
>=20
> The patch looks OK but it misses the most important piece of
> information. Why this is worth changing. Does it lead to a better code?
> Silence a warning or...
>=20
Yes, thank you and I will rewrite the commit log later.

Sincerely,
Huaisheng, Ye
> > ---
> >  include/linux/gfp.h | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index 1a4582b..21551fc 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -401,7 +401,7 @@ static inline bool gfpflags_allow_blocking(const gf=
p_t
> gfp_flags)
> >  static inline enum zone_type gfp_zone(gfp_t flags)
> >  {
> >  	enum zone_type z;
> > -	int bit =3D (__force int) (flags & GFP_ZONEMASK);
> > +	unsigned int bit =3D (__force unsigned int) (flags & GFP_ZONEMASK);
> >
> >  	z =3D (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
> >  					 ((1 << GFP_ZONES_SHIFT) - 1);
> > --
> > 1.8.3.1
> >
>=20
> --
> Michal Hocko
> SUSE Labs
