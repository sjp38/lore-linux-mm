Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9536B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 05:03:06 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k9-v6so14863910ioa.6
        for <linux-mm@kvack.org>; Wed, 30 May 2018 02:03:06 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.4])
        by mx.google.com with ESMTPS id 78-v6si15042493itj.4.2018.05.30.02.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 02:03:05 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [RFC PATCH v2 00/12] get rid of
 GFP_ZONE_TABLE/BAD
Date: Wed, 30 May 2018 09:02:13 +0000
Message-ID: <HK2PR03MB1684C44F2408F3927B1A21BC926C0@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
 <20180522183728.GB20441@dhcp22.suse.cz>
 <HK2PR03MB16847646E90A10E2D48CEA8E926B0@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180524121853.GG20441@dhcp22.suse.cz>
 <HK2PR03MB1684ED6EC6859A88A196DC0C92690@HK2PR03MB1684.apcprd03.prod.outlook.com>
 <20180528133733.GF27180@dhcp22.suse.cz>
In-Reply-To: <20180528133733.GF27180@dhcp22.suse.cz>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On Behalf =
Of Michal Hocko
Sent: Monday, May 28, 2018 9:38 PM
> > In my opinion, originally there shouldn't be such many wrong
> > combinations of these bottom 3 bits. For any user, whether or
> > driver and fs, they should make a decision that which zone is they
> > preferred. Matthew's idea is great, because with it the user must
> > offer an unambiguous flag to gfp zone bits.
>=20
> Well, I would argue that those shouldn't really care about any zones at
> all. All they should carea bout is whether they really need a low mem
> zone (aka directly accessible to the kernel), highmem or they are the
> allocation is generally movable. Mixing zones into the picture just
> makes the whole thing more complicated and error prone.

Dear Michal,

I don't quite understand that. I think those, mostly drivers, need to
get the correct zone they want. ZONE_DMA32 is an example, if drivers can be
satisfied with a low mem zone, why they mark the gfp flags as
'GFP_KERNEL|__GFP_DMA32'?
GFP_KERNEL is enough to make sure a directly accessible low mem, but it is
obvious that they want to get a DMA accessible zone below 4G.

> This should be a part of the changelog. Please note that you should
> provide some number if you claim performance benefits. The complexity
> will always be subjective.

Sure, I will post them to changelog with next version of patches.

Sincerely,
Huaisheng Ye
