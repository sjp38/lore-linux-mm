Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6565BC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:30:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1254E20850
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:30:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="RddUyaXZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1254E20850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4FFB6B0005; Mon, 18 Mar 2019 09:30:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD8516B0006; Mon, 18 Mar 2019 09:30:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 953A76B0007; Mon, 18 Mar 2019 09:30:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4B76B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:30:17 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id z8so2556516wmc.4
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 06:30:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=drNPRNXMxYzVcVNuj6iqzhmMu+oEpiaawcBiiEZ5hwI=;
        b=cp5dnsFMR+wG3CvPfqlPKmkblT5l1pDAFOYFAuhEPxJ4sjVPfmfLjQetM0GbxHjajH
         Eahwj11v5pEd9Z8FeQLhMbC8h+ZwbWf2hk350CKKQfwKWgjUoLtqF5EZWRaT3oNm0FLj
         ZVGYbKFEyzU6SW0byGnoSBWJk8LklTqKlwH31OTiXYQ9R3x9+3WfcsLifatj7aBxKMUs
         DqbXi9p0Otz0CCY6pPl4blbtD4jgTQO8gtDZwCzl3hUFo5FFFZEDOg8q4b89jDrJmpds
         AErIXXsxHN/bwUAy9Yl1OKttekOvf33X9/NObUFZ68xz4EJmpexaMlWCbUTh0XiiKrs2
         /2HA==
X-Gm-Message-State: APjAAAUT4jV23EtgaU8rU+TMqG4WXf/IoC616WDeoj93GvhxkbrX9AwL
	0KhbR2B7yiViXuKfDJZun32Zu+YaW6YKTQ+J5upTHx6MCCZBFjxG+GNC8Zetxr2XH7QL6skFRRs
	8Ng1ALj7iJF3ySlr0m0sMDdDaKxeH/bHlz+tQ932ENT1nNYMCiX51tk5DXN0gLXGowQ==
X-Received: by 2002:adf:84c6:: with SMTP id 64mr12712634wrg.246.1552915816761;
        Mon, 18 Mar 2019 06:30:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1mVOQQLpqfgFp1XXYMw9gBzNDDq0x0AfY+fsqSzfkEcXnkapYAizDZsga+vscYDHKvSTV
