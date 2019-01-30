Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAEC8C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:39:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FE5F20870
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:39:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="okaDjsxS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FE5F20870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EECB68E0002; Wed, 30 Jan 2019 12:39:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9B268E0001; Wed, 30 Jan 2019 12:39:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3D398E0002; Wed, 30 Jan 2019 12:39:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 771FC8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:39:11 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so121806edz.15
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 09:39:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=HFBwZlA2zzCYNeNt7uJfqDsoesFpddqG96hIhNSMGQ4=;
        b=Eljd/ONnMA2T6MOGxoUIJ8FMkQOXq0EiKvul098Ebz9D1Su6P+ozWbznBezL8YN8WA
         q3lLHggXw9XLXU8qT4umkWntIbuDhG2NIZXgZWKPW0WQG7CXvoZ9wkaVSBwrQ9PP4fa0
         rG+yAK5czQ+GkZCfRhiVGQ5pqjBasSFUoKdyKEYE1XYov7+LzXjJEjGC03+NjB3ZTBht
         AXIAiyAb5YIH5MYT0A7iLZExE37IzoplyOkI2otO37za2Bld/hXEtDjyVgJcM4/+iSTM
         I8vIIReSHgKi1m5jDTkR/UqKBWLc+kItSZPu/uxOCgCpYHCA8uhg8sSLYpuESYuYKVtx
         bYSw==
X-Gm-Message-State: AJcUukdue8MPLadCKHgc5g/NltZJnn7Lj8Pq5zCt/XmJjF1uQS3AACSY
	VVAd8Zfc4ZtmqCv8/h2v8ciXCY8AK45QGToCuRU75djQDygIbwrLPDcrUg1kH3SxDF3GC3z2pB8
	oaEZqmFEGNt/7sTf3c6SEFHjZCa43oCP1xp4ZZeCL7V6c712DXe9Q/OxS4tJdbGxSew==
X-Received: by 2002:a05:6402:758:: with SMTP id p24mr31526876edy.92.1548869950918;
        Wed, 30 Jan 2019 09:39:10 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6DhvD9eoFNqxvg/k05DVaRbN/1JkUoPCmvUvKOWE45sBpNixBYSgYEkVQ1oSiE2Tesf9u8
X-Received: by 2002:a05:6402:758:: with SMTP id p24mr31526820edy.92.1548869950082;
        Wed, 30 Jan 2019 09:39:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548869950; cv=none;
        d=google.com; s=arc-20160816;
        b=RW62SA2Fp+z4pa84PxXYD7iJU5PaMIVMpxq88aQhTrx9WMdUtdQsC389EU+aLKOZpm
         FZ+2gqdBDsODtate+s7hRgh45Xisi5vRcWkDKXhM4ppc/DJ0aEL5JT3KlpHj+ABN0wI0
         xwU930x+xO2KjcOOmTji55YN00PDTofiuJKvGIIiZaZj0EllDHjw+EHac9nOoV592Ppz
         gvmajyg2sxt94G4t4EtkId/RK2jo2fCbIigB8AjvvdN0/FOYDnXQbsuDRBfoDwkZqaRS
         bZLbswwB1ispHFV2yzbBC4EDASqhZq9uGwqxSal/QBO4RK1zC6c8BFDp6+WJGXjY0yOT
         IxWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=HFBwZlA2zzCYNeNt7uJfqDsoesFpddqG96hIhNSMGQ4=;
        b=thpKZYJ9vTrFrx9hn8tNMeBp0ooJU/v2YQaJbWBJZbPcV13gt31UcymOCUJEaYgBV7
         62qP7yDqw/102aildJUEhEbLNadgLdcdBtyS3ry0BTIBvK/bT7lQIUSZK/CKkmxnDqhS
         TNknON4jqbEwm46L9jWaUGLqyrR3uIUddMi85Cv3t60ZnKgtC/35vyukRGt16FUcXCUt
         3ALcHXI90DRwWBqdcdX5m9uitbCUsduJ1IR9163WExnWbkvMS9uMwWOrgjcDc4FyNgsD
         gXMfvOK1fGoQTrn1oQpx/jTXJANc6rFcI/oTltC3HsHpJqd7tFgCnNr05vTX7VPLeH7z
         Qqow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=okaDjsxS;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.62 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10062.outbound.protection.outlook.com. [40.107.1.62])
        by mx.google.com with ESMTPS id s27si673908edd.33.2019.01.30.09.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 09:39:10 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.1.62 as permitted sender) client-ip=40.107.1.62;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=okaDjsxS;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.62 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=HFBwZlA2zzCYNeNt7uJfqDsoesFpddqG96hIhNSMGQ4=;
 b=okaDjsxSpeKecjLldjouoR/XYA+lS0F3IsyaPgqfhWR0PutAUtijM47Z34ep+9gVESHm2ysdfUFhNomf8lVSYbbnOwf7QJiTLJMZwzcstjbqMLJZqt1J7SK+4N9aX5LjwvpWDjE+f73KJZNckCBvNFIclU3/P8cTvgKEL0sU82s=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6281.eurprd05.prod.outlook.com (20.179.40.82) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.17; Wed, 30 Jan 2019 17:39:07 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Wed, 30 Jan 2019
 17:39:07 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Jerome Glisse <jglisse@redhat.com>, "Koenig, Christian"
	<Christian.Koenig@amd.com>, Logan Gunthorpe <logang@deltatee.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn
 Helgaas <bhelgaas@google.com>, "Kuehling, Felix" <Felix.Kuehling@amd.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, Marek
 Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>,
	Joerg Roedel <jroedel@suse.de>, "iommu@lists.linux-foundation.org"
	<iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Topic: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Index:
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAAEreAgAAFNYCAALluAIAAKlaAgABZ/ICAABl4gIAAA2KA
Date: Wed, 30 Jan 2019 17:39:07 +0000
Message-ID: <20190130173859.GA17915@mellanox.com>
References: <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205827.GM10108@mellanox.com> <20190130080208.GC29665@lst.de>
 <4e0637ba-0d7c-66a5-d3de-bc1e7dc7c0ef@amd.com>
 <20190130155543.GC3177@redhat.com> <20190130172653.GA6707@lst.de>
