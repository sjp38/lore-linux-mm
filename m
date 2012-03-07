Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 86D286B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 02:06:23 -0500 (EST)
From: Krishna Reddy <vdumpa@nvidia.com>
Date: Tue, 6 Mar 2012 23:06:13 -0800
Subject: RE: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
Message-ID: <401E54CE964CD94BAE1EB4A729C7087E37973BEA74@HQMAIL04.nvidia.com>
References: <000001ccfaea$00c16f70$02444e50$%szyprowski@samsung.com><401E54CE964CD94BAE1EB4A729C7087E37970113FE@HQMAIL04.nvidia.com><20120307.080952.2152478004740487196.hdoyu@nvidia.com>
 <20120307.083706.2087121294965856946.hdoyu@nvidia.com>
In-Reply-To: <20120307.083706.2087121294965856946.hdoyu@nvidia.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroshi Doyu <hdoyu@nvidia.com>
Cc: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "shariq.hasnain@linaro.org" <shariq.hasnain@linaro.org>, "arnd@arndb.de" <arnd@arndb.de>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "andrzej.p@samsung.com" <andrzej.p@samsung.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>

> > > It should be as follows.
> > > unsigned int count =3D 1 << get_order(size) - order;
>=20
> To be precise, as below?
>=20
>  unsigned int count =3D 1 << (get_order(size) - order);

Minus has more precedence than left shift.
"1 << get_order(size) - order;" is equivalent to 1 << (get_order(size) - or=
der);

-KR
--nvpublic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
