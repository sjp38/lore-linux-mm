Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A6CCC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:19:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26CDF2087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:19:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="UzX6sHRR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26CDF2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE42D8E0010; Wed, 30 Jan 2019 14:19:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B699C8E0001; Wed, 30 Jan 2019 14:19:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E48B8E0010; Wed, 30 Jan 2019 14:19:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3EBA38E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:19:56 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id y35so237745edb.5
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:19:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=1Gazb6Jp6B360Dq+MkPlp8a64vElOV9HlssPVSOq7PI=;
        b=SomZOUTd4pac3O26+i5JKSBmO4WNTDMQtBf/qySdPwMiM7/8UnlxqpRbcpmP1Dd3u4
         aS3LvtZYcc2VvSgA00sDdaJ48dTP/AWF1W79lG7Z34UZSiZW9RsfxbBq7VgxAgZsb3F1
         itruPg3m4tqH+j9rmuaPVHqWHzhpcz1Qevhx4bp3OMwXKn9DT1kvqVWsnszQelXiiVk9
         4IiU4viNcB/U0FEj2D6nGcUjLi3hddQSqAOqFik5p5Eh9nujQ9stfAk+bffcvfB4f/pC
         Qyp5cIMtHhJtEVG8ttwHj3i4Ez+o6zqvQi6mApypE06e475LND29Itepxddgp37HNIX1
         fCSg==
X-Gm-Message-State: AJcUukfh8jgkLYSomuxdGnMfH4YQL/rv4y73eA4OoxbgjHWMPABYwdAM
	MNnKytDGGSZsuW8bS9Lj6IBNGmELs3Z37/1kvuzJ9GycYxy3hlRa2jm5oempHrn9sAFGAInNV6e
	w+z4Eq3yAb2IgFW5NrUk7PSEdLLq77oy7xhNK+7VCe9IrOGOXLSs6e3Bb8l1woTyiZA==
X-Received: by 2002:a05:6402:1816:: with SMTP id g22mr31967974edy.191.1548875995805;
        Wed, 30 Jan 2019 11:19:55 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5Yl4scerwIAlem9Y8Dipkp5L2N082vdMvdbPVbHQIHRAcC/nEtsPkvBrk/yYBOEYzJ3VqC
X-Received: by 2002:a05:6402:1816:: with SMTP id g22mr31967947edy.191.1548875995091;
        Wed, 30 Jan 2019 11:19:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548875995; cv=none;
        d=google.com; s=arc-20160816;
        b=lmwZD+qFFOEHHAO8xYp/F5Ni9TpGUAujEm8mgx7gdyqFp5y482TS1Tf5n3wfbZbZrn
         Yp+EZnu8ltHBhXO6yJx8ueeGI0mOZnEAnYbqnbyIzyv+lrtpra3jTzpUz1JEfcWMFcsd
         pZx9sjN3S23JW4BW7DsAdcInxB683f1BTTqOeZJII+QEPGhoLdeTCjr66KEfeGpQtxHM
         n+5qaLIFgeNRAJrL6z0Znqvd0h3ZhHKVvujmnU8zlnZItqtValUiJoiY3o0cHS9FPSbf
         ymEFWHauf0ITCA0pl9izU/OY42NBTok0Uyc1VDn27BrKdzjUpCb/3FRYvAJ37A4KSXhr
         nIoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=1Gazb6Jp6B360Dq+MkPlp8a64vElOV9HlssPVSOq7PI=;
        b=qQX3uDUuDTjB5ZxCE6utTUj1hhcJFj3ZF5TALmamNgOOfTK4j7fZ9fPFUAbAOYNurl
         TFXJXArE2E6PRD3xDuMk6ttrfKmsFhowIDyvq8XIenwa/TPsBlK+Mo+7XSaHUueGfGL0
         rFlDkgSMv+PkkO1evUsLph3Cz7uDDnShcpV2xwNhKNQCFZyXQJwd1BadLl3bt51GgHB9
         GLbiwVeETYBlgm/jcJl85se+SePBZD91ToU1XdV9JfDvg2PNmGMqRchxDXnhwDPw0egj
         fQbjd/eVNr7t6bVSu2XQRb+8Z4AoEVZ84AvOGohOOEINp0K/TBO/9FD3J7h6kaL4zwFB
         VNHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=UzX6sHRR;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.13.80 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-eopbgr130080.outbound.protection.outlook.com. [40.107.13.80])
        by mx.google.com with ESMTPS id hk20-v6si1220620ejb.104.2019.01.30.11.19.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 11:19:55 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.13.80 as permitted sender) client-ip=40.107.13.80;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=UzX6sHRR;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.13.80 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1Gazb6Jp6B360Dq+MkPlp8a64vElOV9HlssPVSOq7PI=;
 b=UzX6sHRR56qy4HbKSErrFp0EcAChEVbY8N3BvrW9CePVEyW4vY+fpOg4QDe8VHDBBt5OBBuTZiGjJizPcNLUMnlotIiYO8iGAwlVBazrNyqdX9rYYOBJg4MOXFs06OsiWPWNeMApeoVn7ph52XRTWDS+ZxAgnsGIwSghnx4xzNA=
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com (20.179.42.80) by
 DBBPR05MB6395.eurprd05.prod.outlook.com (20.179.41.213) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.16; Wed, 30 Jan 2019 19:19:52 +0000
Received: from DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59]) by DBBPR05MB6426.eurprd05.prod.outlook.com
 ([fe80::24c2:321d:8b27:ae59%5]) with mapi id 15.20.1580.017; Wed, 30 Jan 2019
 19:19:52 +0000
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
 AQHUt/rA/dLikqWEmEaIytHIBNLPlqXGkyOAgAAJwICAAAX+AIAAEreAgAAFNYCAALluAIAAoq8AgAAIC4CAABKaAA==
