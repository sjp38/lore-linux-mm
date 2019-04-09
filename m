Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F25DC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 06:55:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3553020880
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 06:55:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="FR518TLZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3553020880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1C6E6B0008; Tue,  9 Apr 2019 02:55:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCABF6B000C; Tue,  9 Apr 2019 02:55:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A92C86B000D; Tue,  9 Apr 2019 02:55:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F43F6B0008
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 02:55:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g83so12357476pfd.3
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 23:55:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=mhvftYmBbxKShj+CoY7y/lw9q0Ayo3jaUwg6pzEUmPo=;
        b=ffTzu/t+Y/OcHP3TDn+CyLGslobAoOc6bKOFdplgakPfefuu+1/kSDcKfQFpcSXQJq
         Fk0zwzJNPxFJIwmw12spf3AQMU+cs0K+aEdc7MpjNuIvGkwvxfQl6yQT+JORqMQZ3zCi
         mLgCnJPQCGlzi1qeiHczwA+nYxSPc6FTbFvK8CuB5/hwhkbkrmp8JGuQ7vyULBhJiqtW
         EBjQOstDFbqDrDuT7DzZIw77kGaMHKrq/KefVfggXYSbvcZVesprmM2pJ4gf5wB+gRWx
         tbl0uDRDMpF2v8f0Ulpxf59pa4gsFTrmaZJmMKTOsLkEVAkEojHdxon2gZ5MxcIfZG7M
         npXw==
X-Gm-Message-State: APjAAAWVhNlkMOUQv+zFi23+SgmAt51/xMLUYJpzDVkO6XjEEwZBh7bn
	p3DzqVuRqCy9Ge1yB10ILaC4M64E03/1iKn+upfQepfX3GVvEp3YfP5N66FCBhpgerhf2IlT8x7
	j2Zs9Z5grx/ETUyLAhGCj0BfzedptVx8XAYqbkJG4sUH//mhtORBLGuyKLK22PHtwgA==
X-Received: by 2002:a63:6844:: with SMTP id d65mr33421555pgc.393.1554792937966;
        Mon, 08 Apr 2019 23:55:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyk7+xuxLnb2WtJpw7B5i6FK9t+C4wTtYk08dxaNCAMv9JvcTu2fBSRZQBUgJvKkkd1tkLU
X-Received: by 2002:a63:6844:: with SMTP id d65mr33421501pgc.393.1554792936961;
        Mon, 08 Apr 2019 23:55:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554792936; cv=none;
        d=google.com; s=arc-20160816;
        b=TpZ1pYvjsq4bwhP/V+/R1uBDiAMyK+JtQEeTCpFGKTzw3qmLcr3BXnigE39otrgSyo
         Fb+RR3T81tMxPk2/ZYpJkKVTvEgqspXtCsZ/F8ssjCacuzns5rQPZkvoNwrf0iNHjEnf
         seDT0bAbSgbaP5ko4AF4ZzApguf7Tpt29euUjtgNY0KKuZxPNx3ADAGTdmRW1McpQhK2
         W8aoSFygI4SUAc+0zsCBXikxg58wJmNvozSNPSyMAnz9kzDxDPrwy0QIMpMX/60POqrx
         plLLAjXH8eg2PUga69QWyjYCPWcgCSmNnHAwvvxFEMpBZa+oSCqqOWNEiVnHnVwIij8U
         k7Qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :to:from:dkim-signature;
        bh=mhvftYmBbxKShj+CoY7y/lw9q0Ayo3jaUwg6pzEUmPo=;
        b=0xBDXbGKrU0pm+dQkSeDsEaVJ9qOA7SaGJwG7Ajuy8RA5t2LFDz30cH6UYKARoMBDx
         dEyYfxFbIxUYT99dq31Vp4/Sw+SgpqRq8iXcrgEUug9mP7JWQgBQcQXW5oXKFrYHYST+
         R1UAoB8Iux8NpOeJ1DMme9NLliZuQT3cc/bmBMs6b1Ktmu+DKG8iMRM3sn0w6LQfJL85
         3d/6wjye0LSZpiqBotg+a0zVBxuFdxQic2H+N3tKX+O6Fcfz6mjEocp5mPNh8KcU8i88
         RDZ+ntDFGIH+watu9K4jOV+k2Sk1VPnWhjy7KgbYiO7jLJXHnDxihh0PcZX19BR89CnC
         ps4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=FR518TLZ;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.41 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-HK2-obe.outbound.protection.outlook.com (mail-eopbgr1300041.outbound.protection.outlook.com. [40.107.130.41])
        by mx.google.com with ESMTPS id t10si10215535pgc.65.2019.04.08.23.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Apr 2019 23:55:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.41 as permitted sender) client-ip=40.107.130.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=FR518TLZ;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.41 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=mhvftYmBbxKShj+CoY7y/lw9q0Ayo3jaUwg6pzEUmPo=;
 b=FR518TLZ4+8qiRHTrjxuqnhhLEUQdi7ILgmL65iyZBsuNf1ZrXcpLQNMGqdXrb78k/A4fFRht2bVkqjBi9fVyMpzWJjV1OEFbaFSqAOP8bS9YRx4Fh166s74KRntHrTvLdPrMAchXL2/gcCLml6d6ECSVF6Eb1d2ixitRHM8H1k=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB4043.apcprd02.prod.outlook.com (20.178.156.204) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.14; Tue, 9 Apr 2019 06:55:34 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1771.019; Tue, 9 Apr 2019
 06:55:34 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Basics : Memory Configuration
