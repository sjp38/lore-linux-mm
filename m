Return-Path: <SRS0=C2dt=WH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37394C0650F
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 22:56:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAC502084D
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 22:56:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="c1mCYEUA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAC502084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 740CD6B0005; Sun, 11 Aug 2019 18:56:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C9E16B0006; Sun, 11 Aug 2019 18:56:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51C756B0007; Sun, 11 Aug 2019 18:56:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0021.hostedemail.com [216.40.44.21])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7036B0005
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 18:56:12 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id CEA74443F
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 22:56:11 +0000 (UTC)
X-FDA: 75811656942.11.rod89_18e979b6cc25c
X-HE-Tag: rod89_18e979b6cc25c
X-Filterd-Recvd-Size: 8824
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40065.outbound.protection.outlook.com [40.107.4.65])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 22:56:11 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=BrXCG6n+bb0YloriCZcAoLBoXRFIWK8pMvd3mk889MQO6lwfGq4LDwkMpw2q4c4K3AgBgW7l7n6iFyQESYIcybBDHx8Bsa06eqGQPxJcm5q5jXxlPWw1hMByGESW8pQi5r6yM4J1o9250i9wjRlkp54H4s0eARlsFqHQtpzF2EQ+m3kX0KP5WdcOJ/MJlUSXR4Cz/sn8TiwYHFZexSgDTBk0RShFVnvNJ1rmeW8ge7NmAxnz2XNyZGcgSJ34k3H/ULtIiskpBLUEoyI+Cm+hzV/rELQ12HyXzMtjzb74yYL7fWOtIvtrFXi5UOdb/FP59NaM0P76NQgra3DlClVx2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ihfbq1g2wtVZgYIFvUAvnGn/h6LqBxie/7S7V1d3dzI=;
 b=KXbpReFVMurDX2qyT1+4z6Frj8byLKytKxA86TgLeN7012aPzIUz+HusBadc9j4nfx20SWgHjQtsVl8l54kMUPOqhU9fNjZlbfgcgmNv6EPmYXipZVmMnnnBTdMioOAW6010UsGBYRUT/xdWP3VLCaX70zSiZ+G4rq3nDMG0ZREy0vFRcQZ++/0lCOoH9GlydNhuFakzRbn+lUJIzaa+K2HYhLHRQf32gxZzri73aStaSMxv7DFyOQnHTS3zzPQkwDNU2eMwyXlR4yf+We0qgoZeddXo6lSEeUi/NKz7WqoJW6qsavJtW5vcknMBlrYCGRUcWK58TFuPU1xgG2gNzg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ihfbq1g2wtVZgYIFvUAvnGn/h6LqBxie/7S7V1d3dzI=;
 b=c1mCYEUAHJQahMbfqNKiIj0+nLdJ2yqCZ/+o05jX0UDw8M5LlEr+qHTIw15gIOMI4uvpba8f4Ouu3FodRN+rin1ZoqUw//2w9/opws5KNUPo14LgORJtfW8LU28kTVy6w95YDLYWcvL1XmdCqD/nYCxSonvr9Vuk1m7MWjDil7g=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4446.eurprd05.prod.outlook.com (52.133.13.30) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.18; Sun, 11 Aug 2019 22:56:08 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2157.022; Sun, 11 Aug 2019
 22:56:08 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Dan Williams <dan.j.williams@intel.com>, Bharata B Rao
	<bharata@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org"
	<linux-nvdimm@lists.01.org>
Subject: Re: [PATCH 5/5] memremap: provide a not device managed memremap_pages
Thread-Topic: [PATCH 5/5] memremap: provide a not device managed
 memremap_pages
Thread-Index: AQHVUBydJp9sIgJNiEmz+d6Kh5T6pKb2j6uA
Date: Sun, 11 Aug 2019 22:56:07 +0000
Message-ID: <20190811225601.GC15116@mellanox.com>
References: <20190811081247.22111-1-hch@lst.de>
 <20190811081247.22111-6-hch@lst.de>
