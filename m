Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85F0FC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 06:06:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED1A82070D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 06:06:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="B84SeBoL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED1A82070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A72E6B0003; Wed, 10 Apr 2019 02:06:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 689916B0005; Wed, 10 Apr 2019 02:06:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 547D76B0006; Wed, 10 Apr 2019 02:06:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1861E6B0003
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 02:06:41 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e12so1169273pgh.2
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 23:06:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=ynrFHRlZLrj5J+eHpTcvYxhKBma448ynGvYpIOwKqZk=;
        b=RzTkfCSX3ofTCZQ3uzmySxHKy2HYJolLDAdu1bMECs73JaDrJvI/gFjxzweE5WUxFt
         NG7M88vQ9HgVgMwaD45YiV9+/pYrYzvhYR73a7LuLtzgZbeEkjmhzunuE6i+lUzDGZUL
         BVogRIMaDGvsdkP70UHs4+ay+j92lW4eUctpGhS779YaFT01mTzdJgFFgoeqMoWp3XTX
         1ETQ1OjqXEsrCvlQ/tuKk+BJqd/j5ZtWdIWzChd1B+iYaimLwV3Xhqr7+OFmcOTgRGqX
         ZJHE/asZLbxRRXWGfvmCT0xscdc+IRMgwme4DaJqNZAbqV0HqMgHS2oXMnCM52zQBldj
         +LuQ==
X-Gm-Message-State: APjAAAWEmhSMUVEQORA4mMi11mRVEXh1LvDgl0ycw5vZGj39uoPCxidP
	xboDaod1+vFRlgcq0CUgEh70QZI9/61Zo43OOJKxhkPwDa9lgTYPy/BAuhm7wAv1T27bH3fqkMs
	dQlJQ4B6jkdJhd/uhmNYeKdss8EqajhVtfPeb+TZB6pm1GB/jQcwu14hxa9WCCtH3yA==
X-Received: by 2002:a62:184a:: with SMTP id 71mr22755511pfy.1.1554876400330;
        Tue, 09 Apr 2019 23:06:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMB7Tqse0glXQjANik4sh8ipai6gdBNMrdpfoHL9oMJ7L5RGxsuP4YUVMQT/7Khp8KgSuZ
