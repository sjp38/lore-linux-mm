Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AB50C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:09:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8E47208C3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:09:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="ZaSXeobN";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="NIYNJDV2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8E47208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DFE88E0005; Fri, 21 Jun 2019 10:09:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 791038E0001; Fri, 21 Jun 2019 10:09:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 658CD8E0005; Fri, 21 Jun 2019 10:09:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA568E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 10:09:41 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x3so4145116pgp.8
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 07:09:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=4zRHIq7iZporpwt9Mv54C1I/opmwoTyPXs8GekB+jtg=;
        b=maYCOiQhmF7yzSV74mAoZAHnqm2ZJnbr1gkXQCbd+QcThnaWdVMjgMscNrC966/bOP
         5wWinBBOugv9eERfJAQquxrfV9veEIWUv0sMPFPM8i3ZkmunV/c2XmnUjVbFC1tY2kMG
         /04jieVOdzcMKOLXuTbrWFmUTDorowPs2tJ+LJy1DESL9HsRmE/C9qpih4keQ18pQ8ym
         s/6gcDvz2ynv4sdU31bzkVNkfduy9OfF2b0lU7At4LoX72fO4ITE+CLTAZOgQoBrS9X9
         ic1XQeFB28tKiaBqHyuILBRDsWTGug3qyqghieFJRdG9gPThR71OijYEq0DB+dCeOoHu
         GlVw==
X-Gm-Message-State: APjAAAXNEkGDBKDwlC9JBXS9FZ0aWSZ5SSM1U0C944Zzx/oEjceO16s6
	nVdFrxkuPeqUEG3sEpnKe50RnHAxuYAg3b0kqFrP3ztdtzVt2L9mgiwp92+WdzUryEDC7N4Z9gx
	Zh4GzfuoZgiGYVH1H/z/lleQkjgTDwkREJVP1vlZ7U0oUkUmAyTa2UggQsjjXjfPJvQ==
X-Received: by 2002:a17:90a:2008:: with SMTP id n8mr6842880pjc.4.1561126180818;
        Fri, 21 Jun 2019 07:09:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZOOF8aDHnmrlZ425dJaQpvE1SPPSHpw79yi74uPlvMVZyuiqWnn1SE3aM92SZv3X7ZnYa
X-Received: by 2002:a17:90a:2008:: with SMTP id n8mr6842820pjc.4.1561126180215;
        Fri, 21 Jun 2019 07:09:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561126180; cv=none;
        d=google.com; s=arc-20160816;
        b=vIXNyRfkC/su3m0S/Q22qRuFaMKO8GLWgARKiM0le5URDE8+xBXYQQPp3ojAT8mW1/
         2K6GIDjgzqbubtuIyfjyx0VR2kSGgMY9deO4n2Hs9RrC/VV1EmS9DrLLW0cn1TYTdibe
         4S6jH5jzw18UwDmeY+O+qZT0OjGsEq2Y+NgnIxZ+0qhGVvtqaFtbdRBvK00J++HnvBf5
         I8Sro1CAjXQZKwK3GCewA6RcAn6OLxbP6Eagxe+8ZdMAK19KeoKWq7hjecLMQpyh4enC
         pw+0ZbEN2b+WxcXOYiU0ocvp/D8y+Lk6FCHVUlkPZXXwB6TFO20iJjQcZHsXbxoMLmLf
         GDUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=4zRHIq7iZporpwt9Mv54C1I/opmwoTyPXs8GekB+jtg=;
        b=aIK/VWiocr2yrECowYvj6IwR0JW/PUTXCDbY/B29+9Oo8T4MIjAmpixnofwkF286YV
         8XOj/nUEkeFNmUoKSovCYzhwPJxi9lZZ2yDbnBMR4lcHINUuCGUek4fL4xkBRcfS6uzS
         bRv7veW34ZbYphdlYNhlN/gnZJajcXDi6TFgN2/0BZZppzNtDtiYQJs/CTjpSfsp5np8
         TtiHXHiL8ZvB0IBakhOx6du8yc5PoZyTC3SyqlOhp00Z3ZaeDDXVs+hEVtNpRm8sz7yB
         sbOYeBX+gt6fhtJ2V+VNsLC4uCuKA/3GXLnIujT51POCYYPhzpTg3vVKWKzbNIBTiAgX
         lsfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ZaSXeobN;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=NIYNJDV2;
       spf=pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10751dd214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id g9si2695743plp.13.2019.06.21.07.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 07:09:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ZaSXeobN;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=NIYNJDV2;
       spf=pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10751dd214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5LE3mah012293;
	Fri, 21 Jun 2019 07:09:39 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=4zRHIq7iZporpwt9Mv54C1I/opmwoTyPXs8GekB+jtg=;
 b=ZaSXeobNIKGfMCaNDzmVPGdCvngPTs8bIQIpSS+RHao62KSU1ypsoUXDmtRfdj4rGUb5
 mkrYtsUlMRSD21WoCnGICsVmlYJXZ+An7atM6xecUf8OMqhwNteLkWbOMW2MdLceAP/G
 cux/0yuMYodO0/ELUj37TuPexFxRNUVzStc= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t8tpth6sp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Fri, 21 Jun 2019 07:09:39 -0700
