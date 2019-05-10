Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0EF1C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:32:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76CDE208C3
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:32:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76CDE208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hpe.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0527D6B0003; Fri, 10 May 2019 12:32:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F20186B0005; Fri, 10 May 2019 12:32:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D70E56B0006; Fri, 10 May 2019 12:32:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 99F9A6B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 12:32:42 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q18so3973817pll.16
        for <linux-mm@kvack.org>; Fri, 10 May 2019 09:32:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=jxvMH3uSEwoYpZ1EixCMUS28qGLJj1DGZGlSfHfKlt4=;
        b=g3V3mwYe8geSlETT3MdiTLwp1p0tCoj760yc/bBwaMwZwmJTOL9OVbyY2z2teHbLYU
         z2F2es1+IKjVYY9OJP6apsOES3woT80eTJKONlmk0Ti0bhB/VeC1M0QBWKRvZms44Tk3
         fOquTvUyZVHl5jrJ1RwdxQRXWmWjni3khiVVFM/HusdMJybxW1X1+nFgxJMUQ6us5ykV
         kZ2N6RzLxmhMaCczOVpsbALcbFZC6PaMbUjs8itq5ouUbKh6AFE55AnkuTgxsHN5BGQd
         tj/B7SkUG/gtDkSYR6z5V1O63b7oRR0bZW0MVVI5/ZO60LV/BoJy2bqXyaD6lmwRYuXq
         FJEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of elliott@hpe.com designates 148.163.147.86 as permitted sender) smtp.mailfrom=elliott@hpe.com
X-Gm-Message-State: APjAAAWEYwe85gU1abV58QWG0HZUA0l8Dojh+uTd6BxquMv1Hty76XdP
	YRIy5jumm51QSCgpo8ffjfziOuXGpnKHQdaIeCDeFoFaIVIxUbpn8Kh8iw5CY8pidbI5WBvu1Hf
	LBiCQ2pzD+r0ZhRGj7GfC8jWs6LGZ4xR42vc9rS0IQE4cAEQ+BymBNFqaPkvW+Mrq4Q==
X-Received: by 2002:a17:902:9884:: with SMTP id s4mr14708457plp.179.1557505962084;
        Fri, 10 May 2019 09:32:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznhX+53LeCfVS6JjFbLiKTSgQt8d6vB0lNK/8mAP/cXmumehxC90gzxuCPBcwlHmObhU4c
X-Received: by 2002:a17:902:9884:: with SMTP id s4mr14708382plp.179.1557505961492;
        Fri, 10 May 2019 09:32:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557505961; cv=none;
        d=google.com; s=arc-20160816;
        b=UpR6/4rnVsWIkv0qiIXqwz6ifENFcVfEZWc1bYwNXZMAd0NQiXxcBEiQ+s4TD/DRou
         wrirFrhBjVIwk1TFeaYAXMOu/aRRLij9izdHdRWkAFgKSNYfhxHV2rboCyQ2k+BRBh0E
         6WyvW/jJ5Vj4CDtFkKib0uyyWJpupAvhKJEbNc63JfDLMgf6Y42tPusmhqigif4WHgGR
         kQWzbprruKpndSeRt+hgJgzmqwLvTnQ9DkuACYaRkal/XARCSObJmAKQ6YtgvfWt7OSy
         z61k9eDE+6GCC8A5pOtdKuXxhJbzP4NomknM/l2eI+5Z5au1c6m1B3iICddBZEvBgnxm
         S36A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:to:from;
        bh=jxvMH3uSEwoYpZ1EixCMUS28qGLJj1DGZGlSfHfKlt4=;
        b=iXlp5J1AOYFfA3nMzr3mnUxnKR3vrQyjo2Goc4DDX+zrZe+UtevBC8xqfD2VBQ9PZx
         NSCwZ3kZyXLyHOOOwjWbYYoiaPyF9WIWjZxK6e6W+ZnEz4c81OD0h7N8YNJGIA32CSSU
         OyKO2OWIpyIFNMDrIT8iVTFaPg/zcxpo3XvUgJ9HTBicttbbss/N0PxcIFjHIQ3jSIXd
         +3tZZy5Q1o/CXaIuLY7hICB71kXv3XmBwiXVGiWs3zGuBWZSIgo5xwj86UbHLx2xz5zA
         zmlk8MrHXlQc4hDjA/znIK69hTyIM47+oA8+fZdkDXjaihEohHne0J3mbS+bYT8Tqxhk
         AxKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of elliott@hpe.com designates 148.163.147.86 as permitted sender) smtp.mailfrom=elliott@hpe.com
Received: from mx0a-002e3701.pphosted.com (mx0a-002e3701.pphosted.com. [148.163.147.86])
        by mx.google.com with ESMTPS id 1si8098469pgp.57.2019.05.10.09.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 09:32:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of elliott@hpe.com designates 148.163.147.86 as permitted sender) client-ip=148.163.147.86;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of elliott@hpe.com designates 148.163.147.86 as permitted sender) smtp.mailfrom=elliott@hpe.com
Received: from pps.filterd (m0134421.ppops.net [127.0.0.1])
	by mx0b-002e3701.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4AGKtiK010000;
	Fri, 10 May 2019 16:32:31 GMT
Received: from g4t3426.houston.hpe.com (g4t3426.houston.hpe.com [15.241.140.75])
	by mx0b-002e3701.pphosted.com with ESMTP id 2sdb13gtqj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Fri, 10 May 2019 16:32:31 +0000
