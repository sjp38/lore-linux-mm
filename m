Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04D0FC3A5A4
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:49:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB0C522CED
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:49:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="KcX0hs9a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB0C522CED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48C096B0006; Wed, 28 Aug 2019 10:49:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43CD86B0008; Wed, 28 Aug 2019 10:49:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32B856B000C; Wed, 28 Aug 2019 10:49:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0105.hostedemail.com [216.40.44.105])
	by kanga.kvack.org (Postfix) with ESMTP id 122496B0006
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 10:49:12 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B6E71824CA08
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:49:11 +0000 (UTC)
X-FDA: 75872119302.11.patch00_6d3a2616a6027
X-HE-Tag: patch00_6d3a2616a6027
X-Filterd-Recvd-Size: 6690
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20064.outbound.protection.outlook.com [40.107.2.64])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:49:10 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Y3X7pVzUuno2nheJXPlytsbh8ZRVKbd6c7WPCrbns32weFi0UGwr0K4hL+3NXSxZf61jKNPVS++1QCLDZRr3yYaiiJHsL4VFk3RkNwUmtudW7jme4Xfw2Xyy5L3Pp5sRHTVSCNTvYMwmMo9yGeQExps8kB+dO9a1LrpWvnVMtKXCoHehLVsm68dsA8qjGO4QGQbUe+u0ffZK6aqxu73KRe8Tf0VeeVALatnMFeWteTc2oEDP2CZVgvzvAh5HRlqbcSzqvgl7j1RHkuzFJtoVcKRzeQILQPH1+0HnPNi0A54PeXYGlYV8bNPmWw5afNzLVq3trnNUKoY3PPb+IAkcow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Qwx5txf2qT3QAH9pb6v1FpDIJuiD60SHzoN9kDRBcJE=;
 b=SdIDdJnutc0oS1KWjqI0DadYc/ig3gkBG+cjrdjt4Ns2e5jeoudFbMsa6Edn6+XPfi08RgvsfthQkfvdhlWpIxwIqkHBUO5zmkn9YcezGaQTt9V+aWLwGpHwce33v1eEmjzaUqL5ODtVqvcCfw9zn2FXJ7YH5BTE5PpkQiR0FEtd/KLnPh54nHNLvoDs0F/B1JmgXcn3SLALqIEcjTjvGbEvSXE6hUrUbWsafy2Ochru7YFDdBDd+5Yl0mgKnMh8VuTvcpiyuXKet9tgjMSKeft11b7GMVVLVuufu5jlgYjpWQMyzo2wyFfXVs5wbOBQ3N/UeEBpJKM/ZsGISCjHJw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Qwx5txf2qT3QAH9pb6v1FpDIJuiD60SHzoN9kDRBcJE=;
 b=KcX0hs9akdBxl3JQOWIqXI8HKvoWdwLRLy+ElFv4TxSyBEu/Bk/0m8VR2Y676LgNoAJAipjjxsK7gNlu12qXCtq4K5MVRXOAydENNBTG4jkF41+ATRUr9xRz/6Rekm/NHJuziRi3ZLDrigxggcHwFXAISFCjI7ypI63XVez1/FU=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4624.eurprd05.prod.outlook.com (20.176.3.145) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2199.21; Wed, 28 Aug 2019 14:49:08 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2199.021; Wed, 28 Aug 2019
 14:49:08 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "daniel@ffwll.ch" <daniel@ffwll.ch>
Subject: Re: [PATCH] mm: remove the __mmu_notifier_invalidate_range_start/end
 exports
Thread-Topic: [PATCH] mm: remove the __mmu_notifier_invalidate_range_start/end
 exports
Thread-Index: AQHVXavZqxXcfLyzmkeft6WFMi/zb6cQobAAgAAB/gCAAABwAA==
Date: Wed, 28 Aug 2019 14:49:08 +0000
Message-ID: <20190828144902.GK914@mellanox.com>
References: <20190828142109.29012-1-hch@lst.de>
 <20190828144020.GI914@mellanox.com> <20190828144728.GA30428@lst.de>
In-Reply-To: <20190828144728.GA30428@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR0101CA0071.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:14::48) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [142.167.216.168]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b66c8561-4ee3-416c-44ff-08d72bc6e196
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4624;
x-ms-traffictypediagnostic: VI1PR05MB4624:
x-microsoft-antispam-prvs:
 <VI1PR05MB462415A263D3A5B4A2ECB52BCFA30@VI1PR05MB4624.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6430;
x-forefront-prvs: 014304E855
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(346002)(39860400002)(366004)(376002)(396003)(199004)(189003)(4326008)(33656002)(7736002)(229853002)(8676002)(66446008)(64756008)(66556008)(66946007)(66476007)(6436002)(86362001)(8936002)(6486002)(256004)(2906002)(81166006)(81156014)(14454004)(6246003)(316002)(6916009)(5660300002)(99286004)(53936002)(1076003)(71190400001)(6116002)(3846002)(4744005)(71200400001)(25786009)(66066001)(36756003)(476003)(2616005)(486006)(11346002)(446003)(6506007)(386003)(478600001)(52116002)(76176011)(54906003)(6512007)(102836004)(305945005)(26005)(186003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4624;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 73QEiwxg4M6S/1eEStQgnnhaQfhmWJsshWOcaUtWQ3C1IusLTH2vKXqW1CY62YpOUl6XLYx1GOrmWxQiucF0JPNa4PO1b9YRDJ0N/giI8uHBbr5lwlOcJkmW/OV0hM3+1PftGmLV1ok+23777XSHBFjvYxUGNEDPQsOfqVTeWoW8oRrZH0vvNv0KKQwmQJz224fXnh6u3pXDHIqdP1mfQBYsNDsqheRH6P5RP1rZibklRPcuTzQifJNBhGxx9BiB8WWhkdy1HkSXXpjxioZJIh0NtOukRAnsaq4t6VlXt9XwcrHfrZ8PDKPLH8v8DlxUpamFrRmTSnlFknNZxklMpPIQwIkVuRsI6h/nxeb7sWBJBqvizlp7dAPX9xkg6F0AtqVg/LSoMph6RrMn6mcRyGgHQYz2/s/0vt/MEjLjC3E=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <BF50AE540214C24AA437B0DBD60624D1@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b66c8561-4ee3-416c-44ff-08d72bc6e196
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Aug 2019 14:49:08.6134
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: DwFL8wFntFo9y5eJAPxL0jYxkCzagyBC/BPw8J5jwq/j+JiBm8lDCu829F3lRuHVo02SPO70EX2qmYO9FkRXpA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4624
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 04:47:28PM +0200, Christoph Hellwig wrote:
> On Wed, Aug 28, 2019 at 02:40:25PM +0000, Jason Gunthorpe wrote:
> > EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range);
> >=20
> > elixir suggest this is not called outside mm/ either?
>=20
> Yes, it seems like that one should go away as well.

I will amend this patch to drop it too and send it through 0-day

Thanks,
Jason

