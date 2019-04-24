Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95A29C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:29:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4621E218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:29:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=wavesemi.onmicrosoft.com header.i=@wavesemi.onmicrosoft.com header.b="Cq40i783"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4621E218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFA026B0005; Wed, 24 Apr 2019 15:29:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E81AE6B0006; Wed, 24 Apr 2019 15:29:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFC066B0007; Wed, 24 Apr 2019 15:29:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE096B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 15:29:32 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id w139so8028529oiw.21
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:29:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=t7/AyjO6O3F7APnFi/cYPCcMaTbpsBRvdsn1jqxi8zs=;
        b=NAVkZ2as7XkUu5tbiiGlygeuMBvpEcH+o3eAD/67YCJV13SCChjF/RL9dJNF9MWuoY
         zHDPZTcwg1mwALouCHrRcGDJKHDmsFVJY1spfoFKMQe7kgS0iZ8qgd5DMcUmjkoMpmxu
         gCjmgzCKyI2l6FRKXHW0GrhYC7Qq6RuOCklbZes5jVwQhSawnlYtWt1JnH6CHDB+pzrK
         a1VKW+YuMJ7VALei/bySvoO0Qx0gtbr5ST8xZwRNCLwwgQZnnJfHodkb4deeRjp4KF/i
         dplADy6InXzbzUTyGibd1sE8x7+1ebVydXykvDgGkGeuRnHLlBIrRSMHkMQEicf3XdQp
         wwqg==
X-Gm-Message-State: APjAAAUaQnl/kzZJ4+i8dAfQZlsIkhFAJ4rbOHRYHGJTdDojbpVih8SR
	cfSUlgH4mgYHQwsYl+X7PF2kFTKPrSH8zMWwiybtt1iWx2XGzA6ySc6Gi12ifz8D3ow1bYbDWOC
	2XDhmOjkUfZ8rSUzyCmd9FJH41XOkfVRKoYiB+wG+eQN8wTL7gRK4Fje4WA+zLmc=
X-Received: by 2002:a9d:6d0f:: with SMTP id o15mr21439109otp.253.1556134172230;
        Wed, 24 Apr 2019 12:29:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSGN1rNqwPyuvQ08tZpiuvZI/Fp2FPbBVUWOAJdTchrivopkvBuKx1RqievWtAyLhYbkm3
X-Received: by 2002:a9d:6d0f:: with SMTP id o15mr21439071otp.253.1556134171497;
        Wed, 24 Apr 2019 12:29:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556134171; cv=none;
        d=google.com; s=arc-20160816;
        b=XYjbNPdZtYyA1lF4W+mirasJtA4WZwMokEpB1l1diINwv7S5Iag97fYUiIjt/ZlpBi
         rW6g242dum8WQ0Sf4v2VDhydAgBsHWd+ETbht4Z/hwUlimlT/KVat1hGQo+vBu9W5DHw
         Zs0YqlaJDDK/a6BZ2KBwMeBtgcDiryrokIeAIfNz2ARiJsK/2f3x1fn9Kye0+V91RfT/
         azw6tSHBnDvnxyDnS27P4AiM3RSH1jO8d/YcAywtN2WgopR7Xf+g/AHjAcwssOHlVU4z
         qba48CwgT16cPOStDE7q1qlrezo7Qnwxa5fNIbFh1QgEboc+HRv7+inhBlozcEyqm/OW
         9Acg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=t7/AyjO6O3F7APnFi/cYPCcMaTbpsBRvdsn1jqxi8zs=;
        b=V6avJ4ayZXZZx41NaqkCE4xuKsjF6U1D8nIP2eQ+mfo4zSdtApC26aLu8ylQRBZ6fK
         nBiycdLyvSvFD9F5O7zV8TQyxvz5q8bTlK+J0B53Hd80n7aI6m1H/eV9pDDoUiOdZSGI
         /+6i64vUVQ/cwq0rhkWbboPjScZEYDygvOgsZxkPvcYFryzh5Pq39juOD/p7zmIY+Asb
         X7+yJIWVLEP6NS+eSKlm0yqxfewufqXaCm6Rn+eECVvdKtlgTHFKSuybbCIWoAVfUaw+
         zJ0uoewg3rn+LO7gEpmET+sloWOm1ep7N6aY949uwJQnBS5rxcZw3hqEsV4gtE8n+E0Z
         XU+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wavesemi.onmicrosoft.com header.s=selector1-wavecomp-com header.b=Cq40i783;
       spf=pass (google.com: domain of pburton@wavecomp.com designates 40.107.78.117 as permitted sender) smtp.mailfrom=pburton@wavecomp.com
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-eopbgr780117.outbound.protection.outlook.com. [40.107.78.117])
        by mx.google.com with ESMTPS id o128si2522146oib.58.2019.04.24.12.29.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 12:29:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of pburton@wavecomp.com designates 40.107.78.117 as permitted sender) client-ip=40.107.78.117;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wavesemi.onmicrosoft.com header.s=selector1-wavecomp-com header.b=Cq40i783;
       spf=pass (google.com: domain of pburton@wavecomp.com designates 40.107.78.117 as permitted sender) smtp.mailfrom=pburton@wavecomp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=wavesemi.onmicrosoft.com; s=selector1-wavecomp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=t7/AyjO6O3F7APnFi/cYPCcMaTbpsBRvdsn1jqxi8zs=;
 b=Cq40i783VkDIdQw51Eo0ZPu5hvCX93sVUEQLARoTEui7BZDxE5ImkQLF5yTSmp0Pm9g3XrjvoMBfgPkeOLvj/FhUmnfmqmHw61+3T7qhZJA5wh+h0Ll1P49YRTQW9VUU2opNNrD7pjX/LUN30yso9oGEONZ+xKeFKUofB1VIxTc=
