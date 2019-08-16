Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1C0FC3A589
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 00:54:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE7A7206C1
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 00:54:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="HDOVeC3O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE7A7206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45C066B0003; Thu, 15 Aug 2019 20:54:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40CE86B0005; Thu, 15 Aug 2019 20:54:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FAF36B0006; Thu, 15 Aug 2019 20:54:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0144.hostedemail.com [216.40.44.144])
	by kanga.kvack.org (Postfix) with ESMTP id 0EA5A6B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:54:39 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id AE8518248ABF
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 00:54:38 +0000 (UTC)
X-FDA: 75826470636.16.ant97_7fba853f34c44
X-HE-Tag: ant97_7fba853f34c44
X-Filterd-Recvd-Size: 7271
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00065.outbound.protection.outlook.com [40.107.0.65])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 00:54:37 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=GRUiByGAjt+W4rbq/316E9SLLwvP3+pyJNIA9QYS7OeF0aCQOWiEM/VK12C/KXaURtZ4MURolXryqWDYRTr26JH11W07up0Ujs7xC1ykT8tqMo3amvSgWjNGt4Nf1Zbd9RtwOmZEOag88erZCtdsIwXWuR8J2NacPF3jUcpcHOQJq/vC2y3j8LFSzUa1cJc/3Cy8A5KzBaQrc9LCEKZhDfDRDnicCb31KJkKodGvzVTqlG6f4Pl3M9sqZzQhhh5YfH7J5NfUcZO6D7UH/FCPn5hfhTSLj7y4BU2VCYqIRe2Nbm0mmd9XXFm5MuCPK3ir3ZD0tb1+jsxQUwxhwdkFIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QwY8MbS2ae9WtsE6Q9UxT79gjFegHeEny7UCSsvSYuI=;
 b=cJIxQVLAl152MhG2qgfSYTB81iKh82n642Ol33b9z7yKJLAAxSIRo1d9IfMA3mhDMyiafqOsZ7LTf/WINPhCdGdKSolxDojVx08PuHJIwO8YxpLkUlECUEhvhs2X2deztAK2D2Pz9PxT2vDQYmEInK1O5xmGzL8DG46XyKa5jn15nHSH6Bzx/nIY9zHcrFaAba2fVU86p4dplh7l1+0Je941TcuD8d/ql1Yln48RoKtNohsuLYsIFLl1IuUpkV0OSlZewS1SNCorxFAHpqCkl/ALCupeU8eMId2wXsYknSsRdFuyj6e/m0DRKhjgQd6pl5rbTpbLqcqybsy6UocfIw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QwY8MbS2ae9WtsE6Q9UxT79gjFegHeEny7UCSsvSYuI=;
 b=HDOVeC3OLES1L5VCf4d5tw9DaLdSFSsehDC6K3NeRd7xtQb5qtbXUf0/LCw2fYX9tgCp91Um4XDxzFmCDncuSARMAWgmZnlux1R/+NaYSTnv6tASAqQzgK6i2tfCY0yDZIDlAKZhZNxI4gACPv+QElS5Viex57occpOIjC+a/z4=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6479.eurprd05.prod.outlook.com (20.179.27.203) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.18; Fri, 16 Aug 2019 00:54:34 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::1d6:9c67:ea2d:38a7%6]) with mapi id 15.20.2178.016; Fri, 16 Aug 2019
 00:54:34 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: "Yang, Philip" <Philip.Yang@amd.com>, Ralph Campbell
	<rcampbell@nvidia.com>
CC: "jglisse@redhat.com" <jglisse@redhat.com>, "alex.deucher@amd.com"
	<alex.deucher@amd.com>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "Kuehling, Felix" <Felix.Kuehling@amd.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>
