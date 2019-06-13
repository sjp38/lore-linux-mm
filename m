Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EB1AC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:16:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D014220896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:16:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="V7VdZPIW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D014220896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48DE98E0004; Thu, 13 Jun 2019 15:16:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43D278E0001; Thu, 13 Jun 2019 15:16:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 306108E0004; Thu, 13 Jun 2019 15:16:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D3BE58E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 15:16:39 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i44so182498eda.3
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:16:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=C2ooA++QqJXVlMpml0l+q+BdnlFCXX3DPFCvyDRLpE4=;
        b=Mhhyy8bDczOyc2lp9OFa3xx1sCM/VXD5Lq8waAAuoZCSEUZ9Xyo7H5NuMh0l9Pteg9
         Aq6mmn8fGmUpXgO2Fx+6ch6FZJDBS6K4OfP48x/sTN6gOjFiZJskPG9vYKKS8WvhYrZv
         U1offvpmcilkKOxYCga5CjbI0802q7Z1OmYKjOvkL/UckKE6qEOo+Uh3/O9IH8wZiNMq
         hzEteFdnb/fLl13axeSq1X3QwlmRtWSDsjmGH0AEbFinavmPM3H2d1LhdCXDF9AP/G2d
         Vp51A3M3Hwp+3ECkt/YXv4om3cK5npHQsH+N2rRSajS+Wf9ekWV5cm5ieYTjtfVK09vI
         BiTQ==
X-Gm-Message-State: APjAAAWX+n375ht/YrU5yiS4cagacxaGloX2/C+N1NicSjpIYQZ1q7Tw
	hjeZ2yknGbfIkXdmYyIeD7AFQBwgwCwmcNPFwnegnKt/lv+PHLIotbR+gX5zFLkDTpfwnS8OZe2
	KwHtb9IRznSljt4fl8FSn8N9UYog42/SOeBV0qa3rn5EJcJ1qBIjB5Nh+fLMs55iGKg==
X-Received: by 2002:a17:906:a394:: with SMTP id k20mr58096963ejz.46.1560453399158;
        Thu, 13 Jun 2019 12:16:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7lCvOlhfx/iUkpJRppbV5iGX5eqnDIRIt9+ZAU2WJya/O1scU3H3ILTWiSkz5RDdCWHSH
X-Received: by 2002:a17:906:a394:: with SMTP id k20mr58096905ejz.46.1560453398382;
        Thu, 13 Jun 2019 12:16:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560453398; cv=none;
        d=google.com; s=arc-20160816;
        b=ZHBeIJ82R+WB80ktJzO7X5OSjMcoUnCO7oXOgaZ2E0nPq2Zqil4jbYqbUJ5d1E0ImF
         w66PlCBpH12f5z7/+yDtA6vHTpCnIRlMQLcbFFvk2/N9aZzfsWYDtsIrG87+of+Ljxew
         F42iCkC4PfDyfQh4tj1mW5g6m6eNiRG9onJRhuxWFd6AtKIw5hhAC20Mm76z5k3tzJz2
         EOxOMKby0rwzALUD2Pv4Ax2E/1h4dHdaUbfvfpNv6n0I8zmjlJfYNdu0V5GF1vjVSyVn
         PKAUx9AIGwyZM8oRxJNB715xTSl2Yne3e9QpUU1+GP33Qn0DKzBxKJZZAeZYR7kxW0Pz
         aTmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=C2ooA++QqJXVlMpml0l+q+BdnlFCXX3DPFCvyDRLpE4=;
        b=TUTUJlAJJNThG2aMxB/GrWV7GYyHOCXBeuJzfWUV8sGGxo0LvRXc70ny7dWLVhiB4T
         nu4DlEamhKNukh8albLvvMVhT2hH/3rgDyYV1+gWZ8ztJGwPvkbqC3FFTIuBhjUsS7UQ
         QBTiLHxZ7gt1VQY9V85LckfgUki5nghnZD7dL/WFvb+hZ/qOpn5i8qJe3CFUsY5ypKVh
         NgD6pB7iOKnjUVcYDQDJMPhWIbg493XoNTBJywHL0vdaKiiogJ1468brfgmWblg+v9L7
         cMYN7VrJdSz+BbGjslzYkvFHP33pMZYT/Zdm02SoWdqSHlFeLu8U5sXpCPjPHascCgjp
         aefA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=V7VdZPIW;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.4.61 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40061.outbound.protection.outlook.com. [40.107.4.61])
        by mx.google.com with ESMTPS id q36si323817edd.119.2019.06.13.12.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 12:16:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.4.61 as permitted sender) client-ip=40.107.4.61;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=V7VdZPIW;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.4.61 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=C2ooA++QqJXVlMpml0l+q+BdnlFCXX3DPFCvyDRLpE4=;
 b=V7VdZPIW66HTni0sHwNdEjjdDESzWYwqXMwBxw2LLk5LoAJiR7gEkp792/H4jtLGYu+L8eFquUi1EoB04iJ1YctP1g14sKdnujwae/ViEaseDfs2dEtdmmSX8qEvGgK5tOZWxb7lEJQrP+ir1nxP2FQrgL8CSAuAUrHqhDUA1L0=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6030.eurprd05.prod.outlook.com (20.178.127.208) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.10; Thu, 13 Jun 2019 19:16:35 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 19:16:35 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 06/22] mm: factor out a devm_request_free_mem_region
 helper
Thread-Topic: [PATCH 06/22] mm: factor out a devm_request_free_mem_region
 helper