Received: from G1W8106.americas.hpqcorp.net (g1w8106.austin.hp.com [16.193.72.61])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
	(No client certificate requested)
	by g4t3426.houston.hpe.com (Postfix) with ESMTPS id 85BD45C;
	Fri, 10 May 2019 16:32:30 +0000 (UTC)
Received: from G9W9209.americas.hpqcorp.net (16.220.66.156) by
 G1W8106.americas.hpqcorp.net (16.193.72.61) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Fri, 10 May 2019 16:32:29 +0000
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (15.241.52.10) by
 G9W9209.americas.hpqcorp.net (16.220.66.156) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3 via Frontend Transport; Fri, 10 May 2019 16:32:28 +0000
Received: from AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM (10.169.7.147) by
 AT5PR8401MB0785.NAMPRD84.PROD.OUTLOOK.COM (10.169.7.8) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1878.22; Fri, 10 May 2019 16:32:26 +0000
Received: from AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM
 ([fe80::2884:44eb:25bf:b376]) by AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM
 ([fe80::2884:44eb:25bf:b376%12]) with mapi id 15.20.1878.022; Fri, 10 May
 2019 16:32:26 +0000
From: "Elliott, Robert (Servers)" <elliott@hpe.com>
To: Larry Bassel <larry.bassel@oracle.com>,
        "mike.kravetz@oracle.com"
	<mike.kravetz@oracle.com>,
        "willy@infradead.org" <willy@infradead.org>,
        "dan.j.williams@intel.com" <dan.j.williams@intel.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        "linux-nvdimm@lists.01.org"
	<linux-nvdimm@lists.01.org>
Subject: RE: [PATCH, RFC 1/2] Add config option to enable FS/DAX PMD sharing
Thread-Topic: [PATCH, RFC 1/2] Add config option to enable FS/DAX PMD sharing
Thread-Index: AQHVBoGeTmkAemjoekib1TYYWlBJqqZkjkrQ
Date: Fri, 10 May 2019 16:32:26 +0000
Message-ID: <AT5PR8401MB116928031D52A318F04A2819AB0C0@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
References: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
 <1557417933-15701-2-git-send-email-larry.bassel@oracle.com>
In-Reply-To: <1557417933-15701-2-git-send-email-larry.bassel@oracle.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [2601:2c3:877f:e23c:eda6:b2df:f285:610b]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f23d3430-588f-45c8-b52f-08d6d56516c2
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:AT5PR8401MB0785;
x-ms-traffictypediagnostic: AT5PR8401MB0785:
x-microsoft-antispam-prvs: <AT5PR8401MB0785C368E342B5E9436A2BF1AB0C0@AT5PR8401MB0785.NAMPRD84.PROD.OUTLOOK.COM>
x-ms-oob-tlc-oobclassifiers: OLM:6108;
x-forefront-prvs: 0033AAD26D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(376002)(366004)(39860400002)(136003)(346002)(199004)(189003)(13464003)(74316002)(52536014)(46003)(186003)(110136005)(86362001)(2201001)(229853002)(66446008)(66946007)(55016002)(64756008)(66556008)(66476007)(478600001)(4744005)(5660300002)(6436002)(9686003)(316002)(73956011)(76116006)(14454004)(81166006)(256004)(81156014)(33656002)(25786009)(2501003)(8936002)(446003)(8676002)(99286004)(68736007)(71190400001)(71200400001)(53936002)(6246003)(305945005)(2906002)(102836004)(476003)(11346002)(6116002)(7696005)(76176011)(7736002)(6506007)(53546011)(486006);DIR:OUT;SFP:1102;SCL:1;SRVR:AT5PR8401MB0785;H:AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hpe.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: G+l2Qd5ZRkoUmswyYI5tPsZbCdBjUhRZaUOeI0i2AEi6Y+GYPvwtbwcVSZHqdGmqFFoP+JnzYf30hBYwtnWRp7qBsIqUTl/29EdT0gGkqspTEcMLIrUx5dsUfESKDZuJrkLdZBvWMcG2HMIinoZVS4oUrsC83/yzRnCuCFtLmAPzoYFrLCUPhJD32E064t25XAUFX3IeUd0iNncfbY4JaegUvA+VkexB0CGaUG3Up083wTTtvoGhcH7rwoaxBX/6ayYCif1WBt/dTpCPHVkjMRHklmp+5+2tpT9LWQj5vp0Nxj1KcwR2XyW5ItIN1qiYXuFz3jnXXhlyVbFhkP78zrnPwacNQUabjUt1tYg4yPYyj4ACjLANuxlzwANVYGEmXIOv6h5TD+hillrAEWJBO/kGWHnd4uxAv7bc4+Se0mw=
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: f23d3430-588f-45c8-b52f-08d6d56516c2
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 May 2019 16:32:26.8565
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 105b2061-b669-4b31-92ac-24d304d195dc
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AT5PR8401MB0785
X-OriginatorOrg: hpe.com
X-HPE-SCL: -1
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-09_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905100111
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> -----Original Message-----
> From: Linux-nvdimm <linux-nvdimm-bounces@lists.01.org> On Behalf Of
> Larry Bassel
> Sent: Thursday, May 09, 2019 11:06 AM
> Subject: [PATCH, RFC 1/2] Add config option to enable FS/DAX PMD
> sharing
>=20
> If enabled, sharing of FS/DAX PMDs will be attempted.
>=20
...
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
...
>=20
> +config MAY_SHARE_FSDAX_PMD
> +	def_bool y
> +

Is a config option really necessary - is there any reason to
not choose to do this?



