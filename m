Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 514E46B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 10:54:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i23so3468125pfi.5
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 07:54:27 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e16si12680525pli.328.2017.10.12.07.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 07:54:26 -0700 (PDT)
Date: Thu, 12 Oct 2017 17:54:20 +0300
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH for-next 2/4] RDMA/hns: Add IOMMU enable support in hip08
Message-ID: <20171012145420.GQ2106@mtr-leonro.local>
References: <1506763741-81429-1-git-send-email-xavier.huwei@huawei.com>
 <1506763741-81429-3-git-send-email-xavier.huwei@huawei.com>
 <20170930161023.GI2965@mtr-leonro.local>
 <59DF60A3.7080803@huawei.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="kZU6r8y0YpRwyDfh"
Content-Disposition: inline
In-Reply-To: <59DF60A3.7080803@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Cc: dledford@redhat.com, linux-rdma@vger.kernel.org, lijun_nudt@163.com, oulijun@huawei.com, charles.chenxin@huawei.com, liuyixian@huawei.com, linux-mm@kvack.org, zhangxiping3@huawei.com, xavier.huwei@tom.com, linuxarm@huawei.com, linux-kernel@vger.kernel.org, shaobo.xu@intel.com, shaoboxu@tom.com, leizhen 00275356 <thunder.leizhen@huawei.com>, joro@8bytes.org, iommu@lists.linux-foundation.org


--kZU6r8y0YpRwyDfh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Oct 12, 2017 at 08:31:31PM +0800, Wei Hu (Xavier) wrote:
>
>
> On 2017/10/1 0:10, Leon Romanovsky wrote:
> > On Sat, Sep 30, 2017 at 05:28:59PM +0800, Wei Hu (Xavier) wrote:
> > > If the IOMMU is enabled, the length of sg obtained from
> > > __iommu_map_sg_attrs is not 4kB. When the IOVA is set with the sg
> > > dma address, the IOVA will not be page continuous. and the VA
> > > returned from dma_alloc_coherent is a vmalloc address. However,
> > > the VA obtained by the page_address is a discontinuous VA. Under
> > > these circumstances, the IOVA should be calculated based on the
> > > sg length, and record the VA returned from dma_alloc_coherent
> > > in the struct of hem.
> > >
> > > Signed-off-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
> > > Signed-off-by: Shaobo Xu <xushaobo2@huawei.com>
> > > Signed-off-by: Lijun Ou <oulijun@huawei.com>
> > > ---
> > Doug,
> >
> > I didn't invest time in reviewing it, but having "is_vmalloc_addr" in
> > driver code to deal with dma_alloc_coherent is most probably wrong.
> >
> > Thanks
> Hi,  Leon & Doug
>     We refered the function named __ttm_dma_alloc_page in the kernel code as
> below:
>     And there are similar methods in bch_bio_map and mem_to_page functions
> in current 4.14-rcx.

Let's put aside TTM, I don't know the rationale behind their implementation,
but both mem_to_page and bch_bio_map are don't operate on DMA addresses
and don't belong to HW driver code.

Thanks

--kZU6r8y0YpRwyDfh
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnfghwACgkQ5GN7iDZy
WKfnThAAkCAcg/gWetYtOCp2APtHDSYURzJFAsyQ3tk4q5WJKXHWNGp+BDn/EVdo
5XyF/anfFiZSh7fQytyXrWDwwfuLeJhR0zBX3N2OnywXImA1+x05Y3UkNb5HZRbR
rYxOkthJgvw7fydhPxcg+NOvZFF28Fgb8JrRF/WbaXPU+fC6363zpTENzAGjdkXv
BoFHQhBne0SpmgZgooC2Twuk6NJP4ITCNt67q09kd1nojMfWwqBuXvsqi9QmCZAh
vY+Yt2UkJxvuTD/46lppqhRil9EhTOENGGZtgBU6nmzOIbZR/lZd+OQr1qpsMWL5
KqSUyuWNRoL+hpDQ584lW8dKT/3OfUnCF4ec4O7SfDwfxOlSiZB1RLb3LlZFBrKc
7L18ZS5MPJev9fjXNUq1dD2t9dLUZ8KJU+2NFQdF8X/BYZZcFO8UxfTJN6a1rkLn
DnDGlMJ0RmuJ0N9evJuM2Jd/eEpxmCfERSL+3tykkcZln1CJsAwHJ5L5C9igpwg+
+1W9eZcrUdn7VgF/7NkG0kYr0DKmSL3k1R/t5BykGvIf5fHIwsWCPBE80bV3CNXm
Mb4JdmFimeDKpscU86C0s29e079lftQMvMWG4TIyV8pBVJ8Tibj9W+NKjNuR8sTs
sC8d+BythwvjzNa9wfmF+3imQCti8r8waoX+UavmbhPKMoaNnfE=
=y/UZ
-----END PGP SIGNATURE-----

--kZU6r8y0YpRwyDfh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