Thread-Topic: Basics : Memory Configuration
Thread-Index: AQHU7qEJC6EuUiGvjEiZ+OVh95dcdw==
Date: Tue, 9 Apr 2019 06:55:34 +0000
Message-ID:
 <SG2PR02MB3098925678D8D40B683E10E2E82D0@SG2PR02MB3098.apcprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 751437ea-88cb-4a1e-d3a0-08d6bcb85d6c
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SG2PR02MB4043;
x-ms-traffictypediagnostic: SG2PR02MB4043:
x-microsoft-antispam-prvs:
 <SG2PR02MB4043FF045576F230EF49F1B3E82D0@SG2PR02MB4043.apcprd02.prod.outlook.com>
x-forefront-prvs: 000227DA0C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39850400004)(366004)(396003)(346002)(136003)(376002)(189003)(199004)(9686003)(3846002)(6116002)(2906002)(476003)(44832011)(66066001)(7696005)(486006)(25786009)(99286004)(316002)(110136005)(14454004)(68736007)(55016002)(53936002)(81166006)(305945005)(7736002)(33656002)(8676002)(81156014)(74316002)(478600001)(6436002)(26005)(14444005)(55236004)(102836004)(8936002)(256004)(5024004)(71200400001)(186003)(2501003)(6506007)(86362001)(5660300002)(52536014)(105586002)(106356001)(66574012)(78486014)(97736004)(71190400001);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB4043;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 OLQhb5QUQA9QWg7Owjq+RUq0FC+c+7gqkaSiU/vsJWQSEsMLhNOCPJdpdjXpTy9d4b5YqwYIUmTu1zZplHJ3tCLwxJkuUxpwTEa/o6mX9K6PiOQfTkvfv4dt1Hb21f4zdf8pI+/q0VgwqAkwHOo2B7v5bSg8eoHTet3pQt/nOEHWYv4DsA2GkWf8fGuL3yz/d4PbkSqFH2JtO9Q0I2tdEfKOPfHhFKL5sAMb802GeewZZ4f/F0vvj543d88so4FYgzXEeCdzJP9WBx36UDM0kaTE6AboXa93slIsITtqQ0rLNT4fCE6nsncX+pRJut8h6FdkUVkNrLGf5SnTDhiygUrhiqawGRKqwnrjKj1isTSZRCr66Jspj2DbcFkbMUL4tqnMPAirSweRm8SVdu84tM2Ozo2AH1lJIAjk5a0nIII=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 751437ea-88cb-4a1e-d3a0-08d6bcb85d6c
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Apr 2019 06:55:34.5650
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB4043
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I am confuse about memory configuration and I have below questions

1. if 32-bit os maximum virtual address is 4GB, When i have 4 gb of ram for=
 32-bit os, What about the virtual memory size ? is it required virtual mem=
ory(disk space) or we can directly use physical memory ?

2. In 32-bit os 12 bits are offset because page size=3D4k i.e 2^12 and 2^20=
 for page addresses
   What about 64-bit os, What is offset size ? What is page size ? How it c=
alculated.

3. What is PAE? If enabled how to decide size of PAE, what is maximum and m=
inimum size of extended memory.

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

