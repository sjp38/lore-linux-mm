Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97FD6C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 07:56:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56F8620857
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 07:56:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="fu257IWz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56F8620857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E66F46B0008; Mon,  1 Apr 2019 03:56:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEE786B000A; Mon,  1 Apr 2019 03:56:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C69446B000C; Mon,  1 Apr 2019 03:56:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 888AA6B0008
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 03:56:25 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g83so6676851pfd.3
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 00:56:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=LYzMQyAhasE0Q2EE9k+wuIbZo9QNt5Qwmj9eKemqg2Q=;
        b=DaOVOCKTWA6bVDOHVzeAiXYmZk0BnRGJn6/sGxdQqt80F0veD2UoRmNohAuQb8Fsyl
         wGAT1sb5fV5OYXgBndrUM0wIOcRosAPwJGUXrwfGaI4xZr+mlfJXmul+G3w8Hh/m3iSg
         CkwIl5vNrE0V1Fs2OU3cIP0E5pSQkSnUaplHM3H9dvepr1SAjGWO8Tp5bnE+Z6Z/UaPM
         HfCWXFoMfNvmkH3/QYhG3vifYLasjfrTn0Fbsu31ceBhdtQrs0PvBEF9nNqb3TKEdDXX
         eVtaTbqyS0bBgCgGmYtcBo/LLeC6Yz9jhXphWUjQfHNDjF2aUMBCQ32VIyIDgNTIpGO8
         B5fw==
X-Gm-Message-State: APjAAAXAHmCtrlwvYgBugE9mjpzqdsXqMPD3WFP7dtL6p9UQKr/XNA1V
	dqJZZ+vVxBSHZur95GAuQ868AleDEauO5GzsRYshwtxpSqdQCNVTzjbFBrs6vTvcMtvQIKtVNBb
	l1MBAYARIbKms4oLXBD4a3/P/2JZVFeeXicD8mvfjSYOl0GEkJQbXac7MeWt1HXUD1Q==
X-Received: by 2002:a63:c06:: with SMTP id b6mr59634037pgl.440.1554105385165;
        Mon, 01 Apr 2019 00:56:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWzgofMkGB+aiQltCvmJsFGUOBp0UxklcWvxT1F8GnYIDiBrLNmJlKP1KNepKf4Z10wPa4
X-Received: by 2002:a63:c06:: with SMTP id b6mr59633999pgl.440.1554105384443;
        Mon, 01 Apr 2019 00:56:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554105384; cv=none;
        d=google.com; s=arc-20160816;
        b=REYVyHSA+X0mT8pMDskJoF+LwMYRy5L5iDIq+xgKafnBgiKXR0SJPMZuFApMQZqMS1
         2e7QOmq7xKLJXvvFmWZuT9eFFgWIVTsR+49lmbx3m+ILInOaqpP6M26+i0tFyz+otEQw
         Wg3P3oVRKzMqLmVFe4wVAPkKOd/eweIqAdoXnS5G990dWc4L9hGF8Bm3YzF+GBSgsw2q
         aswDFZFRYK4BFb7vRGB7lKcjh2kcFvW/mWbI7B3cxBlg6AdKFYVDQGHwlL0GJqUwAa9W
         GxK1VkQk5DPsFuM617Y8Gtbbqf8l1lwyk9O09fgtIXxq3tHK2HD/5cYH3CZcgxLvx1O5
         /GnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :to:from:dkim-signature;
        bh=LYzMQyAhasE0Q2EE9k+wuIbZo9QNt5Qwmj9eKemqg2Q=;
        b=uZZnoXMG2A7OTKwOs8dlrJqLwJC11jI5F6WXLGCbYFwA1x+KfAvwiFjOcJo5XFBK5q
         e3nsxuqJt6bM1Kp8DqXtu/koZu+K12UhF60zv84QRTiOdkzQNoEJ+dNIEtcHdwGVKUzD
         Gh7z3e90eTij1Geb8+IkjxTjmJQaB3h7RgMEuN2p9Ihu05pye6qfKDwQZO5RCN0mSs/d
         P66kVD1n8H95hhJ+gSrj732/+sFrH+32HpP04/uZs83Ye+ANewiBy+tgij/LMJk+xJYz
         XEAuNzkA8/yDIlKBpHwpE3j7uk484tithe7etCfh+ryePpHyA9+9WsqqV/M7oigEFSt+
         AM1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=fu257IWz;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.49 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-SG2-obe.outbound.protection.outlook.com (mail-eopbgr1310049.outbound.protection.outlook.com. [40.107.131.49])
        by mx.google.com with ESMTPS id m16si5372786pls.150.2019.04.01.00.56.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 00:56:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.49 as permitted sender) client-ip=40.107.131.49;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=fu257IWz;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.49 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=LYzMQyAhasE0Q2EE9k+wuIbZo9QNt5Qwmj9eKemqg2Q=;
 b=fu257IWzaYjElFdZWx14YVvZCid8fR0BT0r50IOozhVKYWTEBBwwif2jgZL+3xbP6sly7BGutJL29dHbUavnCCO1PijxOCXKjmnAl8Bmn87lS+dF4gd6awyFBT2zH+NlptSefDDbhnzaZhAYX/1t25iiZ8trBHixx+8RzBXMkwQ=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB3800.apcprd02.prod.outlook.com (20.177.170.202) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1750.15; Mon, 1 Apr 2019 07:56:21 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1750.017; Mon, 1 Apr 2019
 07:56:21 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: CMA area pages information
