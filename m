Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 739FDC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 10:30:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23486206BA
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 10:30:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="oRVwzzyk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23486206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B48626B0005; Tue, 19 Mar 2019 06:30:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF70A6B0006; Tue, 19 Mar 2019 06:30:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E6766B0007; Tue, 19 Mar 2019 06:30:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 598846B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 06:30:00 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o24so22040572pgh.5
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 03:30:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=jQl7/78edH7yLD5G0CT1U9U8IhbAPTO5XuOLXV5a4WE=;
        b=FWWPoTdKC0tN62B4usAwpcRj5Q9GDHR/lpZjhDsYPkHoY+XZjST8jWSngjE36gkpmB
         /JZEFtgS7XsPSH1TVM0GLVat7ow4gPzRgTxbu2+eNgCY1vwfjAWWWT7xTbEwCi+1q4cG
         NguZc3a+Hy2XwVihOnKpXWdy3Tpp8bJpeTasa1/4jfAmLhUN8NZ4ZJolgt5jP3I045rq
         TnMQgXiXsr1zwNKc++w6Bz7VvdDAXHk6YS2FAt9PKrqGr+vLMbpha/CXjEU8LZdFm+ss
         jSrrYqcFQURIgSnu0VhPrkU9ojNk7/vhMYrYGKtaPZ/bZ9UFpRFU0IliibzDWFx4ztMK
         HRvg==
X-Gm-Message-State: APjAAAXjYIr4LJaQ5KG1ZvFWX+VK4PItZbmY7zN9nAOtJG/gRCvvhn4I
	Qa3I0/r8n0+i/zNCk7U1CxV4LPTI9/1srVUsaA07N6ySJVYXZKtBXGguqvvlaTeU0FLppYokj7m
	LK3bNfTTbC+nJ9jmpjXWSTAcD099JzEKQ2jSvs4Rq/bR8GvsPiux9WV78GtMg8ULhWA==
X-Received: by 2002:a62:1e82:: with SMTP id e124mr1203694pfe.258.1552991399886;
        Tue, 19 Mar 2019 03:29:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrQk379hwi3fQlYAimxjR+VDua+ZJ4hP323Zgfs6vUZqW7OXjVxmQIQTYhaPhXhRHfjq+r
