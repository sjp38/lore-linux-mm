Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A732CC282CD
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 04:18:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 543F420820
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 04:18:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="p6RgcDkI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 543F420820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E84F38E0005; Tue, 29 Jan 2019 23:18:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5ADA8E0001; Tue, 29 Jan 2019 23:18:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFC6B8E0005; Tue, 29 Jan 2019 23:18:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 78F3B8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 23:18:52 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e12so8806434edd.16
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 20:18:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=odFD/pFRFfFYR8wF/TesPm0cK31nWbm6naTZkKG5Tkw=;
        b=QMTBFkrOm9dk9tdNhVkhzUHgwbREIL48Zej/2YZtqQnL67Cl+MB1p78Vttw4TDPEnp
         aoAurv8rcF2E1XwNFtBUFdUwTs2v/YbCzkuim3YTA4ZXkHle7aBPu5xYAG5TVRTa6p/K
         /QOWw4QIQnjXSx+KDowACUr0hTIPy0wB0ydhsOE8kCTlXRAn5VaWIPdKN19fZetSZ6Nf
         qLbkUWJpWqwBKb1vzPGRy0QCX5PGbLTJ2+n1EgPl3XGOfhmwKNn6J9zYn+FGzff8XjWX
         pnXWxnF7jfgdqVvrLPW/uHa9rAthG227LqGyal5jbuJ62TKoEGhI6MnIYk7rhD4o0yfy
         ZV6A==
X-Gm-Message-State: AJcUukeSBoyvFEfzp1E7OBhRBY0IM/01RX1sawy866xs7c1CfIbSTewG
	sJQ6WxNKKZNjnt6vcq1B91sbeWzbUhSzqTB6Mr2xBCNpr95EzLFPFTM/f5Wg17I/JCVY6BuL6h4
	33CsVkdkZ2I9uVnXmWfCBCymDoFm6lDm1nhWmOT5AY8M+ulhF6cfq9xR1fiGJwAP8qg==
X-Received: by 2002:a50:b68a:: with SMTP id d10mr28358455ede.16.1548821932008;
        Tue, 29 Jan 2019 20:18:52 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4hMunpTqzEUTQV4DrHeybi0SP9Pz8pZf8rUqSIx1GAQ7HDzyx67laLuM5gpobbd5FPfcTJ
X-Received: by 2002:a50:b68a:: with SMTP id d10mr28358414ede.16.1548821931151;
        Tue, 29 Jan 2019 20:18:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548821931; cv=none;
        d=google.com; s=arc-20160816;
        b=DItEispxTmm8/spsRf/t2ORqdsscPCjdOoop3hWOBArBYbAxGLVys4lKehRj9VQTE0
         CYYhUPI4fPtd1dmcBYnmAlW34VoHGbkAHgeI4wVtaVjtmkJtAupbG8Q8dIB0JjB+pW5q
         Vb++35oqKVurWo2rUNikChe9iRzNav6IT5qoBP+e0d9f248yArHfaqYZAIlCL+LbrE33
         Se6SFaLQ9qmHGJHknsqqmHRxtbCjFygPJ2fXB5XHJ/oQLFQZi6CBIiQwTaECWflMgW/w
         YO4wFLmWkNzQw6zj4x+mOU0OxmHG8Et64m8FPJeSXRya63vkJqtBUF54CgbgMATwDcXg
         aQyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=odFD/pFRFfFYR8wF/TesPm0cK31nWbm6naTZkKG5Tkw=;
        b=TcCNX8vL93dzUCrEFxXLIobXX55qpSVNC1fn2d5QsjnfwJ9zPyglWj7f4iy6K/8uH2
         kShj9/APYSzUXa2aqjNu0sFwDtC8kSYnFqEkSIDUYt2/0rgSxV39gpRZv3UwkzLUPMa/
         bvKUPWrnTUl9jUryGXr+rpoCLVtr+CfaEaDymL3MPx8ccqbgkQU/5DqEiAsZazDH/MhE
         dolPRyU/ycHHGXS/cTttO081FIFol6a8+yemHcXb0mIz1Ae6RIs9FIn+6N007R4sRxYq
         YihHga56FZHy3KSd0VZqKAZPz88+FxfePvBYIUhG8IwvDYCRi+JKaOHs6/6wfiAqxo0T
         jWhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=p6RgcDkI;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.44 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140044.outbound.protection.outlook.com. [40.107.14.44])
        by mx.google.com with ESMTPS id b54si413255ede.267.2019.01.29.20.18.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Jan 2019 20:18:51 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.14.44 as permitted sender) client-ip=40.107.14.44;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=p6RgcDkI;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.44 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=odFD/pFRFfFYR8wF/TesPm0cK31nWbm6naTZkKG5Tkw=;
 b=p6RgcDkIdbBvDffPNVCjkEQweUEYjT3fOX36rD1t5vMdJIESNDty+5NRcaw/AewW1d8PF66Yo5Yct1pqGYqKxJiFZQfRydymYxllxIcsMR6o+qxyy04O2CjQu4miQAirtrYJhoiGDES2YLb7TGg3Xs+lr6bNMm/+bH4oSB4Liz0=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6345.eurprd05.prod.outlook.com (20.179.41.75) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.16; Wed, 30 Jan 2019 04:18:48 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Wed, 30 Jan 2019
 04:18:48 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Logan Gunthorpe <logang@deltatee.com>