Thread-Topic: CMA area pages information
Thread-Index: AQHU6GA9RylraT4uwk+04/PdjD+qFg==
Date: Mon, 1 Apr 2019 07:56:21 +0000
Message-ID:
 <SG2PR02MB30986806577CDA3F568553B6E8550@SG2PR02MB3098.apcprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 577af18c-ac62-4bb6-b688-08d6b67787b8
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600139)(711020)(4605104)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB3800;
x-ms-traffictypediagnostic: SG2PR02MB3800:
x-microsoft-antispam-prvs:
 <SG2PR02MB3800A83B5C0237FE40076143E8550@SG2PR02MB3800.apcprd02.prod.outlook.com>
x-forefront-prvs: 0994F5E0C5
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(346002)(366004)(136003)(39840400004)(376002)(189003)(199004)(25786009)(3480700005)(478600001)(14454004)(486006)(81156014)(81166006)(5660300002)(86362001)(8676002)(186003)(7736002)(6116002)(52536014)(66066001)(74316002)(33656002)(2906002)(6436002)(106356001)(55016002)(9686003)(476003)(55236004)(102836004)(68736007)(26005)(53936002)(3846002)(110136005)(7696005)(6506007)(8936002)(316002)(2501003)(305945005)(97736004)(105586002)(71190400001)(99286004)(71200400001)(256004)(14444005)(5024004)(44832011)(66574012)(78486014);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB3800;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 apC02R6Y7AZkWJ+7rOENAjEqxNb041Yq7vW7Nyw9ihtrVE0DGBk/rGQjYToFai8iPPvp4Yv1Wx+8z4ux0d9WsYsq48YuaathoS0ZlMBTdUsscDaQTkBKdn/IMfE4FQIMUITTgPXFdrne5bfeIvguH/oKv8oR/vgtibdJg6FGQFOyjb6CEs1rgdT60p66clTFnZMRXY2HFzU8qz2JyRkcRFvmQsY1F58XjR509rIRkNh1N//+RbZbfjKDv5Lm7R40cS6cGR3iB5T81BzF56Jf3MvltTNGA+sscQxj4BX3sGW6wR6jm1DOlalMB8F78BWNzSazAD2XkMrHzyhtomXHFxlDW4nuziOWqBb9D5jyFtutA2wROjkZjL0AVElWQz3nj63zQcNcT6P20eDioTEBgrnKFMRYXaR2//AmpAqpkXw=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 577af18c-ac62-4bb6-b688-08d6b67787b8
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Apr 2019 07:56:21.2916
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB3800
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000566, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

Is there any way to get CMA area pages information (tool/application) ?

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