Subject: Re: [PATCH] mm/hmm: hmm_range_fault handle pages swapped out
Thread-Topic: [PATCH] mm/hmm: hmm_range_fault handle pages swapped out
Thread-Index: AQHVU6tqPJgEXxIoEkOKYOi6xfC1Fab88vqA
Date: Fri, 16 Aug 2019 00:54:34 +0000
Message-ID: <20190816005429.GD9929@mellanox.com>
References: <20190815205227.7949-1-Philip.Yang@amd.com>
In-Reply-To: <20190815205227.7949-1-Philip.Yang@amd.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0005.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00::18) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: dea49aa3-3fb5-4a34-ccf0-08d721e44de0
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6479;
x-ms-traffictypediagnostic: VI1PR05MB6479:
x-microsoft-antispam-prvs:
 <VI1PR05MB6479B893C951BF5616E25917CFAF0@VI1PR05MB6479.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0131D22242
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(366004)(376002)(346002)(396003)(39850400004)(189003)(199004)(446003)(6512007)(64756008)(8936002)(8676002)(6506007)(478600001)(66556008)(76176011)(66446008)(54906003)(102836004)(305945005)(81156014)(53936002)(6116002)(7736002)(81166006)(2906002)(66476007)(3846002)(14454004)(4326008)(25786009)(256004)(6246003)(110136005)(66946007)(86362001)(386003)(52116002)(99286004)(14444005)(229853002)(33656002)(486006)(11346002)(316002)(36756003)(186003)(4744005)(6436002)(2616005)(66066001)(1076003)(71190400001)(5660300002)(26005)(71200400001)(476003)(6486002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6479;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 CsmS3afi4x7IW3WXyP4l6K5lqN/aSqWhGjmmZb0hqKSyDJSR35A2Ljh+yUsUIefbjqtm4mu1YeuqVmqyuFTohQ+GowRJmfS5dqVRPV6NNW59VgzA04ul95SBbvVvqnvbDsq3RBupsADPMfWFJVbdpQTSvLwTj+4uf/YUe16Y5WKqOCq/KrK0YMJzCdmS8Ik4NeYCMr7qyMQQhfyhU7/jM5L5y54zWijRYc0e9l+t1QwVHJP/qIdRYxRSU4L8S/PuPMgAII5BI5Md4w5LiDphgQBzSRY7hZQEuZnxYxwrMJ42BCwd5v5jVwfA+9GarMgsiMyoIr32TOyhCyoNfuQGbjWqZk1Gw/Vvl2vpWf46cBj+yY4P71o5O37YxrvWNdBAGDFDvQcL5aFNFqWFbz0iF0W6FaNEDSXmISQz0g0aFsI=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <156BFA0EFAA85449B09AE3B7C3825D33@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: dea49aa3-3fb5-4a34-ccf0-08d721e44de0
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Aug 2019 00:54:34.0651
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: QeReuAKldV6xUrDt/HB8x1EC4510QD5bDcoJdPz3JOb8IxVWTquESjcMukcMlF0CpD0goXAcjm29a7sVL9Gn8Q==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6479
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 08:52:56PM +0000, Yang, Philip wrote:
> hmm_range_fault may return NULL pages because some of pfns are equal to
> HMM_PFN_NONE. This happens randomly under memory pressure. The reason is
> for swapped out page pte path, hmm_vma_handle_pte doesn't update fault
> variable from cpu_flags, so it failed to call hmm_vam_do_fault to swap
> the page in.
>
> The fix is to call hmm_pte_need_fault to update fault variable.

> Change-Id: I2e8611485563d11d938881c18b7935fa1e7c91ee

I'll fix it for you but please be careful not to send Change-id's to
the public lists.

Also what is the Fixes line for this?

> Signed-off-by: Philip Yang <Philip.Yang@amd.com>
>  mm/hmm.c | 3 +++
>  1 file changed, 3 insertions(+)

Ralph has also been looking at this area also so I'll give him a bit
to chime in, otherwise with Jerome's review this looks OK to go to
linux-next

Thanks,
Jason

