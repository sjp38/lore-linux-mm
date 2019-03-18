Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 452E9C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:28:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEBA720850
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:28:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="TebYaZGo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEBA720850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E7EF6B0005; Mon, 18 Mar 2019 09:28:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 497F16B0006; Mon, 18 Mar 2019 09:28:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 360E06B0007; Mon, 18 Mar 2019 09:28:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E852F6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:28:55 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e5so18596330pgc.16
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 06:28:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:mime-version;
        bh=W0l15GP7ecyrU3fZKMTz+o4Pe4XKyD5gTWabMiUMsYc=;
        b=Rp4sU75tn/JxZYSOtYvczruTisbR42/5G4skGoIjhd/vTn0AfNhZzQu0zjGExVvI6j
         l2HjYysHItAhZoTJcSvJAuG8iUq0UeYk56fCZ9hFfEOMap5sMJdDYpWFSQQGMdVquw5Y
         Q+N7Y1kynvywel1DVX99TJuGdmLIlMygFVrJZenR0UtS+3MtAtgKG9n7WkXvhfFbzI6f
         OVvrH36Y5EE7hMDiqVDBeaFakUbl8l4c2Xc4olDtzqc7ixZLcUPtfyg7uO1kdCYu9rgB
         CSaaDAu5q/SeYjF01ori75bi7EDqvpANyUeJAPkHb+I0ag91+/5sVORgmNewgiRX1ASx
         lO8Q==
X-Gm-Message-State: APjAAAVmq9NN389yZCZPvYNvhtMZxcp/wwroyAI/zuLJ3/OlLzZh4QHt
	9C8LOjUTywNwWASzaiChhVL6H/4sRolPwu3e45n3zqM8z5nmRwnypkFvWXqdAYNJUF0R7Qp5veO
	GrsQCCGDyfbF7a14ywu9Ekq3hed4egPIwqsOOPsgBv0nzHrILDyADCheqC3yJMgTAww==
X-Received: by 2002:a17:902:bb0c:: with SMTP id l12mr19939292pls.108.1552915735521;
        Mon, 18 Mar 2019 06:28:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMmjtyVc141jTOGTG8qEF+11gX+H7aQuniIuHVGnpikmsjRiFHOehKtEAGMHmzZsNwHYLA
X-Received: by 2002:a17:902:bb0c:: with SMTP id l12mr19939219pls.108.1552915734324;
        Mon, 18 Mar 2019 06:28:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552915734; cv=none;
        d=google.com; s=arc-20160816;
        b=GFCJsDudy0aho1ZE5Wp/VtwDgl8HI8H6AVWi8SD8pd570y5Wdpv81AsqLUmdEiD2K4
         ZZV1MbCshiGL8M/gnMhNGxqPq455jGowquqEmf3bpZ6AmDikXd0JI2Rqze47RYAdI1bF
         idDbL6+HQqqlyHckG4EVQTarCGYcAAs5bej51J+476lW34zcbvuf92JmkECFxPnnYmpl
         oGIP6M1JUHpX3+HGuHdOihfi5pMGhq/Swds70GeSXAJoPcwiyO2d8dZa/d8MrVM4VXv3
         dd0irZCCWq7Rg7RZYi1j2r9ZFVG1i/HlBW0EmuQylQKq8mo4fezdP6rTYbv9kIHxiAYL
         OSdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-language:accept-language:in-reply-to
         :references:message-id:date:thread-index:thread-topic:subject:cc:to
         :from:dkim-signature;
        bh=W0l15GP7ecyrU3fZKMTz+o4Pe4XKyD5gTWabMiUMsYc=;
        b=mthCSqRmxWnPgXwhjELX1xQsVChsDTJDZuTlTtVg+ZVjsJZHxPln7l9P9ULYQffVq5
         vb5yFK7NtB+CTdGdvO6+UhfK1WF6d9HKD0bJQYXwuYTnhcrVdzZgqyAU0nslsRp+ngsV
         pOWl9vJW2W9ILf63bQucfXwDBC7VSidopZyDVTLFWRLIiJH3zA40JiEIxbGMbnY6JiAd
         eKzi64IHmA6/kns6GMr/D0jvcnRrq8t+bDkt6ZpPlGd+1HnjNYdVTQu57qzGQUq3AjD5
         YM4EFF2PxxPHsJD3PeAhV9VBEiMPBD8CNSIxPEbH2CawHDUHC6aqBsq/GPz17njYtkd8
         I76g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=TebYaZGo;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.70 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-PU1-obe.outbound.protection.outlook.com (mail-eopbgr1320070.outbound.protection.outlook.com. [40.107.132.70])
        by mx.google.com with ESMTPS id r11si852443pga.249.2019.03.18.06.28.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 06:28:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.70 as permitted sender) client-ip=40.107.132.70;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=TebYaZGo;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.70 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=W0l15GP7ecyrU3fZKMTz+o4Pe4XKyD5gTWabMiUMsYc=;
 b=TebYaZGoDPiToZseL9M6pA5K9V+PyWDRFOEVMe2TDzI3Wcyskn6rBHBchwPEvqosYOXBpWup8/wnUORxONhzGTv9S8LcfdIbPJtX1QT404woyrhQCZxAutDSkGZDwg5CWh01PsTfzuQULcp5n/EyXWFNwA3GttzliAlDXcCO6/w=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB4153.apcprd02.prod.outlook.com (20.178.158.74) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.14; Mon, 18 Mar 2019 13:28:50 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1709.015; Mon, 18 Mar 2019
 13:28:50 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "minchan@kernel.org" <minchan@kernel.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [External] Re: mm/cma.c: High latency for cma allocation
