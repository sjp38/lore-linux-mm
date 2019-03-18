Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 460B9C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:43:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4E992083D
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:43:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="NUefAe0j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4E992083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FF5E6B0007; Mon, 18 Mar 2019 05:43:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 287206B0008; Mon, 18 Mar 2019 05:43:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DCFC6B000A; Mon, 18 Mar 2019 05:43:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B672D6B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 05:43:11 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id p127so18043535pga.20
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 02:43:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=fLpoGd/9J1BXkIwPzl0F60fCH9yJiaJoywJBV2fSvoc=;
        b=b3eb2mux98Ai2lcnNiYn7lMPzVJWoK76l42HaHZfpmu//KTN9hJMjYRjhT+WO9xboN
         DTtlLbgxyeoPS9yrPPKkOUE6kmPc/pArnWgvkYiLiM6cXAJZoamigbdsoKSyNvOFWru7
         5s4gg4tjTLYb1L/SAJPl3rBnqCkBFbmVwbPrARWUfauY/d6Js1wNKgPeRF0e7gXpXQsx
         Hd8pzfUQ5A6yrd4fw1ulwTDyVdHWHc/mtcm9O526akSTUp5B1X14UfcFQWsQEV0o4OUy
         6/q/exnEveDp+QLXAvWIwMFfDUrtgryk37O/G8q/VxeWGEzrl1f92u7e3gsCKiNE8gAe
         D9UA==
X-Gm-Message-State: APjAAAWfVQPT+3fC4DeQiC/kDkcvwkUA8YBYDLmOjfcfyXoWZvXDwYx8
	YY8af7J06P+hNO3LN3sg7hs64YiKID6rtWNekBCP5DJ8y1EazTOjhh4IRz8FpSYsmjbRVJQxWHB
	CefR+yusWqQXvd0x2umZq44PrAAw/PCJrvXwOLScVVXI3PMAzzIhItWy9Cvy7qvcaug==
X-Received: by 2002:a17:902:1008:: with SMTP id b8mr18431794pla.120.1552902191172;
        Mon, 18 Mar 2019 02:43:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMgm27vuNDNsRi7T9oW6UokvD1y1am9MtqE6P3LIT7C1NZ1gAyZBuWVWe6BhDp//WGlzLF
