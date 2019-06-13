Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74157C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:01:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 226CA2133D
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:01:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="nXHH6oTM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 226CA2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B70378E0001; Thu, 13 Jun 2019 16:01:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B20876B000C; Thu, 13 Jun 2019 16:01:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E8098E0001; Thu, 13 Jun 2019 16:01:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5310C6B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:01:58 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l26so341113eda.2
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:01:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=2lmhrKuSV7GaCf2C9+fxP56+CLwg4sVHwuhk2+6yAoA=;
        b=a2YxqiB1XR8597b//dDx+7Fqo3+ckumeLNra2MRAv6JzGNBs6XZNzqOJXwmAW30Iqf
         DccaQDJKzCb0G8pUThhPWsyIEYTGYTg0Htng6yrdfpfdD2aO/BBC+o5rolFdOS1ixqli
         WSU9M1beD601PLtrEgPzD51DsA/klpvNSN4XYJhhxeC7cLGjntBohxfRLBbRVtjb7y9H
         gUDvftA4FvB2bVfCEVAqpvnX34o35TAkLgAmXDU0c9uut2uwaUbGcQlSkhkumN71Gy1b
         jPo4GHk3A7XpDjMWp3p8wGoTS2Hhea3LGAMV0yySfsdsQ+E4XCvlVHbP2kfm8IWRbFwu
         6lWQ==
X-Gm-Message-State: APjAAAV/n2SNpglhrSj0H4oDzsrwb+XgHQfRa+pCVHjtGH0fO5mzFCK/
	gPf7VRZV0kCGbuKYhlGEpvP23K0tYrtuCAwbJEnKxbjzA9RetKieMtnICVq9hXnFRHsb6FrVOl2
	ZPgXJp2c1ztVyzl/1StDmBD9iWOpxfncST2G8YBYPRotRx4gfFYzAIbp0juCCYGAOKQ==
X-Received: by 2002:a17:906:5254:: with SMTP id y20mr45890437ejm.59.1560456117771;
        Thu, 13 Jun 2019 13:01:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKLbt77sEWcpFJKGWprWmF5loEdK1rx/1UDvFaVLPQSmazJ9GX7No/tgWANhmjDvRJqwjb
