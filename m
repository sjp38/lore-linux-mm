Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BBFCC10F00
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 09:49:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21DB221872
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 09:49:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="C5VOnOD9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21DB221872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 782C86B0279; Fri, 15 Mar 2019 05:49:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 732426B027A; Fri, 15 Mar 2019 05:49:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F9206B027B; Fri, 15 Mar 2019 05:49:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3387B6B0279
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 05:49:33 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id o66so10984681ywc.3
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 02:49:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=3xSobpf67/du1W5ZrjDfdhkHwfuTUiTkG0DJVu2WwlU=;
        b=F+Op5IR5kl/r4rntdgd8fZYrx2KoL3fVlRH3neu1yzDXJxGm4v8eoMQvXOThkMTbZe
         CbEU0aIcfqQVoS46+w0IYkpbLHGfdHpaTxeIyAmQZd8BJsDDhYmdxEkB9UASaNiOBBT1
         HsxfIiFqzrv7OFgmOBTKKFyCLLC2mHF3iiQaXr4yc13muHtrUvuG+V7ONUq69NDxw6Xb
         MfdeW96T35sEnBoloe2CrV+F9t3/aClgfoszMAiWxHOiYXG+TrffDZFrtFtI7LCnuCOq
         fgQyazgWJvuqyPUQh+vqSbTH6YJtZpGp+nghicsQ3EDYuOPd2cJNPDqusG9zdwVqvT5O
         LkCg==
X-Gm-Message-State: APjAAAXj+M0KoI9eYL2yMsDqV9z1X2E4uBJCpJAKoALLz8rCLO24ZTCu
	8a1Gn1kW25K+2yF2lIXTgM1iCSn+KNDXUD3zC4x0GYGHGy55uzOAjsTbn1BTnLbXGijlTPdUVO9
	NR5Y1E2H7g93opB2LhxtwgxN8wnviwnDn1TPYna5q06+mloAgeLhz2DZK0YJeGLvKQA==
X-Received: by 2002:a81:2446:: with SMTP id k67mr1892644ywk.504.1552643372917;
        Fri, 15 Mar 2019 02:49:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdUtPLNi6zGgeSo8hV/xo92F9+6Q3i7Pep4ccSdtyr7XsieTviNpCr72g+LtSijbG5gS64
X-Received: by 2002:a81:2446:: with SMTP id k67mr1892581ywk.504.1552643371689;
        Fri, 15 Mar 2019 02:49:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552643371; cv=none;
        d=google.com; s=arc-20160816;
        b=tIfIfc3Ridn4mmL47g80zq0e0u6xVTCxgM57hTzPj/xK4shWAVmwyGakf1YS9IuLBT
         +TpzIrOkKATkhqIEKpT4Unevbzcjnv4jNDZT7fyXZyNFjFEQUDTfAqRH9aZtVfXAtByv
         ZbnSokVSavX2uAVyMGWCYp+pR9xRUHK6YOsDBsENxkVb/QKzoSdpKIVnu9vaE9hYZ4sE
         Faal0OnEiFdt66vAdDAmcbUe5PQhQKbMr1K53M9W2W2GIHuJcyXUn16Pz9N7I3lp/wa9
         +x83WzFPrG72M+zX0/F7jYizPJL4/QdjWTLbmYNcULLfB0igr9UlS9x/O+rhqGH+5EkS
         Zxpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=3xSobpf67/du1W5ZrjDfdhkHwfuTUiTkG0DJVu2WwlU=;
        b=dqAgPh5cHvx6xH/+qMEfkUFMEImEKInUFm+w9EMW98nMnuITUs1Zl9q7dA9TRmr2Js
         DYhZIiYnTKJtK7aaoHNbOdUyBdv/nlECZ5Sm0LNy10xqqxC30nRVRemhmHAh/t46BFm/
         WE3GAIL9ibOijt44Sk84WxB0TTad5NBcWlbBL+QdY50k3v2HlvhsrNvZp04Cday1ifjO
         fOdj19I72RR8rrDWSK91oV3o6RQ0CCYkj0JG3zbl64djrmvlutvtPnYlrJp5HfTuyf2f
         O7F9ftfw2KksHOqEc9DqG9FXMYakmZpoYhFHKU99OqummwkORUdULP3huDQivGvUz8qs
         Z5+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=C5VOnOD9;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.84 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-PU1-obe.outbound.protection.outlook.com (mail-eopbgr1320084.outbound.protection.outlook.com. [40.107.132.84])
        by mx.google.com with ESMTPS id b194si919635ywh.300.2019.03.15.02.49.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 15 Mar 2019 02:49:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.84 as permitted sender) client-ip=40.107.132.84;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=C5VOnOD9;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.84 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=3xSobpf67/du1W5ZrjDfdhkHwfuTUiTkG0DJVu2WwlU=;
 b=C5VOnOD9fv4mhP78ncmEtApBBCODuj5QC7OA8l+IaX3t7RfOytkEV4RWyXz8qvBDaBZKQXn8VNWESImVBz2lp9JRZvrQzLV1XMczWT+o6BGGc/J/x1f8o8jqsj1uYIPMHDCVCwTyF5mGzWDGKJDhjK6eTfjZCkYNOy+YTKjcaoU=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB4171.apcprd02.prod.outlook.com (20.178.158.84) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.13; Fri, 15 Mar 2019 09:49:26 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::3180:828f:84bc:ea3]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::3180:828f:84bc:ea3%4]) with mapi id 15.20.1686.021; Fri, 15 Mar 2019
 09:49:26 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