CC: Jerome Glisse <jglisse@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn
 Helgaas <bhelgaas@google.com>, Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, Christoph Hellwig <hch@lst.de>, Marek
 Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>,
	Joerg Roedel <jroedel@suse.de>, "iommu@lists.linux-foundation.org"
	<iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Topic: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Thread-Index:
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAAEreAgAAFCQCAAAk3gIAABX0AgAATFYCAAA25AIAAGRqAgAAykIA=
Date: Wed, 30 Jan 2019 04:18:48 +0000
Message-ID: <20190130041841.GB30598@mellanox.com>
References: <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205749.GN3176@redhat.com>
 <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
 <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
In-Reply-To: <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MWHPR14CA0010.namprd14.prod.outlook.com
 (2603:10b6:300:ae::20) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6345;6:H4A4wUJn0ItXsLQN1LgE4YdE70nyc4iTGrlE2qbmv590oIG7lqiM4MlLXBseI6Cb5faHzW216O9vJfWGxiunoOqiY/4dZ7JRCIxcusRm2wxGmmui0I+nKAJWdH7whmwT2HGuiHVh/Hk3CJ1al3ehB+Ngj0HfE+vr7Ywbvews+9XphXGFfJU+eYgNW0s+71Oc672OlQbM3+NoPbbIshawVsnjs5m2NYL+c+Ti3jb5cB6hupAOoET6XQk1zaDzdj+HoxQ4RNVPepaNKcYe95HGg2dDU9tTOs9bKU2kE2GHDrqR9KS0veoPiyQ14/JfLzAJR+VVk7PFLSjMaEnm2Wis1S/zgz7yUshobhKkGll8pzxu7RZOqQcj+h3uOpnf4/eK8irgjcm9CnUPPEnq4+Na6eYuqcKWxrMiXt2RvylRmZwy5QpdZbSnZUSOl8F9LxO1Hye4nhnFIHDdOnSTpRfp7g==;5:EJRY6VOIFbo621ZwP8pChZ1luqiGy6EBgNQqNZhsnuyOBoXvy9X5rVxeWO/eVWYJq/OmvOtq0NAJdWu0XPH/OFxxP8yXn/drjvky28ZG+K1lNH56i345p4UVn9CMmsrz8Vq7BBF2m01tu5aynB+U0tJlI/rvrKociAys+iL7rsrjo3vVnyTwGDoZo4PrPmROonv9hy0YPNUkkC1Mqg4XEw==;7:XWp6E+PllBrWgYWUNR2gsmBynyaeFVr1UhbEFtJ/QJdCqfz++qIqK3LaL0gYcwIGC185OcyHKplvmM+Vcg36U/I2L96jr7yLltJO4DnC8eYgQqOsXPYdPiUFp3fBxOogbNnTB/YU0njrG9K1k3r8UA==
x-ms-office365-filtering-correlation-id: 4b51e9cd-5390-4465-8cca-08d6866a0842
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6345;
x-ms-traffictypediagnostic: DBBPR05MB6345:
x-microsoft-antispam-prvs:
 <DBBPR05MB63451F9433CA6C03FC51CB77CF900@DBBPR05MB6345.eurprd05.prod.outlook.com>
x-forefront-prvs: 0933E9FD8D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(366004)(346002)(396003)(376002)(136003)(189003)(199004)(4326008)(76176011)(93886005)(6246003)(25786009)(33656002)(81166006)(8676002)(8936002)(99286004)(81156014)(52116002)(7416002)(6116002)(316002)(14454004)(54906003)(2906002)(36756003)(3846002)(478600001)(6916009)(53936002)(97736004)(66066001)(105586002)(102836004)(6512007)(86362001)(217873002)(386003)(229853002)(11346002)(6506007)(1076003)(256004)(305945005)(6486002)(26005)(476003)(4744005)(446003)(68736007)(71200400001)(71190400001)(106356001)(2616005)(6436002)(486006)(7736002)(186003);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6345;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 b8GsDOImAOCI4A5iDMbH5ipBxDYzgCyqT37NgpLWL0UmrTUhLFH9cf/LLzWXIWEHtu94jPnEaqiEBaq7yLgrwOWehxWAK7Xnqad9lh1nFrZecn4h0/eeNCFYDPVumqc+81MqxY2aucrdSso0MDgwDcQQuRlYr664uNa9xLGXtXCnJbQPx9oZaRxq2zpGC4bAmET53lerI6CR/E1Wmu2nWfHDeIQhHQ+/rLGtjJ+TkzRMHZeZpoWj8dGrmy2pIOzpviicNDGIuhAP72cJeGgBXZDmR6COmi5ZeGmpp+3d+r7mplCW7G74x5OijDaxg28gBXreLC8EGu0P6PxdVzvCEPEMiTxBQwa3L2I9hBdSWbgMfbPBnFlHgEpbMn94gNai2vCqdSsLQFRF4Gi7qkAri6fhW77QZg7/s5LHQoPbxag=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <82BFF7F760AB5D47935C40953858BB8C@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4b51e9cd-5390-4465-8cca-08d6866a0842
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jan 2019 04:18:48.2718
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6345
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 06:17:43PM -0700, Logan Gunthorpe wrote:

> This isn't answering my question at all... I specifically asked what is
> backing the VMA when we are *not* using HMM.

At least for RDMA what backs the VMA today is non-struct-page BAR
memory filled in with io_remap_pfn.

And we want to expose this for P2P DMA. None of the HMM stuff applies
here and the p2p_map/unmap are a nice simple approach that covers all
the needs RDMA has, at least.

Every attempt to give BAR memory to struct page has run into major
trouble, IMHO, so I like that this approach avoids that.

And if you don't have struct page then the only kernel object left to
hang meta data off is the VMA itself.

It seems very similar to the existing P2P work between in-kernel
consumers, just that VMA is now mediating a general user space driven
discovery process instead of being hard wired into a driver.

Jason

