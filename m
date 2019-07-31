Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DB07C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:02:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C34E821851
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:02:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="L5UQjTDS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C34E821851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F1868E0003; Wed, 31 Jul 2019 13:02:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A0F38E0001; Wed, 31 Jul 2019 13:02:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 342318E0003; Wed, 31 Jul 2019 13:02:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC5238E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:02:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c31so42854522ede.5
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:02:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=h66GYamRh5h8PU3T095hhzCj9UAlrpEZrkJYNRToWEw=;
        b=qr7u/WJMys41xHCbugZWAnPMV10J/tzoqI/3TNO17skt6+v6JALQtj6YmAA1qWgR6l
         e2VtrO9Z++zN29zfcigV3VRJlCfwZfzxUEBB2Fq2YIGSKMrRvBeGdhxuypbphnDf9jPe
         9+U5Rqqyq5oa++GJFB0DgH4ToiXshbdmL4zwa+hKdR0hRrnshXxsUpRIM5qNrbg+M1Rp
         rYugxWdWp380pz+dzT00ZNH1NvtkTp8U7VufRLRamxNpYiPRfEChhw18MN10XAaDFplJ
         i+NCvE31krQaz7AGJ+HDMHWm97AvBaCCvcbTUngkHyrAP7vI8sSEY54aQlb/vqS9k67B
         KhgA==
X-Gm-Message-State: APjAAAV1g3rzyVcYo3ovAZVU10fftK29wDB5NBo1U4xB63pz/r2rUPZi
	VmxrdPLF2D+KNJiwEjpxFzqlZumtG9NgMbU9CtQnD98OZBsGjXjoeE/v3adMZjJGm5pP0f3hjsS
	aoSEonRJL9w/8b0gCqQNrKmVjvEZdM+nFgzeCp6BYR1ZT0wQTsTO+TQyXVPqOr3OxhA==
X-Received: by 2002:aa7:c49a:: with SMTP id m26mr111120860edq.0.1564592546472;
        Wed, 31 Jul 2019 10:02:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYSK9OqkrgID+Jis2bBR0VmtQZ94qg/X6Tde0F+Y5dtq6Iw1CP70R4w96RXk6WJzH5KpJa
X-Received: by 2002:aa7:c49a:: with SMTP id m26mr111120781edq.0.1564592545839;
        Wed, 31 Jul 2019 10:02:25 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564592545; cv=pass;
        d=google.com; s=arc-20160816;
        b=xk/G9aIKFdZSiRte6XpZT1ShVIL1SLevul9gS05GeGNyBXtIROzqRHqtNNh5EpaXZ0
         5TwFThukbv9LkiIMXucnOS2VOzfaTZ+wSvisK+dlqQCn1ccfJMU/f8dFJQC0hPlyliFb
         o7dIA1ZreMbk/MGtbCMw2i67JaxBlCgzDlXIK3BU8vNHJhoe7t7cuc5TvGRcyKuJVAjj
         6XMotPkjkEHhFnTjj877i1JKeBng7Stb5uPYHyI1TMDZQ7lhH0KLV60K0anI4C+nnr67
         3CovF1vdLmx2BMA2Vb4JVZqGKZV56hchCKadi7qpAw+ZIUaVMmf8hec0cgAFRWl9e7KH
         9KGw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=h66GYamRh5h8PU3T095hhzCj9UAlrpEZrkJYNRToWEw=;
        b=Mbt6VEK5s3gr1YPSxea1GvPbN85Pd3KG4uABfc4BT2d9N+x1BKY/x3mF3/vWvSoaNh
         boGpOYYEiYNBS+AZ/sib9ORbV7Y/oGEg41bpHHzquViOqVJEUoWIbkTQ/Y1JjG9B48rc
         DykSkbSPZj6/89T7b8qtEmC3aazmsuyYoubOl+4j3zGMHCUBpcO6d1MgLllFfwLOQVP8
         sXIO6tkdkJuXPuDOoORbTcTEcaqQGvn664g4nGugKjkt6Am/E79bKPN3LsE6yquCwXoW
         MrOOjeJmAmrD8OfGpdf7MJZA4U/B+92WtLxDPpc0gpGNnzcgN5QI+2V+DXtpB55n1yz2
         yOlg==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=L5UQjTDS;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.7.89 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70089.outbound.protection.outlook.com. [40.107.7.89])
        by mx.google.com with ESMTPS id t4si18808169ejs.337.2019.07.31.10.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 10:02:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.7.89 as permitted sender) client-ip=40.107.7.89;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=L5UQjTDS;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.7.89 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=fOXT2KUTfxcPvEMCppPXk2wrMj4BZLasKl0MVTzmNI0fkSjLV66M4uEv4krqsabdQDAjj/97Yq17EVEK1CYwucARO5gIJ8n49ieAhWP84LKaiJXcCQuzJR2yUnt1e8yP8sAwa7oVw4aMqLe84HOk7VQrTvm3gGJdXNzMc/W56FObR+HJ9D8hv4Qey2bPXSJmcFVGjUXd2Z5LR4WCqHcDwlr89wMcx6SvIx5WIiWdqZdZdFf7rVeBTOniH9u2pzNo7r02r6//ESGNRHeNrfPnix8l/pazfCnh6Ivg6dPk76aksMhEYb2i/t9gJJ7O1u762oYwKhwdbDrus5mfExRACw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=h66GYamRh5h8PU3T095hhzCj9UAlrpEZrkJYNRToWEw=;
 b=XwwlJYgAJQ4rZvYxgaUjCaHIM3BgbPeo8fO7H8WknkiiXp6hPzMXD+HBG0xTmdt5pD5/tsUT6PEoJqkKChPfD7QtMM3203BxKoiY+J5ljyjUjfNrmfwKXb7PV/kZbVW1BRyAWbM0QyMJbIlPAY2LCyM7KY5ioZb9MM5wNwt7HLSIOc+06lDgWhuag9DToWEsnafL8alrqHyG7sa7XCcwarWyTLzgos3EnWmjkG+BLz+BXoWnJ7Jh+/ptHMdFsbqC5fo0/L1D/EhC/OUgSg3pxO/BsTF3mutzY9Cyo6Gx9ZIikl3Ao5OXK5S82QOPRhYmts1cCdJz1dK3+M2ovDYY0A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=h66GYamRh5h8PU3T095hhzCj9UAlrpEZrkJYNRToWEw=;
 b=L5UQjTDS1konX8ry82cmnIKY6y4buSB33dhb+3UGmgB1jB4Vg1G2ZhzCOwrInofPuCtPO3GvfZL63BtlB/3W59RYqZg0AT9ehbXxTjjCeTwybV7EXAQ6AWY+31P8WpQYtN4KeeuCQ4x6NJpluZzswU0VAXr0RZuQgyYmgdREKs0=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB3231.eurprd05.prod.outlook.com (10.170.238.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.15; Wed, 31 Jul 2019 17:02:24 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2136.010; Wed, 31 Jul 2019
 17:02:24 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
CC: Christoph Hellwig <hch@lst.de>, =?iso-8859-1?Q?J=E9r=F4me_Glisse?=
	<jglisse@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Ralph Campbell
	<rcampbell@nvidia.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 02/13] amdgpu: don't initialize range->list in
 amdgpu_hmm_init_range
