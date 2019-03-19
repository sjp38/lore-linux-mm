Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3EEAC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 11:45:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7496220857
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 11:45:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="PndsmpbG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7496220857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1D606B0005; Tue, 19 Mar 2019 07:45:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA57D6B0006; Tue, 19 Mar 2019 07:45:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1FC16B0007; Tue, 19 Mar 2019 07:45:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 80D2E6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 07:45:07 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 14so15808pgf.22
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 04:45:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=aJGKjeDfkxq63qK6+Utz9cs+S1CRCPma+t2/scCTmUM=;
        b=lv9/Zf1nnfydy0Mst8Rs/M/IpslLKqyd3E+W/ILYoi8zHmfzzCRzgF+DBqlAc8LhuC
         TkVE3mVsfqWVVZ6TXGeRqvRCm6S/1OKsJubCV4e4kZ4bDSFKHhRoWu33J3nkRgv/+mq5
         eysQ4aKGkBNImHLXq1p9YAYw8oZyEnzjd8Q1YwTZu00cJmvU/NZMWKlnGRW5dH4pmCKJ
         Qpwewr50pkRH5Y7kxxev4BR8t8FWW2fCu4y4x5mPNtCDt1jDmy9vyRAyaNv7Tqy6Zs4g
         TJnp6MPAF7FVnTs8yDX6u7FHowMAz8MAUlavhbW+ZCOXrpPeHy7akRzsj2wiZs0DMooz
         6xpw==
X-Gm-Message-State: APjAAAUXEhYe1PPo2MG+O9pvxxxxg6t0zRb2PVLd1l4FnOwCm27qSS6y
	tZZuMHusFvNNmRM0UeCtXIRf8LKKmYDrt54X+4KEuZlC1pOJ1l4ZqAhsPXB4quyOqIrMfLxQonq
	0ewtdGh7s9RuGjcK3lv0b37Sd3SKMmC/8iHWAF0zmjb56EaiaVFtzpB2MC4TtUwafdA==
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr1608617plk.126.1552995907093;
        Tue, 19 Mar 2019 04:45:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0gXt2iDx0dkfW6E4uyY0M1hZw0TXX/HBqXZJIL7rVCpX+ZujszgVqZSL1tNEHm6mFbT91
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr1608559plk.126.1552995906026;
        Tue, 19 Mar 2019 04:45:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552995906; cv=none;
        d=google.com; s=arc-20160816;
        b=CSfWQxVropd4PLiSIO6BGpTs/Ef1h0v2ekKkK8/8JLREHbszKz2r/ElxeQQSJnvr3L
         PqR7Vj8/ElMipLvvAw//eq3zgqhhST26isa3kxzJX/AO5EIPc5I4Ub9liIk2l33vm1V3
         RILTSyq4BHr4lCfWraOmZmSXkma48xIv7SUDe8p5uV+/2TDdqQ3bf46v2iQDibsytUAm
         1vtpGAPyHteWDLoDKqCw1K+fEoS21BqzTnp2MUL3Yts4Y2fMOlTz3PMN3EQ2Fz06E4L9
         IMONIBUFNFK6YZA+i0umChRW57qecQefd52MODalZmmWQ22g8bDSCmMMTlFNfPBGrsqF
         jRXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=aJGKjeDfkxq63qK6+Utz9cs+S1CRCPma+t2/scCTmUM=;
        b=lglA//1ePWdIXmaN1bYWz33k5aakfx4y9Zz5oAtJ0bsk7Ox+8ZxQb94ogyS1wzhVVs
         oTtaqFJ3Cd1qVlF3p3xYJZQ+pCOCFJ+b851tEa1obEf+O5tWPE4vpH+wjA0RvCJnVvsi
         UxDO3Guyi79OpxPKSQQn4DRum1xtrFDMi4dtQVDWmdbhl4kA694kcrpJYgbgbuAkPUAi
         Uf9JjpC42iy3zsVEbxM+iNXMR9EoIEQ99odN1kwEg9oZKEe5ifTSdK6narjmLQdxBUQ1
         v/qZyEyRPHc876UkVSETICmo5pvMAr/G94JEpHt5dYYbopExnhs1iQLyWXgZqazcGGL4
         fYVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=PndsmpbG;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.73 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-SG2-obe.outbound.protection.outlook.com (mail-eopbgr1310073.outbound.protection.outlook.com. [40.107.131.73])
        by mx.google.com with ESMTPS id 59si12258589plp.100.2019.03.19.04.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 04:45:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.73 as permitted sender) client-ip=40.107.131.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=PndsmpbG;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.73 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aJGKjeDfkxq63qK6+Utz9cs+S1CRCPma+t2/scCTmUM=;
 b=PndsmpbGeAJGs2qLGVxDS0BCHh+ll/QDZsOEM6RTPEJoab/5OSQ5Wq9DezzziQO/CpHeFAKp9bax/i4gOesyfzIw4rj32v5czpp0i3Tg0gp8iEXgG7LhHf54tLPsTMB4szpAb5eVVXQoY5g6ZsEidLonwcbNqP92+eR2INj/5Ag=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB2700.apcprd02.prod.outlook.com (20.177.85.202) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.14; Tue, 19 Mar 2019 11:45:03 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1709.015; Tue, 19 Mar 2019
 11:45:03 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "minchan@kernel.org" <minchan@kernel.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [External] Re: mm/cma.c: High latency for cma allocation
