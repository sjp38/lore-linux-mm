Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id AA53B6B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 06:18:09 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id n21-v6so14395727iob.17
        for <linux-mm@kvack.org>; Tue, 22 May 2018 03:18:09 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.7])
        by mx.google.com with ESMTPS id m129-v6si15198376iof.174.2018.05.22.03.18.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 03:18:08 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: RE: [External]  Re: [RFC PATCH v2 02/12] arch/x86/kernel/amd_gart_64:
 update usage of address zone modifiers
Date: Tue, 22 May 2018 10:17:50 +0000
Message-ID: <HK2PR03MB16847D58C0B62ED73DBD1B2392940@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
 <1526916033-4877-3-git-send-email-yehs2007@gmail.com>
 <20180522093806.GA25671@infradead.org>
In-Reply-To: <20180522093806.GA25671@infradead.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@suse.com" <mhocko@suse.com>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "colyli@suse.de" <colyli@suse.de>, NingTing
 Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Robin Murphy <robin.murphy@arm.com>, Huaisheng Ye <yehs2007@gmail.com>

From: owner-linux-mm@kvack.org On Behalf Of Christoph Hellwig
>=20
> This code doesn't exist in current mainline.  What kernel version
> is your patch against?
>=20
> On Mon, May 21, 2018 at 11:20:23PM +0800, Huaisheng Ye wrote:
> > From: Huaisheng Ye <yehs1@lenovo.com>
> >
> > Use __GFP_ZONE_MASK to replace (__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32=
).
> >
> > ___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 have been deleted from GFP
> > bitmasks, the bottom three bits of GFP mask is reserved for storing
> > encoded zone number.
> > __GFP_DMA, __GFP_HIGHMEM and __GFP_DMA32 should not be operated by OR.
>=20
> If they have already been deleted the identifier should not exist
> anymore, so either your patch has issues, or at least the description.

Dear Christoph,

The kernel version of my patches against is Linux 4.16, the most of
modifications come from include/Linux/gfp.h. I think they should be
pushed to Linux-mm, so I follow the requirement of maintainers to make
patches based on mmotm/master.

I just checked the current mainline, yes,
(__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32) has been deleted, I can
rebase my patches to mainline, and resend them to mail list.

Sincerely,
Huaisheng Ye
