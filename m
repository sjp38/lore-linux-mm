Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEED2C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:02:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82ACD218AF
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:02:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="YXefsJum"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82ACD218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 177978E0002; Thu, 31 Jan 2019 14:02:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FDC88E0001; Thu, 31 Jan 2019 14:02:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E92AF8E0002; Thu, 31 Jan 2019 14:02:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFF08E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 14:02:19 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so1740192edz.15
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:02:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=3nufCx3hqfLVglKqxGmnoTk/Ptp5QELUM4LvKps5rQs=;
        b=ln/OtRNaSxfIyS6+Tp+CEUY9GoMMii0j1HT+Ztwu2VuMGWB762I4kLIQa2sfjTO8Tg
         zVAwtVAAP/p9EpNJPRan6no+QIN7cSAARw4t3hwx0Y+k19EzjecZsLd+zhiiGjN/1jVX
         XjmLY/oHF7sfGgnMVCdUtUzfVoI7OtZy8JJESxH9HnP3HmKlQI6evgi+UK2SFc0jYs5t
         Br0t8sy1YZeww0opaQI/8oL0sPrlF5eJqiOFgwdt+39dtGD5BybBkLAeoYiqWKB8X8gh
         +G5HmcdQR/v+Ms3zSGeyq/+6Cw85USA0le/mmUfW1dmDsuOhI6ZIu4kQaU2m5xGhdd4U
         3AZg==
X-Gm-Message-State: AJcUukdjIx8TxTq36saYAmfYo3/QizDfAe0CZzajwLKa0/bpEgJ+DSp7
	AAvCxrs7UO4HMoPIlgmITs65HGdGWoKh19k/m8T7JnxCMmC7PITckG8jCrT29uG5OHX9ue+zJ0A
	pB+etF/bnTUjFJ0vlo+LYqijKAdT8fsCDJLR6x7hLJI2lbkHU2Qif6AzCKyG1yIpYsA==
X-Received: by 2002:a50:b205:: with SMTP id o5mr34517150edd.245.1548961338901;
        Thu, 31 Jan 2019 11:02:18 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4YVuQecSUROAzNeSQ84cyl6PFXGOc8jcq3DrWosvYUN7RiMm/j2daFleR0EWG201Rk2Fis
X-Received: by 2002:a50:b205:: with SMTP id o5mr34517062edd.245.1548961337358;
        Thu, 31 Jan 2019 11:02:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548961337; cv=none;
        d=google.com; s=arc-20160816;
        b=mngNvRWgrCtnEqFQ6EZ7BZD59ey6Xm0s+apkVa28h1IK17c5ggnt8hQlm2YfyR3uQr
         zRNIHVGxS5eL+q8prOJfzRu+uquo/Xivo2qIwxLdl4Yi1ix3arH0Q9p4GeRXz3axHJ7Q
         TgO9oKr2e9+J88IrNU/DFwWaiB33OA2rw4JS2J1kvnv/96poScMilq21WTgOG48Lg03M
         PBPHZ5l49Krq7bUHQJJu8Tvmy7sBgQ5meUiTuRfcm4d9erypW32h4VrAdghnLp4on/1E
         MN3vbZtEw35LnhNh5vAXkdXw/b240O7adMjDR9MNgm1iYYKroxLMlbneDBHUNjqd+iPu
         r5IQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=3nufCx3hqfLVglKqxGmnoTk/Ptp5QELUM4LvKps5rQs=;
        b=XX5p6Y/Z1uAza5M2E94fhyFbws/bZ5rwdAHv8Y5Gfa7IY165zljWvbjtMH9f5LB/he
         ISG8Tmz/OOBeDVzAsV6c+ayPct9kTOu3/lMy4N5cgNs2JG1i6KQX12fGvqB3dg702aN1
         1HfDsC/qq7OtqFMBEG++YnKXD6ZD41Jk0aFHEW/BORqnvZHTdwnm8lsCS4MjkmyfJX0A
         HTjjEjh2Jo0imp0bKWXB28c6igNSQWKcp9Qe2XDbXnHE8w96g7bza5ZJrE/5gZ1pND/F
         HsHSqSl7ePh8qkAfIi9zle8RX0trxzm7Cg7qXbqgtUrPyl+UB+lg6muc8mScs3pttC++
         mBIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=YXefsJum;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.56 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10056.outbound.protection.outlook.com. [40.107.1.56])
        by mx.google.com with ESMTPS id a12si2684909edh.350.2019.01.31.11.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 31 Jan 2019 11:02:17 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.1.56 as permitted sender) client-ip=40.107.1.56;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=YXefsJum;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.56 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=3nufCx3hqfLVglKqxGmnoTk/Ptp5QELUM4LvKps5rQs=;
 b=YXefsJumO8hpqJLahYiT0QQbysGPrF2c0hG5ycpe37QETVPi6t8drxKRdI1cCof1JgGNZz9L8Zrb+DUxJJ6Hw2HH6flqW2W1q8iOpRmcXJy7P4UHxouLSdCWaTtnkpWCX1VhARBs85yq4Xz0j+Dr86xCmS17gSTUgh1mJMdbgGA=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6572.eurprd05.prod.outlook.com (20.179.44.83) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.17; Thu, 31 Jan 2019 19:02:15 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Thu, 31 Jan 2019
 19:02:15 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Logan Gunthorpe <logang@deltatee.com>, Jerome Glisse <jglisse@redhat.com>,
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
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAAEreAgAAFCQCAAAk3gIAABX0AgAATFYCAAA25AIAAGRqAgAAykICAAD3dAIAAukqAgAAK3wCAAAOzAIAAEXyAgAANnoCAABFLgIAAnPCAgAC1FQA=
Date: Thu, 31 Jan 2019 19:02:15 +0000
Message-ID: <20190131190202.GC7548@mellanox.com>
References: <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com> <20190130080006.GB29665@lst.de>
 <20190130190651.GC17080@mellanox.com>
 <840256f8-0714-5d7d-e5f5-c96aec5c2c05@deltatee.com>
 <20190130195900.GG17080@mellanox.com>
 <35bad6d5-c06b-f2a3-08e6-2ed0197c8691@deltatee.com>
 <20190130215019.GL17080@mellanox.com>
 <07baf401-4d63-b830-57e1-5836a5149a0c@deltatee.com>
 <20190131081355.GC26495@lst.de>