X-Received: by 2002:a62:184a:: with SMTP id 71mr22755435pfy.1.1554876399432;
        Tue, 09 Apr 2019 23:06:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554876399; cv=none;
        d=google.com; s=arc-20160816;
        b=lOe4nj2wpPuhvq0RVwJackA9QzELuPBVEAjdaPwWZ/W4Iqu3IeovdzmyDTXZOBZs1z
         G18yUbb8hZcNS0di0sNLrnd7LvZfd2XAS4PdvSQtZciuAcVZiCUQ1wvQceicDV3wEpFV
         CBnKaeFZb8PNrjKWAU5yagxmbFKPxgH8VS61oQkXab9f0WKZV0j+F4k5KmDniy3/X4tP
         kkPEAUQ+OczCPz93Hd5eqtJMNTgewvrwAebOprNEIZsm/qk4JFQv4xwqEteL5iBHbXfD
         NiiCZ2hQhubbd5A6ev/Zp8+S702f+kVs36nCQQoWgF9ltu7sQgbYq5Uf0PPexye2Oiso
         ItVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=ynrFHRlZLrj5J+eHpTcvYxhKBma448ynGvYpIOwKqZk=;
        b=pqmFsgroH6t6VLC5TiVNHCBRqcDlbE61tuXWogl3F4UJUKkoVV3CUVjcAVjSGRFfGL
         2pAubah71gAIzW53ZlApYy5xomPTnvozAUq43rdZRhw6aMX8FYQSFFTw3JsZsMiKGopY
         TCxcEt7xuW08MlgZOMcswuqOS2rNDM5rYepIaNfFfuSyJwb7Zqiln7CMxIoAatlEiTRr
         bclRXQ9abOdK3ER9JyExFZMqDAGAS56Nb0pJzp0mKBzLT205Xt/p+/4y/xM5lUSpuOm+
         Ki1fwzFUvKfaQYprRgVnGI2RUesRK1bCfOfZWuboAPF+Vb5nyeWQBGKPdgqEolnEcPxy
         mYDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=B84SeBoL;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.53 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-SG2-obe.outbound.protection.outlook.com (mail-eopbgr1310053.outbound.protection.outlook.com. [40.107.131.53])
        by mx.google.com with ESMTPS id x13si18160323pga.2.2019.04.09.23.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Apr 2019 23:06:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.53 as permitted sender) client-ip=40.107.131.53;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=B84SeBoL;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.53 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ynrFHRlZLrj5J+eHpTcvYxhKBma448ynGvYpIOwKqZk=;
 b=B84SeBoLbbtVkwbBVgf5tZWBOduQogOzy+ZJ8ATNuN5dg1VuAcHQ9zX9r0n3LuX2ic3CM/qaA/aTwEQWH7iGsF9Igp2DrRlTLAjz8Mun3BpCXTugbYGDfwcYpTwDu9uqV/oLZ+B15u7lmVH7mznHkN9Eugw26DgkcsTHHnLZtPU=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB1567.apcprd02.prod.outlook.com (10.167.77.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.19; Wed, 10 Apr 2019 06:06:36 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1771.019; Wed, 10 Apr 2019
 06:06:36 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: Christopher Lameter <cl@linux.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [External] Re: Basics : Memory Configuration
Thread-Topic: [External] Re: Basics : Memory Configuration
Thread-Index: AQHU7qEJC6EuUiGvjEiZ+OVh95dcd6Yz/amAgADo4Wc=
Date: Wed, 10 Apr 2019 06:06:36 +0000
Message-ID:
 <SG2PR02MB30989B644196598CEDDD5337E82E0@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098925678D8D40B683E10E2E82D0@SG2PR02MB3098.apcprd02.prod.outlook.com>,<0100016a02d5038e-2e436033-7726-4d2a-b29d-d3dbc4c66637-000000@email.amazonses.com>
In-Reply-To:
 <0100016a02d5038e-2e436033-7726-4d2a-b29d-d3dbc4c66637-000000@email.amazonses.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: cc86bda2-c7a8-422d-8c58-08d6bd7ab055
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SG2PR02MB1567;
x-ms-traffictypediagnostic: SG2PR02MB1567:
x-microsoft-antispam-prvs:
 <SG2PR02MB15676281446B4EBE6DB49FA7E82E0@SG2PR02MB1567.apcprd02.prod.outlook.com>
x-forefront-prvs: 00032065B2
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(39840400004)(376002)(136003)(366004)(396003)(189003)(199004)(66066001)(54906003)(25786009)(478600001)(33656002)(6116002)(3846002)(76176011)(2906002)(55016002)(78486014)(6436002)(86362001)(52536014)(7696005)(11346002)(229853002)(14454004)(71200400001)(6916009)(446003)(71190400001)(316002)(186003)(14444005)(4326008)(7736002)(53936002)(105586002)(256004)(81166006)(5660300002)(99286004)(6246003)(476003)(55236004)(6506007)(9686003)(8676002)(53546011)(106356001)(8936002)(66574012)(97736004)(81156014)(68736007)(44832011)(74316002)(305945005)(486006)(26005)(5024004)(102836004)(586874002);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB1567;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 bmlzdzWn2Pk1q+5mTtZD2YfVM4p8MYkS2goKRW2wAiGy3RGQ5ZA+V1EAlAr02T/h9h9tivL/4aZi4r8ZyEjCtBh19n8bwbymr9vwGmayKtsH2Ck1uG6De9jH5PFvDWs1nXlLAoJHGsiQqXVPwzEgR3sjzs46gKhGdkM0xwHnPayqhi/0BfUOOLgwo0PTPYaNU8PuyFx8gKlI9tOdR2dLCskYMBq9mPNcYb7xmpdC+f1hdDJO696BMrmebIWtGf2zzlhjSm50YGZpXtk6Yy/U2WUHP3b+mlH4XWzHRFs8aM3d4KOJx/+Tv/qr0rgl1NZtYLjNxBmZCkrbnYaHq9GzaC34fcrKhex5/Nf/keW2C5fzWYE8DnYoHn74JaVB1B+d33RV/i2YHlGKpyLijCKgPhU3R7NWufaLGyUlTROKy7M=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: cc86bda2-c7a8-422d-8c58-08d6bd7ab055
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 Apr 2019 06:06:36.0929
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB1567
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


________________________________________
From: Christopher Lameter <cl@linux.com>
Sent: 09 April 2019 21:31
To: Pankaj Suryawanshi
Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org
Subject: [External] Re: Basics : Memory Configuration


On Tue, 9 Apr 2019, Pankaj Suryawanshi wrote:


> I am confuse about memory configuration and I have below questions

Hmmm... Yes some of the terminology that you use is a bit confusing.

> 1. if 32-bit os maximum virtual address is 4GB, When i have 4 gb of ram
> for 32-bit os, What about the virtual memory size ? is it required
> virtual memory(disk space) or we can directly use physical memory ?

The virtual memory size is the maximum virtual size of a single process.
Multiple processes can run and each can use different amounts of physical
memory. So both are actually independent.

The size of the virtual memory space per process is configurable on x86 32
bit (2G, 3G, 4G). Thus the possible virtual process size may vary
depending on the hardware architecture and the configuration of the
kernel.

If i have configures VMSPLIT =3D 2G/2G what does it mean ?
Virtual memory uses disk space ? let say for 32-bit os i have 4GB ram than =
what is the use case of virtual memory ?

If i have 32-bit and 2gb/3gb ram than virtual memory is useful  because its=
 less than 4GB ?

> 2. In 32-bit os 12 bits are offset because page size=3D4k i.e 2^12 and
> 2^20 for page addresses
>    What about 64-bit os, What is offset size ? What is page size ? How it=
 calculated.

12 bits are passed through? Thats what you mean?

The remainder of the bits  are used to lookup the physical frame
number(PFN) in the page tables.

64 bit is the same. However, the number of bits used for lookups in the
page tables are much higher.

for 32-bit os page size is 4k, what is the page size for 64-bit os ? page s=
ize and offset is related to each other ?

if i increase the page size from 4k to 8k, does it change the offset size t=
hat it 2^12 to 2^13 ?

Why only 48 bits are used in 64-bit os ?


> 3. What is PAE? If enabled how to decide size of PAE, what is maximum
> and minimum size of extended memory.

PAE increases the physical memory size that can be addressed through a
page table lookup. The number of bits that can be specified in the PFN is
increased and thus more than 4GB of physical memory can be used by the
operating system. However, the virtual memory size stays the same and an
individual process still cannot use more memory.

Let say i have ,enabled PAE for 32-bit os with 6GB ram.Virtual size is same=
 4GB, 32-bit os cant address more thatn 4gb, Than what is the use of 6GB wi=
th PAE enabled.

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