Thread-Index: AQHVIcyBwDOm/h2tmE+QYz8Gijo2yqaZ9WQA
Date: Thu, 13 Jun 2019 19:16:35 +0000
Message-ID: <20190613191626.GR22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-7-hch@lst.de>
In-Reply-To: <20190613094326.24093-7-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTXPR0101CA0024.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00::37) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: aee64c42-1b0a-4c20-67ad-08d6f033a6ea
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6030;
x-ms-traffictypediagnostic: VI1PR05MB6030:
x-microsoft-antispam-prvs:
 <VI1PR05MB6030C106FA4C6D235C27E224CFEF0@VI1PR05MB6030.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3826;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(346002)(396003)(366004)(39860400002)(376002)(189003)(199004)(54094003)(36756003)(11346002)(6916009)(8936002)(33656002)(71190400001)(71200400001)(8676002)(476003)(2616005)(6512007)(7416002)(478600001)(81166006)(53936002)(66066001)(6436002)(229853002)(6486002)(54906003)(25786009)(486006)(81156014)(7736002)(102836004)(305945005)(26005)(186003)(5660300002)(66946007)(2906002)(73956011)(66556008)(6246003)(64756008)(66446008)(68736007)(1076003)(386003)(6506007)(6116002)(99286004)(256004)(76176011)(4326008)(14444005)(3846002)(316002)(14454004)(446003)(86362001)(66476007)(52116002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6030;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 gFYuGZngpuoWy6b/5P5+pZVhkYde8Vg4kuhBxMcM8WgNyeQuKyOzuYbYK+RZsXWyfP/fL1+P5JypqG+u+CCNKCqx7kGWiq9gVi/HHoc0v0f3UAL12m0S3zuXKyGXJDgW1QGe4SgzinVfrsOl/J99CyKMUWmPdhiMu90UjK0JtzVQVPyjXo1X7SudjInUW2xRbSGM25XY7fRoRneHQf8lbmE+bXyLamYlgzoSP8F3p0bi6etqGNMjp6bsKZqHCvbAqOvFJl78eeDUdR4ue8gf4ehfZp+F2sOSFWF9/hKp9VBA11Qrx7YGIofrJsayt1HWVs4LtEH6D83v+8gp2SHUXo0fULNWMmscGL0nKZ81+v2nK5HIrTA5n4usC71bywolPMNxpW6IhQhEVBdGe0tbfQbiHZMP++kJVuhYlLI5T14=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <4BAAE06211A39D40A138C3AEA8033A18@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: aee64c42-1b0a-4c20-67ad-08d6f033a6ea
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 19:16:35.7010
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6030
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:43:09AM +0200, Christoph Hellwig wrote:
> Keep the physical address allocation that hmm_add_device does with the
> rest of the resource code, and allow future reuse of it without the hmm
> wrapper.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  include/linux/ioport.h |  2 ++
>  kernel/resource.c      | 39 +++++++++++++++++++++++++++++++++++++++
>  mm/hmm.c               | 33 ++++-----------------------------
>  3 files changed, 45 insertions(+), 29 deletions(-)
>=20
> diff --git a/include/linux/ioport.h b/include/linux/ioport.h
> index da0ebaec25f0..76a33ae3bf6c 100644
> +++ b/include/linux/ioport.h
> @@ -286,6 +286,8 @@ static inline bool resource_overlaps(struct resource =
*r1, struct resource *r2)
>         return (r1->start <=3D r2->end && r1->end >=3D r2->start);
>  }
> =20
> +struct resource *devm_request_free_mem_region(struct device *dev,
> +		struct resource *base, unsigned long size);
> =20
>  #endif /* __ASSEMBLY__ */
>  #endif	/* _LINUX_IOPORT_H */
> diff --git a/kernel/resource.c b/kernel/resource.c
> index 158f04ec1d4f..99c58134ed1c 100644
> +++ b/kernel/resource.c
> @@ -1628,6 +1628,45 @@ void resource_list_free(struct list_head *head)
>  }
>  EXPORT_SYMBOL(resource_list_free);
> =20
> +#ifdef CONFIG_DEVICE_PRIVATE
> +/**
> + * devm_request_free_mem_region - find free region for device private me=
mory
> + *
> + * @dev: device struct to bind the resource too
> + * @size: size in bytes of the device memory to add
> + * @base: resource tree to look in
> + *
> + * This function tries to find an empty range of physical address big en=
ough to
> + * contain the new resource, so that it can later be hotpluged as ZONE_D=
EVICE
> + * memory, which in turn allocates struct pages.
> + */
> +struct resource *devm_request_free_mem_region(struct device *dev,
> +		struct resource *base, unsigned long size)
> +{
> +	resource_size_t end, addr;
> +	struct resource *res;
> +
> +	size =3D ALIGN(size, 1UL << PA_SECTION_SHIFT);
> +	end =3D min_t(unsigned long, base->end, (1UL << MAX_PHYSMEM_BITS) - 1);

Even fixed it to use min_t

> +	addr =3D end - size + 1UL;
> +	for (; addr > size && addr >=3D base->start; addr -=3D size) {
> +		if (region_intersects(addr, size, 0, IORES_DESC_NONE) !=3D
> +				REGION_DISJOINT)
> +			continue;

The FIXME about the algorithm cost seems justified though, yikes.

> +
> +		res =3D devm_request_mem_region(dev, addr, size, dev_name(dev));
> +		if (!res)
> +			return ERR_PTR(-ENOMEM);
> +		res->desc =3D IORES_DESC_DEVICE_PRIVATE_MEMORY;

I wonder if IORES_DESC_DEVICE_PRIVATE_MEMORY should be a function
argument?

Not really any substantive remark, so

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

