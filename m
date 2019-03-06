Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C6D2C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 17:13:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7D9F206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 17:13:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=wavesemi.onmicrosoft.com header.i=@wavesemi.onmicrosoft.com header.b="SCNXtahL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7D9F206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 178608E0003; Wed,  6 Mar 2019 12:13:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 127878E0002; Wed,  6 Mar 2019 12:13:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F097C8E0003; Wed,  6 Mar 2019 12:13:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 98A748E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 12:13:04 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id j5so6666064edt.17
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 09:13:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=fcrIwh5FAS/p9ZnN5P/05g+4grW/DAzlhzsDUfqXcHs=;
        b=SAHIk3+9TBztXVQ5857aB+E6gW1ylhvjZlIjVRw/nG09/Xs5ugvE3xp1Rb39ED5Cov
         56kYxlEoDtrZ1tJAbGWgZ5ICFqCqZaufDGWob86AS6VAFYWLZkBrxvo9ZShM2Wv8x5bR
         BxC9xrCxGogSgEg8x5y5PYRY4OAPXfEDVdHdpmgkInQJcFsNJGGykkFdFp897K9RwiiK
         lI22+zWhElmCTlQyZFAm94YqUaAzveyi4pLkhmRQcSRS/og5jPhd+9IfmfgbXSL+UiKs
         FgkCMRVkzhhPHLhbncnhyt3IcivG//X6EQBIf2WmkYfTZNjGgb4g7fuy0YNIBTl+mibH
         UtCw==
X-Gm-Message-State: APjAAAWkG0I+JYT9lGRFRBhOwK2lYilZrCkt0Ja4uX3kOQa27ggD9EFh
	ev3CkeXAbKundsB0ieV8lmBi0I+8B/eO4bZe9AY0dJ5OCkXI3Ho5s3oqbGv7hikOefG012F027c
	eetes832PGSuRhsSpCJF60O0bI/vQWg3tQLm+9fL2IioNGXcjwotr9hUrOfnCx6o=
X-Received: by 2002:a17:906:3450:: with SMTP id d16mr4596617ejb.51.1551892384197;
        Wed, 06 Mar 2019 09:13:04 -0800 (PST)
X-Google-Smtp-Source: APXvYqynu7y5g55dqFi/DtNhlGxrRgF7yO1xUTb0KlfyRUJCRBBZrCZrAtq7JFs4ofuzkMIbMmwG
X-Received: by 2002:a17:906:3450:: with SMTP id d16mr4596559ejb.51.1551892383163;
        Wed, 06 Mar 2019 09:13:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551892383; cv=none;
        d=google.com; s=arc-20160816;
        b=jKQQKh9xr/yqoKo/UTyDs2wJ/XLvhz+0ey+wdhhPXchNNRUCgYgHy0EvJrlKKnYjft
         yE+amjw63IHxXJmQjNdlIFK+cRNZaCIqKeqNOSeUrlcTjWlpY0xN1JZlpJom7ZzoV1M+
         VA+eTbDH62bQ9powoUWQ5p4r/ypKCCSzYvXiHKR4wuYF7mxf+upmrl910mqTAalm5xeC
         o1CBUvBe0C6h6onU4Hc1RXjtwZYq61MiovvLdBKuyAWIqop7bmJhQdMUhvDng1B8o6zf
         gP8tktwz9GBlRpoGXrySu7OXhHOMIWHr3YcN6VdSjVZAkWppNqvzR+4yLfEEEbieMaBM
         SJ1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=fcrIwh5FAS/p9ZnN5P/05g+4grW/DAzlhzsDUfqXcHs=;
        b=O0dze5OLtSLaR6NWVWXTMluVnWUU9/nRgo+KeUt3U4WDOO4D7yBifHWCb0Kh5IP8/2
         wRBSSbWK9FiqfUgmnGiRMex35i5aqcmMsu7vS+7yzDMFr9hG0jeq+LrQ+rZ1MAUbVCxL
         LjrU798uVg715wwFXiNnhzKWQBAVu5BnnIv8WJ14DYS1F618vpYMw46MQtouUWY69aJ5
         HuL4OhQgV7tOz3pa6fubINAtqYmBvmK0SxMSj5zM8jdU3zGXFSAVYgEhyHPT+O+gx3Si
         jYBaNLmrnjNifiNK8ffygXVhDO61m4bcJQplZZ1hDn2OgnRkaRvIxxjqofiA7sWOqVfQ
         V0xQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wavesemi.onmicrosoft.com header.s=selector1-wavecomp-com header.b=SCNXtahL;
       spf=pass (google.com: domain of pburton@wavecomp.com designates 40.107.77.95 as permitted sender) smtp.mailfrom=pburton@wavecomp.com
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-eopbgr770095.outbound.protection.outlook.com. [40.107.77.95])
        by mx.google.com with ESMTPS id v21si866799edm.85.2019.03.06.09.13.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Mar 2019 09:13:03 -0800 (PST)