X-Received: by 2002:a17:902:1008:: with SMTP id b8mr18431725pla.120.1552902190104;
        Mon, 18 Mar 2019 02:43:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552902190; cv=none;
        d=google.com; s=arc-20160816;
        b=iM7bT5hf8wVtSAjhtHW4cII1gpIlG8slge1k/AYbnYBuHyQjyIMFs2F8SzWHf+H2TV
         S95nKdtiRnXY+xI1heHHLLHSd4vFIkei/2vvBHBhKfEC7Rbz3I37I0FRvdaFLrB9O5T7
         oXKKF7dADoFy/0q/nD8WIh98sHofVNFod6k5QANLlaOLXqMnhqHF/Hyx1sgwm5mzzLSH
         vKqe8dzNFIRH6dvFOpCd0rRI8VQ4Z9SqLHHy1cN1yqZb7MSDkRy4qwvdnL4FJvUGo46P
         DluDCjrTQcquJ3rqWgGlvNSzKcR3v32L854trsfSY7i8y6s6FPWn+L2Zo/9v6jCX11Pq
         XEHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=fLpoGd/9J1BXkIwPzl0F60fCH9yJiaJoywJBV2fSvoc=;
        b=H2Nkj7AQxZaGDpb7BGhib1ljcZOHSTv/OmaMeIRDNT/xZtK1nqydya7RVNhxEk4Vi0
         v/AYLG34ULYB6p2cO47bN4xuJTXGFEbseTGEQj6ISJh7cwBH+/ULZRBH4fyPNSralSZJ
         6rTWr8egTctan3/f01SMcO6l8hRCsaO7MGH+W600DQknoZad8tuh1LC6vN0mrspA4gVS
         AI3k0/XHXJ0ZDLHnRjnancF9PYIcmMSXn7Kfh9w2wwmTyhpiaDs/cnwM20tPzFO2qJpY
         /P+D7S+RO6WsgGPm7M/ecYtqUe1MyxnAKyZWEg4SR1mdTJ3bkcUeN6ibr/82ikIaRr9M
         NZxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=NUefAe0j;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.83 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-PU1-obe.outbound.protection.outlook.com (mail-eopbgr1320083.outbound.protection.outlook.com. [40.107.132.83])
        by mx.google.com with ESMTPS id g1si8263425pgq.227.2019.03.18.02.43.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 02:43:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.83 as permitted sender) client-ip=40.107.132.83;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=NUefAe0j;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.83 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=fLpoGd/9J1BXkIwPzl0F60fCH9yJiaJoywJBV2fSvoc=;
 b=NUefAe0jeBbxwagqbGmLHbKmeNE9w1KaOMhcelsFVgev89jtJMzY83YqzQirTz0GECRZNnOU0RZOHv43Ooxrk6zjRROIs+r2Q33/sehfe4CvtC57RS29ENigS6pajPjptavchH/l96h83vgDjc8mdnGTvpLZM51Gb9LefSeRKks=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB3608.apcprd02.prod.outlook.com (20.177.170.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.14; Mon, 18 Mar 2019 09:43:04 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1709.015; Mon, 18 Mar 2019
 09:43:04 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>, Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@kernel.org>, "aneesh.kumar@linux.ibm.com"
	<aneesh.kumar@linux.ibm.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"minchan@kernel.org" <minchan@kernel.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "khandual@linux.vnet.ibm.com"
	<khandual@linux.vnet.ibm.com>, "hillf.zj@alibaba-inc.com"
	<hillf.zj@alibaba-inc.com>
Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
Thread-Topic: [External] Re: vmscan: Reclaim unevictable pages
Thread-Index: AQHU3WaYCAMWaFadm0e/0+hd2XPYGaYRGYZ/gAAG5oCAAAD82g==
Date: Mon, 18 Mar 2019 09:43:04 +0000
Message-ID:
 <SG2PR02MB3098EEAF291BFD72F4163936E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098A05E09B0D3F3CB1C3B9BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB309806967AE91179CAFEC34BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098B751EC6B8E32806A42FBE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190314084120.GF7473@dhcp22.suse.cz>
 <SG2PR02MB309894F6D7DF9148846088F3E84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <226a92b9-94c5-b859-c54b-3aacad3089cc@virtuozzo.com>
 <SG2PR02MB3098299456FB6AE2FD822C4CE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB30988333AD658F8124070ABEE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098AB587F4BFCD6B9D042FDE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098E6F2C4BAEB56AE071EDCE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <0b86dbca-cbc9-3b43-e3b9-8876bcc24f22@suse.cz>
 <SG2PR02MB309841EA4764E675D4649139E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>,<56862fc0-3e4b-8d1e-ae15-0df32bf5e4c0@virtuozzo.com>
In-Reply-To: <56862fc0-3e4b-8d1e-ae15-0df32bf5e4c0@virtuozzo.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2f924ac6-db8f-48bc-b334-08d6ab861e6a
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB3608;
x-ms-traffictypediagnostic: SG2PR02MB3608:|SG2PR02MB3608:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <SG2PR02MB360808C2E3A957348B762E2EE8470@SG2PR02MB3608.apcprd02.prod.outlook.com>
x-forefront-prvs: 098076C36C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39840400004)(376002)(136003)(346002)(366004)(396003)(54534003)(199004)(189003)(256004)(5024004)(14444005)(4326008)(26005)(102836004)(78486014)(55236004)(6506007)(478600001)(53546011)(186003)(99286004)(25786009)(2906002)(33656002)(7696005)(14454004)(81156014)(81166006)(68736007)(316002)(105586002)(8936002)(93886005)(7736002)(305945005)(8676002)(74316002)(76176011)(106356001)(229853002)(55016002)(6436002)(9686003)(6306002)(53936002)(97736004)(54906003)(110136005)(3846002)(966005)(6246003)(71190400001)(71200400001)(446003)(486006)(5660300002)(44832011)(2501003)(52536014)(66574012)(11346002)(476003)(86362001)(6116002)(66066001);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB3608;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 iWgcn1uVKIbEp4RPLYmBxc+6EG3OicqwxcCsZ16YRcWQ4TMI7nqLisz9lQTJk3YMikLr3uYqQ5iBp5/5X2lH/li4L5qfsnqH7CWDgC+1xa+tqaZJAm9pgiBTlslOUn6hfTwuTx40sIA8jJJhPMfuJH+cErHt4CmaMmeD7nVlmSmbG2zvIiVQxzWY3h0+lqelyFWwsp/yqWltHIsVyJ8mf1IHaSYs3WHn7VlDco1k+IALxhWPF0OKCFVf8u/Y/VEoJVuQvmSWL6r7gX44hKSBwHU4+OxYRaB528Zp7g/GugqYmbHsdnaYlfkhYa1/Y62ZePtFd0NfTDCDU8Qrx9HLDqOhO5kyI9RsKxzS+BwbixidWzYEjgdSfmmOwavkvXg1exjdd99TggS723Q4PZOEvVzyhzvLoh1oGhBHLdTdjyo=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2f924ac6-db8f-48bc-b334-08d6ab861e6a
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Mar 2019 09:43:04.2089
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB3608
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Kirill Tkhai,

