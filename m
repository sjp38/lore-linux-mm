Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BA52C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 14:02:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 959A520989
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 14:02:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="W/XsH4k/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 959A520989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCFE16B0005; Mon, 18 Mar 2019 10:02:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7F326B0006; Mon, 18 Mar 2019 10:02:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C47946B0007; Mon, 18 Mar 2019 10:02:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 846C76B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:02:14 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a6so18726276pgj.4
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 07:02:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=QKt5/eL+MaYo676wm7nZV2bM/n32t2UwHBXrPccUSOw=;
        b=S1TjRSPQp+df82CNUIw1KD4HOQNlpdkadJi31AXcyelalTDkdJvb4p9G4ljw/bmd3S
         g+VDC5lWECnvC+tSKpZ348M81Hadv8jphu4ekRaKiYuqzMx/iX0TqS5CyOjLkTZOQ9LS
         Nj2OcznxLqcRZ0ColJmyG+s+lI5kwTodF+CTros9mpZBkdj0RBFsv8fZMMm8WkWcbTnJ
         UFoBA+Ocufv8w0t6t6tLVwb1Vt+CCyuqLr7uYakf8hp4JtMztx0lFj1ST9vAyxBFoSr/
         RadYy5+OfN2EU+8CU6MLVg6K0d9bbaO/SD9ArSQ5zvS0pXD4dBntJfY6mZc5NhDxSSvz
         ag/Q==
X-Gm-Message-State: APjAAAUpF7SFTdKzNjiwRfTD4LfHHGkOnuQtBBOIDi9abUt1iQoi0205
	zswGJDM1guZ5HnDZGRT43J8L5NMGQWkU7jDHEWA0nAQW5vloCjBCszloln0jS6n2Z9DRfj7V6hZ
	H7Rhy0n8N7Nr2iNrcW/k13MInYzyM1uo9qCilwdsQgMMZPiLPZXdgg4Ai5Tnx4JFK1g==
X-Received: by 2002:a17:902:8ec8:: with SMTP id x8mr2725363plo.129.1552917734125;
        Mon, 18 Mar 2019 07:02:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRuHtb+21F1jIAhoFdPJobGv8RxVImDbiZ9B4zgEATIrL+ClqE9hgdRfxNMaf/5Z9dXwbI
X-Received: by 2002:a17:902:8ec8:: with SMTP id x8mr2725258plo.129.1552917733014;
        Mon, 18 Mar 2019 07:02:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552917733; cv=none;
        d=google.com; s=arc-20160816;
        b=VxjTvjri+KZhYfM1EDzPOrIwskliyXcJ90Dz+QwSvK6n9nUxcBMqrZgZh9yXK5w7up
         4x3oiNkfdwyS9eOcFG3sCGSudFCX4SrfhLh6gol8JSPEahxbMkmh2E6v3faw3qDBwxCe
         MnnH3a4B0A8sMUE7hjZ45+pWQBdzz89PLUHvpJ5RX4yCuI1bpkmGxnbNPHoRi0LZCVHv
         ZcJy07/LQcn81rRvwvAqlZ+6YZT8UhlpvfCuTcX5Tm/btAx5DusFR2J+Mse5CjfFH6Lj
         mE1/HcxFcgY0P5WVufWHnMFWpPjcgBCENrOCzJAcz2W+2rdmnQDvzsk+lkVphtPk96Cq
         3nnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=QKt5/eL+MaYo676wm7nZV2bM/n32t2UwHBXrPccUSOw=;
        b=ZGVIRPotxkJXlqPtQxOOab2DRaVddqfj1k4ixAZYfd3QA15G8WIJ2lbCCp7U9FhAiF
         Nx1WvvoiD2Z/dNXfRTWL9+CDFoSijWfvMmTtmjzLKB54UeKWmuLVAGQhIfQ49y8Y9gB7
         4Kc541PJMF34xMTKwHTROUqcOCnVybx0EuVlyGlCStRhtALSnrih0VQC8Fi6zdMMy+Vo
         A1T/bK9K/HAOVVytU4pkL9S1pOrRWSteE9Bm4GEe2vFY8Ct8qjdbiUrcnLDuoYnXd/u4
         8409Md7s9JIikhxqwXGmW2lB3Dgqol/N3ofjGv3TLW9vpHR7V0vMqF2dhgKBJp+kLFnc
         ZSDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b="W/XsH4k/";
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.71 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-HK2-obe.outbound.protection.outlook.com (mail-eopbgr1300071.outbound.protection.outlook.com. [40.107.130.71])
        by mx.google.com with ESMTPS id u2si8858813pgr.285.2019.03.18.07.02.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 07:02:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.71 as permitted sender) client-ip=40.107.130.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b="W/XsH4k/";
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.71 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QKt5/eL+MaYo676wm7nZV2bM/n32t2UwHBXrPccUSOw=;
 b=W/XsH4k/W/pa26rPugv0tXAASEzPtwYZA/faz4a62mt9Z5OocSYb+QMo0ZqcKSNUwkbZN/xmayBzP+M6JtchZ8Px2AZXKFC90JjQ4qxuDwn6bIaQQt9Doff/QNW9Qaa+15Clz1W+t9JmS58Q0V4YIn/BNCEQqcKQDqRnElpGsso=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB4060.apcprd02.prod.outlook.com (20.179.102.11) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.13; Mon, 18 Mar 2019 14:02:09 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1709.015; Mon, 18 Mar 2019
 14:02:09 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "minchan@kernel.org" <minchan@kernel.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [External] Re: mm/cma.c: High latency for cma allocation