Received-SPF: pass (google.com: domain of pburton@wavecomp.com designates 40.107.77.95 as permitted sender) client-ip=40.107.77.95;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wavesemi.onmicrosoft.com header.s=selector1-wavecomp-com header.b=SCNXtahL;
       spf=pass (google.com: domain of pburton@wavecomp.com designates 40.107.77.95 as permitted sender) smtp.mailfrom=pburton@wavecomp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=wavesemi.onmicrosoft.com; s=selector1-wavecomp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=fcrIwh5FAS/p9ZnN5P/05g+4grW/DAzlhzsDUfqXcHs=;
 b=SCNXtahLLKEaqGDYdpx0420+UtlkuOktGW+vyeSD+fqyhg4Sv4ERsXLNSQU++8mQ0ZTPe5DKX6VXnFj8tvewBVoUzvGUNBKxGe+ey8fA/ddcq8s9QWSv+/fXWpmVakVthkpxSYVfSSys9sePXXVe3tgTcE+swKqs3wzkvPNQynI=
Received: from MWHPR2201MB1277.namprd22.prod.outlook.com (10.174.162.17) by
 MWHPR2201MB1261.namprd22.prod.outlook.com (10.174.162.13) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1686.18; Wed, 6 Mar 2019 17:12:59 +0000
Received: from MWHPR2201MB1277.namprd22.prod.outlook.com
 ([fe80::b8d4:8f0d:d6d1:4018]) by MWHPR2201MB1277.namprd22.prod.outlook.com
 ([fe80::b8d4:8f0d:d6d1:4018%3]) with mapi id 15.20.1665.020; Wed, 6 Mar 2019
 17:12:59 +0000
From: Paul Burton <paul.burton@mips.com>
To: Steven Price <steven.price@arm.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski
	<luto@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann
	<arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Catalin Marinas
	<catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo
 Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Peter Zijlstra
	<peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon
	<will.deacon@arm.com>, "x86@kernel.org" <x86@kernel.org>, "H. Peter Anvin"
	<hpa@zytor.com>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Mark Rutland <Mark.Rutland@arm.com>, "Liang,
 Kan" <kan.liang@linux.intel.com>, Ralf Baechle <ralf@linux-mips.org>, James
 Hogan <jhogan@kernel.org>, "linux-mips@vger.kernel.org"
	<linux-mips@vger.kernel.org>
Subject: Re: [PATCH v4 03/19] mips: mm: Add p?d_large() definitions
Thread-Topic: [PATCH v4 03/19] mips: mm: Add p?d_large() definitions
Thread-Index: AQHU1DRlehjTtbAKgEapDADsPcSi/KX+10aA
Date: Wed, 6 Mar 2019 17:12:58 +0000
Message-ID: <20190306171257.5eii6aqpfp6kvszb@pburton-laptop>
References: <20190306155031.4291-1-steven.price@arm.com>
 <20190306155031.4291-4-steven.price@arm.com>
