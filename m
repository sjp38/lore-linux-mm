Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7430F6B0008
	for <linux-mm@kvack.org>; Tue, 22 May 2018 06:23:02 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id n83-v6so18921511itg.2
        for <linux-mm@kvack.org>; Tue, 22 May 2018 03:23:02 -0700 (PDT)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.12])
        by mx.google.com with ESMTPS id t1-v6si13969134iti.65.2018.05.22.03.23.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 03:23:01 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: Re: [RFC PATCH v2 00/12] get rid of GFP_ZONE_TABLE/BAD
Date: Tue, 22 May 2018 10:22:42 +0000
Message-ID: <HK2PR03MB168444ADEEFF5D6397FB94D992940@HK2PR03MB1684.apcprd03.prod.outlook.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@suse.com" <mhocko@suse.com>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "colyli@suse.de" <colyli@suse.de>, NingTing
 Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, Huaisheng Ye <yehs2007@gmail.com>

From: owner-linux-mm@kvack.org On Behalf Of Christoph Hellwig
> This seems to be missing patch 1 and generally be in somewhat odd format.
> Can you try to resend it with git-send-email and against current Linus'
> tree?
>=20
Sure, I will rebase them to current mainline ASAP.

> Also I'd suggest you do cleanups like adding and using __GFP_ZONE_MASK
> at the beginning of the series before doing any real changes.

Ok, thanks for your suggestion.

Sincerely,
Huaisheng Ye
