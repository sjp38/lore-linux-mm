Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8714EC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 12:58:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3741520857
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 12:58:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="QHAgM2UN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3741520857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2BEB6B0003; Mon, 18 Mar 2019 08:58:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDB1D6B0006; Mon, 18 Mar 2019 08:58:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACB116B0007; Mon, 18 Mar 2019 08:58:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 68C826B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 08:58:33 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f19so18971825pfd.17
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 05:58:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=NWa96tqDALkG/Ihkkz4AKVvab5GUIL1OORVySlstbmA=;
        b=nplqN5TvNqqI/tGaKjtQ+4QUtb1+Wpclw0CuSWa29M/PQVjqOPFQ+XqM+8bcdSpoOd
         NGV8PGEy+MJz32q+6TsTPbe8TnfVCFl5whKJgWmBc1PJAT10dN6qGHNPt+nDsnQ/6j4t
         br8c84w4LPyk7YqudOsouab3A2MzIJfh3H6Nrb6ScbRzaDmT5YQpiyU6aA0tPVYRW22f
         K3bBUMab27MC19zPb1v6KGvNpumn6y034OliiTojAlydaEE/5fULSJbj0+KkyUIpxx9U
         jBE9FHE32J/4Pc3KsIjZy7X5Ed81aC7fQmFBVJh5IA+oxAqHaei/nELiQOo7nCKiJo5S
         Iahw==
X-Gm-Message-State: APjAAAXG9xd/z6v8IcJld9SW+a9hMtZLELDFzAgDAgnG5Y4Lm6M/gFiz
	oOjF2VePt6/4dCJpHQVSOmEfYJKtr68JXGboSQxsY9Ebe1sq+rsQHDT/g9lJt0OS9T4fsepqhwb
	Vmuc5hhdwSe0oNQPKz/iMnepXvfaZHbIvPRe79lWzW4oDc1lpUBWX2sHWi0P4cugqHw==
X-Received: by 2002:a17:902:2947:: with SMTP id g65mr19640652plb.258.1552913913002;
        Mon, 18 Mar 2019 05:58:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqc7O5OF7HfxVBowGwV4UafdchUijAJssp4RS7+6MA6IerrJ9KlmtodaUZLMuMycFLQQ2F
X-Received: by 2002:a17:902:2947:: with SMTP id g65mr19640540plb.258.1552913911484;
        Mon, 18 Mar 2019 05:58:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552913911; cv=none;
        d=google.com; s=arc-20160816;
        b=sTkaOwf24F+phJoITUMI/ekYxuX6KYqQ1iO4DuLEwznJyx4IjLyWo+CjNwjCReKCcv
         sc1+H78B/Wpwc3/4NzkTM1duFLHw1Thbepb+nzuPBpK61iFsZsRJhHQRO1rb1Ti8AhIN
         l5pd2N8MlU6A7Cxip+PrTcgI2tSdIXsUW47wmApfNPlupWFrMDS+86SolsB3jrQHaKMC
         ekhlnV59BzWnxDF4iwOuZ2CiCjSlZ7Wrym5i2SWZiSjLOypmxesgG7p0GU13hBFlcREZ
         tPrtyhefG9wsjh2ItpCCL61FyOCm5bg7ph7jlV6ng4A/hBvf4mgBa83Khz1RVRCTj1R4
         ahqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=NWa96tqDALkG/Ihkkz4AKVvab5GUIL1OORVySlstbmA=;
        b=BxbrJM9B/zM2NFfKXexyR+FBhzK1zqlQ00SL1nFZZU4gGia+xCwcuI5GPNyDZI4X6/
         LA+V96ssmx+2KNtvs7lrSAia6d8DcCwyoz3v1mZX0JEU4I2t5871GlGaPQS43Qlg9J8S
         SGC8Mei/T/0L+Z6mY4IzAKrTePYVLroRYSzJuP0ZCS+Bm5hJeTTLSn0UkMyrytsCC2SF
         stFuCZin48iMZb43wz8El7hf/GrJMpILMgVRdzEYqkV122147oOn1Ktg+t+HTH+fByUX
         V0zty0XNJaX/7dnmeRZpY01SCu8cxsxfMXkL6IiKsiNU/qJQyGIk2Xqo3D/yv/DyF629
         kBCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=QHAgM2UN;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.54 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-SG2-obe.outbound.protection.outlook.com (mail-eopbgr1310054.outbound.protection.outlook.com. [40.107.131.54])
        by mx.google.com with ESMTPS id c12si8544189pgk.202.2019.03.18.05.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 05:58:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.54 as permitted sender) client-ip=40.107.131.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=QHAgM2UN;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.54 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=NWa96tqDALkG/Ihkkz4AKVvab5GUIL1OORVySlstbmA=;
 b=QHAgM2UNDZ8q05tNsAH+piTQsbp5oCMaYN+eC3m74bJbcyWqDTWMPyCNSmTTUTjy1Ei+8hSAGj8/qzmGyzf+LxuWVRHgi3rbWAp+ZrwalTIyromJX1KeEs40BXAUv1EA3ssz4oCmSBwYg74PJXbcY+cfQa0KHoXP8x8Y8v4RdCM=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB2985.apcprd02.prod.outlook.com (20.177.88.207) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.13; Mon, 18 Mar 2019 12:58:29 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1709.015; Mon, 18 Mar 2019
 12:58:29 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "minchan@kernel.org" <minchan@kernel.org>,
	Michal Hocko <mhocko@kernel.org>
