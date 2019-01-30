Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B83DC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 20:44:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F876218AC
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 20:44:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="IVsxBU4Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F876218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E38428E0004; Wed, 30 Jan 2019 15:44:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE7CE8E0001; Wed, 30 Jan 2019 15:44:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CADEE8E0004; Wed, 30 Jan 2019 15:44:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 722BE8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 15:44:23 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b7so311503eda.10
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:44:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=3q11Gc6Y/Uf6UbDCnmanryNWthVNpQPbMtMsj4rAnGc=;
        b=hiXcsGR3Iu39SOjDv7kxCzeAz+Rhva8KKLRh9ze2jQuKsCbQvAMwBAnySb3yAiNzyC
         NcKEGVbWoYU9fmqQxiF7CXbgI04kxRL6oEqaQQKVlwVzqsuJnXfpiTJlmjrD5VUrOFSm
         Hj06LRiDLR6oi4wZWGuM6jSJn6GNCrOqGBpBRbCMURL6uOYmvj/Mdx98wPVEJsWUBL9D
         hf2nSWvfc6qPz54u+BUDoAsxkO5J6AIGdOGF1oAQRfPuHBXGhIcWhQvyRHVyTXGnYZdd
         z7Xvm5dUrSPL7gnXiGpFESAPknBdxX8k3RnfwdmzX1tGVBAYS2JcKrfGzla4poBAZRcR
         73TA==
X-Gm-Message-State: AJcUukfG7DVjyuYrLJzLmW+7D8MsTz2q8yWHrNiAHI02KJqF8r19R62Y
	+WSMKbJ2SvWQd0/I2D+gxayd380swPgtUKKfPlQq92ejJYKY4B+mzFrbTSWWrmyDjjCCd+qGHd9
	OE6r2T714qO7NIP0sKFOinO5KL4jE6naQgH9dBwi85YIo2aNLr2VDOAeM/9qMAVa2XA==
X-Received: by 2002:a17:906:1848:: with SMTP id w8mr13054909eje.7.1548881063004;
        Wed, 30 Jan 2019 12:44:23 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4KxGe0nikT5+m92tYSwHke7QceqSRLCGr6QWjqCXWJpBORnTbskovHF4F6ja/i6sVXY14B
X-Received: by 2002:a17:906:1848:: with SMTP id w8mr13054878eje.7.1548881062040;
        Wed, 30 Jan 2019 12:44:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548881062; cv=none;
        d=google.com; s=arc-20160816;
        b=aDYHruCKymoLP82T74TIfIokEBpra5fYwYtFtdieKAxJJWl2Kj8D/lDVq3keO1ZHvJ
         xl5ed+0UxnrvFvrJRtjxtWaxa2F2+ZtWX02rMseyDcP6vuOcDwcEPGng0guadREOuZ+n
         nr3h4E/VbYDW2PwbQipudCd4DMuVSGMNIAQ5N7yV5rRkjoE5faj66hZ761jDeb5DzvYh
         nzY8MiqLeQCk1wDUp0r3MaWiFQnmrJzSEcBfHEitw6UWTFQS6j8bPicxriu8q/J52s+Z
         oWlcCtqyTdvh7/gySeX/e2SrANccsAdkuKzCpVEqXI3PC3+E7vepbYeXc5Np+ftnTxn3
         cAPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=3q11Gc6Y/Uf6UbDCnmanryNWthVNpQPbMtMsj4rAnGc=;
        b=XZifJI/+Vt5KWgBXqhocEIqHpSm8H2Cta8Kj8GFyC6Go7CtvSuIy8XmN2UjjpON+Ih
         uxWknp6Buiw4aa3pGpGsqsOS/ztnoEsC8p0vgrNduQs5ebQcTurp4hHcVAGIF1ivvimu
         SZbFuXF1rBni1NDvYhLI43Gk2Zo6iar0WzXrZjarBQrW9/5xMQhMnAvAfeDJ5bUJJ7Ak
         YCiYC6fDJ1SHkttLbpjAFT89rt5VsBkyaClWjQT/k5vKNX3ZexHGmTTvUCV565MWqbSu
         g5Q2oty3lgY+fAXpHuHvkgspVYS31snQ8gbJgVOBUYFsxs7EIkkkb5ruMjE0uyZYY6fN
         oHjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=IVsxBU4Q;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.89 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30089.outbound.protection.outlook.com. [40.107.3.89])
        by mx.google.com with ESMTPS id s28si1380606edc.349.2019.01.30.12.44.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 12:44:22 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.3.89 as permitted sender) client-ip=40.107.3.89;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=IVsxBU4Q;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.89 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=3q11Gc6Y/Uf6UbDCnmanryNWthVNpQPbMtMsj4rAnGc=;
 b=IVsxBU4Qr2gMlUY/+eNNxf9zp6oNvHxL9hrVgsi9Nzp8or9MMZi/tQtv+uLk4vzkGnJSo+4sGiqod0D/MkPFD6SH/2W1dwFmP55lJxVtEDKl5gqGyel1CC07YwmCC6uNcSXqa2vJlpwd/zhqd7jmykRJ1rErYONbuvkgiHe25yo=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6539.eurprd05.prod.outlook.com (20.179.43.210) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.18; Wed, 30 Jan 2019 20:44:21 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Wed, 30 Jan 2019
 20:44:20 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Logan Gunthorpe <logang@deltatee.com>
