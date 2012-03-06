Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id B1A406B00EB
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 18:36:53 -0500 (EST)
From: Krishna Reddy <vdumpa@nvidia.com>
Date: Tue, 6 Mar 2012 15:36:32 -0800
Subject: RE: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
Message-ID: <401E54CE964CD94BAE1EB4A729C7087E3797011437@HQMAIL04.nvidia.com>
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
 <1330527862-16234-10-git-send-email-m.szyprowski@samsung.com>
 <20120306232138.GF15201@n2100.arm.linux.org.uk>
In-Reply-To: <20120306232138.GF15201@n2100.arm.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-samsung-soc@vger.kernel.org" <linux-samsung-soc@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

> On Wed, Feb 29, 2012 at 04:04:22PM +0100, Marek Szyprowski wrote:
> > +static int arm_iommu_mmap_attrs(struct device *dev, struct
> vm_area_struct *vma,
> > +		    void *cpu_addr, dma_addr_t dma_addr, size_t size,
> > +		    struct dma_attrs *attrs)
> > +{
> > +	struct arm_vmregion *c;
> > +
> > +	vma->vm_page_prot =3D __get_dma_pgprot(attrs, vma-
> >vm_page_prot);
> > +	c =3D arm_vmregion_find(&consistent_head, (unsigned
> long)cpu_addr);
>=20
> What protects this against other insertions/removals from the list?

arm_vmregion_find uses a spin_lock internally before accessing consistent_h=
ead.
 So, it is protected.


-KR

--nvpublic


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