Date: Wed, 30 Jan 2019 19:19:52 +0000
Message-ID: <20190130191946.GD17080@mellanox.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205827.GM10108@mellanox.com> <20190130080208.GC29665@lst.de>
 <20190130174424.GA17080@mellanox.com>
 <bcbdfae6-cfc6-c34f-4ff2-7bb9a08f38af@deltatee.com>
In-Reply-To: <bcbdfae6-cfc6-c34f-4ff2-7bb9a08f38af@deltatee.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: CO2PR04CA0185.namprd04.prod.outlook.com
 (2603:10b6:104:5::15) To DBBPR05MB6426.eurprd05.prod.outlook.com
 (2603:10a6:10:c9::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;DBBPR05MB6395;6:/EUG6rN1Pl0LhGz+YLBfOhGglyVXmjKrFuRN+IvaFnbSOe68/O6+nK72Cm6QcD7d0TSvLFJUAKBpA6bJUnI1FuDWcOvtUehF1tj+zhv0iK43AGAf0usyGG5J+PaO1uX3AFNNc3wGApQ3B6Dhy1LY9g+TjT1mH42dYeWEnXWaxyh7sqlLJdwzVQvPULfsZuWaNgXL+g255UwHb4t3feNg+Bd3l3sw2CalhRiDJvancL21/OOAJi+v8u6biUPdERh6gDySgJPOTqZboa5et7QHdyyVkjXPgllhiY9+FsXK0IKNNyHJMUunwa88Th8LAPGRtFrGBbvPrCn3Y5kbMOKgp7kfcmoTy83TPNEiLOxVo/jdmX5h+Bl+9P/kESw0GETfp3mz5S/lZFHykVMvNdHnt/vpZb7Z1y0opqIlP72tJ6T3iqQnpvSFamcI9SmIXjvBdPmSahkEEWIoc5rt3WZRFQ==;5:Crbz8a9BZD54YXFZevGAFLMvdcWZa7qezxOdj19uIrgLDz8xpGwotVj556Qa/XfI3d8rZSpzrPxQDqj25ILs8GOiyMfQumCcDMvwyarlLEpc9fHo7gPGI7XIp+2ErYoOHhWdFfq53cvB8XZ2pUmVi/KLgaGoJAuuCNUhyqtebpfDqFfExMLLrPEWtPRpVJ6z4ZohVdySHhLWERuOr8Xgqg==;7:8j6QfQXfIbjgtF1JWbSGx/TDa/PqeDpiB9Dv9g+Vyh89Ky8eMRYnssf9rBAoRHzsV4JhMUDdd7/ZetNe5SUtPVhetlPATm2m9cptMYVpfRnOsyS22InngAFQklCJLKcRiH8TaV2OBRP9A8aoSxfwVQ==
x-ms-office365-filtering-correlation-id: 141dbce2-fcb6-438c-3fab-08d686e7e8e6
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6395;
x-ms-traffictypediagnostic: DBBPR05MB6395:
x-microsoft-antispam-prvs:
 <DBBPR05MB6395CD70E422712DC53CC647CF900@DBBPR05MB6395.eurprd05.prod.outlook.com>
x-forefront-prvs: 0933E9FD8D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(366004)(396003)(346002)(376002)(136003)(199004)(189003)(54906003)(316002)(6246003)(68736007)(105586002)(446003)(2906002)(25786009)(53936002)(97736004)(4326008)(36756003)(76176011)(2616005)(476003)(11346002)(106356001)(33656002)(53546011)(6506007)(486006)(256004)(217873002)(52116002)(26005)(99286004)(186003)(386003)(102836004)(6116002)(6916009)(3846002)(66066001)(4744005)(1076003)(6436002)(6512007)(8676002)(81166006)(305945005)(7736002)(71190400001)(6486002)(229853002)(8936002)(478600001)(81156014)(93886005)(7416002)(14454004)(71200400001)(86362001);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6395;H:DBBPR05MB6426.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 uZltpbhLDx/I/aSUk9bXd8dUSVjJoSxhzqz+W/18RtNysqS/wJ4mPoHP7JdgoAtsnUekdTPo/8qwYi+dogonykLMJ1Pd/2rGSRZoEf8c3xKpQ0QR+JwvdTI3+PcXk+S5aOS8flwScOXfAlrKdYdMiBiUxnhTXM5MWYKW6DCe82M34QwzLox92rry6x7I0XoIdut7dOTe7jm4L7z3TBd2gKD7/aRITwT8AEv9EMjU7t4a4wyQK+/NvqXaucg5XBshGoXZie0Fl3FJvCInwLy8i9H1ojviDjdieAytVAAz83CNLzFb1o75DuV7AaEbQQAw1tTSO//erXE20cygsJmUSWYloEDMen3fsNCzfaTMKON48DYZ/7zf3TWYIuBzBY7e3qsVAlxr/YBl4yWs17Ewht9WRm+WOIOERRsSd1gadK0=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2608ADBADE66244CAF93015265B4523A@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 141dbce2-fcb6-438c-3fab-08d686e7e8e6
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jan 2019 19:19:52.2454
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6395
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 11:13:11AM -0700, Logan Gunthorpe wrote:
>=20
>=20
> On 2019-01-30 10:44 a.m., Jason Gunthorpe wrote:
> > I don't see why a special case with a VMA is really that different.
>=20
> Well one *really* big difference is the VMA changes necessarily expose
> specialized new functionality to userspace which has to be supported
> forever and may be difficult to change.=20

The only user change here is that more things will succeed when
creating RDMA MRs (and vice versa to GPU). I don't think this
restricts the kernel implementation at all, unless we intend to
remove P2P entirely..

Jason

