Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05B19C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:18:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD0B4214AF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:18:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=wavecomp.com header.i=@wavecomp.com header.b="rw9cYvw8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD0B4214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33B1A6B0008; Wed, 24 Jul 2019 16:18:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EC626B000A; Wed, 24 Jul 2019 16:18:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B3018E0002; Wed, 24 Jul 2019 16:18:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C09076B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:18:25 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so30835895eds.14
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:18:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=0O8bf3MkktXRPasPPM0aZ8FRhXf2oYT66ZTm5ExM6I0=;
        b=i6luwzUnTaHKUYammfoApdRDn6719fl1VfqIpTyf9knm2y6amDbEDzzdhYv0f7xFKy
         76iyMwMDZ/PfA2oPGbXrjjwZc86igUmwoSvvKte7lwACvo1XCfvTsa4kYRldo8Sn2pg6
         Jes094ZQxnznkrl0iGMH7nuxXqn9n/9AKMTsFtnPQ6bz+IOATygCBm3ytAw4kx9/Bzut
         YWu7EiJOKzcPsr3keU0PkCbIZbsr1JuquVejOMN5nCzCW81rmTrsSnvJzIBDN7tYKhQe
         BRNbelOsdg12RvGH21HHvNjurFBPOQNY/qyI+9YNfiFNMyMZh5Ta/bPfiOnDrvlmqORk
         NccQ==
X-Gm-Message-State: APjAAAUs2MwGexVCX3y5x/TXye4e+o+mdH6wNht+8Obq4c8aZGcqk/Pa
	TeRd3LIRJbhk8qQcbScW6PW4SoU+ZXURek1Oit7wkhPMXhhE5+cy1r6PS1AyCsNNrup3e1WDvn3
	gStiiLlC/259VB+5EduNoUVoxZbBEEyRE4KYTliruxCg7MZFaHbxyJ0xo4zEDqTA=
X-Received: by 2002:a50:9168:: with SMTP id f37mr74352419eda.242.1563999505367;
        Wed, 24 Jul 2019 13:18:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPZxbOzx2IJM+zidurlWxR3yqPtP2nP5QaYEj2obPXHrVjqb14qoD2CKNR5Mw9XJ4kl/uY
