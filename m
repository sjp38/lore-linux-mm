Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00A29C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:34:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A542C20857
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:34:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="XHbpoHJ5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A542C20857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40EE26B0005; Tue, 26 Mar 2019 04:34:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BED46B0006; Tue, 26 Mar 2019 04:34:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 285F76B000D; Tue, 26 Mar 2019 04:34:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DA1B56B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 04:34:24 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 42so1704385pld.8
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 01:34:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=CJi1wBv89/pqERKxkJrY7iOegis+ayi6V4u/t5aTaJo=;
        b=ZFaLVZWo4nLLR7BCiw5gBzl5DGJgHPLFThoUBn9IWUavSW5cOw42b2uDmcmAH+XBMp
         1HCfYV7nWUjPNXNanHd1dNEck+tUmkFWh8Qx6sBbA+Zj7jBewGNc+Z8I2+eiXFxaRLH8
         kP6CUT2RsRQLNMdqQrPXR/2zGzzuzktSxtSHykH3q6H9tbkq4CJTdacd+74NWcLWgrK1
         Hs0YdzAiuPbh7b62YHZMzD96Oq9sJCyjjpufexlAxzEDZJDollwbCRnbWFclrbLeRTcv
         JXvd9+yJ0CIIS+t/ID5QXq908O8Sbj1RJuMi6duLAwDDCkBQAd/1Oq8slpKEbcj8zlXH
         b8Lw==
X-Gm-Message-State: APjAAAWWFsqj4CPIgycIUqkgACp9/Jn5kg/pDr1T7MkQ9rBWuVMXVNE4
	XSvTAEUQlJNoB9t6dOYiIUgAdDoFUgS1Et+ftMT9E2OfbRmPu7ZdvpU4wHjxEOY0vBBt8FxoxX0
	BF5OJ8yHG/eqgF4tQvAKY9lA5jDribp0godctPXsilhgD0aXbmdYiR8t+wjOAvn5eaQ==
X-Received: by 2002:a62:415d:: with SMTP id o90mr28248201pfa.236.1553589264390;
        Tue, 26 Mar 2019 01:34:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTw6lZKWeDrPzbwOZveu+IBNCdwWqti/Z2jIz8z/PvQsgGpu6tk6F9qlfioxX21RU+w9ci
X-Received: by 2002:a62:415d:: with SMTP id o90mr28248156pfa.236.1553589263589;
        Tue, 26 Mar 2019 01:34:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553589263; cv=none;
        d=google.com; s=arc-20160816;
        b=icXAriu42QyLK/KDK9P2pXstCpZ6Roct1rBnuXb/UZ+I/pM57kltOlZr+xAExz0yN1
         hU8RJH0OXja5QmYCHMlWY5/yEnYTEHOJ7YxfEORmXn5XMk0B/H5rjD/csDSCJhmRMMFE
         k/PtqXjyxsEkaoIXAgvyQyGCX1B+Lx1gpauzDiUIs4wW4+mAbLvq/CwAiTrEa7+ECHMb
         RJ454OliDag0h65RzT9qediEYEZZGmjXaeHjKB+lt6dQ2SsDZaoaGoHppuqBRbcRFlYJ
         IebS0jvQmzF3bHJBFQfs9fHi/WflgFxCDxWWkfQMtU+U1hu7txnKamSILBGwdHVyeRKV
         r9hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :to:from:dkim-signature;
        bh=CJi1wBv89/pqERKxkJrY7iOegis+ayi6V4u/t5aTaJo=;
        b=eeyjgEF6bVTrwS0Qax8DDUYKldBXwO4dXnFyOriAsDrp2zLPL8B/+Tx2nsdxGvylTg
         am43vZy19lKBOKApSz6pEaJOUfOIS340hknq+8xSCrsLZ9Ji0Z8z4R/ueaLRum33u0z7
         Od1hJ6+fvwOB0GQx4cxosy5q29+e/K4SYx6Jjea1ihDIqvqpACb/pDqH4UGq4Mi8SyNy
         DnspwjKyQ4cfUX8iU+Uqz4oIwvOpZW/c9tOg3gcYnZBr+GDqvkAQpxPM6wFKOGaDr5Xg
         GJuJxiAZL1/xMRbuvoNwrWIslsFZwHzoD8ti9V7ljBECF+FCehdrUoYAuuVsO8q4cbGh
         +Yew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=XHbpoHJ5;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.70 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-SG2-obe.outbound.protection.outlook.com (mail-eopbgr1310070.outbound.protection.outlook.com. [40.107.131.70])
        by mx.google.com with ESMTPS id f131si15898128pfc.92.2019.03.26.01.34.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Mar 2019 01:34:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.70 as permitted sender) client-ip=40.107.131.70;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=XHbpoHJ5;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.70 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=CJi1wBv89/pqERKxkJrY7iOegis+ayi6V4u/t5aTaJo=;
 b=XHbpoHJ57QgZ3jU9XMKdnslkm8lfFjBL7U1PX0ilkJBgOWYRaIv4gT7JxmwVsSKPdmcKP9tkpqYblzdwskzV7SmH3T4hP1+IJ1jUic7MbQYKgwWucRyXVNZsfQp5OdnetutNBT6i2lBXfWgee2u2FjSVMAJdENZj+h07yPuUW1s=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB3321.apcprd02.prod.outlook.com (20.177.81.84) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.18; Tue, 26 Mar 2019 08:34:21 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1730.019; Tue, 26 Mar 2019
 08:34:21 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Print map for total physical and virtual memory
