Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id ECC536B0324
	for <linux-mm@kvack.org>; Wed, 16 May 2018 08:12:29 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o189-v6so1040142itc.8
        for <linux-mm@kvack.org>; Wed, 16 May 2018 05:12:29 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.9])
        by mx.google.com with ESMTPS id b17-v6si2235704ioa.15.2018.05.16.05.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 05:12:28 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [PATCH v1] include/linux/gfp.h: getting rid of
 GFP_ZONE_TABLE/BAD
Date: Wed, 16 May 2018 12:12:00 +0000
Message-ID: <HK2PR03MB1684A881A868E9676C7E55E692920@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525968625-40825-1-git-send-email-yehs1@lenovo.com>
 <20180510163023.GB30442@bombadil.infradead.org>
 <HK2PR03MB16843E14AD56B3E546D9F52D929F0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180511132613.GA30263@bombadil.infradead.org>
 <HK2PR03MB1684BC9802BC2E5C1BF2DC74929E0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180512142249.GA24215@bombadil.infradead.org>
In-Reply-To: <20180512142249.GA24215@bombadil.infradead.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> From: Matthew Wilcox [mailto:willy@infradead.org]
> Sent: Saturday, May 12, 2018 10:23 PM>=20
> On Sat, May 12, 2018 at 11:35:00AM +0000, Huaisheng HS1 Ye wrote:
> > > The point of this exercise is to actually encode the zone number in
> > > the bottom bits of the GFP flags instead of something which has to be
> > > interpreted into a zone number.  When somebody sets __GFP_MOVABLE, th=
ey
> > > should also be setting ZONE_MOVABLE:
> > >
> > > -#define __GFP_MOVABLE   ((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOV=
ABLE allowed
> */
> > > +#define __GFP_MOVABLE   ((__force gfp_t)(___GFP_MOVABLE | (ZONE_MOVA=
BLE ^
> ZONE_NORMAL)))
> > >
> > I am afraid we couldn't do that, because __GFP_MOVABLE would be used po=
tentially
> with other __GFPs like __GFP_DMA and __GFP_DMA32.
>=20
> That's not a combination that makes much sense.  I know it's permitted to=
day
> (and it has the effect of being a no-op), but when you think about it, it
> doesn't actually make any sense.

Yes, you are right.
After checking almost all references of __GFP_MOVABLE and other __GFP_* fla=
gs, perhaps I was far to get excessive pursuit of logical correctness.
For those nonsense combinations, I should ignore them.
Current GFP_ZONE_TABLE can ensure all logical correctness. That makes me wa=
nt to pursue same effect.

Next, I will revise the patch according to your advice, then try to get ove=
rall testing result as far as possible.
There are many combinations because of a lot of conditions in file system a=
nd drivers. Hope I could test all things related to the lower 4 bits of gfp=
.

Sincerely,
Huaisheng Ye