X-Received: by 2002:a50:9168:: with SMTP id f37mr74352357eda.242.1563999504711;
        Wed, 24 Jul 2019 13:18:24 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1563999504; cv=pass;
        d=google.com; s=arc-20160816;
        b=0WgpkdaqxcKp75/LTeyJX2J2gHgHU0aFHcPIANmacvMCgxL0IJOWOq+AF+joiF+PDI
         wFvZZctqbW2Pg0eRyQl6S/KzE3fsDwFOPoP3n1MJgQG/kFhx7NDxYlKPI83G5I2cev5J
         lCJYXqVA3Y1riGiShooO3bQwicibiPPvgY7BLFgsLuFRbl8h46HHSER7LTLLgBQzyGAl
         esA0csD+naBKjUGK0a2K6rqM6LzDkD5Ly/Qj0PtJC85P1PwPe3BoptE+aVHIkiU8eR70
         2j4fGRtosOqxjcrGjref9+GOfEbDkZ3klcaIOlabO/pQaYwjJLnNT6eDKKul28aTfxZ6
         ZS0Q==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=0O8bf3MkktXRPasPPM0aZ8FRhXf2oYT66ZTm5ExM6I0=;
        b=jMwGNEMj8RWmrfAbuR+nKc9egbeZlEduR5hbhYzUjYMB1AwNcDdLFAQyYWAmsAV1LE
         VZ/pg0M68KVcWdCA3185/tyMui/nY234y3YSencRt1aXBMIGd7ZMxd9JnjGXCCiXvkBd
         IGfqZLx/3yj1Bv7+79mVoJIP1LKWuUhm6vuniNb3jj3Fex+uPmapphTkPXAE3y08OApi
         +uz+2/vNnrIrMXRDyYeMxnVb+f7BBLEvQrtsTL7tcT0Q78H2RxmZmAwScv2qjNXeUsbl
         9x6K3Q8+Xhi7LXj4MFgZp4q4s83qAq9OWPn2ZY+kg5YLsMJmtzaUBo35WITsfD1qdEjV
         07Lw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@wavecomp.com header.s=selector1 header.b=rw9cYvw8;
       arc=pass (i=1 spf=pass spfdomain=wavecomp.com dkim=pass dkdomain=mips.com dmarc=pass fromdomain=mips.com);
       spf=pass (google.com: domain of pburton@wavecomp.com designates 40.107.82.111 as permitted sender) smtp.mailfrom=pburton@wavecomp.com
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-eopbgr820111.outbound.protection.outlook.com. [40.107.82.111])
        by mx.google.com with ESMTPS id f23si10021492edf.439.2019.07.24.13.18.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 13:18:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of pburton@wavecomp.com designates 40.107.82.111 as permitted sender) client-ip=40.107.82.111;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wavecomp.com header.s=selector1 header.b=rw9cYvw8;
       arc=pass (i=1 spf=pass spfdomain=wavecomp.com dkim=pass dkdomain=mips.com dmarc=pass fromdomain=mips.com);
       spf=pass (google.com: domain of pburton@wavecomp.com designates 40.107.82.111 as permitted sender) smtp.mailfrom=pburton@wavecomp.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=dEcxRKaSO2AoIYxNQlEQnkYJF2+19aVRVaTXx8Qw3axYRl/nLGeZfzFMjj1ZYJBmKKaWddySOzvyiciZ/6hJK4xKjxL0dZVinXzwh14S0G1RWOwE4RjVBfpnyl7luLPgd0tYIDXgik518b6P/yG//lB8JPFTMuZsLjFr/uRSobpQL/xyWrti1LDLtZahRvcbXUm8hDvg48/FVdsowPpi77B8GyqOxiolZJupjMAo1i2AaC5dcTTuH8NDbYNHQw+46k+LrdhM4oNZznypB0KV3fOijfVMMH5fO2ZELTUsLPk6N1lwsj5zr7xRCvLx/tRrmL6cQvosIRMOWGuQhFLSjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=0O8bf3MkktXRPasPPM0aZ8FRhXf2oYT66ZTm5ExM6I0=;
 b=GjhLEl/3aCpE5yBEUbXtH7RFh0N9vPDeyFB+jonv13OOm4aWyqfkCo1pN1W3C6mjbmpPhJ+i/bR6jawkwlTKLSUpYHZ3prIaAap+t4x/tu+UjMcG8KmwX8eeZJvIeLP2nLc4DmcqLZdwAF0RPMUwaoGSCMK6aOJIMa0L3t6Qm7Vc/xR/9akg/PsTeGxNQDj4qUbr8IfEtKw6qEJcbL77erp/nvlgvklh+KMXKF8GD7MfGSE/oPuKlWTBq92AqpSHpXXkVbGg6ImH/zuJ08zTtjz3WWBB4f6b0biPbpFqm1Drzbby17IeZsahVMhLS75esyNZu+e9MXgeCNFhjDUY7Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=wavecomp.com;dmarc=pass action=none
 header.from=mips.com;dkim=pass header.d=mips.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=wavecomp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=0O8bf3MkktXRPasPPM0aZ8FRhXf2oYT66ZTm5ExM6I0=;
 b=rw9cYvw81npIghzHa7jJTgc1qKS8CzgD6T/igdouSV7aKAtnCQJLFdVX/2PpIJOQdRopyH3dpan9mgJOq0s8DcBq3tDVKzZFLg2PkOmiC7UIUPAl27C/gDUf/lQ/qbYDUchMN505PEuBt6ls8gbnJffVAYz3kD3VYMJDx5h89vk=
Received: from MWHPR2201MB1277.namprd22.prod.outlook.com (10.172.60.12) by
 MWHPR2201MB1136.namprd22.prod.outlook.com (10.174.171.38) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2094.16; Wed, 24 Jul 2019 20:18:21 +0000
Received: from MWHPR2201MB1277.namprd22.prod.outlook.com
 ([fe80::49d3:37f8:217:c83]) by MWHPR2201MB1277.namprd22.prod.outlook.com
 ([fe80::49d3:37f8:217:c83%6]) with mapi id 15.20.2094.017; Wed, 24 Jul 2019
 20:18:21 +0000
From: Paul Burton <paul.burton@mips.com>
To: Alexandre Ghiti <alex@ghiti.fr>
CC: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>, Catalin Marinas
	<catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle
	<ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Palmer Dabbelt
	<palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Alexander Viro
	<viro@zeniv.linux.org.uk>, Luis Chamberlain <mcgrof@kernel.org>, Kees Cook
	<keescook@chromium.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-mips@vger.kernel.org"
	<linux-mips@vger.kernel.org>, "linux-riscv@lists.infradead.org"
	<linux-riscv@lists.infradead.org>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [EXTERNAL][PATCH REBASE v4 00/14] Provide generic top-down mmap
 layout functions