Please see mm/vmscan.c in which it first added to list and than throw the e=
rror :
---------------------------------------------------------------------------=
-----------------------
keep:
                list_add(&page->lru, &ret_pages);
                VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page=
);
---------------------------------------------------------------------------=
------------------------

Before throwing error, pages are added to list, this is under iteration of =
shrink_page_list().

From: Kirill Tkhai <ktkhai@virtuozzo.com>
Sent: 18 March 2019 15:03:15
To: Pankaj Suryawanshi; Vlastimil Babka; Michal Hocko; aneesh.kumar@linux.i=
bm.com
Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org; k=
handual@linux.vnet.ibm.com; hillf.zj@alibaba-inc.com
Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
=A0=20

Hi, Pankaj,

On 18.03.2019 12:09, Pankaj Suryawanshi wrote:
>=20
> Hello
>=20
> shrink_page_list() returns , number of pages reclaimed, when pages is une=
victable it returns VM_BUG_ON_PAGE(PageLRU(page) || PageUnevicatble(page),p=
age);

the general idea is shrink_page_list() can't iterate PageUnevictable() page=
s.
PageUnevictable() pages are never being added to lists, which shrink_page_l=
ist()
uses for iteration. Also, a page can't be marked as PageUnevictable(), when
it's attached to a shrinkable list.

So, the problem should be somewhere outside shrink_page_list().

I won't suggest you something about CMA, since I haven't dived in that code=
.

> We can add the unevictable pages in reclaim list in shrink_page_list(), r=
eturn total number of reclaim pages including unevictable pages, let the ca=
ller handle unevictable pages.
>=20
> I think the problem is shrink_page_list is awkard. If page is unevictable=
 it goto activate_locked->keep_locked->keep lables, keep lable list_add the=
 unevictable pages and throw the VM_BUG instead of passing it to caller whi=
