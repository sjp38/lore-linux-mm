Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A5BDC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:32:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02BD8217F5
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:32:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="WESN1TyN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02BD8217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F3498E0003; Wed, 27 Feb 2019 13:32:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A2428E0001; Wed, 27 Feb 2019 13:32:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71D0A8E0003; Wed, 27 Feb 2019 13:32:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC618E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 13:32:16 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id g3so13523282ioh.12
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 10:32:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:mime-version;
        bh=I4rhwHCQa0B8of5vnQhN5du0f8DbSpAUR6rJfOWsUSY=;
        b=pgzx8tfx2RBDkEfSvjnKcu4FKhWt4Pg1U5Isg85938lSM2WYbKXmlSOwOP5KZPdwv3
         skMPQ5eT/WpDiDbbTGU98eLiEKMCHoDBv2GxB6MRXIrIZ3lq03Bj3ObsTBaBwNmdmS6v
         bd3va0W1w/bWqP7NuXw44ehEcXFPYSercNxnazv3GbsbQBOPNkCQQ22nhLySZ1lISEKU
         aIi4nlvS1ugRHDopOABPx7ijHkfOZTiv8llZrlrMjZEdy+/pzvTwy8gSm25tXmpBytyz
         pmuXxGmlgGqXuuwpVMvwbXN/9CrgklLykJOnnPixiOCehzIqUCiRzWzaqdfauJDdHBnf
         pzdQ==
X-Gm-Message-State: APjAAAUdhvuRfx3sWv0K5M3lWWnCAMf4g0qBqUc217iLlZxlIVGlC4Hg
	ZYA1qc66/JgcdHMTrA0kj3ni8w5TKnbzkvKsY3Eel6NkSFOf99hLGCd/ijU1NfanYdkHpL5TxfS
	eRB+ULzVFOtBgMIRt9NBnktDEhfRwriCQ5Xjb0+tGsfLvlnEM8hR6A60XTUTEpZE=
X-Received: by 2002:a6b:5905:: with SMTP id n5mr3181288iob.33.1551292335899;
        Wed, 27 Feb 2019 10:32:15 -0800 (PST)
X-Google-Smtp-Source: APXvYqyA3ZFICngukt0xvnFF+amph2loPedvP+5YQRLIYAdfNO6m/8hu0r25igQ4iLLr3jvPvzOS
X-Received: by 2002:a6b:5905:: with SMTP id n5mr3181238iob.33.1551292334962;
        Wed, 27 Feb 2019 10:32:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551292334; cv=none;
        d=google.com; s=arc-20160816;
        b=A9Q2VoYWE8Wfae5NQk0813kQRpS2m6y346U6RxWsjPuYMHjdTn1OvjUwfoUElCISp7
         w91FHo0iEBMNTI7eqICJfFDR+bUnkkgYXTfLkkH9bxRmHHMDDXZKgo3d8aqD7GmETE38
         IB4t7obSYY0kSAAcHbt+rmRXLV8ht0a42jI53nOt49AdbbGnn/eWYx/lMXG6ogTA+h1/
         dlYWR7miY9S0gEwFfgySF196t1KqShv7RJJHWmpHqGRLbMI2r/rRPdGlq6GBmioPpNDn
         XyXkAC087TBXWnV+pVYI6HslU9g+mMIMyd/TVxCNGLHrfVRGR11g3c9vyBm/1NAEXxPl
         4PmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-language:accept-language:in-reply-to
         :references:message-id:date:thread-index:thread-topic:subject:cc:to
         :from:dkim-signature;
        bh=I4rhwHCQa0B8of5vnQhN5du0f8DbSpAUR6rJfOWsUSY=;
        b=Yu2cN9ZrQJM+IxnOV748LdxzzxvBjBMCTUC3pUvu+HRAaN83Q9oHtW4POJQiOIYDGS
         6qLo+0hWqmeQ81Jyi3brOd5U4dN8jicrbIxpFVUiDr+DuSdQrT4yNBff3rxQCkpE9P8O
         3rsnzj5nCFN9o8/FgPAgt1b46egxEb5BHsOLh5qHuXX6it7J8GhRzfOBM2a3sS0+oqxR
         TS8rIm2SNwPV5K7FI2AarwvwjV4ZuCcPL6JAhtNp+ugn71hJWgfxUuAFeN9u3mdOD2lP
         uBjauyTdBnRsMsfVj0Cy3Rphz1Dl8nFoIiYZT2rfFXmB36Da59EE+hZfAyZVEioAzdZ+
         //Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=WESN1TyN;
       spf=neutral (google.com: 40.107.69.51 is neither permitted nor denied by best guess record for domain of alexander.deucher@amd.com) smtp.mailfrom=Alexander.Deucher@amd.com
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (mail-eopbgr690051.outbound.protection.outlook.com. [40.107.69.51])
        by mx.google.com with ESMTPS id z65si8468043iof.71.2019.02.27.10.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 10:32:14 -0800 (PST)
