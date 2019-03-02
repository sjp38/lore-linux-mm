Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AB5DC43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 22:19:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D29B120863
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 22:19:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="HZKdj7AG";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="F84eWWKr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D29B120863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 713A08E0003; Sat,  2 Mar 2019 17:19:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C1848E0001; Sat,  2 Mar 2019 17:19:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53B318E0003; Sat,  2 Mar 2019 17:19:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B03A8E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 17:19:16 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 23so1210587pfj.18
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 14:19:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:mime-version;
        bh=rNOtDNLOFh5Se4jmWFXlyXJ4HvwxpyGO0EgxHsDdrpY=;
        b=D1+kTopAtyF2ojLF0XZvi9IsAHNoySqX/SqbcB+h8yO6Yh51yfqznGPs1jqiJL8YH3
         4KI4V9wqIKU7HhBmUzbQUwXzW1zMp1XL9DJ/V1lLXG+hHtLn/AlCy/Lz1QmoGWDMUTBs
         jGviU7RlM9b8o5B05k9+3s+BMXhLzAxg4YlY3xrQZHU7fSTJMHAy+Dy80n9/x248/p0V
         9r2klW/MPKDNf7fv9RzGVrseEcx+CiR/6pkFt3ZYQjHJNWFiKp6YtZ7X9UraHbj8/rX1
         eRMLsyYs92Z/R9RqNPmw3mBl20+8x3gC9QuMudgTvMaUEN9vk84oo+AqKeB3l0iExim0
         mT0w==
X-Gm-Message-State: APjAAAVr3fSeEs1y1MkfvulIgYoU+YajreTlZ7wXFZUdd+nUQCRDRPKp
	nhcxSrQ+BtBlO58aJBI3LHr0DQ43RParGLBjK862FEWRxnKvWwTkSri8QKBYOuiu19HmiyuxvFO
	AOv/0duO7R0VmncDTI9r9cXrq6b/lSfbOHaSrXcPR3OyjMETo31QHkkvF95Lsh7Ad1A==
X-Received: by 2002:a17:902:801:: with SMTP id 1mr12201161plk.299.1551565155580;
        Sat, 02 Mar 2019 14:19:15 -0800 (PST)