Thread-Topic: [External] Re: mm/cma.c: High latency for cma allocation
Thread-Index:
 AQHU3YpG7XMhet9mv0+1ZFJR3Y1R16YRXCGAgAACGm2AAAebAIAABP0wgAAIBgCAAU6K1oAAEw1b
Date: Tue, 19 Mar 2019 11:45:03 +0000
Message-ID:
 <SG2PR02MB30981381635A6BC3783D42CDE8400@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098E44824F5AA69BC04F935E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190318130757.GG8924@dhcp22.suse.cz>
 <SG2PR02MB309886996889791555D5B53EE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190318134242.GI8924@dhcp22.suse.cz>
 <SG2PR02MB30986F43403B92F31499E42AE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>,<20190318142916.GK8924@dhcp22.suse.cz>,<SG2PR02MB3098DCB820E3367B09DDA45AE8400@SG2PR02MB3098.apcprd02.prod.outlook.com>
In-Reply-To:
 <SG2PR02MB3098DCB820E3367B09DDA45AE8400@SG2PR02MB3098.apcprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f8d42a61-6cb7-449f-521a-08d6ac605393
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB2700;
x-ms-traffictypediagnostic: SG2PR02MB2700:|SG2PR02MB2700:
x-microsoft-antispam-prvs:
 <SG2PR02MB2700F4825851954D5F391649E8400@SG2PR02MB2700.apcprd02.prod.outlook.com>
x-forefront-prvs: 0981815F2F
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(366004)(136003)(346002)(39840400004)(376002)(189003)(199004)(229853002)(66066001)(6436002)(9686003)(52536014)(81166006)(81156014)(8936002)(8676002)(68736007)(5024004)(53936002)(55016002)(478600001)(3846002)(14444005)(14454004)(2940100002)(256004)(86362001)(6116002)(6916009)(99286004)(97736004)(106356001)(5660300002)(486006)(11346002)(7696005)(25786009)(105586002)(446003)(476003)(186003)(102836004)(6246003)(76176011)(6506007)(71190400001)(44832011)(53546011)(55236004)(74316002)(93156006)(305945005)(4326008)(316002)(93886005)(54906003)(33656002)(7736002)(2906002)(26005)(78486014)(66574012)(71200400001)(586874002);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB2700;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 vTp4PyWNK5Q4wTO/soaConbGoaqij8SazmSblTSnnbfbYJrQ9M/oQBP77JgFkvCse9S1RoXj7ZaCqZSpaUCJYaMcbEHQ+DTZQjhoZxSDMigVv7NGs5EKuXc4VD5yXdTAxml3SvS05OzWuGjt6wSgsbct4ewkIvP2Zh4uKUIwquyPuIYhZ+2tOptY9yYepUSx2WZvzNJC4YctEhSd6pZJBuYEBRe7Tw1507eH++fjoPBne57GS1dGaEEXzqcXIIW+PzHsg4LIZgc/4X/9SHl470Zl5n+DsgjYZ4XLmCDcJ1nI86B8Sn1MLKqDcQqS0gfGIsxF5hgcszXSd+aMc4Xj4xNy8zPDo0bCiYnwnReDdv0U/uDKr+bDIvjAvJr3ywD2KRqTwLj4h0p+BUx5lIiXj1OO4R1qldwnQi5jrz+GUe4=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f8d42a61-6cb7-449f-521a-08d6ac605393
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Mar 2019 11:45:03.6814
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB2700
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