In-Reply-To: <20190131081355.GC26495@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MWHPR2201CA0056.namprd22.prod.outlook.com
 (2603:10b6:301:16::30) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6572;6:HNkZF7avC8/n5VWQOBdA1HlI8rj2UKHNvQF8/BvCNCCEo352KPB2cF+1ylV+WbGOOkcT+wHNBbAlh6wCgFSo1XC4CdlO1f++D1ae8peTgMnWTiN2CGYUCV1AvYGGHRMqrKk/0KyHgxJZhNYYCWSMXFiSYIIuYwoqLGhk936XzOmw8opAnL1EJ6YkVC2DRqdTjeY7wRweKnm9HyW/MygFtp7arLshc7P/RQb6Zjr4t5ar2m2mZWlo71ies/22f8BylJEi7nS33UMf5oHK+LDqiY14XYMdBLil5vtRnPQMV9Yesgk+dRpSfOR0E6wxQtryIHQ8AjEcwELM9XpsQM+p4hXNT26osd9ffHmrpchN+wnpAYFTzHLLZm0G5KcVtVnSWQKB/30z4L2c1Wtka0kJPvarytFsdMa6WEeKMSmwdBxa2A2/p52jRSTfFXUrYt+5j36WVysA+SGYaIlVjway1g==;5:BRoqPTooKEsVS+ZNcMN0we1IS1yCPVExUUlmkyoymiOlHKyz6ZyttYyhO/cJnLDLZaWhjFqPj7q/iR9ZvA63rRIBPn4ZHNWOyaHIJM9RV5LFm3peDlRzEQpj1gKfeY1PlcXU3kRySu61a+FZGAEMokI8U9W9m7BcfgDe2TFCimGOujMcXSPfrkki2Ok8JU7bK670Vz8PVRkBZwb3giB4xA==;7:o373IAlTU66yM22edgyqTz+VhUhiV9JdG9gWD+VFEXH+gLHl4MGcyLBGoJEku9MZKpo0lIao7r+eRrVeEspre0Fkemcy7MTNu3AHABp3rpy8z4C0vWyy192lLttP0ugsaid+/SyODmYZ5GKznoWtJQ==
x-ms-office365-filtering-correlation-id: 2f9dac1c-7542-49db-bafd-08d687ae9d04
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6572;
x-ms-traffictypediagnostic: DBBPR05MB6572:
x-microsoft-antispam-prvs:
 <DBBPR05MB65724259DD6B135A185987F2CF910@DBBPR05MB6572.eurprd05.prod.outlook.com>