In-Reply-To: <20190811081247.22111-6-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0058.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:1::35) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: da46094c-32aa-437f-8eb9-08d71eaf18a0
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:VI1PR05MB4446;
x-ms-traffictypediagnostic: VI1PR05MB4446:
x-microsoft-antispam-prvs:
 <VI1PR05MB444687D8FB939B16D58BAD6ECFD00@VI1PR05MB4446.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0126A32F74
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(396003)(346002)(376002)(366004)(39860400002)(189003)(199004)(26005)(76176011)(102836004)(6916009)(386003)(6506007)(52116002)(53936002)(446003)(11346002)(2616005)(476003)(486006)(14454004)(36756003)(66066001)(81166006)(229853002)(8676002)(81156014)(478600001)(6246003)(4326008)(6116002)(33656002)(25786009)(256004)(316002)(3846002)(5660300002)(6436002)(2906002)(71190400001)(71200400001)(1076003)(6486002)(305945005)(8936002)(6512007)(54906003)(186003)(86362001)(66446008)(7736002)(66476007)(5024004)(99286004)(66946007)(66556008)(64756008);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4446;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 0PFxO0rcI6aS5QTFOfDBaZYlxKrMcnDFRo9AsDqL5Yv2l3TCxORxA8M6LJgp2Jzn20I32HcagLrns80CZqv0GT1ONU1VCbmxSjXx9HuJIS1gLqWlnmSK19pLkjTfCv/R7Qe+3DayEV+zr3cfKOlxLgpHXwsunesiTj7UazNBgcuBdl8l6uwMHaDEIbZZotk1pBFitRGZ0bZStUCtIp0rqbgih50I/sn/dUMtb4obqcyr/KTctHQ14luchwUsMOavbazZQ9jy77NQN9DNbKakLHveqzZMz780Jmiknp2ee3fx8yIuPd8ORkoSBlmRnQm1aansToKO/aYVvVh+oTyjIoT2d8riNGZDdKdmUwI4kI1BXNY5IocWAmEEz7Z0eeprWichM2Ctz2U2il7NEv0/HCj/RF4zp0c7Eas1BkkGL4g=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8D1BA42D29E93F4995158A7AF3F2DFA1@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: da46094c-32aa-437f-8eb9-08d71eaf18a0
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Aug 2019 22:56:07.9299
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: nYbcecdaUhkaf74EDCnMPyf59qsfc4TZ5wh2Ft4QeFseo/6onKC82venBEVzDlioMk6MQS7wuFxHhpolvsYfNA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4446
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 11, 2019 at 10:12:47AM +0200, Christoph Hellwig wrote:
> The kvmppc ultravisor code wants a device private memory pool that is
> system wide and not attached to a device.  Instead of faking up one
> provide a low-level memremap_pages for it.  Note that this function is
> not exported, and doesn't have a cleanup routine associated with it to
> discourage use from more driver like users.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  include/linux/memremap.h |  1 +
>  mm/memremap.c            | 74 ++++++++++++++++++++++++----------------
>  2 files changed, 45 insertions(+), 30 deletions(-)
>=20
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 8f0013e18e14..eac23e88a94a 100644
> +++ b/include/linux/memremap.h
> @@ -123,6 +123,7 @@ static inline struct vmem_altmap *pgmap_altmap(struct=
 dev_pagemap *pgmap)
>  }
> =20
>  #ifdef CONFIG_ZONE_DEVICE
> +void *memremap_pages(struct dev_pagemap *pgmap, int nid);
>  void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)=
;
>  void devm_memunmap_pages(struct device *dev, struct dev_pagemap *pgmap);
>  struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
> diff --git a/mm/memremap.c b/mm/memremap.c
> index 09a087ca30ff..7b7575330db4 100644
> +++ b/mm/memremap.c
> @@ -137,27 +137,12 @@ static void dev_pagemap_percpu_release(struct percp=
u_ref *ref)
>  	complete(&pgmap->done);
>  }
> =20
> -/**
> - * devm_memremap_pages - remap and provide memmap backing for the given =
resource
> - * @dev: hosting device for @res
> - * @pgmap: pointer to a struct dev_pagemap
> - *
> - * Notes:
> - * 1/ At a minimum the res and type members of @pgmap must be initialize=
d
> - *    by the caller before passing it to this function
> - *
> - * 2/ The altmap field may optionally be initialized, in which case
> - *    PGMAP_ALTMAP_VALID must be set in pgmap->flags.
> - *
> - * 3/ The ref field may optionally be provided, in which pgmap->ref must=
 be
> - *    'live' on entry and will be killed and reaped at
> - *    devm_memremap_pages_release() time, or if this routine fails.
> - *
> - * 4/ res is expected to be a host memory range that could feasibly be
> - *    treated as a "System RAM" range, i.e. not a device mmio range, but
> - *    this is not enforced.
> +/*
> + * This version is not intended for system resources only, and there is =
no

Was 'is not' what was intended here? I'm having a hard time reading
this.

Jason