Received: from ash-exhub203.TheFacebook.com (2620:10d:c0a8:83::5) by
 ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 21 Jun 2019 07:09:38 -0700
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Fri, 21 Jun 2019 07:09:38 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4zRHIq7iZporpwt9Mv54C1I/opmwoTyPXs8GekB+jtg=;
 b=NIYNJDV2qDDAWwn1BG4QmPju4GblgAc7ei1wosivusX3Dc54yY2FL/sAdtY6RFte6EGBzkHsdZau+YJWlfCT1Zg+/SBaUsGE25S4QA+087mk3RBvo52XX1P7Bc/2enj5BY1kXM08JH8R91O3g8pq89ucinKRNBy9QA4HbWueI+4=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1373.namprd15.prod.outlook.com (10.173.233.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.12; Fri, 21 Jun 2019 14:09:36 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.014; Fri, 21 Jun 2019
 14:09:36 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: Linux-MM <linux-mm@kvack.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "chad.mynhier@oracle.com" <chad.mynhier@oracle.com>,
        "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>
Subject: Re: [PATCH v2 2/3] mm,thp: stats for file backed THP
Thread-Topic: [PATCH v2 2/3] mm,thp: stats for file backed THP
Thread-Index: AQHVIt4miVueYeg2BEu7pHE3XHmsBKamGhsAgAAWEgA=
Date: Fri, 21 Jun 2019 14:09:36 +0000
Message-ID: <8C37677C-1B9E-458B-BDCE-3861ACAE6F4B@fb.com>
References: <20190614182204.2673660-1-songliubraving@fb.com>
 <20190614182204.2673660-3-songliubraving@fb.com>
 <20190621125036.yf4yjqolu3bx77wt@box>
In-Reply-To: <20190621125036.yf4yjqolu3bx77wt@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:ed23]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0a059d97-57f3-4cb7-4b0e-08d6f65217e8
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1373;
x-ms-traffictypediagnostic: MWHPR15MB1373:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <MWHPR15MB1373543C7BD090375BB72F2CB3E70@MWHPR15MB1373.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:229;
x-forefront-prvs: 0075CB064E
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(366004)(346002)(39860400002)(376002)(136003)(199004)(189003)(51914003)(50226002)(476003)(53546011)(6506007)(11346002)(446003)(486006)(102836004)(186003)(64756008)(14454004)(66476007)(76116006)(76176011)(46003)(25786009)(66556008)(66446008)(2616005)(316002)(8936002)(36756003)(478600001)(6246003)(73956011)(86362001)(4326008)(5660300002)(99286004)(6436002)(229853002)(66946007)(6512007)(6306002)(6486002)(81166006)(81156014)(8676002)(256004)(33656002)(4744005)(6916009)(53936002)(6116002)(966005)(54906003)(68736007)(305945005)(57306001)(7736002)(2906002)(71190400001)(71200400001)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1373;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 11W616OU/hn+CG776tnPFakLC3ZaiIdD+aMIIGRgaqQ6WtZyb6mRgiJvwYYJSvRs4yfrPChMsVguYjRvHNaENgpYLD6ElNKAW+Hyw4U+s8VeCTlNOB4z60njkb/6woQUnmhGeZK5Q1smwtJsZROAVD+ESA3j0Rsz9koAUCxKnLzcVw8KZihfsZ1XZYNirMtpWOq3Mxyz/geznTZH7/viZEIIddJVgBNWfBVwPwNmGHIk6lXxLpSxgFXq4VDObFrbPFefM4wUZNJb51zYuiN9/tWkEyF0TZr9rQdz75xpidlRGVDbAl8PKBAG0VlUgKFOEOQQnirwk+WbdMckK8YaVDB9MVeaXRcjqOoZpWb8R1W8ZP1LF4x0WZR3py6tfLrhIdDE/rKwly9wYnDxMlW7T5cfiNfPQ+mGuY6HUOi9l2w=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2A6973D0274C2E46AE5C8C003B2A9614@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 0a059d97-57f3-4cb7-4b0e-08d6f65217e8
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Jun 2019 14:09:36.7243
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1373
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=887 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210118
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 21, 2019, at 5:50 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Fri, Jun 14, 2019 at 11:22:03AM -0700, Song Liu wrote:
>> In preparation for non-shmem THP, this patch adds two stats and exposes
>> them in /proc/meminfo
>>=20
>> Signed-off-by: Song Liu <songliubraving@fb.com>
>=20
> I think you also need to cover smaps.
>=20
> See my old patch for refernece:
>=20
> https://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git/commit/?h=
=3Dhugeext4/v6&id=3De629d1c4f9200c16bd7b4b02e8016d020c0869cb
>=20
Thanks for the reference!

Adding the fix.=20

Thanks,
Song