X-Received: by 2002:a17:906:5254:: with SMTP id y20mr45890379ejm.59.1560456117157;
        Thu, 13 Jun 2019 13:01:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560456117; cv=none;
        d=google.com; s=arc-20160816;
        b=MvoAVhRSmfzWl1k7yhdraS/inLo4RB+HjDm5Z0Vn4CzTSPiIbskYpRvbfqE34DwQl6
         iWlBTVD6gEuHln4kveyB+8DCVT03TaozCFV2P5LPZVPcatcxmerFxqqk+pGNUuAcQ7wc
         HBcUK+Uy/9UkOoPOJ0LTy6uO5dbnkgb64tZHtsOBCdInJCarc5j18RUxlw8RH7qY0kEx
         gIzm1wjb/jpqAjZLxYq2GFmBa17K1it4jqanuSlh60MhVfA5fXyblpeZjT6jhbWBpWml
         xOefBnoi+2opkaXbSwwIhZxazFbwqD1f0yh7r/yae88rjwa5cT1bO9P5SZUf+ae8fYBL
         cZsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=2lmhrKuSV7GaCf2C9+fxP56+CLwg4sVHwuhk2+6yAoA=;
        b=y5aIlxGw73S6DGn51azdXifNL17DPoZe1l0XzEWbpLvXftPhTelvcPfsa/JS9dUp8N
         kI8yp7Q529zeTptKWAE6BusXjfXfkt8puBThr4C81Dkgu7/HnLREUPZCGpgiUukcjAyQ
         3u4L2oBuGPmPEeBiuc9ZRKa2I4nGdSpBhHGvXZjAllqG5ThgUsqjqe54CgvInPcT1AFw
         Ny/AZwb2WYa24ArdZq1pQgcOrjwJxB0xlwGqPIFNrrlX27mWRTW7hw48b0S3Go1BxFUr
         7tuxMbYvs0LDTBdev5V33g5lcxeJf4iYRcL1qLmIhymPxN6M+B5hhsexrFz2ItN0KkLW
         QIqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=nXHH6oTM;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.58 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20058.outbound.protection.outlook.com. [40.107.2.58])
        by mx.google.com with ESMTPS id z4si369243edp.380.2019.06.13.13.01.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Jun 2019 13:01:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.2.58 as permitted sender) client-ip=40.107.2.58;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=nXHH6oTM;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.58 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=2lmhrKuSV7GaCf2C9+fxP56+CLwg4sVHwuhk2+6yAoA=;
 b=nXHH6oTMdTMLmi/TtImBS/dCyHU78zPjEUjNSp4lnVViy2lTe4AGx/4SeMkZVFDBhoMNAia0JdmLifxdH4Lr98odLCuLVpxPcLYBuHFpOxbTMu3TvhAnWgTwwxsm+pF4izCRK+/ISDqaIWNIQj2rfgiibv/r9EJD1smDKgXN6eA=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4381.eurprd05.prod.outlook.com (52.133.13.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.13; Thu, 13 Jun 2019 20:01:55 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 20:01:55 +0000
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
Subject: Re: [PATCH 21/22] mm: remove the HMM config option
Thread-Topic: [PATCH 21/22] mm: remove the HMM config option
Thread-Index: AQHVIcybZ4YnmSc/ekSwqfkgyQT9faaaAhMA
Date: Thu, 13 Jun 2019 20:01:55 +0000
Message-ID: <20190613200150.GB22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-22-hch@lst.de>
In-Reply-To: <20190613094326.24093-22-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BL0PR02CA0082.namprd02.prod.outlook.com
 (2603:10b6:208:51::23) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c7d97d2a-4a43-492c-522b-08d6f039fbe4
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4381;
x-ms-traffictypediagnostic: VI1PR05MB4381:
x-microsoft-antispam-prvs:
 <VI1PR05MB4381BEEE04CCE0A53CD45D77CFEF0@VI1PR05MB4381.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7219;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(136003)(376002)(39860400002)(346002)(366004)(189003)(199004)(68736007)(52116002)(53936002)(2906002)(6246003)(71190400001)(71200400001)(26005)(66066001)(81156014)(81166006)(36756003)(54906003)(5660300002)(33656002)(6436002)(102836004)(1076003)(86362001)(99286004)(6486002)(6916009)(229853002)(6116002)(76176011)(3846002)(386003)(316002)(7416002)(6506007)(14454004)(446003)(476003)(7736002)(11346002)(6512007)(8936002)(2616005)(186003)(4326008)(478600001)(486006)(64756008)(66446008)(305945005)(66556008)(256004)(4744005)(8676002)(25786009)(73956011)(66946007)(66476007);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4381;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 7yWCsk29qZQJ4Hn9JUnWEfUTBD+kbukUw0AN3qXho23YT0zYsYge5E4RXgxJRsbaXi5No2o4BAdg3BW9u67HbUL/SigKNq9GtuqbhSWyCmUbByPx6Qh+tnSkwrr6J++SoZOFL38nzVkfKSB0Dg7VS7R2jtx055eoY7l/DcgRp8Rsm1zQ/FL0XElohyiIghL8gA6UoyT1JU0Du1rAA508vDb2CvlZv2hIGcs5AYYuKsqpDOJGlM7TjL3GJWbl8B8wNSh2iTlmyf2VDQoE4WlvPqhMKur+sHPzL0R7SZg257XZygcRGjOFIyJLnOyo1z6DalA94eYsFjveI0KR74DInxMg4ixWlprhTJ0l5J1ub+ASeoqTeP83paufq04i2gx1MODiqrVm82Fv2gIkrAqFm+kQZfckMDd0HKbfK308SNI=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <4F4AB6FDDD24014F95455A97A0E953B7@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c7d97d2a-4a43-492c-522b-08d6f039fbe4
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 20:01:55.3627
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4381
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:43:24AM +0200, Christoph Hellwig wrote:
> All the mm/hmm.c code is better keyed off HMM_MIRROR.  Also let nouveau
> depend on it instead of the mix of a dummy dependency symbol plus the
> actually selected one.  Drop various odd dependencies, as the code is
> pretty portable.

I don't really know, but I thought this needed the arch restriction
for the same reason get_user_pages has various unique arch specific
implementations (it does seem to have some open coded GUP like thing)?

I was hoping we could do this after your common gup series? But sooner
is better too.

Jason