In-Reply-To: <20190130172653.GA6707@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MWHPR18CA0047.namprd18.prod.outlook.com
 (2603:10b6:320:31::33) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6281;6:i3Ddi6MlAPQ+2fGC0MjB8zJ2BrxePCDXP1bJgz14FBKuXzLSyqICg8fHgfIpLsg/AXWq9voOnF6zWCHonnSRpKTsUif51fJmlQP0pjp7DdwtRyvandWdW3jJWJAuZkd6l5Uro+mfeB7pGENXbeIrIr9uHxthbZjwFAr6jj8nDA+9bqM8uqWUOV7HUzB9jM16dG/XUfo/4xvxHBgqzm9RmM3g29wUcFEp2pi6DW95Bx95CAH2KLcZ/GmhxK4Eb+lEMT1kTtEq7bFr0zUpJXhzVJKAyz9QteIvJsk09hm3JcCNhCMMMPyY0cg8AeCnKjYLBHNkGF5Cp9w/68VRBgYZv4QryL8YNZ87L8wLKHYlmZ8unIcG+7Qvs2iNyb27TXE3n/airJrRF7tuBRPm+W3yCxT18K2jRzBGUk0qE5X2uTi08bYrqtDNj9LK9UFzW0COs7D+w+6OJ0GNpZ5/OyMtMw==;5:Eu69CSHFrP+uRWDH/Sq8b6X1IJxfnupRxcHpGepUc++XCwtVfCzqRzPAk3QZ25NATa8IQMoCr6YC6KzeJJKE1pN/qO+/T2eI1zG1crBt3MaH+/KswOQbGw/0ym9oddo+mBjyyVoVHB+XEr1ithV6eLwlaD+5RQIWqRwg4wSynnnZXaJzDnS+QpX87qf7EJ/IQuSysdyjBAjBpPJK4BITvQ==;7:P7YikNjitzseXWj2XC23fmhH8kMsOO6B4SYiTr4tkkCTowerkRz95qPMrpAu3RdKdN3WeB2KLKPuxWRuO0kUvB6VfR0QuPT6jVrMzey1AuL5L6qvvGm41SnnNokvcWyi1k7xWLSTF1wEl4Th8/IlUA==
x-ms-office365-filtering-correlation-id: 249e8713-9439-4f8a-696a-08d686d9d5c9
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6281;
x-ms-traffictypediagnostic: DBBPR05MB6281:
x-microsoft-antispam-prvs:
 <DBBPR05MB62818FBC22EEA4F5DAA1429DCF900@DBBPR05MB6281.eurprd05.prod.outlook.com>
x-forefront-prvs: 0933E9FD8D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(376002)(366004)(346002)(136003)(396003)(199004)(189003)(1076003)(53936002)(2906002)(229853002)(6486002)(4744005)(3846002)(6116002)(36756003)(68736007)(93886005)(6246003)(6512007)(11346002)(446003)(478600001)(33656002)(102836004)(26005)(186003)(476003)(52116002)(76176011)(14454004)(105586002)(106356001)(2616005)(7416002)(386003)(6436002)(6506007)(256004)(71190400001)(217873002)(4326008)(6916009)(86362001)(486006)(25786009)(97736004)(8676002)(81166006)(305945005)(66066001)(7736002)(54906003)(81156014)(99286004)(71200400001)(316002)(8936002);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6281;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 25TotRKO5RJFA61APu7tnxgk8w2lU8T8dWgCrap401DSik3vwYJuf9mLXnw0C3RGPFBJ1FcGOZCi2pPMKPszvIxGjnWEGnK0j2wDr+H+h2eFuv5QNhCUClMqPTQG8ZgrObwP7Ou0zfd09E1THhtHiXhfro7jC2m+kNC6Msi3++3xJ42ghvnMSBCwE6jgKplsyASOwLPkcZJgglDZwjNvHBBAceqTd/IEe4Hz71/+4V5xhDBE1+nnHbS95l4QtvIw5i8CH2pKc+w5Hkm5enLug/UolVdczHhbUqHFh9w+6xfQwsOOu4cQlOPLE/uqF1rPyzWejdLz/Qs0VJdbGDHOhR4GkoCXgRJ2oXTBJ61OmV2wyGj3tTahSv6ijGkUi0P7A9uii/v/vLrVcGMQkm6/fmer69QJGGZ2cSfiIOVodhs=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <E7430F120D2DC64DA4E2E168FBE5A5DC@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 249e8713-9439-4f8a-696a-08d686d9d5c9
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jan 2019 17:39:07.2255
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6281
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 06:26:53PM +0100, Christoph Hellwig wrote:
> On Wed, Jan 30, 2019 at 10:55:43AM -0500, Jerome Glisse wrote:
> > Even outside GPU driver, device driver like RDMA just want to share the=
ir
> > doorbell to other device and they do not want to see those doorbell pag=
e
> > use in direct I/O or anything similar AFAICT.
>=20
> At least Mellanox HCA support and inline data feature where you
> can copy data directly into the BAR.  For something like a usrspace
> NVMe target it might be very useful to do direct I/O straight into
> the BAR for that.

It doesn't really work like that.=20

The PCI-E TLP sequence to trigger this feature is very precise, and
the data requires the right headers/etc. Mixing that with O_DIRECT
seems very unlikely.

Jason

