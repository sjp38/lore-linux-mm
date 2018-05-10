Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 645386B05B4
	for <linux-mm@kvack.org>; Wed,  9 May 2018 23:53:54 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id c82-v6so1109601itg.1
        for <linux-mm@kvack.org>; Wed, 09 May 2018 20:53:54 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.11])
        by mx.google.com with ESMTPS id w5-v6si62523itb.74.2018.05.09.20.53.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 20:53:52 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External] [RFC PATCH v1 3/6] mm, zone_type: create ZONE_NVM and
 fill into GFP_ZONE_TABLE
Date: Thu, 10 May 2018 03:53:34 +0000
Message-ID: <HK2PR03MB16847C0C5F1D9DB6FCF09F9692980@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525746628-114136-1-git-send-email-yehs1@lenovo.com>
 <1525746628-114136-4-git-send-email-yehs1@lenovo.com>
 <HK2PR03MB1684653383FFEDAE9B41A548929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <ce3a6f37-3b13-0c35-6895-35156c7a290c@infradead.org>
 <HK2PR03MB16847B78265A033C7310DDCB92990@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180509114712.GP32366@dhcp22.suse.cz>
 <HK2PR03MB168425F6D00C30918169C77C92990@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180509205609.GV32366@dhcp22.suse.cz>
In-Reply-To: <20180509205609.GV32366@dhcp22.suse.cz>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

>=20
> On Wed 09-05-18 14:04:21, Huaisheng HS1 Ye wrote:
> > > From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On B=
ehalf Of
> Michal Hocko
> > >
> > > On Wed 09-05-18 04:22:10, Huaisheng HS1 Ye wrote:
> [...]
> > > > Current mm treats all memory regions equally, it divides zones just=
 by size,
> like
> > > 16M for DMA, 4G for DMA32, and others above for Normal.
> > > > The spanned range of all zones couldn't be overlapped.
> > >
> > > No, this is not correct. Zones can overlap.
> >
> > Hi Michal,
> >
> > Thanks for pointing it out.
> > But function zone_sizes_init decides
> > arch_zone_lowest/highest_possible_pfn's size by max_low_pfn, then
> > free_area_init_nodes/node are responsible for calculating the spanned
> > size of zones from memblock memory regions.  So, ZONE_DMA and
> > ZONE_DMA32 and ZONE_NORMAL have separate address scope. How can they
> > be overlapped with each other?
>=20
> Sorry, I could have been a bit more specific. DMA, DMA32 and Normal
> zones are exclusive. They are mapped to a specific physical range of
> memory so they cannot overlap. I was referring to a general property
> that zones might interleave. Especially zone Normal, Movable and Device.

Exactly, here ZONE_NVM is a real physical range same as ZONE_DMA, ZONE_DMA3=
2 and ZONE_Normal. So, it couldn't overlap with other zones.
Just like you mentioned, ZONE_MOVABLE is virtual zone, which comes ZONE_Nor=
mal.
The way of virtual zone is another implementation compared with current pat=
ch for ZONE_NVM.
It has advantages but also disadvantages, which need to be clarified and di=
scussed.

Sincerely,
Huaisheng Ye