Thread-Topic: [External] Re: mm/cma.c: High latency for cma allocation
Thread-Index: AQHU3YpG7XMhet9mv0+1ZFJR3Y1R16YRXCGAgAACGm2AAAebAIAABP0w
Date: Mon, 18 Mar 2019 14:02:09 +0000
Message-ID:
 <SG2PR02MB30986F43403B92F31499E42AE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098E44824F5AA69BC04F935E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190318130757.GG8924@dhcp22.suse.cz>
 <SG2PR02MB309886996889791555D5B53EE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>,<20190318134242.GI8924@dhcp22.suse.cz>
In-Reply-To: <20190318134242.GI8924@dhcp22.suse.cz>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d7aa5700-ac66-456a-8fb9-08d6abaa4fe5
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB4060;
x-ms-traffictypediagnostic: SG2PR02MB4060:|SG2PR02MB4060:
x-microsoft-antispam-prvs:
 <SG2PR02MB406044BEF1CCEACAC6B53D97E8470@SG2PR02MB4060.apcprd02.prod.outlook.com>
x-forefront-prvs: 098076C36C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(396003)(39850400004)(366004)(376002)(346002)(189003)(199004)(486006)(76176011)(14444005)(4326008)(8676002)(186003)(14454004)(256004)(71200400001)(478600001)(11346002)(44832011)(25786009)(8936002)(5660300002)(33656002)(81166006)(81156014)(6116002)(3846002)(446003)(71190400001)(6916009)(476003)(9686003)(66066001)(6436002)(2906002)(55016002)(53936002)(106356001)(26005)(305945005)(7736002)(229853002)(97736004)(74316002)(105586002)(86362001)(54906003)(68736007)(52536014)(78486014)(6506007)(93886005)(102836004)(7696005)(53546011)(55236004)(66574012)(6246003)(99286004)(316002)(5024004)(586874002);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB4060;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 EYEPCboMKYYV7MPN9nSgGB4Bd25wTpndLjW9+JxJXOHD58Jxx4Dk6nI0oS5ugahAHW49XtWUvkUiyifnBb2XtaazqKSkt/Wpr4PM9vd0eSYW9rH7VpPppD8wlzp1yHFM215EiRP9DNEeDK9Ln5wrDkcw5p+cwfjIy7gyOKxwtuNSXgR0oc0efb86pFGcBoMZusqL+I9R1Gl93ylIXVCCfIrZy1C11BHv1ky4VUb4AIcW9+cTt7J5W2QGHfJriYDY3V8orVtI+8PlyFbO3hahqHsDSCyYEJpAmSZgGdIo91G6ZW7a//7kkpMXuJAdDEbvnlghGSaI+/e73GJgXW8a46zO5rrLl8mAvvnzSl8sxYr5XsKV2idi9QfOjs+15f/yJlvnoQDJGA1V4gB7b4/zpaMdmaFKMJxB3VhOqeUVgXo=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d7aa5700-ac66-456a-8fb9-08d6abaa4fe5
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Mar 2019 14:02:09.1037
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB4060
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


________________________________________
From: Michal Hocko <mhocko@kernel.org>
Sent: 18 March 2019 19:12
To: Pankaj Suryawanshi
Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; minchan@kernel.org; K=
irill Tkhai
Subject: Re: [External] Re: mm/cma.c: High latency for cma allocation

[Please do not use html emails to the mailing list and try to fix your
email client to not break quoating. Fixed for this email]
okay.

On Mon 18-03-19 13:28:50, Pankaj Suryawanshi wrote:
> On Mon 18-03-19 12:58:28, Pankaj Suryawanshi wrote:
> > > Hello,
> > >
> > > I am facing issue of high latency in CMA allocation of large size buf=
fer.
> > >
> > > I am frequently allocating/deallocation CMA memory, latency of alloca=
tion is very high.
> > >
> > > Below are the stat for allocation/deallocation latency issue.
> > >
> > > (390100 kB),  latency 29997 us
> > > (390100 kB),  latency 22957 us
> > > (390100 kB),  latency 25735 us
> > > (390100 kB),  latency 12736 us
> > > (390100 kB),  latency 26009 us
> > > (390100 kB),  latency 18058 us
> > > (390100 kB),  latency 27997 us
> > > (16 kB), latency 560 us
> > > (256 kB), latency 280 us
> > > (4 kB), latency 311 us
> > >
> > > I am using kernel 4.14.65 with android pie(9.0).
> > >
> > > Is there any workaround or solution for this(cma_alloc latency) issue=
 ?
> >
> > Do you have any more detailed information on where the time is spent?
> > E.g. migration tracepoints?
> >
> > Hello Michal,
>
> I have the system(vanilla kernel) with 2GB of RAM, reserved 1GB for CMA. =
No swap or zram.
> Sorry, I don't have information where the time is spent.
> time is calculated in between cma_alloc call.
> I have just cma_alloc trace information/function graph.

Then please collect that data because it is really hard to judge
anything from the numbers you have provided.
Any pointers from which i can get this details ?
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