CC: "minchan@kernel.org" <minchan@kernel.org>, Michal Hocko
	<mhocko@kernel.org>
Subject: High Latency of CMA allocation
Thread-Topic: High Latency of CMA allocation
Thread-Index: AQHU2xLZ1UQoU59DckqzS9+63pBkgg==
Date: Fri, 15 Mar 2019 09:49:26 +0000
Message-ID:
 <SG2PR02MB30984EA8472065757E5F32F7E8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: af77d70b-5fd2-4baf-58bf-08d6a92b831e
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB4171;
x-ms-traffictypediagnostic: SG2PR02MB4171:|SG2PR02MB4171:
x-microsoft-antispam-prvs:
 <SG2PR02MB4171B2FA5B59B2F85E7DD4F8E8440@SG2PR02MB4171.apcprd02.prod.outlook.com>
x-forefront-prvs: 09778E995A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(346002)(366004)(396003)(39850400004)(136003)(189003)(199004)(110136005)(71200400001)(478600001)(68736007)(105586002)(14454004)(78486014)(256004)(44832011)(476003)(14444005)(5024004)(3846002)(6116002)(106356001)(71190400001)(33656002)(25786009)(86362001)(4326008)(486006)(102836004)(8676002)(74316002)(97736004)(53936002)(6436002)(2501003)(9686003)(81156014)(8936002)(66574012)(26005)(55016002)(7696005)(316002)(186003)(5660300002)(2906002)(66066001)(99286004)(7736002)(305945005)(81166006)(54906003)(52536014)(6506007)(55236004);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB4171;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 p1EZh44X1rgyMmVxLJFrCW/7pdOrKIXiMmq6P8ZswEG14sVp3Y2zXe3JDxweXevo/YyYscdV/ZPbqbffxDIiDppm/BfOVznvCTsSfH0xfDhuNO9xbtFiHgDwhF3nQqH1fxMK8ZoqFlp3lo0NSLAPCFnu9UlYTLBhKyvN0G+0n9saeYXoWOw2qibTwRYA2ujDCTT+6B1oCd5KD1kOyYXUKO3PkyhfSDNgkcpbhBZ1LOK32v74B1o0OR7tkXAXpTApfklmYC1ZN0AEtho3Wbohsk8o4Zf0pgNkpRj6QfwumycXKLdNRMSRLTjmysLX+Xee5LUBdK0acmltOm+RwtbfLnlL6SQyAJIfa8r0eGIt/e2yNsvhzgphdXCF9/yuiswzgg3qDRWhfGMs15BZKC8Gnyt8r7xhbiwVo2OQCejFGAw=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: af77d70b-5fd2-4baf-58bf-08d6a92b831e
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Mar 2019 09:49:26.5514
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB4171
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000019, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I am facing issue of high latency in CMA allocation of large size buffer .

I am frequently allocating/deallocation CMA memory, but latency of allocati=
on is very high.

Below are the stat for allocation/deallocation latency issue.

(389120 kB),  latency 29997 us
(389120 kB),  latency 22957 us
(389120 kB),  latency 25735 us
(389120 kB),  latency 12736 us
(389120 kB),  latency 26009 us
(389120 kB),  latency 18058 us
(389120 kB),  latency 27997 us
(16 kB),  latency 560 us
(256 kB),  latency 280 us
(4 kB), latency 311 us

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