Received-SPF: neutral (google.com: 40.107.69.51 is neither permitted nor denied by best guess record for domain of alexander.deucher@amd.com) client-ip=40.107.69.51;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=WESN1TyN;
       spf=neutral (google.com: 40.107.69.51 is neither permitted nor denied by best guess record for domain of alexander.deucher@amd.com) smtp.mailfrom=Alexander.Deucher@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=I4rhwHCQa0B8of5vnQhN5du0f8DbSpAUR6rJfOWsUSY=;
 b=WESN1TyNqX0pkGCQAktXujVndE/OgoH+sWZfznCzUuM0a7/9gv5pFX5LS6LzUtSlDfIf6zSJY5jgUDtRk+rbBWoUtZ06rrBrYqJKYhw84lG9huN/j00Qa5qWlKU5ORHVjonDcTmDtkS3YR8Fx90ef9QwRrEg/USzxL851FkiH4U=
Received: from BN6PR12MB1809.namprd12.prod.outlook.com (10.175.101.17) by
 BN6PR12MB1345.namprd12.prod.outlook.com (10.168.225.19) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.16; Wed, 27 Feb 2019 18:32:12 +0000
Received: from BN6PR12MB1809.namprd12.prod.outlook.com
 ([fe80::51a:7e56:5b6e:bc1f]) by BN6PR12MB1809.namprd12.prod.outlook.com
 ([fe80::51a:7e56:5b6e:bc1f%2]) with mapi id 15.20.1643.019; Wed, 27 Feb 2019
 18:32:12 +0000
From: "Deucher, Alexander" <Alexander.Deucher@amd.com>
To: "Yang, Philip" <Philip.Yang@amd.com>, =?iso-8859-1?Q?Michel_D=E4nzer?=
	<michel@daenzer.net>, =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
Subject: Re: KASAN caught amdgpu / HMM use-after-free
Thread-Topic: KASAN caught amdgpu / HMM use-after-free
Thread-Index: AQHUzr5Jtqa2+5svxEmSQ7Yyfhi6laXz4jEAgAAFZYCAAAkBAIAAB0PN
Date: Wed, 27 Feb 2019 18:32:11 +0000
Message-ID:
 <BN6PR12MB18090BDFE1DD800785C5ED76F7740@BN6PR12MB1809.namprd12.prod.outlook.com>
References: <e8466985-a66b-468b-5fff-6e743180da67@daenzer.net>
 <83fde7eb-abab-e770-efd5-89bc9c39fdff@amd.com>
 <c26fa310-38d1-acba-cf82-bc6dc2f782c0@daenzer.net>,<35d7e134-6eef-9732-8ebf-83256e40eb65@amd.com>