________________________________________
From: Pankaj Suryawanshi
Sent: 19 March 2019 15:59
To: Michal Hocko
Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; minchan@kernel.org; K=
irill Tkhai
Subject: Re: [External] Re: mm/cma.c: High latency for cma allocation


________________________________________
From: Michal Hocko <mhocko@kernel.org>
Sent: 18 March 2019 19:59
To: Pankaj Suryawanshi
Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; minchan@kernel.org; K=
irill Tkhai
Subject: Re: [External] Re: mm/cma.c: High latency for cma allocation

On Mon 18-03-19 14:02:09, Pankaj Suryawanshi wrote:
>> > I have the system(vanilla kernel) with 2GB of RAM, reserved 1GB for CM=
A. No swap or zram.
>> > Sorry, I don't have information where the time is spent.
>> > time is calculated in between cma_alloc call.
>> > I have just cma_alloc trace information/function graph.
>
>> Then please collect that data because it is really hard to judge
>> anything from the numbers you have provided.
>
> Any pointers from which i can get this details ?

I would start by enabling built in tracepoints for the migration or use
a system wide perf monitoring with call graph data.

Calling Sequence is as below.

cma_alloc() -->
alloc_contig_range() -->
start_isolate_page_range() -->
__alloc_contig_migrate_range() -->
isolate_migratepages_range() -->
reclaim_clean_pages_from_list() -->
shrink_page_list()

There is no built in tracepoints except cma_alloc.
How to know where it taking time ?

I have tried for latency count for 385MB:

reclaim- reclaim_clean_pages_from_list()
migrate- migrate_pages()
migrateranges- isolate_migratepages_range()
overall - __alloc_contig_migrate_range()

Note: output is in us