Received: from MWHPR2201MB1277.namprd22.prod.outlook.com (10.174.162.17) by
 MWHPR2201MB1182.namprd22.prod.outlook.com (10.174.169.158) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1835.13; Wed, 24 Apr 2019 19:29:29 +0000
Received: from MWHPR2201MB1277.namprd22.prod.outlook.com
 ([fe80::b9d6:bf19:ec58:2765]) by MWHPR2201MB1277.namprd22.prod.outlook.com
 ([fe80::b9d6:bf19:ec58:2765%7]) with mapi id 15.20.1813.017; Wed, 24 Apr 2019
 19:29:29 +0000
From: Paul Burton <paul.burton@mips.com>
To: Aaro Koskinen <aaro.koskinen@iki.fi>
CC: "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: MIPS/CI20: BUG: Bad page state
Thread-Topic: MIPS/CI20: BUG: Bad page state
Thread-Index: AQHU+spp/ojd69QglkGCzSQtjt0+I6ZLsnQA
Date: Wed, 24 Apr 2019 19:29:29 +0000
Message-ID: <20190424192922.ilnn3oxc7ryzhd3l@pburton-laptop>
References: <20190424182012.GA21072@darkstar.musicnaut.iki.fi>
In-Reply-To: <20190424182012.GA21072@darkstar.musicnaut.iki.fi>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR05CA0075.namprd05.prod.outlook.com
 (2603:10b6:a03:e0::16) To MWHPR2201MB1277.namprd22.prod.outlook.com
 (2603:10b6:301:24::17)
user-agent: NeoMutt/20180716
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pburton@wavecomp.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [67.207.99.198]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 84d0241e-5eed-4977-601f-08d6c8eb2b3f
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:MWHPR2201MB1182;
x-ms-traffictypediagnostic: MWHPR2201MB1182:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <MWHPR2201MB118248C8CA8C7A2492EDCB45C13C0@MWHPR2201MB1182.namprd22.prod.outlook.com>
x-forefront-prvs: 00179089FD
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(7916004)(396003)(39850400004)(366004)(136003)(376002)(346002)(189003)(199004)(54094003)(102836004)(76176011)(386003)(6506007)(11346002)(26005)(186003)(25786009)(476003)(33716001)(6486002)(52116002)(6916009)(6436002)(68736007)(99286004)(446003)(66066001)(42882007)(7736002)(305945005)(54906003)(1076003)(58126008)(66556008)(316002)(73956011)(66476007)(5660300002)(64756008)(66446008)(66946007)(53936002)(4326008)(256004)(8936002)(6246003)(44832011)(71200400001)(71190400001)(81156014)(486006)(966005)(478600001)(14454004)(229853002)(97736004)(2906002)(3846002)(6306002)(6512007)(9686003)(81166006)(8676002)(6116002);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR2201MB1182;H:MWHPR2201MB1277.namprd22.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: wavecomp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 l161aSF98xcBLcjyJrUF7FMAbjLVTCFVwIqO2pIR7x/kW1qydwnC2h8t948AJVbW5ZojlrY1GXltF6R6Cpudc5lsr01buZkexxifhmI1wMdvACHRvbLSh4BDk86bG+sE5vG00/i0zYFASLfVhKkze3OrjQwcofUA3WCx6t1MEPS00/PYg3agkv/Mz59zt5X7Ne1u0xJn4QGknSfdB87xzXwfgiKv7Vm+kR9/56NRYkKuYdvyk68iqfsRPEB4C7FiMhy4ZxxQMJjnkymUqQAhcn57QB/zTtG1CIIMTt5LEe4GpGQFMAPv1/JmCudTvmnEqamwDs+CNkDahPpJhw1HU5BmFt3PQ33YAXol/jcp6kgdz2PJzyW2vgeiceOu7O15uIpkOXNugZNY4Bi3Jf/+/et6D8fseuH9fzdHYw6DUV8=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <53CC108A17D0F64E8F5147A3DDE5D833@namprd22.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: mips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 84d0241e-5eed-4977-601f-08d6c8eb2b3f
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Apr 2019 19:29:29.1420
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 463607d3-1db3-40a0-8a29-970c56230104
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR2201MB1182
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Aaro,

On Wed, Apr 24, 2019 at 09:20:12PM +0300, Aaro Koskinen wrote:
> I have been trying to get GCC bootstrap to pass on CI20 board, but it
> seems to always crash. Today, I finally got around connecting the serial
> console to see why, and it logged the below BUG.
>=20
> I wonder if this is an actual bug, or is the hardware faulty?
>=20
> FWIW, this is 32-bit board with 1 GB RAM. The rootfs is on MMC, as well
> as 2 GB + 2 GB swap files.
>=20
> Kernel config is at the end of the mail.

I'd bet on memory corruption, though not necessarily faulty hardware.

Unfortunately memory corruption on Ci20 boards isn't uncommon... Someone
did make some tweaks to memory timings configured in the DDR controller
which improved things for them a while ago:

  https://github.com/MIPS/CI20_u-boot/pull/18

Would you be up for testing with those tweaks? I'd be happy to help with
updating U-Boot if needed.

Do you know which board revision you have? (Is it square or a funny
shape, green or purple, and does it have a revision number printed on
the silkscreen?)

Thanks,
    Paul