Thread-Topic: [External] Re: mm/cma.c: High latency for cma allocation
Thread-Index: AQHU3YpG7XMhet9mv0+1ZFJR3Y1R16YRXCGAgAACGm0=
Date: Mon, 18 Mar 2019 13:28:50 +0000
Message-ID:
 <SG2PR02MB309886996889791555D5B53EE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098E44824F5AA69BC04F935E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>,<20190318130757.GG8924@dhcp22.suse.cz>
In-Reply-To: <20190318130757.GG8924@dhcp22.suse.cz>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f5b5a76b-1df3-4bbd-c1c3-08d6aba5a8b5
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB4153;
x-ms-traffictypediagnostic: SG2PR02MB4153:|SG2PR02MB4153:
x-microsoft-antispam-prvs:
 <SG2PR02MB4153EFF493C70E98B25D52E5E8470@SG2PR02MB4153.apcprd02.prod.outlook.com>
x-forefront-prvs: 098076C36C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39850400004)(376002)(396003)(136003)(346002)(366004)(199004)(189003)(19627405001)(7696005)(6916009)(68736007)(66066001)(53546011)(6506007)(71200400001)(2906002)(76176011)(99286004)(4326008)(66574012)(256004)(6246003)(5660300002)(229853002)(14444005)(5024004)(86362001)(53936002)(71190400001)(78486014)(316002)(25786009)(74316002)(3846002)(478600001)(54896002)(8936002)(6606003)(7736002)(52536014)(8676002)(33656002)(6436002)(54906003)(97736004)(81166006)(81156014)(9686003)(55016002)(11346002)(446003)(186003)(486006)(6116002)(476003)(44832011)(26005)(14454004)(105586002)(55236004)(106356001)(102836004);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB4153;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 slbju6o/uau+sL5GhfUwsRFStSgALJoD6Ky8rw6/SGiiyb8t9JULziR741axNg7+XEjhMdIKOIWhMVQl3ygRotGUaBDz5lPKnuC4B1dijIcm2knz9UHkWsXmrzWx1ZvYrB7VK9jvz1OxbxrAilslvSzfQPbEoKGGCkkroIoBZoMlTPltLSmxw0pfBA3XjuOykuT/K1NQav/9x2BYgHD7bUReOKpXfIYHT5Vsqe6BpklHbqn3XDu2vmSyMOwPsHp5by5RxPJqKZAu3O10IE8NIw30j8rboVHcwYWQ+rtWmcnTroqfuXN9ANp3nb7kqVkO1oUZsoDocSX9LmhMczoIpEKP/4vd6YduNlMJm9ZdRk3Q822IbvYuUEaz2ZRc8EyXUQh4a0n6KmhpMwI8RAIyyhtg6XT/N9ON7SPc7AwF4DQ=
Content-Type: multipart/alternative;
	boundary="_000_SG2PR02MB309886996889791555D5B53EE8470SG2PR02MB3098apcp_"
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f5b5a76b-1df3-4bbd-c1c3-08d6aba5a8b5
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Mar 2019 13:28:50.6360
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB4153
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--_000_SG2PR02MB309886996889791555D5B53EE8470SG2PR02MB3098apcp_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