Thread-Topic: [PATCH 02/13] amdgpu: don't initialize range->list in
 amdgpu_hmm_init_range
Thread-Index: AQHVRpr2/Xz4jNPu6k2DNRcwdQGPdqbkuYYAgAA8sIA=
Date: Wed, 31 Jul 2019 17:02:24 +0000
Message-ID: <20190731170219.GG22677@mellanox.com>
References: <20190730055203.28467-1-hch@lst.de>
 <20190730055203.28467-3-hch@lst.de>
 <a4586f5c-0ae4-8cbd-65ff-dfe70d34f99b@amd.com>
In-Reply-To: <a4586f5c-0ae4-8cbd-65ff-dfe70d34f99b@amd.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0071.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:1::48) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e18b437b-1d80-4064-93a4-08d715d8dbb1
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB3231;
x-ms-traffictypediagnostic: VI1PR05MB3231:
x-microsoft-antispam-prvs:
 <VI1PR05MB3231B23EE08859787CFF93EECFDF0@VI1PR05MB3231.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 011579F31F
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(396003)(39860400002)(366004)(376002)(346002)(136003)(189003)(199004)(6512007)(478600001)(66556008)(6916009)(6436002)(11346002)(14454004)(229853002)(446003)(256004)(7416002)(6116002)(3846002)(54906003)(53936002)(305945005)(36756003)(86362001)(316002)(486006)(2906002)(476003)(2616005)(66066001)(33656002)(4744005)(81156014)(8676002)(102836004)(26005)(6506007)(66446008)(71200400001)(1076003)(53546011)(386003)(6486002)(81166006)(4326008)(99286004)(6246003)(52116002)(76176011)(68736007)(66476007)(64756008)(66946007)(25786009)(5660300002)(71190400001)(8936002)(186003)(7736002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB3231;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 XvANRZ0wSiwaYImTi/Xr3Vcjvyb3jUZ9kXGpIMAMliLL6nh88DIR9Yh1Zop+BRn/H8Ent1VUnvJsbHWZ2M6wXZBC7utyFXLbpNkbuXcvSREmn69Vjgy9PZoVRZvZjJmGYQy96YC/pPe6eAJXl63HvODgzwUjaz2yy2i2kJea4byM3/AV8p0T+OYwG+WYSIWwJbqWlF6x2pX7NEku1uagH3ZhYaovCn0XJ8Ng0oOvKn9KUrtJRtcyB1WmZKjyFlGGb34I0aa3oYIex22SOsO3C+cC0zOnj089fsi3t9ySZu9jjRa/qEgBWRhE9fLEGuDenzxZOuM4FPdDyp6B3gAm7cXxSg5Kfjb+gyNtPrlWEuFUQBS45zRynPfUGNRudHAY6IhgLvaZjl8nqJltfM/1+bgV7RLjNuiYlQZL8IdecDA=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <FAC49FFA8B421F49B49EF44701A00263@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e18b437b-1d80-4064-93a4-08d715d8dbb1
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Jul 2019 17:02:24.1750
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB3231
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 01:25:06PM +0000, Kuehling, Felix wrote:
> On 2019-07-30 1:51 a.m., Christoph Hellwig wrote:
> > The list is used to add the range to another list as an entry in the
> > core hmm code, so there is no need to initialize it in a driver.
>=20
> I've seen code that uses list_empty to check whether a list head has=20
> been added to a list or not. For that to work, the list head needs to be=
=20
> initialized, and it has to be removed with list_del_init.=20

I think the ida is that 'list' is a private member of range and
drivers shouldn't touch it at all.

> ever do that with range->list, then this patch is Reviewed-by: Felix=20
> Kuehling <Felix.Kuehling@amd.com>

Please put tags on their own empty line so that patchworks will
collect them automatically..

Jason