Thread-Topic: [EXTERNAL][PATCH REBASE v4 00/14] Provide generic top-down mmap
 layout functions
Thread-Index: AQHVQeTmQ3VcX06rl0WqkHC9YJERUabaNhSA
Date: Wed, 24 Jul 2019 20:18:20 +0000
Message-ID: <20190724201819.6bhvyugquhfrldfa@pburton-laptop>
References: <20190724055850.6232-1-alex@ghiti.fr>
In-Reply-To: <20190724055850.6232-1-alex@ghiti.fr>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR03CA0001.namprd03.prod.outlook.com
 (2603:10b6:a02:a8::14) To MWHPR2201MB1277.namprd22.prod.outlook.com
 (2603:10b6:301:18::12)
user-agent: NeoMutt/20180716
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pburton@wavecomp.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [12.94.197.246]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: cf1a8fed-1258-4da6-cc22-08d710741252
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR2201MB1136;
x-ms-traffictypediagnostic: MWHPR2201MB1136:
x-microsoft-antispam-prvs:
 <MWHPR2201MB1136D73898811083245B6C6CC1C60@MWHPR2201MB1136.namprd22.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 0108A997B2
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(7916004)(366004)(199004)(189003)(33716001)(6246003)(76176011)(498600001)(256004)(52116002)(66066001)(66946007)(5660300002)(64756008)(66476007)(66556008)(3846002)(66446008)(8676002)(1076003)(4744005)(6116002)(68736007)(4326008)(386003)(6506007)(6916009)(71190400001)(71200400001)(305945005)(102836004)(26005)(6436002)(81156014)(7736002)(2906002)(9686003)(6512007)(229853002)(7416002)(42882007)(58126008)(54906003)(8936002)(53936002)(99286004)(446003)(11346002)(14454004)(44832011)(25786009)(6486002)(186003)(476003)(486006)(81166006)(41533002);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR2201MB1136;H:MWHPR2201MB1277.namprd22.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: wavecomp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 WBLpAxl0Uei/df2NBs1wSm/pUK/0/nZcFDTE1JL7co+n5YffPuoFkkubkl2DnVpFgsg/ShI7v/j6PI9el+OoSH8IU2+aUbrLiI01ePp1Fs53VLA9mtAmRRnZp8+vW42I5fKA1+Ac4MpqTLk6mmK9Jd13L1B872iZfJJW9mQXvPI5y04CDfIUnuvE9/v0W3wCHzAOltlSpJz8W5kShY5DuIFTr4FUed7TIDpYIkdTvdn3S3/wOi3lpaeO6iok/SUjHQNbYc9UG0fA0qngBZ40kdwQlkJHU84J7Dn18x9xrG9/OFSLu8YGXF68xqleN7IbrKMBUD4/6098KibtOs92PqSWKhSVzMJ5H3yXfDTPAgCb0NlEhASAuZMyMmFxm3cz2OVVn3LhXIa/pNmaiSDsVCwK3zx1cFnTDUNs0Q7hteM=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <FB1BB9830032BE468CCBFB9649F40069@namprd22.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: mips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: cf1a8fed-1258-4da6-cc22-08d710741252
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Jul 2019 20:18:20.8213
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 463607d3-1db3-40a0-8a29-970c56230104
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: pburton@wavecomp.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR2201MB1136
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Alexandre,

On Wed, Jul 24, 2019 at 01:58:36AM -0400, Alexandre Ghiti wrote:
> Hi Andrew,
>=20
> This is simply a rebase on top of next-20190719, where I added various
> Acked/Reviewed-by from Kees and Catalin and a note on commit 08/14 sugges=
ted
> by Kees regarding the removal of STACK_RND_MASK that is safe doing.
>=20
> I would have appreciated a feedback from a mips maintainer but failed to =
get
> it: can you consider this series for inclusion anyway ? Mips parts have b=
een
> reviewed-by Kees.

Whilst skimming email on vacation I hadn't spotted how extensive the
changes in v4 were after acking v3... In any case, for patches 11-13:

    Acked-by: Paul Burton <paul.burton@mips.com>

Thanks,
    Paul