________________________________
From: Michal Hocko <mhocko@kernel.org>
Sent: 18 March 2019 18:37:57
To: Pankaj Suryawanshi
Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; minchan@kernel.org; K=
irill Tkhai
Subject: [External] Re: mm/cma.c: High latency for cma allocation

CAUTION: This email originated from outside of the organization. Do not cli=
ck links or open attachments unless you recognize the sender and know the c=
ontent is safe.


On Mon 18-03-19 12:58:28, Pankaj Suryawanshi wrote:
> Hello,
>
> I am facing issue of high latency in CMA allocation of large size buffer.
>
> I am frequently allocating/deallocation CMA memory, latency of allocation=
 is very high.
>
> Below are the stat for allocation/deallocation latency issue.
>
> (390100 kB),  latency 29997 us
> (390100 kB),  latency 22957 us
> (390100 kB),  latency 25735 us
> (390100 kB),  latency 12736 us
> (390100 kB),  latency 26009 us
> (390100 kB),  latency 18058 us
> (390100 kB),  latency 27997 us
> (16 kB), latency 560 us
> (256 kB), latency 280 us
> (4 kB), latency 311 us
>
> I am using kernel 4.14.65 with android pie(9.0).
>
> Is there any workaround or solution for this(cma_alloc latency) issue ?

Do you have any more detailed information on where the time is spent?
E.g. migration tracepoints?

Hello Michal,

I have the system(vanilla kernel) with 2GB of RAM, reserved 1GB for CMA. No=
 swap or zram.
Sorry, I don't have information where the time is spent.
time is calculated in between cma_alloc call.
I have just cma_alloc trace information/function graph.

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

--_000_SG2PR02MB309886996889791555D5B53EE8470SG2PR02MB3098apcp_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">
<style type=3D"text/css" style=3D"display:none;"><!-- P {margin-top:0;margi=
n-bottom:0;} --></style>
</head>
<body dir=3D"ltr">
<div id=3D"divtagdefaultwrapper" style=3D"font-size:11pt;color:#000000;font=
-family:Calibri,Helvetica,sans-serif;" dir=3D"ltr">
<br>
<hr tabindex=3D"-1" style=3D"display:inline-block; width:98%">
<div id=3D"divRplyFwdMsg" dir=3D"ltr"><font style=3D"font-size:11pt" face=
=3D"Calibri, sans-serif" color=3D"#000000"><b>From:</b> Michal Hocko &lt;mh=
ocko@kernel.org&gt;<br>
<b>Sent:</b> 18 March 2019 18:37:57<br>
<b>To:</b> Pankaj Suryawanshi<br>
<b>Cc:</b> linux-mm@kvack.org; linux-kernel@vger.kernel.org; minchan@kernel=
.org; Kirill Tkhai<br>
<b>Subject:</b> [External] Re: mm/cma.c: High latency for cma allocation</f=
ont>
<div>&nbsp;</div>
</div>
<div class=3D"BodyFragment"><font size=3D"2"><span style=3D"font-size:11pt"=
>
<div class=3D"PlainText">CAUTION: This email originated from outside of the=
 organization. Do not click links or open attachments unless you recognize =