x-forefront-prvs: 09347618C4
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(396003)(366004)(39860400002)(346002)(376002)(189003)(199004)(51444003)(486006)(11346002)(305945005)(36756003)(81166006)(8936002)(7416002)(71190400001)(71200400001)(8676002)(2906002)(68736007)(81156014)(97736004)(476003)(105586002)(2616005)(6916009)(7736002)(106356001)(446003)(1076003)(186003)(66066001)(256004)(14444005)(217873002)(478600001)(6486002)(86362001)(93886005)(386003)(52116002)(6506007)(25786009)(316002)(229853002)(102836004)(54906003)(6512007)(33656002)(6116002)(3846002)(6436002)(4326008)(53936002)(76176011)(99286004)(6246003)(14454004)(26005);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6572;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 09p5BRgWBkIqlg8tnVg1jiC0Aeq8rYPttLCDa+ObAmnsN0Yl051RsM19dqA2D2lh9JIVbRMlaJ6lRJSI5yZCUOzWNEypRax7cm6S8kVD5PA10cOVH1ZzsNkTl3XgrLx4y+N4IaZe/9/mxHj/BoYjZf1TMjqN8f5y7/gpVtpHjOlu9EbmdbUEpiLqqrtB10BsfiEPu6s0DWttu87AmTlo2iMMLbI8w5rR90FoPl3kz6UPrjBD7NK4bQ7Rbuwlk5sIDjC8aFxVhUXzvbA36UnDeILc9cT0dedug8L0utacZh3bapVXmpoXfnjX//VP8gCWZIaffAjf/qAn7FjrtIzZE4hl5pNuFjohUY2be55wAsmOCpuRd04NfBskCqMk27hdorWaFluV96Ni+mu8sEfcRGbqmMH4nvK4I3k9atdDfaQ=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <CD8CEED72A7F8B4182C44E495B868BB9@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2f9dac1c-7542-49db-bafd-08d687ae9d04
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Jan 2019 19:02:14.7876
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6572
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 09:13:55AM +0100, Christoph Hellwig wrote:
> On Wed, Jan 30, 2019 at 03:52:13PM -0700, Logan Gunthorpe wrote:
> > > *shrug* so what if the special GUP called a VMA op instead of
> > > traversing the VMA PTEs today? Why does it really matter? It could
> > > easily change to a struct page flow tomorrow..
> >=20
> > Well it's so that it's composable. We want the SGL->DMA side to work fo=
r
> > APIs from kernel space and not have to run a completely different flow
> > for kernel drivers than from userspace memory.
>=20
> Yes, I think that is the important point.
>=20
> All the other struct page discussion is not about anyone of us wanting
> struct page - heck it is a pain to deal with, but then again it is
> there for a reason.
>=20
> In the typical GUP flows we have three uses of a struct page:
>=20
>  (1) to carry a physical address.  This is mostly through
>      struct scatterlist and struct bio_vec.  We could just store
>      a magic PFN-like value that encodes the physical address
>      and allow looking up a page if it exists, and we had at least
>      two attempts at it.  In some way I think that would actually
>      make the interfaces cleaner, but Linus has NACKed it in the
>      past, so we'll have to convince him first that this is the
>      way forward

Something like this (and more) has always been the roadblock with
trying to mix BAR memory into SGL. I think it is such a big problem as
to be unsolvable in one step..=20

Struct page doesn't even really help anything beyond dma_map as we
still can't pretend that __iomem is normal memory for general SGL
users.

>  (2) to keep a reference to the memory so that it doesn't go away
>      under us due to swapping, process exit, unmapping, etc.
>      No idea how we want to solve this, but I guess you have
>      some smart ideas?

Jerome, how does this work anyhow? Did you do something to make the
VMA lifetime match the p2p_map/unmap? Or can we get into a situation
were the VMA is destroyed and the importing driver can't call the
unmap anymore?

I know in the case of notifiers the VMA liftime should be strictly
longer than the map/unmap - but does this mean we can never support
non-notifier users via this scheme?

>  (3) to make the PTEs dirty after writing to them.  Again no sure
>      what our preferred interface here would be

This need doesn't really apply to BAR memory..

> If we solve all of the above problems I'd be more than happy to
> go with a non-struct page based interface for BAR P2P.  But we'll
> have to solve these issues in a generic way first.

I still think the right direction is to build on what Logan has done -
realize that he created a DMA-only SGL - make that a formal type of
the kernel and provide the right set of APIs to work with this type,
without being forced to expose struct page.

Basically invert the API flow - the DMA map would be done close to
GUP, not buried in the driver. This absolutely doesn't work for every
flow we have, but it does enable the ones that people seem to care
about when talking about P2P.

To get to where we are today we'd need a few new IB APIs, and some
nvme change to work with DMA-only SGL's and so forth, but that doesn't
seem so bad. The API also seems much more safe and understandable than
todays version that is trying to hope that the SGL is never touched by
the CPU.

It also does present a path to solve some cases of the O_DIRECT
problems if the block stack can develop some way to know if an IO will
go down a DMA-only IO path or not... This seems less challenging that
auditing every SGL user for iomem safety??

Yes we end up with a duality, but we already basically have that with
the p2p flow today..

Jason

