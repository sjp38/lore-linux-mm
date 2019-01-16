Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 75C4B8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 22:38:43 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id b186so380551wmc.8
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 19:38:43 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50042.outbound.protection.outlook.com. [40.107.5.42])
        by mx.google.com with ESMTPS id x7si51457090wrw.135.2019.01.15.19.38.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 19:38:41 -0800 (PST)
From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [rpmsg PATCH v2 1/1] rpmsg: virtio_rpmsg_bus: fix unexpected huge
 vmap mappings
Date: Wed, 16 Jan 2019 03:38:38 +0000
Message-ID: 
 <VI1PR0402MB36000DE975EBFBD40D1352C4FF820@VI1PR0402MB3600.eurprd04.prod.outlook.com>
References: <1545812449-32455-1-git-send-email-fugang.duan@nxp.com>
 <CAKv+Gu-zfTZAZfiQt1iUn9otqeDkJP-y-siuBUrWUR-Kq=BsVQ@mail.gmail.com>
 <20181226145048.GA24307@infradead.org>
 <VI1PR0402MB3600AC833D6F29ECC34C8D4CFFB60@VI1PR0402MB3600.eurprd04.prod.outlook.com>
 <20181227121901.GA20892@infradead.org>
 <VI1PR0402MB3600799A06B6BFE5EBF8837FFFB70@VI1PR0402MB3600.eurprd04.prod.outlook.com>
 <VI1PR0402MB36000BD05AF4B242E13D9D05FF840@VI1PR0402MB3600.eurprd04.prod.outlook.com>
 <20190110140726.GA6223@infradead.org>
 <VI1PR0402MB3600E7160A2921A8D3DCA055FF850@VI1PR0402MB3600.eurprd04.prod.outlook.com>
 <20190114095315.GA24495@infradead.org>
In-Reply-To: <20190114095315.GA24495@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "bjorn.andersson@linaro.org" <bjorn.andersson@linaro.org>, "ohad@wizery.com" <ohad@wizery.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Robin Murphy <robin.murphy@arm.com>, "linux-remoteproc@vger.kernel.org" <linux-remoteproc@vger.kernel.org>, "anup@brainfault.org" <anup@brainfault.org>, "loic.pallardy@st.com" <loic.pallardy@st.com>, dl-linux-imx <linux-imx@nxp.com>, Richard Zhu <hongxing.zhu@nxp.com>, Jason Liu <jason.hui.liu@nxp.com>, Peng Fan <peng.fan@nxp.com>

From: Christoph Hellwig <hch@infradead.org> Sent: Monday, January 14, 2019 =
5:53 PM
> On Fri, Jan 11, 2019 at 01:28:46AM +0000, Andy Duan wrote:
> > As NXP i.MX8 platform requirement that M4 only access the fixed memory
> > region, so do You have any suggestion to fix the issue and satisfy the
> > requirement ? Or do you have plan To fix the root cause ?
>=20
> I think the answer is to use RESERVEDMEM_OF_DECLARE without the DMA
> coherent boilerplate code.
If use RESERVEDMEM_OF_DECLARE with DMA contiguous code (CMA), it can
match the requirement, but as you know, the CMA size alignment is 32M bytes=
,
we only need 8M bytes contiguous mem for rpmsg.

>=20
> For the initial prototype just do it inside the driver, although I'd like=
 to
> eventually factor this out into common code, especially if my proposal fo=
r
> more general availability of DMA_ATTR_NON_CONSISTENT goes ahead.