the sender and know the content is safe.<br>
<br>
<br>
On Mon 18-03-19 12:58:28, Pankaj Suryawanshi wrote:<br>
&gt; Hello,<br>
&gt;<br>
&gt; I am facing issue of high latency in CMA allocation of large size buff=
er.<br>
&gt;<br>
&gt; I am frequently allocating/deallocation CMA memory, latency of allocat=
ion is very high.<br>
&gt;<br>
&gt; Below are the stat for allocation/deallocation latency issue.<br>
&gt;<br>
&gt; (390100 kB),&nbsp; latency 29997 us<br>
&gt; (390100 kB),&nbsp; latency 22957 us<br>
&gt; (390100 kB),&nbsp; latency 25735 us<br>
&gt; (390100 kB),&nbsp; latency 12736 us<br>
&gt; (390100 kB),&nbsp; latency 26009 us<br>
&gt; (390100 kB),&nbsp; latency 18058 us<br>
&gt; (390100 kB),&nbsp; latency 27997 us<br>
&gt; (16 kB), latency 560 us<br>
&gt; (256 kB), latency 280 us<br>
&gt; (4 kB), latency 311 us<br>
&gt;<br>
&gt; I am using kernel 4.14.65 with android pie(9.0).<br>
&gt;<br>
&gt; Is there any workaround or solution for this(cma_alloc latency) issue =
?<br>
<br>
Do you have any more detailed information on where the time is spent?<br>
E.g. migration tracepoints?</div>
<div class=3D"PlainText"><br>
</div>
<div class=3D"PlainText">
<div>
<div id=3D"divtagdefaultwrapper" dir=3D"ltr" style=3D"font-size: 11pt; colo=
r: rgb(0, 0, 0); font-family: Calibri, Helvetica, sans-serif, &quot;EmojiFo=
nt&quot;, &quot;Apple Color Emoji&quot;, &quot;Segoe UI Emoji&quot;, NotoCo=
lorEmoji, &quot;Segoe UI Symbol&quot;, &quot;Android Emoji&quot;, EmojiSymb=
ols;">
<div>Hello Michal,</div>
<div><br>
</div>
<div>I have the system(vanilla kernel) with 2GB of RAM, reserved 1GB for CM=
A. No swap or zram.</div>
<div><font size=3D"2"><span style=3D"font-size:11pt"><font size=3D"2"><span=
 style=3D"font-size:11pt">Sorry, I don't have information where the time is=
 spent.</span></font></span></font></div>
<div><font size=3D"2"><span style=3D"font-size:11pt"><font size=3D"2"><span=
 style=3D"font-size:11pt">time is calculated in between cma_alloc call.</sp=
an></font></span></font><br>
</div>
<div>I have just cma_alloc trace information/function graph.<br>
</div>
</div>
</div>
&nbsp;<br>
--<br>
Michal Hocko<br>
SUSE Labs<br>
</div>
</span></font></div>
</div>
***************************************************************************=
***************************************************************************=
******* eInfochips Business Disclaimer: This e-mail message and all attachm=
ents transmitted with it are intended
 solely for the use of the addressee and may contain legally privileged and=
 confidential information. If the reader of this message is not the intende=
d recipient, or an employee or agent responsible for delivering this messag=
e to the intended recipient, you
 are hereby notified that any dissemination, distribution, copying, or othe=
r use of this message or its attachments is strictly prohibited. If you hav=
e received this message in error, please notify the sender immediately by r=
eplying to this message and please
 delete it from your computer. Any views expressed in this message are thos=
e of the individual sender unless otherwise stated. Company has taken enoug=
h precautions to prevent the spread of viruses. However the company accepts=
 no liability for any damage caused
 by any virus transmitted by this email. **********************************=
***************************************************************************=
************************************************
</body>
</html>

--_000_SG2PR02MB309886996889791555D5B53EE8470SG2PR02MB3098apcp_--