In-Reply-To: <35d7e134-6eef-9732-8ebf-83256e40eb65@amd.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Alexander.Deucher@amd.com; 
x-originating-ip: [71.219.73.123]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4b7940ab-8790-404c-bc48-08d69ce1e3bb
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:BN6PR12MB1345;
x-ms-traffictypediagnostic: BN6PR12MB1345:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics:
 1;BN6PR12MB1345;20:FixHWXxsUi27Zf6zb4b4JMgC1ijwQ/FX22NTNyPCQqyerBcbz/cqPmznD0aRCMyv8jwCznwkIn2KkGZ/HMuLVG/NQUSn7a1laiCEvCuFaR7Rr53zuG/cwsMaonO/qC4Eh/7HOWfkLGsUu96q7+w8o2ZbnmP2REisA961vyCU/h+5DiWQB9AeCREREWSLN51Sf2hlJwr+B8XVPq/aPEc2DHQg+WefjuyIB/c6H6vvCXJ0tvsVvJ7rG0HFRsp2tdTi
x-microsoft-antispam-prvs:
 <BN6PR12MB1345647B0E36580DC7CC1FF1F7740@BN6PR12MB1345.namprd12.prod.outlook.com>
x-forefront-prvs: 0961DF5286
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(346002)(376002)(39860400002)(396003)(136003)(199004)(189003)(478600001)(7696005)(14454004)(72206003)(966005)(76176011)(93886005)(97736004)(4326008)(110136005)(316002)(33656002)(6246003)(606006)(25786009)(106356001)(99286004)(55016002)(229853002)(256004)(54896002)(66066001)(6436002)(7736002)(105586002)(9686003)(236005)(6306002)(71190400001)(71200400001)(105004)(476003)(54906003)(11346002)(446003)(486006)(186003)(26005)(102836004)(53546011)(6506007)(86362001)(8936002)(3846002)(6116002)(53936002)(2906002)(8676002)(81156014)(81166006)(52536013)(74316002)(19627405001)(68736007)(5660300002);DIR:OUT;SFP:1101;SCL:1;SRVR:BN6PR12MB1345;H:BN6PR12MB1809.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 s7tsZ21oU8aVi3HIYpO1j8LllaGSIipQ/qC9sgwTRMr6OT/W9hzWERrGurvs3QdYKQxhbce1LfVpXRo0E/mon/X3xbKsSO2jCZR9Uo6YdddsBAyo0y3iPqJZT0EA5v6NoR453S0perSXHNlmsqcSjXFb+zP5SJYS4sIAiwWNFCixJqq/Y2NVmVy0PHn7eo+EnhpJky3Vw5pHLG2lS5tT7QFEi2MlY1WTVY98AHHjqvmk74x8Di+ruEbcnuATx+Uxy5Q22qAcR+1LPtaXQdgy4qRvsRUESemhBtrMiP9T3AV2uOu978jTlaxQSccyZQBcznEuUQbpvcSSA7UPwRk/oGJMS39wb8gfAzHQyfUp5HqxxZgIefIPJlAgj0pIkqUkzGdoLDtXXgdnsPxljJHYiF18xsdRNsT4LGFIdMmLm6w=
Content-Type: multipart/alternative;
	boundary="_000_BN6PR12MB18090BDFE1DD800785C5ED76F7740BN6PR12MB1809namp_"
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4b7940ab-8790-404c-bc48-08d69ce1e3bb
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Feb 2019 18:32:12.0148
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR12MB1345
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--_000_BN6PR12MB18090BDFE1DD800785C5ED76F7740BN6PR12MB1809namp_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Go ahead an apply it to amd-staging-drm-next.  It'll naturally fall out whe=
n I rebase it.

Alex
________________________________
From: amd-gfx <amd-gfx-bounces@lists.freedesktop.org> on behalf of Yang, Ph=
ilip <Philip.Yang@amd.com>
Sent: Wednesday, February 27, 2019 1:05 PM
To: Michel D=E4nzer; J=E9r=F4me Glisse
Cc: linux-mm@kvack.org; amd-gfx@lists.freedesktop.org
Subject: Re: KASAN caught amdgpu / HMM use-after-free

amd-staging-drm-next will rebase to kernel 5.1 to pickup this fix
automatically. As a short-term workaround, please cherry-pick this fix
into your local repository.

Regards,
Philip