CC: Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: mm/cma.c: High latency for cma allocation
Thread-Topic: mm/cma.c: High latency for cma allocation
Thread-Index: AQHU3YpG7XMhet9mv0+1ZFJR3Y1R1w==
Date: Mon, 18 Mar 2019 12:58:28 +0000
Message-ID:
 <SG2PR02MB3098E44824F5AA69BC04F935E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4b0802b4-42ef-4a12-41b8-08d6aba16ada
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB2985;
x-ms-traffictypediagnostic: SG2PR02MB2985:|SG2PR02MB2985:
x-microsoft-antispam-prvs:
 <SG2PR02MB2985ED45BB680E702AAA9D75E8470@SG2PR02MB2985.apcprd02.prod.outlook.com>
x-forefront-prvs: 098076C36C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(39850400004)(136003)(346002)(376002)(396003)(199004)(189003)(106356001)(186003)(105586002)(66574012)(78486014)(14454004)(81156014)(86362001)(25786009)(81166006)(8936002)(2201001)(33656002)(256004)(2501003)(305945005)(68736007)(7736002)(5024004)(14444005)(71200400001)(71190400001)(3846002)(6116002)(8676002)(53936002)(5660300002)(97736004)(110136005)(486006)(2906002)(476003)(44832011)(55236004)(9686003)(316002)(55016002)(74316002)(4326008)(6436002)(26005)(66066001)(52536014)(99286004)(6506007)(478600001)(102836004)(7696005);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB2985;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 cQAffUqDq+wDrBEPBA21/GK+RAGu+eJXh0aKr6PLcXo2E9WUvNhbIR3drxIyVX/vYDYr9G5D2A4GEoOBb+duO8Za4kVN1V1Abb7d+wTBWdSSSRU+EGDwKLlehpkICEBGIcuqrjZEPVTMC+Hx5drXAuO0P7pIApgwRCESvAUD0RBV5Yf37cM5VzAp4TnSO5iinX+GjJaN5Va8InFcFW/vNfDStBdtKfJRqKfdGXKkRxfo45/nHd6DfUAI3Zj4NqhrzjCirCvFlAk04H9H9TJBpjG+Dv21KgCxGaAXF1nyY7X25LpvFAFpA3vZDSD18vpLs+1hEvixAbOqeSA4IpdEeHdk9EFOW66szODqjU1TauDemkYukXR9pyaju4X7x0muk7R0qDx2z66HSPKAHY0I+OiNV7PKX5p3funNV49TXjU=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4b0802b4-42ef-4a12-41b8-08d6aba16ada
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Mar 2019 12:58:28.8675
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB2985
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I am facing issue of high latency in CMA allocation of large size buffer.

I am frequently allocating/deallocation CMA memory, latency of allocation i=
s very high.

Below are the stat for allocation/deallocation latency issue.

(390100 kB),  latency 29997 us
(390100 kB),  latency 22957 us
(390100 kB),  latency 25735 us
(390100 kB),  latency 12736 us
(390100 kB),  latency 26009 us
(390100 kB),  latency 18058 us
(390100 kB),  latency 27997 us
(16 kB), latency 560 us
(256 kB), latency 280 us
(4 kB), latency 311 us

I am using kernel 4.14.65 with android pie(9.0).

Is there any workaround or solution for this(cma_alloc latency) issue ?

Regards,
Pankaj
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