In-Reply-To: <20190306155031.4291-4-steven.price@arm.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR07CA0086.namprd07.prod.outlook.com
 (2603:10b6:a03:12b::27) To MWHPR2201MB1277.namprd22.prod.outlook.com
 (2603:10b6:301:24::17)
user-agent: NeoMutt/20180716
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pburton@wavecomp.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [67.207.99.198]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 49a42e8a-b36c-444c-b2f5-08d6a256fb2e
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:MWHPR2201MB1261;
x-ms-traffictypediagnostic: MWHPR2201MB1261:
x-microsoft-exchange-diagnostics:
 =?iso-8859-1?Q?1;MWHPR2201MB1261;23:c5ZQguQj1PJYjxSVVFvqQhrLxF/zVtPpatgzX?=
 =?iso-8859-1?Q?iIDGxc0/UiApQJGQUTc7jij7C9Z73HTCl5RMQtMGNZVkcuN4APzpNC8s8e?=
 =?iso-8859-1?Q?9xHcGwQT0jvaB7nNJeECofMPPTTfoc2hS2Jl4zVgmgNL4fKZSwOH5mRGv3?=
 =?iso-8859-1?Q?yK0iKW/Cz8pBcw3j7FMHM1hmjz3n2urVNR5eui23Ai0DvALsrknfhHhsYD?=
 =?iso-8859-1?Q?s0UMgI88Cy/ks3cMfqVumlpk1q/X+vYFhXX6l+eRSGzMQ6BcabY7/Vubp6?=
 =?iso-8859-1?Q?tKU9ik7E0VlxuMUIN4v653DZ7fULwl8wQVwRz1NdGncCpAb0tKTy1cIQdg?=
 =?iso-8859-1?Q?eB6oPAYf7k+BbVuAft3vftWTNFNMV11t7cgsVrP/FZ+lMirRLsz0QIo2TR?=
 =?iso-8859-1?Q?ikiiydMmz5bq7dJZbycmOWkMUNsSkqMwaCEVbzUnBo8CzQZgBtaNLg4CN3?=
 =?iso-8859-1?Q?Zr2g4dySwdo58fj4WyTTwOi+HV1pN01umSYG1B9BtrA5piyaXdJ8Mb/24k?=
 =?iso-8859-1?Q?vkqu0p5EtGBNSNfWMpsIy+EU9VpYMe3RxVFubLiClsKvogvkkLHubPCFGX?=
 =?iso-8859-1?Q?C9+4GUe/CAgcC4Rsk5IyRK3kMOyCl1CAKycgzHvGwRiIM3YqxM78rKasD2?=
 =?iso-8859-1?Q?x9dQ9CR3Wtw123reCicsTMbTaHN+cubgnHo1qQEnocPE4i/83B1NKhF5/e?=
 =?iso-8859-1?Q?deBW006a9LJL/RhIyNtlJ6Lw/Q5OizIO0Ak0ms2/lSQWHiwiEEk/jDm5qc?=
 =?iso-8859-1?Q?hCzUYUnNadp5y4qSGEbWzav4IUKpmo0CNavIgeX6GsNfuoOaTIQSzciRhE?=
 =?iso-8859-1?Q?mc/AMLFVta10ApCGpxY/In9HiXuGsRxwlMy4GqCog643UwfOYPUTrfteTl?=
 =?iso-8859-1?Q?zTuoBCN+xq3JJdIatfs4UvtbS8BaGDrFO+BKJPs0TY/E9r3Wj1a2Dm5fFe?=
 =?iso-8859-1?Q?7+KsaR8vl95v547kQD8PavrQ3Uo38RPIYpj/lhKQfykViJwcKbmRMKG1Qn?=
 =?iso-8859-1?Q?bNaTL78h7Yh7pfF3cSVDRR3UuPtmOgWqZ8v7Ys5lxfH4cpghxgS6bxn4CQ?=
 =?iso-8859-1?Q?AvveO/C/YIMd8c2x1Fbv7PpNMtQshXKIagMUQ4Ieb3fChA2lU/AwkTpCrk?=
 =?iso-8859-1?Q?1Ljdu68A5CmyCnIBw1OJIypcmEETWYAtsCNI6W/XpYYu7J5YmCzCO9HnAj?=
 =?iso-8859-1?Q?BTPsOD4pJIGnlOpEMKomdcl1Wbh9GlCclBhA/IAAeKiHv9G6knsKJ9qDHY?=
 =?iso-8859-1?Q?phrhQB+A48WiKm2KZL23iBJEEq3xditrd07mVgvTX7uVfSOHyVMij4oeud?=
 =?iso-8859-1?Q?3tJTLG962b33K5194a7X3rclYpALRo3ua9GhmbrT5kav0aL4tPnE+TJmT6?=
 =?iso-8859-1?Q?/lpn+hnOBw=3D?=