On 2019-02-27 12:33 p.m., Michel D=E4nzer wrote:
> On 2019-02-27 6:14 p.m., Yang, Philip wrote:
>> Hi Michel,
>>
>> Yes, I found the same issue and the bug has been fixed by Jerome:
>>
>> 876b462120aa mm/hmm: use reference counting for HMM struct
>>
>> The fix is on hmm-for-5.1 branch, I cherry-pick it into my local branch
>> to workaround the issue.
>
> Please push it to amd-staging-drm-next, so that others don't run into
> the issue as well.
>
>
_______________________________________________
amd-gfx mailing list
amd-gfx@lists.freedesktop.org
https://lists.freedesktop.org/mailman/listinfo/amd-gfx

--_000_BN6PR12MB18090BDFE1DD800785C5ED76F7740BN6PR12MB1809namp_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">
<style type=3D"text/css" style=3D"display:none;"> P {margin-top:0;margin-bo=
ttom:0;} </style>
</head>
<body dir=3D"ltr">
<div style=3D"font-family: Calibri, Arial, Helvetica, sans-serif; font-size=
: 12pt; color: rgb(0, 0, 0);">
Go ahead an apply it to amd-staging-drm-next.&nbsp; It'll naturally fall ou=
t when I rebase it.</div>
<div style=3D"font-family: Calibri, Arial, Helvetica, sans-serif; font-size=
: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
<div style=3D"font-family: Calibri, Arial, Helvetica, sans-serif; font-size=
: 12pt; color: rgb(0, 0, 0);">
Alex<br>
</div>
<div id=3D"appendonsend"></div>
<hr style=3D"display:inline-block;width:98%" tabindex=3D"-1">
<div id=3D"divRplyFwdMsg" dir=3D"ltr"><font face=3D"Calibri, sans-serif" st=
yle=3D"font-size:11pt" color=3D"#000000"><b>From:</b> amd-gfx &lt;amd-gfx-b=
ounces@lists.freedesktop.org&gt; on behalf of Yang, Philip &lt;Philip.Yang@=
amd.com&gt;<br>
<b>Sent:</b> Wednesday, February 27, 2019 1:05 PM<br>
<b>To:</b> Michel D=E4nzer; J=E9r=F4me Glisse<br>
<b>Cc:</b> linux-mm@kvack.org; amd-gfx@lists.freedesktop.org<br>
<b>Subject:</b> Re: KASAN caught amdgpu / HMM use-after-free</font>
<div>&nbsp;</div>
</div>
<div class=3D"BodyFragment"><font size=3D"2"><span style=3D"font-size:11pt;=
">
<div class=3D"PlainText">amd-staging-drm-next will rebase to kernel 5.1 to =
pickup this fix
<br>
automatically. As a short-term workaround, please cherry-pick this fix <br>
into your local repository.<br>
<br>
Regards,<br>
Philip<br>
<br>
On 2019-02-27 12:33 p.m., Michel D=E4nzer wrote:<br>
&gt; On 2019-02-27 6:14 p.m., Yang, Philip wrote:<br>
&gt;&gt; Hi Michel,<br>
&gt;&gt;<br>
&gt;&gt; Yes, I found the same issue and the bug has been fixed by Jerome:<=
br>
&gt;&gt;<br>
&gt;&gt; 876b462120aa mm/hmm: use reference counting for HMM struct<br>
&gt;&gt;<br>
&gt;&gt; The fix is on hmm-for-5.1 branch, I cherry-pick it into my local b=
ranch<br>
&gt;&gt; to workaround the issue.<br>
&gt; <br>
&gt; Please push it to amd-staging-drm-next, so that others don't run into<=
br>
&gt; the issue as well.<br>
&gt; <br>
&gt; <br>
_______________________________________________<br>
amd-gfx mailing list<br>
amd-gfx@lists.freedesktop.org<br>
<a href=3D"https://lists.freedesktop.org/mailman/listinfo/amd-gfx">https://=
lists.freedesktop.org/mailman/listinfo/amd-gfx</a></div>
</span></font></div>
</body>
</html>

--_000_BN6PR12MB18090BDFE1DD800785C5ED76F7740BN6PR12MB1809namp_--