CC: Christoph Hellwig <hch@lst.de>, Jerome Glisse <jglisse@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn
 Helgaas <bhelgaas@google.com>, Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, Marek Szyprowski
	<m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Joerg Roedel
	<jroedel@suse.de>, "iommu@lists.linux-foundation.org"
	<iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Topic: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Index:
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAAEreAgAAFNYCAALluAIAAoq8AgAAIC4CAABKaAIAACAuAgAAPjwA=
Date: Wed, 30 Jan 2019 20:44:20 +0000
Message-ID: <20190130204414.GH17080@mellanox.com>
References: <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205827.GM10108@mellanox.com> <20190130080208.GC29665@lst.de>
 <20190130174424.GA17080@mellanox.com>
 <bcbdfae6-cfc6-c34f-4ff2-7bb9a08f38af@deltatee.com>
 <20190130191946.GD17080@mellanox.com>
 <3793c115-2451-1479-29a9-04bed2831e4b@deltatee.com>
In-Reply-To: <3793c115-2451-1479-29a9-04bed2831e4b@deltatee.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: CO2PR18CA0055.namprd18.prod.outlook.com
 (2603:10b6:104:2::23) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6539;6:Omiz0DSeGgLhAXELIhDr9hk2fKOu4/wM65PuVQ33k+CelyqGX7054wB8swMUNZKFQm18ogcoJ7CVAWT0RcT4CdrqawSPm97Wj7o17OqU6ATQMYZ6rr9eRDld8t9bJA5d7CKCtuwvJwzSFDVcJCKmuI+Z0CkdEd5Bup/UA4JByDPjv+x9ZbQR4A5Hvl5fsha59Z89RcQO7R10B0CSrMxdKBweUL3kVA5BlX0L+KlFEU5x27Ow6jFnsx0uDIDdDDHh9NdFWSoMo7P6pkvnnOH9vrplQ8mLA4L7x45qwtUCH4WVfRPTMdfpC+I27s9QoZ1ppheIA+Srp32zGzEit2/N/FpV9pSvcr7BGq4CRLy1BcLMsK6bFRUDvzOHZLVGMTjWAa1dKpQDSvjNOJRLdCF7oD9iLoFMFZhnleuroCvCrh/5w1v0YllkRDFZTtb/80mIsAc36+5OyW9EVljkW727tA==;5:4AcdBrpN+8g7TECWJsZeksXpks/OwRAqBDOwXblnAOpapNVj1uDkG3maeMBDwcmOJVXpdL8Vbj2N7O/lhZwmBfwUYoGMb68aoev2zxzZPdUmSqmxsIY8gvdTxEdPD3pQE7E52B6vpS6JFzss9V7M2mHjGtX47taGi96OqRi0BXyMeeoIHUwPyxqxuDJgkyQ5vox4hkt9lWNcjc1jWl+V7Q==;7:Q8MRctFj1IKslXKCAird3q9mqe/AwT0Je/VHVY15prhEWO59XuNM4Zjvvg3dzN2vEUFVQxIS4X/J7ulHMkWyCRNvX9dKN8KbYDPHMqXssgzhTZd8fVg/P90jwDS/7fGRt3CzWJXM66QtCE0d9X7nOA==