X-Received: by 2002:a62:1e82:: with SMTP id e124mr1203607pfe.258.1552991398581;
        Tue, 19 Mar 2019 03:29:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552991398; cv=none;
        d=google.com; s=arc-20160816;
        b=E6ipgh/hhpU7CYBGrx23XJAurf6isgCw/dXIdzOoIoj7Bto5+7oH23ugGYs2y11Bnz
         Zg8MmCLPBsD9HtzLyuQwoQOGKEB5lN0M0ox4015bEoqN1xk/XunXfyII9mzxndJt9Pm6
         oLQHZzcdyU1WbKeP8QZzzC5bWMzDORbZUGlf7rT6mAjKl5gBt/StbIAT4fhMocwEgG4p
         xyKiKuf03RI80pMRpNAWaiv5+vvaVH8kCv5zJCp6gcK9UKeeSTNnr0G4BSPKb0iHUfLr
         IOb2IVdilSF8G8H11G13/rofue4sqydwmHQ4y7JppnNTnsYb/3sUwbtCCu5SAtvXsZT3
         XGvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=jQl7/78edH7yLD5G0CT1U9U8IhbAPTO5XuOLXV5a4WE=;
        b=j4hiS8gs3ILLCyYDwBK3RAXuCq7m7ZD0JGpzsRkZdI948FDYEKd7SsbZwwXfdqyLue
         JDsRBykC9tjxpuZM3mEOImElK9BaMvsp3+vX9t4j7EdWWscD1fvOLQNQYr1D59AzQz2p
         KM/5+WCXQnsPkQeSrzt7G6bnPnQXMr6QWNyFUd5r7VJ+PeMvaSaoH6kJMDn83YT57pQA
         VNxilHkLwAGURe39bFeR83zr3+w46EyElwZlK1UUB8yyTZTTxlZHaJ9X/xs9ps3Dlzic
         6VpwJ3I2l8s9VyBHrp7dwHJLJqm4UGb+vYds22KqM0x7DOzFulbSuwjf1NheeVL7QKlF
         UZUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=oRVwzzyk;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.80 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-SG2-obe.outbound.protection.outlook.com (mail-eopbgr1310080.outbound.protection.outlook.com. [40.107.131.80])
        by mx.google.com with ESMTPS id bj1si11407554plb.15.2019.03.19.03.29.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 03:29:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.80 as permitted sender) client-ip=40.107.131.80;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=oRVwzzyk;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.80 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jQl7/78edH7yLD5G0CT1U9U8IhbAPTO5XuOLXV5a4WE=;
 b=oRVwzzykwxT02ZsOGtzXqR0BACDolHMLukHDd11hTox2Q6GDFddvIwWKUB4zb81IsqEAFo9sfqZ2No5BzzY6S9928ktJPPCq2VtJAta0PWuNC3H1HIcNb2xWj0lpjC2pPn4004cXAoJJiH+AbYjZbC/m5YOKVp1wVOj1c+WcTFk=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB2527.apcprd02.prod.outlook.com (10.170.141.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.13; Tue, 19 Mar 2019 10:29:55 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1709.015; Tue, 19 Mar 2019
 10:29:55 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "minchan@kernel.org" <minchan@kernel.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [External] Re: mm/cma.c: High latency for cma allocation
Thread-Topic: [External] Re: mm/cma.c: High latency for cma allocation
Thread-Index:
 AQHU3YpG7XMhet9mv0+1ZFJR3Y1R16YRXCGAgAACGm2AAAebAIAABP0wgAAIBgCAAU6K1g==
Date: Tue, 19 Mar 2019 10:29:55 +0000
Message-ID:
 <SG2PR02MB3098DCB820E3367B09DDA45AE8400@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098E44824F5AA69BC04F935E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190318130757.GG8924@dhcp22.suse.cz>
 <SG2PR02MB309886996889791555D5B53EE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190318134242.GI8924@dhcp22.suse.cz>
 <SG2PR02MB30986F43403B92F31499E42AE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>,<20190318142916.GK8924@dhcp22.suse.cz>
In-Reply-To: <20190318142916.GK8924@dhcp22.suse.cz>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 12e0e1bc-2895-425b-f9ae-08d6ac55d47e
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB2527;
x-ms-traffictypediagnostic: SG2PR02MB2527:|SG2PR02MB2527:
x-microsoft-antispam-prvs:
 <SG2PR02MB2527EFAA505129018FE4AED7E8400@SG2PR02MB2527.apcprd02.prod.outlook.com>
x-forefront-prvs: 0981815F2F
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(136003)(376002)(346002)(39850400004)(396003)(189003)(199004)(14454004)(71190400001)(5024004)(305945005)(66066001)(26005)(93886005)(99286004)(256004)(8936002)(81156014)(5660300002)(14444005)(52536014)(6436002)(9686003)(97736004)(3846002)(54906003)(33656002)(7736002)(6246003)(74316002)(2906002)(81166006)(78486014)(6116002)(53546011)(102836004)(8676002)(6506007)(55016002)(105586002)(229853002)(316002)(53936002)(44832011)(25786009)(4326008)(478600001)(476003)(7696005)(66574012)(486006)(55236004)(71200400001)(186003)(6916009)(76176011)(86362001)(11346002)(446003)(106356001)(68736007)(586874002);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB2527;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 JQeeIFxDRRZf2zSfjen3AyGVAx0B+LCLCJYr4024lsVX7/szQtqhvRLrEr7cI/i9nUpl/UMQ2aC7CYBt/xAc8VLOs4mtVTMtrRK4foVMM3PRUnfTPPLdsZbUN2bpgjDMHUOdAbcEGpU6EOkJRxTwiXpah9MmGS2uiOEipthv3NbXrArs63B1mO8NnhWPnFwPtD8eisrVu0QquIA1hfFRPMc54TEJM8qPyYr+ImBZKYdh8XQSCA2VfYCaN7526rxWJvvmvLNk8Rfem56cLP4eD1S9u0JyuoLtCd7x4b7BjPCqLwvNBNGXcE2a8YDqK0SrUv5hUYQzLA9NjuHPH8JxclULROz/uzd1nA/McZW/57X30Va5oa+qeSwx1obEMJCdbwt1KrOlZSV37rmYk1hORP8kjjAGCyak0tyPjyzZ7qs=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 12e0e1bc-2895-425b-f9ae-08d6ac55d47e
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Mar 2019 10:29:55.6312
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB2527
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


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