X-Google-Smtp-Source: APXvYqyNqOMtcPRdGd/BQcfptrqgdoJTr87cvuOmTZh+NVnmT2g8h60bj+Rh65SQoIDw0F/+ylGX
X-Received: by 2002:a17:902:801:: with SMTP id 1mr12201103plk.299.1551565154347;
        Sat, 02 Mar 2019 14:19:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551565154; cv=none;
        d=google.com; s=arc-20160816;
        b=EuczsJNM/Fz2oPZvxnzK8NLm9w36YGx3gMxbbQenOaXUOhpk45wttxKu5HPiDp0k19
         Gy6kweWS2W0XgT8P1s9vrLbFcwDF44iRSMqX8Eeb3yN5OfRujVxtxxwjX2lG2p3BgtwC
         y1fg04SlCwsk9tbrotq9p1hkctaE98A7UgHpZ32EZC1yazN+LH0Gf0bCmP2u0zmdO0nR
         Wi62dmTQyItjKXuA4GDbU/Ix2Yg6vIJEuigesyuh4jJTmfli91XeM2plu9jBklv/F80l
         HbJYIBgP2KvJUjXlhOQSyoOFICBpwHSG7jNqvYvI3eMsWk1VGl1l8NxObmZt+GDAWBgI
         3w6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-language:accept-language:in-reply-to
         :references:message-id:date:thread-index:thread-topic:subject:cc:to
         :from:dkim-signature:dkim-signature;
        bh=rNOtDNLOFh5Se4jmWFXlyXJ4HvwxpyGO0EgxHsDdrpY=;
        b=mXvBq+6sORaEmz/67/u7L1pjA1Z2YxjaWFkO/4XCgPnVs+Xaixd0GrTAHc4AwHFVdk
         iIQVMiSwSP9Mi7akPObsvVNVcb/86FJfSVqXSsjB0LWDO3TxdpkQbbOMxN8uFIqFc+N7
         OTyjV1wALItLzPFL7QqEXuJYo3CxxU9sQiJ0tJJFxPCjgoz9Q/suM4XMcElilhoNyToK
         ZKb13rFdJw7q+Vh8UHVG0XKJ9umPLYomxFUeoeYRZS3dtBva/wPEFWxlzTBrO5KleRLc
         Rz9bxE4ehri1mNG291IC8KsCNtt5P4gPW2YTiX10f04YC8Xs/NsFojZFoZNEbq0/wH42
         J1XA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=HZKdj7AG;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=F84eWWKr;
       spf=pass (google.com: domain of prvs=89647cfb46=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=89647cfb46=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id ay6si1515045plb.293.2019.03.02.14.19.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 14:19:14 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=89647cfb46=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=HZKdj7AG;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=F84eWWKr;
       spf=pass (google.com: domain of prvs=89647cfb46=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=89647cfb46=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x22MIgY5032522;
	Sat, 2 Mar 2019 14:19:07 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type :
 mime-version; s=facebook; bh=rNOtDNLOFh5Se4jmWFXlyXJ4HvwxpyGO0EgxHsDdrpY=;
 b=HZKdj7AG94HO8ZwonmzE2T/PR09lM4u0zLSVk9IxVdxjiuRYNGwJGKVYj+5yEy6iEWuy
 QOgmhDQ2cBcjTfNVbJyY1EBcZEHxg2PQfcecFEDb/EW7DC0H8/fk/2JwrSVAU95cuAlM
 GJmuWbHbNECIOslEpHSqCQL0fuY23hKBU1o= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qyt10s22b-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Sat, 02 Mar 2019 14:19:07 -0800
Received: from frc-hub03.TheFacebook.com (2620:10d:c021:18::173) by
 frc-hub02.TheFacebook.com (2620:10d:c021:18::172) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Sat, 2 Mar 2019 14:19:05 -0800
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.73) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Sat, 2 Mar 2019 14:19:05 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=rNOtDNLOFh5Se4jmWFXlyXJ4HvwxpyGO0EgxHsDdrpY=;
 b=F84eWWKrjvpLszj2XDXnk6DRFf2kyvaCKMCjJQ84lTJo8aQTP3dHuiWYuyoVNgYWbSU5BifWcaUTpLCBxJm/CNqQ7A/sEj4L4lA2LDGalDc4fWmRyOxhkhc9UbkPYQlKGrtZNQTDvYNwlRujtgJEMyRlT4d0bX74YE29AUZpEOE=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2231.namprd15.prod.outlook.com (52.135.196.158) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.18; Sat, 2 Mar 2019 22:19:03 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1665.019; Sat, 2 Mar 2019
 22:19:03 +0000
From: Roman Gushchin <guro@fb.com>
To: Oded Gabbay <oded.gabbay@gmail.com>,
        Andrew Morton
	<akpm@linux-foundation.org>
CC: Linux Memory Management List <linux-mm@kvack.org>,
        Johannes Weiner
	<hannes@cmpxchg.org>
Subject: Re: [rgushchin:release_percpu 321/401] ERROR: "dma_fence_release"
 [drivers/misc/habanalabs/habanalabs.ko] undefined!
Thread-Topic: [rgushchin:release_percpu 321/401] ERROR: "dma_fence_release"
 [drivers/misc/habanalabs/habanalabs.ko] undefined!
Thread-Index: AQHU0JlNxo0deVP1w0SdQBC85tLqcqX4Df2AgADcHlw=
Date: Sat, 2 Mar 2019 22:19:03 +0000
Message-ID: <BYAPR15MB2631C71F48BD77C8B86DE813BE770@BYAPR15MB2631.namprd15.prod.outlook.com>
References: <201903020948.mXKq6Z2s%fengguang.wu@intel.com>,<CAFCwf10c_rjZTDmDnDhH4wjihV8PhO=PSN2mwCwU6cB7+fx-5Q@mail.gmail.com>
In-Reply-To: <CAFCwf10c_rjZTDmDnDhH4wjihV8PhO=PSN2mwCwU6cB7+fx-5Q@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [2620:10d:c090:180::96c5]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b0fce641-2270-432b-8162-08d69f5d141f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2231;
x-ms-traffictypediagnostic: BYAPR15MB2231:
x-ms-exchange-purlcount: 2
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2231;20:U01mtfyujw/kSG6PwPx9dcqkmGQEMm482FE0UqOpD4OtMaxDG0QP3j2qwCxjrhJmaeYJMUimBINS54qSsozC/Xcr681LKRGdzVxiDrxxGxAYeLpemlSboAHUgAimiNxZsMWFWHMF8lGlixzEXwPjtJuNFjqYn403MQVnV0kMG+o=
x-microsoft-antispam-prvs: <BYAPR15MB2231BD748FD0A93641E63452BE770@BYAPR15MB2231.namprd15.prod.outlook.com>
x-forefront-prvs: 09645BAC66
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(136003)(39860400002)(376002)(396003)(346002)(52314003)(199004)(189003)(97736004)(6306002)(6116002)(81166006)(4326008)(8936002)(55016002)(6606003)(25786009)(33656002)(105586002)(6246003)(19627405001)(81156014)(9686003)(8676002)(229853002)(74316002)(14454004)(7696005)(53936002)(106356001)(99286004)(54896002)(236005)(7736002)(606006)(316002)(478600001)(2906002)(966005)(110136005)(6436002)(53546011)(446003)(76176011)(68736007)(256004)(186003)(52536013)(86362001)(102836004)(11346002)(5660300002)(5024004)(476003)(71190400001)(71200400001)(6506007)(486006)(54906003)(46003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2231;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: kZLWsHUZbYfOv+PQh/uvyyBIZUHCj6itW0MO4JkmbD6nMKBrcXk5oCq+VF5avgpsJqdpTx9CaGBAk7sY2wzlU4JFKp3x3G4zDWHt0WNug3sSP4+07ea53wCt1y4bgXP+Ju1UuADX5R4kyYfLZrCuOQD6eM09YZmiIwIUbFX4hWNWZbPzyjxOaI3VhSama8BJ9O3dCVuUnOum5TUkn4SQU6AuL+GVVnwqCByrLwI0v2Wbkhx4N6SuRSHJgxRirs1Svxn8YbXiqTifpRyL8I/kMdThdFvBOyWJx+ZuRgOCa5Ewd2A8H0yWDKMydqY3HSqD4LzqQFWVvKniwwDqAsPlH2R9x6G7sHLdh71wgd3mnvjOToYI+vINcV++NfZQOqjRRemUbsWs80anarDNICqG7lImPuf3GIkpum2URZFkR0g=
Content-Type: multipart/alternative;
	boundary="_000_BYAPR15MB2631C71F48BD77C8B86DE813BE770BYAPR15MB2631namp_"
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: b0fce641-2270-432b-8162-08d69f5d141f
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Mar 2019 22:19:03.6706
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2231
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-02_12:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--_000_BYAPR15MB2631C71F48BD77C8B86DE813BE770BYAPR15MB2631namp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi Oded!


Thank you for sharing this information!


Tbh, I was surprised that the kbuild test robot did cc Andrew and others, a=
s it's my private repo,

and I didn't send these patches publicly yet. Anyway, thank you for looking=
 into the problem.


Thanks!

Roman

________________________________
From: Oded Gabbay <oded.gabbay@gmail.com>
Sent: Saturday, March 2, 2019 1:09:09 AM
To: Roman Gushchin; Andrew Morton
Cc: Linux Memory Management List; Johannes Weiner
Subject: Re: [rgushchin:release_percpu 321/401] ERROR: "dma_fence_release" =
[drivers/misc/habanalabs/habanalabs.ko] undefined!

On Sat, Mar 2, 2019 at 3:42 AM kbuild test robot <lkp@intel.com> wrote:
>
> Hi Andrew,
>
> First bad commit (maybe !=3D root cause):
>
> tree:   https://github.com/rgushchin/linux.git release_percpu
> head:   8b287c57af99a4642cdf70b3b1a5ab1d90877bba
> commit: 773ae09cc9c61b8f7dc983e9a1d4ce5abbd6339d [321/401] linux-next-rej=
ects
> config: x86_64-randconfig-m3-02280836 (attached as .config)
> compiler: gcc-7 (Debian 7.4.0-5) 7.4.0
> reproduce:
>         git checkout 773ae09cc9c61b8f7dc983e9a1d4ce5abbd6339d
>         # save the attached .config to linux build tree
>         make ARCH=3Dx86_64
>
> All errors (new ones prefixed by >>):
>
> >> ERROR: "dma_fence_release" [drivers/misc/habanalabs/habanalabs.ko] und=
efined!
> >> ERROR: "dma_fence_init" [drivers/misc/habanalabs/habanalabs.ko] undefi=
ned!
> >> ERROR: "dma_fence_signal" [drivers/misc/habanalabs/habanalabs.ko] unde=
fined!
> >> ERROR: "dma_fence_default_wait" [drivers/misc/habanalabs/habanalabs.ko=
] undefined!
> >> ERROR: "dma_fence_wait_timeout" [drivers/misc/habanalabs/habanalabs.ko=
] undefined!
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Ce=
nter
> https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__lists.01.org_piper=
mail_kbuild-2Dall&d=3DDwIBaQ&c=3D5VD0RTtNlTh3ycd41b3MUw&r=3DjJYgtDM7QT-W-Fz=
_d29HYQ&m=3DHPA84jVOmuSotww9zAhO59SftxRFVUYNTjerZypaw8k&s=3Ds7A8kZ6RjzQwYxs=
jp9zi0KTzwWbmVFkEPUDEvtz7rzA&e=3D                   Intel Corporation

Hi Roman and Andrew.
That error comes from the original patch-set of the driver, where a
there was missing "select DMA_SHARED_BUFFER" in Kconfig. So for
certain configurations, the build would fail.
This is already fixed in the current char-misc-next tree of gkh.

Thanks,
Oded

--_000_BYAPR15MB2631C71F48BD77C8B86DE813BE770BYAPR15MB2631namp_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<style type=3D"text/css" style=3D"display:none;"><!-- P {margin-top:0;margi=
n-bottom:0;} --></style>
</head>
<body dir=3D"ltr">
<div id=3D"divtagdefaultwrapper" style=3D"font-size:12pt;color:#000000;font=
-family:Calibri,Helvetica,sans-serif;" dir=3D"ltr">
<p style=3D"margin-top:0;margin-bottom:0">Hi Oded!</p>
<p style=3D"margin-top:0;margin-bottom:0"><br>
</p>
<p style=3D"margin-top:0;margin-bottom:0">Thank you for sharing&nbsp;this i=
nformation!</p>
<p style=3D"margin-top:0;margin-bottom:0"><br>
</p>
<p style=3D"margin-top:0;margin-bottom:0">Tbh, I was surprised that the kbu=
ild test robot did cc Andrew and others, as it's my private repo,</p>
<p style=3D"margin-top:0;margin-bottom:0">and I didn't send these patches p=
ublicly yet. Anyway, thank you for looking into the problem.</p>
<p style=3D"margin-top:0;margin-bottom:0"><br>
</p>
<p style=3D"margin-top:0;margin-bottom:0">Thanks!</p>
<p style=3D"margin-top:0;margin-bottom:0">Roman</p>
</div>
<hr style=3D"display:inline-block;width:98%" tabindex=3D"-1">
<div id=3D"divRplyFwdMsg" dir=3D"ltr"><font face=3D"Calibri, sans-serif" st=
yle=3D"font-size:11pt" color=3D"#000000"><b>From:</b> Oded Gabbay &lt;oded.=
gabbay@gmail.com&gt;<br>
<b>Sent:</b> Saturday, March 2, 2019 1:09:09 AM<br>
<b>To:</b> Roman Gushchin; Andrew Morton<br>
<b>Cc:</b> Linux Memory Management List; Johannes Weiner<br>
<b>Subject:</b> Re: [rgushchin:release_percpu 321/401] ERROR: &quot;dma_fen=
ce_release&quot; [drivers/misc/habanalabs/habanalabs.ko] undefined!</font>
<div>&nbsp;</div>
</div>
<div class=3D"BodyFragment"><font size=3D"2"><span style=3D"font-size:11pt;=
">
<div class=3D"PlainText">On Sat, Mar 2, 2019 at 3:42 AM kbuild test robot &=
lt;lkp@intel.com&gt; wrote:<br>
&gt;<br>
&gt; Hi Andrew,<br>
&gt;<br>
&gt; First bad commit (maybe !=3D root cause):<br>
&gt;<br>
&gt; tree:&nbsp;&nbsp; <a href=3D"https://github.com/rgushchin/linux.git">h=
ttps://github.com/rgushchin/linux.git</a> release_percpu<br>
&gt; head:&nbsp;&nbsp; 8b287c57af99a4642cdf70b3b1a5ab1d90877bba<br>
&gt; commit: 773ae09cc9c61b8f7dc983e9a1d4ce5abbd6339d [321/401] linux-next-=
rejects<br>
&gt; config: x86_64-randconfig-m3-02280836 (attached as .config)<br>
&gt; compiler: gcc-7 (Debian 7.4.0-5) 7.4.0<br>
&gt; reproduce:<br>
&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; git checkout 773ae09cc=
9c61b8f7dc983e9a1d4ce5abbd6339d<br>
&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; # save the attached .c=
onfig to linux build tree<br>
&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; make ARCH=3Dx86_64<br>
&gt;<br>
&gt; All errors (new ones prefixed by &gt;&gt;):<br>
&gt;<br>
&gt; &gt;&gt; ERROR: &quot;dma_fence_release&quot; [drivers/misc/habanalabs=
/habanalabs.ko] undefined!<br>
&gt; &gt;&gt; ERROR: &quot;dma_fence_init&quot; [drivers/misc/habanalabs/ha=
banalabs.ko] undefined!<br>
&gt; &gt;&gt; ERROR: &quot;dma_fence_signal&quot; [drivers/misc/habanalabs/=
habanalabs.ko] undefined!<br>
&gt; &gt;&gt; ERROR: &quot;dma_fence_default_wait&quot; [drivers/misc/haban=
alabs/habanalabs.ko] undefined!<br>
&gt; &gt;&gt; ERROR: &quot;dma_fence_wait_timeout&quot; [drivers/misc/haban=
alabs/habanalabs.ko] undefined!<br>
&gt;<br>
&gt; ---<br>
&gt; 0-DAY kernel test infrastructure&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Open Source Technology=
 Center<br>
&gt; <a href=3D"https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__list=
s.01.org_pipermail_kbuild-2Dall&amp;d=3DDwIBaQ&amp;c=3D5VD0RTtNlTh3ycd41b3M=
Uw&amp;r=3DjJYgtDM7QT-W-Fz_d29HYQ&amp;m=3DHPA84jVOmuSotww9zAhO59SftxRFVUYNT=
jerZypaw8k&amp;s=3Ds7A8kZ6RjzQwYxsjp9zi0KTzwWbmVFkEPUDEvtz7rzA&amp;e=3D">
https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__lists.01.org_piperma=
il_kbuild-2Dall&amp;d=3DDwIBaQ&amp;c=3D5VD0RTtNlTh3ycd41b3MUw&amp;r=3DjJYgt=
DM7QT-W-Fz_d29HYQ&amp;m=3DHPA84jVOmuSotww9zAhO59SftxRFVUYNTjerZypaw8k&amp;s=
=3Ds7A8kZ6RjzQwYxsjp9zi0KTzwWbmVFkEPUDEvtz7rzA&amp;e=3D</a>&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;
 Intel Corporation<br>
<br>
Hi Roman and Andrew.<br>
That error comes from the original patch-set of the driver, where a<br>
there was missing &quot;select DMA_SHARED_BUFFER&quot; in Kconfig. So for<b=
r>
certain configurations, the build would fail.<br>
This is already fixed in the current char-misc-next tree of gkh.<br>
<br>
Thanks,<br>
Oded<br>
</div>
</span></font></div>
</body>
</html>

--_000_BYAPR15MB2631C71F48BD77C8B86DE813BE770BYAPR15MB2631namp_--