Thread-Topic: Print map for total physical and virtual memory
Thread-Index: AQHU46nCeD1YOwMRP0e9ea2iKxtjwQ==
Date: Tue, 26 Mar 2019 08:34:20 +0000
Message-ID:
 <SG2PR02MB3098F980E1EB299853AC46E6E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 70c8df0c-9ad4-4d31-83f9-08d6b1c5d809
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB3321;
x-ms-traffictypediagnostic: SG2PR02MB3321:|SG2PR02MB3321:
x-microsoft-antispam-prvs:
 <SG2PR02MB332178D2087864A88801CA6EE85F0@SG2PR02MB3321.apcprd02.prod.outlook.com>
x-forefront-prvs: 09888BC01D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(366004)(396003)(376002)(39850400004)(346002)(189003)(199004)(186003)(5660300002)(486006)(6116002)(105586002)(3846002)(52536014)(6436002)(66574012)(8936002)(86362001)(26005)(102836004)(305945005)(7736002)(55236004)(6506007)(66066001)(25786009)(81156014)(8676002)(81166006)(55016002)(74316002)(7696005)(110136005)(14444005)(316002)(14454004)(68736007)(256004)(478600001)(53936002)(2906002)(9686003)(78486014)(33656002)(476003)(5024004)(2501003)(97736004)(106356001)(71190400001)(71200400001)(44832011)(99286004);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB3321;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 WFNt4OYHVwknG3Rntm4VSnvUp4WIJRNqUj9+1ZsLgLQzCP4ZmTvYc4k/h31T4EHz1nDLweqxOE1q73tEu7jonSp1jDnwalQAbqNYBWODVnr6bUyOhpNpgy//vGAPXkFp/xmf7tpvw6sqgcTzAp8C0spS9rwyeJuvQd88gp+rfBHFD8n4oOmz2mfzlqBaHgMq6kjAPVYr1FgMteiyiHTDJk7Ffor6ksz94NShWQR7Ycv/AUkIm1LhB54O7LhvCg2TgCXIB6I9oq/l+XM67Nj7Fj6KnB92E/HELo6q9hwZ0EuZAmFGgIxU7M9VlTQpUcQxML6MA9jv3BkHk0Llk0pUXGCVy9aJJ/uGoWmbKjEaFA8DZTHp9RVEzPn60H9JOgw/H4fC9Z9LjDkWXdL0gMOatbiZigxbFyVhnzxRetsdsT0=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 70c8df0c-9ad4-4d31-83f9-08d6b1c5d809
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Mar 2019 08:34:20.8888
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB3321
X-Bogosity: Ham, tests=bogofilter, spamicity=0.002268, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

1. Is there any way to print whole physical and virtual memory map in kerne=
l/user space ?

2. Is there any way to print map of cma area reserved memory and movable pa=
ges of cma area.

3. Is there any way to know who pinned the pages from cma reserved area ?


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