le it relies on caller for non-reclaimed-non-unevictable=A0  page's putback=
.
> I think we can make it consistent so that shrink_page_list could return n=
on-reclaimed pages via page_list and caller can handle it. As an advance, i=
t could try to migrate mlocked pages without retrial.
>=20
>=20
> Below is the issue of CMA_ALLOC of large size buffer : (Kernel version - =
4.14.65 (On Android pie [ARM])).
>=20
> [=A0=A0 24.718792] page dumped because: VM_BUG_ON_PAGE(PageLRU(page) || P=
ageUnevictable(page))
> [=A0=A0 24.726949] page->mem_cgroup:bd008c00
> [=A0=A0 24.730693] ------------[ cut here ]------------
> [=A0=A0 24.735304] kernel BUG at mm/vmscan.c:1350!
> [=A0=A0 24.739478] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
>=20
>=20
> Below is the patch which solved this issue :
>=20
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index be56e2e..12ac353 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -998,7 +998,7 @@ static unsigned long shrink_page_list(struct list_hea=
d *page_list,
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sc->nr_scanned++;
> =A0
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (unlikely(!page_evictabl=
e(page)))
> -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto =
activate_locked;
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto cul=
l_mlocked;
> =A0
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (!sc->may_unmap && page_=
mapped(page))
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 got=
o keep_locked;
> @@ -1331,7 +1331,12 @@ static unsigned long shrink_page_list(struct list_=
head *page_list,
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 } else
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 lis=
t_add(&page->lru, &free_pages);
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 continue;
> -
> +cull_mlocked:
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (PageSwapCache(page))
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 tr=
y_to_free_swap(page);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 unlock_page(page);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 list_add(&page->lru, &ret_=
pages);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 continue;
> =A0activate_locked:
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /* Not a candidate for swap=
ping, so reclaim swap space. */
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (PageSwapCache(page) && =
(mem_cgroup_swap_full(page) ||
>=20
>=20
>=20
>=20
> It fixes the below issue.
>=20
> 1. Large size buffer allocation using cma_alloc successful with unevictab=
le pages.
>=20
> cma_alloc of current kernel will fail due to unevictable page
>=20
> Please let me know if anything i am missing.
>=20
> Regards,
> Pankaj
>=A0=A0=20
> From: Vlastimil Babka <vbabka@suse.cz>
> Sent: 18 March 2019 14:12:50
> To: Pankaj Suryawanshi; Kirill Tkhai; Michal Hocko; aneesh.kumar@linux.ib=
m.com
> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org;=
 khandual@linux.vnet.ibm.com; hillf.zj@alibaba-inc.com
> Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
> =A0=20
>=20
> On 3/15/19 11:11 AM, Pankaj Suryawanshi wrote:
>>
>> [ cc Aneesh kumar, Anshuman, Hillf, Vlastimil]
>=20
> Can you send a proper patch with changelog explaining the change? I
> don't know the context of this thread.
>=20
>> From: Pankaj Suryawanshi
>> Sent: 15 March 2019 11:35:05
>> To: Kirill Tkhai; Michal Hocko
>> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org
>> Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages
>>
>>
>>
>> [ cc linux-mm ]
>>
>>
>> From: Pankaj Suryawanshi
>> Sent: 14 March 2019 19:14:40
>> To: Kirill Tkhai; Michal Hocko
>> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org
>> Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages
>>
>>
>>
>> Hello ,
>>
>> Please ignore the curly braces, they are just for debugging.
>>
>> Below is the updated patch.
>>
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index be56e2e..12ac353 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -998,7 +998,7 @@ static unsigned long shrink_page_list(struct list_he=
ad *page_list,
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sc->nr_scanned++;
>>
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (unlikely(!page_evic=
table(page)))
>> -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto=
 activate_locked;
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto cu=
ll_mlocked;
>>
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (!sc->may_unmap && p=
age_mapped(page))
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 goto keep_locked;
>> @@ -1331,7 +1331,12 @@ static unsigned long shrink_page_list(struct list=
_head *page_list,
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 } else
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 list_add(&page->lru, &free_pages);
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 continue;
>> -
>> +cull_mlocked:
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (PageSwapCache(page))
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 t=
ry_to_free_swap(page);
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 unlock_page(page);
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 list_add(&page->lru, &ret=
_pages);
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 continue;
>> =A0 activate_locked:
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /* Not a candidate for =
swapping, so reclaim swap space. */
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (PageSwapCache(page)=
 && (mem_cgroup_swap_full(page) ||
>>
>>
>>
>> Regards,
>> Pankaj
>>
>>
>> From: Kirill Tkhai <ktkhai@virtuozzo.com>
>> Sent: 14 March 2019 14:55:34
>> To: Pankaj Suryawanshi; Michal Hocko
>> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org
>> Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages
>>
>>
>> On 14.03.2019 11:52, Pankaj Suryawanshi wrote:
>>>
>>> I am using kernel version 4.14.65 (on Android pie [ARM]).
>>>
>>> No additional patches applied on top of vanilla.(Core MM).
>>>
>>> If=A0 I change in the vmscan.c as below patch, it will work.
>>
>> Sorry, but 4.14.65 does not have braces around trylock_page(),
>> like in your patch below.
>>
>> See=A0=A0=A0=A0=A0  https://git.kernel.org/pub/scm/linux/kernel/git/stab=
le/linux.git/tree/mm/vmscan.c?h=3Dv4.14.65
>>
>> [...]
>>
>>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>>> index be56e2e..2e51edc 100644
>>>> --- a/mm/vmscan.c
>>>> +++ b/mm/vmscan.c
>>>> @@ -990,15 +990,17 @@ static unsigned long shrink_page_list(struct lis=
t_head *page_list,
>>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 page =3D lru_to_pa=
ge(page_list);
>>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 list_del(&page->lr=
u);
>>>>
>>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (!trylock_page(pag=
e)) {
>>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 goto keep;
>>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }
>>
>> ************************************************************************=
***************************************************************************=
********** eInfochips Business Disclaimer: This e-mail message and all atta=
chments transmitted with it are  intended=A0 solely for the use of the addr=
essee and may contain legally privileged and confidential information. If t=
he reader of this message is not the intended recipient, or an employee or =
agent responsible for delivering this message to the intended recipient,  y=
ou=A0 are hereby notified that any dissemination, distribution, copying, or=
 other use of this message or its attachments is strictly prohibited. If yo=
u have received this message in error, please notify the sender immediately=
 by replying to this message and  please=A0 delete it from your computer. A=
ny views expressed in this message are those of the individual sender unles=
s otherwise stated. Company has taken enough precautions to prevent the spr=
ead of viruses. However the company accepts no liability for any damage  ca=
used=A0 by any virus transmitted by this email. ***************************=
***************************************************************************=
*******************************************************
>>
>=20
>=A0=A0=A0=A0=20
>=20
    =