x-microsoft-antispam-prvs:
 <MWHPR2201MB126180195E437DD9F7F5A281C1730@MWHPR2201MB1261.namprd22.prod.outlook.com>
x-forefront-prvs: 0968D37274
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(7916004)(136003)(376002)(366004)(346002)(39840400004)(396003)(189003)(199004)(25786009)(7736002)(6436002)(53936002)(106356001)(256004)(478600001)(305945005)(6916009)(3846002)(4326008)(6116002)(97736004)(316002)(58126008)(6246003)(4744005)(6512007)(9686003)(54906003)(1076003)(5660300002)(6486002)(71190400001)(71200400001)(6506007)(386003)(33716001)(102836004)(8676002)(81156014)(81166006)(229853002)(99286004)(8936002)(7416002)(68736007)(476003)(11346002)(42882007)(44832011)(486006)(2906002)(446003)(105586002)(26005)(66066001)(52116002)(76176011)(14454004)(186003);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR2201MB1261;H:MWHPR2201MB1277.namprd22.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: wavecomp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 8jt+BVppR0Vb816sAwTQVXEmfvJS8UX31/SIqi1LS8KwFNkItVuCccfF40InI0eRNBWGPv4swBJNshjxVoEHQDtGOhX4G0gYAROsy2nSssGrX0I/H4rvl+k04FCexW7PH+XVAZrTrYx5zp2SU2tW8MV3OqmBi9JGJDspSzC9k07uBg29cRCsH4iIECei9wRmxnl5D8gNdgcTJ8RFoI6YlHn1HQnsyfrHOZ4fUVQVt54hpD5JinFs3+D1Qmcd7f/uof7VU4fuYb0huPdKZFA8mZ/7KoxDYqqHRZ0bkvNvoupdOh51suwpeuVB7f+WzU3BbSMHuvhpHQM+QH4U7M0nZF5zXeDISYdiEnaKx410DahMzD+I4P3X/lE4krQssIstG19tQuYolI0vTraKLrnkQb6JJ9BeQ94tBl0AcetVoAs=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <166FB649BE7A0943BDD8181B357816BB@namprd22.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: mips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 49a42e8a-b36c-444c-b2f5-08d6a256fb2e
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Mar 2019 17:12:58.7825
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 463607d3-1db3-40a0-8a29-970c56230104
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR2201MB1261
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Steven,

On Wed, Mar 06, 2019 at 03:50:15PM +0000, Steven Price wrote:
> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information is provided by the
> p?d_large() functions/macros.
>=20
> For mips, we only support large pages on 64 bit.
>=20
> For 64 bit if _PAGE_HUGE is defined we can simply look for it. When not
> defined we can be confident that there are no large pages in existence
> and fall back on the generic implementation (added in a later patch)
> which returns 0.
>=20
> CC: Ralf Baechle <ralf@linux-mips.org>
> CC: Paul Burton <paul.burton@mips.com>
> CC: James Hogan <jhogan@kernel.org>
> CC: linux-mips@vger.kernel.org
> Signed-off-by: Steven Price <steven.price@arm.com>

Acked-by: Paul Burton <paul.burton@mips.com>

Thanks,
    Paul