X-Received: by 2002:adf:84c6:: with SMTP id 64mr12712578wrg.246.1552915815948;
        Mon, 18 Mar 2019 06:30:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552915815; cv=none;
        d=google.com; s=arc-20160816;
        b=pKHpXr/dH0Fa1l7L4DeX5i1aGAsmznJjfrANQtg08VHcPUUaR+BhlhxeSqWFD0OQp9
         yQq4t3zN+AZe9QcgwxZMh0FHElHrbbYprAMkxIaCrllH6v8fsP20JxtqAip1SRNePISn
         X41NZ/g7evcLSwiYA46W6hQ2HEWPqKgyQ7pGz4VbpDVl/f0mhMuruNPvZ5AbjZgCQIZt
         QM9ELamblNS2EeXrFpepy2tU5mjaugfgLUXVPWLM7aPbuLowmB2DdGkxVERu56d0Ggu5
         Us84Dtukkoks9iQDYAPfAppHIJvs+hNrRjRf9DIp62AUd9yovg69JB7tTVWq/feBQ09R
         6bAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=drNPRNXMxYzVcVNuj6iqzhmMu+oEpiaawcBiiEZ5hwI=;
        b=a8gpaiqz7JkFwM0qSP7JphMsYkrCp8SZpPLTOE7grSHTKcOsBjR3cvolHKe9JIwRfk
         bnMVzBqPr7FPnmRD5p05HOW2cdkzv7XUvMYM80UnL9IjXE2BsZeLTn6jQGFW2WTTZNkm
         lmPaBlG9hOP8A0T3/W502iqAeQCl3/9j8QqHJ8PGuMsMdVeqKrqrzrn2GCrxoWJ/nLyb
         3i93ZaUhkeWZkBSPzYwSxLe+04/V4SZ004Il3QQYfL4jRV5a4waqUkLl7FLmZIciNIOI
         OwA8uVIpqlkl2KzoaYBsL7a9aMi0AKwLXKWG7hF0JX7b7Py+/Mq7nxUCRVDIkTHF429j
         sR3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=RddUyaXZ;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.83 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-HK2-obe.outbound.protection.outlook.com (mail-eopbgr1300083.outbound.protection.outlook.com. [40.107.130.83])
        by mx.google.com with ESMTPS id e3si1248790wrj.124.2019.03.18.06.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 06:30:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.83 as permitted sender) client-ip=40.107.130.83;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=RddUyaXZ;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.83 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=drNPRNXMxYzVcVNuj6iqzhmMu+oEpiaawcBiiEZ5hwI=;
 b=RddUyaXZvHz1gSTsLrjFo6Y76zOgZ1nUDhUQD9ncDbwu0AZaJk5WONS688aipvbz6lMpMtYmw2Hvbj9ND5h1N90Agyw1GFVuEtTVqQ5k2wRw8cPtVY6HuTRuynsiUSRiyF6HhzoZq+73bfia9D2KJIjV5JFAoTZGBs5z/UmXxpA=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB3179.apcprd02.prod.outlook.com (20.177.86.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.15; Mon, 18 Mar 2019 13:30:12 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1709.015; Mon, 18 Mar 2019
 13:30:12 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "minchan@kernel.org" <minchan@kernel.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [External] Re: mm/cma.c: High latency for cma allocation
Thread-Topic: [External] Re: mm/cma.c: High latency for cma allocation
Thread-Index: AQHU3YpG7XMhet9mv0+1ZFJR3Y1R16YRXCGAgAAGDUo=
Date: Mon, 18 Mar 2019 13:30:12 +0000
Message-ID:
 <SG2PR02MB30989BAE73A493DD1EC09791E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098E44824F5AA69BC04F935E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>,<20190318130757.GG8924@dhcp22.suse.cz>
In-Reply-To: <20190318130757.GG8924@dhcp22.suse.cz>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: fe07ad14-3123-48ec-8332-08d6aba5d97e
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB3179;
x-ms-traffictypediagnostic: SG2PR02MB3179:|SG2PR02MB3179:
x-microsoft-antispam-prvs:
 <SG2PR02MB3179AC47B358B0078B3DA5F4E8470@SG2PR02MB3179.apcprd02.prod.outlook.com>
x-forefront-prvs: 098076C36C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(136003)(366004)(376002)(39850400004)(396003)(189003)(199004)(476003)(6246003)(66574012)(11346002)(446003)(6506007)(78486014)(102836004)(26005)(14444005)(5024004)(7696005)(6116002)(3846002)(99286004)(55236004)(53546011)(186003)(76176011)(54906003)(316002)(33656002)(55016002)(97736004)(9686003)(71190400001)(71200400001)(105586002)(486006)(106356001)(53936002)(44832011)(6436002)(52536014)(66066001)(6916009)(25786009)(4326008)(86362001)(305945005)(74316002)(8936002)(478600001)(8676002)(7736002)(14454004)(5660300002)(81156014)(68736007)(81166006)(256004)(2906002)(229853002);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB3179;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 iL7+Gm5XDls7xLItnjLLgTTX0S4z0cvgrjUkL2jUV4fOvDhAvuwJwwihk4zkfRg/olx7b+aBfUaQBQEPHtoxNHDStqx2ogDd1zaW67KEm9WtfD8n2QXvYyWMKDMN5U84kGc7hFjXANu7DLFGanuIFz+EaNEJZU5jj35ntoYfwvUi6vFUrLYuAVNUB0+FvYxQu+9AneAyB2izsDq3RuSLwOQm0ZYjFO6YLs0igZpLicUI++gdmzu6O8tKk6GC78x4/oGgJXLg9/LE1aBqNjCKCycKtUD6+Qzdt6Cr+kvFFe2zs8B4JpfeBvJrwLj1hpTm2oUxMYtYb3rxIlNVZW/xShAHWeQfkP49u5FMcpxsnwSDa6tFo/JlyhlU7AUndh3nR5KXm6qgpZ1q0XzMf2T6WK0xLKgetP9n5C7oMK2a2Hg=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: fe07ad14-3123-48ec-8332-08d6aba5d97e
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Mar 2019 13:30:12.4973
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB3179
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>









From: Michal Hocko <mhocko@kernel.org>
Sent: 18 March 2019 18:37:57
To: Pankaj Suryawanshi
Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; minchan@kernel.org; K=
irill Tkhai
Subject: [External] Re: mm/cma.c: High latency for cma allocation


CAUTION: This email originated from outside of the organization. Do not cli=
ck links or open attachments unless you recognize the sender and know the c=
ontent is safe.


On Mon 18-03-19 12:58:28, Pankaj Suryawanshi wrote:
> Hello,
>
> I am facing issue of high latency in CMA allocation of large size buffer.
>
> I am frequently allocating/deallocation CMA memory, latency of allocation=
 is very high.
>
> Below are the stat for allocation/deallocation latency issue.
>
> (390100 kB),  latency 29997 us
> (390100 kB),  latency 22957 us
> (390100 kB),  latency 25735 us
> (390100 kB),  latency 12736 us
> (390100 kB),  latency 26009 us
> (390100 kB),  latency 18058 us
> (390100 kB),  latency 27997 us
> (16 kB), latency 560 us
> (256 kB), latency 280 us
> (4 kB), latency 311 us
>
> I am using kernel 4.14.65 with android pie(9.0).
>
> Is there any workaround or solution for this(cma_alloc latency) issue ?

Do you have any more detailed information on where the time is spent?
E.g. migration tracepoints?

Hello Michal,

I have the system(vanilla kernel) with 2GB of RAM, reserved 1GB for CMA. No=
 swap or zram.
Sorry, I don't have information where the time is spent.
time is calculated in between cma_alloc call.
I have just cma_alloc trace information/function graph.

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