x-ms-office365-filtering-correlation-id: 50eb40fb-a4f6-42a8-6361-08d686f3b5c3
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6539;
x-ms-traffictypediagnostic: DBBPR05MB6539:
x-microsoft-antispam-prvs:
 <DBBPR05MB6539123104E85E87355E1655CF900@DBBPR05MB6539.eurprd05.prod.outlook.com>
x-forefront-prvs: 0933E9FD8D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(136003)(376002)(396003)(346002)(366004)(189003)(199004)(1076003)(26005)(186003)(217873002)(93886005)(81156014)(81166006)(68736007)(8936002)(8676002)(478600001)(11346002)(76176011)(86362001)(14454004)(446003)(102836004)(476003)(2616005)(54906003)(99286004)(53546011)(386003)(52116002)(6506007)(486006)(2906002)(6116002)(6916009)(229853002)(36756003)(6512007)(105586002)(256004)(316002)(6436002)(66066001)(97736004)(106356001)(6246003)(4326008)(33656002)(53936002)(71190400001)(25786009)(7736002)(7416002)(6486002)(71200400001)(3846002)(305945005);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6539;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 CHULca8f3+EJ6Oteo3lb2I2iarq0zQD+w5JA+Zcit0200uw+4hppmIIU/YO/KflhNzm2Cx2dE/n+ZKJ9yQDbRZV2rIs1Z6d11njjKjsQncGjZ+6Fu7P2hO8ENtrW7pvr0erZB76BsK50Pv9gwRVaaFrULUxi4E9cVIjHzgdbbSFWV1ZGrg0IpLmUKUWOYUIGfLnt6PE0V8jE4N7trPbArR0E1vE27triIK9iLqppoMqBK/VkfY0ipQngFu1KY5RbdhvwVq9SG+UAeXCbFKURuEBq21nlrbcWW2F7kPsD0GWneRCYNSXeUFlGMd6G3AWyPf9Pkk2djMeFr0yFHgFSfIJ8fGJHYiGzpfYY4MBpzGmhBv8cMm+9YBESsqOGOF+xCI3j2I2o7zUvg0ezBgRTiEb3naUEA8uC+OeRMqE05DE=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <5DDBA0D21FE94042ACFF73FC449CFD7D@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 50eb40fb-a4f6-42a8-6361-08d686f3b5c3
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jan 2019 20:44:20.4139
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6539
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 12:48:33PM -0700, Logan Gunthorpe wrote:
>=20
>=20
> On 2019-01-30 12:19 p.m., Jason Gunthorpe wrote:
> > On Wed, Jan 30, 2019 at 11:13:11AM -0700, Logan Gunthorpe wrote:
> >>
> >>
> >> On 2019-01-30 10:44 a.m., Jason Gunthorpe wrote:
> >>> I don't see why a special case with a VMA is really that different.
> >>
> >> Well one *really* big difference is the VMA changes necessarily expose
> >> specialized new functionality to userspace which has to be supported
> >> forever and may be difficult to change.=20
> >=20
> > The only user change here is that more things will succeed when
> > creating RDMA MRs (and vice versa to GPU). I don't think this
> > restricts the kernel implementation at all, unless we intend to
> > remove P2P entirely..
>=20
> Well for MRs I'd expect you are using struct pages to track the memory
> some how....=20

Not really, for MRs most drivers care about DMA addresses only. The
only reason struct page ever gets involved is because it is part of
the GUP, SGL and dma_map family of APIs.

> VMAs that aren't backed by pages and use this special interface must
> therefore be creating new special interfaces that can call
> p2p_[un]map...

Well, those are kernel internal interfaces, so they can be changed

No matter what we do, code that wants to DMA to user BAR pages must
take *some kind* of special care - either it needs to use a special
GUP and SGL flow, or a mixed GUP, SGL and p2p_map flow.=20

I don't really see why one is better than the other at this point, or
why doing one means we can't do the other some day later. They are
fairly similar.

O_DIRECT seems to be the justification for struct page, but nobody is
signing up to make O_DIRECT have the required special GUP/SGL/P2P flow
that would be needed to *actually* make that work - so it really isn't
a justification today.

Jason

