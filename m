Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56D386B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 02:15:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x17-v6so9716288pfm.18
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 23:15:52 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f3-v6si10416153plr.214.2018.06.18.23.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 23:15:51 -0700 (PDT)
Date: Tue, 19 Jun 2018 09:15:48 +0300
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180619061548.GC7557@mtr-leonro.mtl.com>
References: <20180617012510.20139-1-jhubbard@nvidia.com>
 <20180617012510.20139-3-jhubbard@nvidia.com>
 <CAPcyv4i=eky-QrPcLUEqjsASuRUrFEWqf79hWe0mU8xtz6Jk-w@mail.gmail.com>
 <20180617200432.krw36wrcwidb25cj@ziepe.ca>
 <CAPcyv4gayKk_zHDYAvntware12qMXWjnnL_FDJNUQsJS_zNfDw@mail.gmail.com>
 <20180618081113.GA16991@lst.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7iMSBzlTiPOCCT2k"
Content-Disposition: inline
In-Reply-To: <20180618081113.GA16991@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>


--7iMSBzlTiPOCCT2k
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jun 18, 2018 at 10:11:13AM +0200, Christoph Hellwig wrote:
> On Sun, Jun 17, 2018 at 01:10:04PM -0700, Dan Williams wrote:
> > I believe kernel behavior regression is a primary concern as now
> > fallocate() and truncate() can randomly fail where they didn't before.
>
> Fail or block forever due to actions of other unprivileged users.
>
> That is a complete no-go.

They will fail "properly" with some error, which is better than current
situation where those unprivileged users can trigger oops.

Thanks

--7iMSBzlTiPOCCT2k
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJbKJ+UAAoJEORje4g2clin69QP/jWFR8E7MKYfBqiosGF6OPVf
qxjEVTcaIMnnC6GrMykfAnOg7ApYKitetux5SV3+h+EChVTck2nQacbNKGC+kRJ1
bPKSM2qVPUSgcsfj5kDPXHslVZdhnuYp066rnGkc7CJEfnrMTpcexgOkCQW7iQb/
B+dpa2VaC5G14XoxVBpONweQ+NedTSX8lLemYazAsY6nm8uwVDAQqdk8bu2F0ayp
zoarTVCwYV7ENdv0rTkhLyPtB207GHoeCweSU/kj7mdj8Pbaf1CDzxIlOvY4djSC
Ia5fscHImRT29r8oIIlTI7JfLwsQaPye03o0AZ++qPhwmlGfspJy1dwYea0eMChl
CvgSigrS22txh367GZ70hn9lpHIAeuUP85RVVODN3tXokJS5cJNHT4n5lwdItcii
GDaXUzVx+a1Qio3J/mb/4MvLstCbE1Y4r2nYj2ag5gL1XuLPdqp8icYM6OEPQ2lf
B6z8OF6uQu0bzXj/m//Rep1bhwRnVjgrTVDzc67+hscq/BswhhAx04+COquTEXxv
TpHOraax/ZLN31lLQ/3QUIMKUZNvuhWVl2ARQJXtb8hmbPo+zQYkuP+ip8DmD5ny
wvtHqR04dCCwDEp1VmoPFe3PJy+zQvBHe18OyjyuarokNQNZCVAO0pNfivzibwFm
m1W/BwqX6Z3QRrQrQtYA
=LD7E
-----END PGP SIGNATURE-----

--7iMSBzlTiPOCCT2k--