[ 1151.420923] LATENCY reclaim=3D 43 migrate=3D128 migrateranges=3D23
[ 1151.421209] LATENCY reclaim=3D 11 migrate=3D253 migrateranges=3D14
[ 1151.427856] LATENCY reclaim=3D 45 migrate=3D12 migrateranges=3D12
[ 1151.434485] LATENCY reclaim=3D 44 migrate=3D33 migrateranges=3D12
[ 1151.440975] LATENCY reclaim=3D 45 migrate=3D0 migrateranges=3D11
[ 1151.447513] LATENCY reclaim=3D 39 migrate=3D35 migrateranges=3D11
[ 1151.453919] LATENCY reclaim=3D 46 migrate=3D0 migrateranges=3D12
[ 1151.460474] LATENCY reclaim=3D 39 migrate=3D41 migrateranges=3D11
[ 1151.466947] LATENCY reclaim=3D 54 migrate=3D32 migrateranges=3D17
[ 1151.473464] LATENCY reclaim=3D 45 migrate=3D21 migrateranges=3D12
[ 1151.480016] LATENCY reclaim=3D 41 migrate=3D39 migrateranges=3D12
[ 1151.486551] LATENCY reclaim=3D 41 migrate=3D36 migrateranges=3D12
[ 1151.493199] LATENCY reclaim=3D 13 migrate=3D188 migrateranges=3D12
[ 1151.500034] LATENCY reclaim=3D 60 migrate=3D94 migrateranges=3D13
[ 1151.506686] LATENCY reclaim=3D 78 migrate=3D9 migrateranges=3D12
[ 1151.513313] LATENCY reclaim=3D 33 migrate=3D147 migrateranges=3D12
[ 1151.519839] LATENCY reclaim=3D 52 migrate=3D98 migrateranges=3D12
[ 1151.526556] LATENCY reclaim=3D 46 migrate=3D126 migrateranges=3D12
[ 1151.533254] LATENCY reclaim=3D 22 migrate=3D230 migrateranges=3D12
[ 1151.540145] LATENCY reclaim=3D 0 migrate=3D305 migrateranges=3D13
[ 1151.546997] LATENCY reclaim=3D 1 migrate=3D301 migrateranges=3D13
[ 1151.553686] LATENCY reclaim=3D 40 migrate=3D201 migrateranges=3D12
[ 1151.560395] LATENCY reclaim=3D 35 migrate=3D149 migrateranges=3D12
[ 1151.567076] LATENCY reclaim=3D 77 migrate=3D43 migrateranges=3D16
[ 1151.573836] LATENCY reclaim=3D 34 migrate=3D190 migrateranges=3D12
[ 1151.580510] LATENCY reclaim=3D 51 migrate=3D120 migrateranges=3D12
[ 1151.587240] LATENCY reclaim=3D 33 migrate=3D147 migrateranges=3D13
[ 1151.594036] LATENCY reclaim=3D 20 migrate=3D241 migrateranges=3D13
[ 1151.600749] LATENCY reclaim=3D 75 migrate=3D41 migrateranges=3D13
[ 1151.607402] LATENCY reclaim=3D 77 migrate=3D32 migrateranges=3D12
[ 1151.613956] LATENCY reclaim=3D 72 migrate=3D35 migrateranges=3D12
[ 1151.620642] LATENCY reclaim=3D 59 migrate=3D162 migrateranges=3D12
[ 1151.627181] LATENCY reclaim=3D 76 migrate=3D9 migrateranges=3D11
[ 1151.633795] LATENCY reclaim=3D 80 migrate=3D0 migrateranges=3D12
[ 1151.640278] LATENCY reclaim=3D 87 migrate=3D18 migrateranges=3D12
[ 1151.646758] LATENCY reclaim=3D 82 migrate=3D10 migrateranges=3D11
[ 1151.653307] LATENCY reclaim=3D 71 migrate=3D31 migrateranges=3D12
[ 1151.659911] LATENCY reclaim=3D 61 migrate=3D77 migrateranges=3D12
[ 1151.666514] LATENCY reclaim=3D 94 migrate=3D42 migrateranges=3D15
[ 1151.673089] LATENCY reclaim=3D 67 migrate=3D59 migrateranges=3D12
[ 1151.679655] LATENCY reclaim=3D 81 migrate=3D14 migrateranges=3D12
[ 1151.686253] LATENCY reclaim=3D 49 migrate=3D93 migrateranges=3D12
[ 1151.692815] LATENCY reclaim=3D 61 migrate=3D54 migrateranges=3D12
[ 1151.699438] LATENCY reclaim=3D 42 migrate=3D99 migrateranges=3D10
[ 1151.705881] OVERALL overall=3D285157

cma_alloc latency is =3D 297385 us

Please let me know is there any workaround/solution to reduce large size bu=
ffer cma_alloc  latency ?

--
Michal Hocko
SUSE Labs
***************************************************************************=
***************************************************************************=
******* eInfochips Business Disclaimer: This e-mail message and all attachm=
ents transmitted with it are intended solely for the use of the addressee a=
nd may contain legally privileged and confidential information. If the read=
er of this message is not the intended recipient, or an employee or agent r=
esponsible for delivering this message to the intended recipient, you are h=
ereby notified that any dissemination, distribution, copying, or other use =
of this message or its attachments is strictly prohibited. If you have rece=
ived this message in error, please notify the sender immediately by replyin=
g to this message and please delete it from your computer. Any views expres=
sed in this message are those of the individual sender unless otherwise sta=
ted. Company has taken enough precautions to prevent the spread of viruses.=
 However the company accepts no liability for any damage caused by any viru=
s transmitted by this email. **********************************************=
***************************************************************************=
************************************

