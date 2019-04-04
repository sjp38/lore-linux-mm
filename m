Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2023BC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:28:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF99D20820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 09:27:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="QXMBP+j/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF99D20820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 485316B0007; Thu,  4 Apr 2019 05:27:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 437336B0008; Thu,  4 Apr 2019 05:27:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3250B6B000A; Thu,  4 Apr 2019 05:27:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF3176B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 05:27:58 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n5so1209201pgk.9
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 02:27:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=5QJEwPl+CXdreFGjX7hUhAb/B83qjn99ySBy4TnWAbk=;
        b=j/hYRROPT2z73QYWmX9BwSA9LygUbDuEv+Y1zmaffR/jKvgyTPEb9LAOFxBAJsZUV2
         nuZ2XzvyZoAUdlHd/UxfPlwNFjgHFq2kehDrGJ98ICffNRKLvc1XwuunQ2KouuyF/3GP
         5XZBD/15m2kXqWlCEWw2DLKjFpo4AZDAbLMr+ljXyNDSB8JW0+QtXA5GI0d1liq5c8Lo
         MpMGQBhFjW5w/C/asXNMaGSJhdRq5E+oiZyI6vIm6fj9mLhST2lyJrMSApykWl1D4OdG
         8FU6HU9GR9zjeo0dKpJhFdB4xSBvLy7PgKrm12ZUUQm19kUVLyqHQNxc8r+fpv1m4U3H
         Cjdg==
X-Gm-Message-State: APjAAAUnxjwSrOjBLywgoaqFkFiXejbsIinNXkWzCUs5XH+C0aIy/L0V
	+6clUZYOMS96WSYmJTDCSVgDU9H2SxVvJMUKH2VP2gfPkaz70UKRbhCVB3KCnvcTPzY9vWSugD8
	Hq69D7gdVymUXOcbLeSWMQF2B7yV0JnAG5uZEZ2h5zrkd/GW7upUpz9sAe/ryb20rfQ==
X-Received: by 2002:a17:902:2888:: with SMTP id f8mr5344355plb.244.1554370078553;
        Thu, 04 Apr 2019 02:27:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyj0skoJ9Zy+Xvay3t3x+B5KegkVi+53+4xauKNHaEN2/euZvbj07B+wHC9mqgPuEeK45lt
X-Received: by 2002:a17:902:2888:: with SMTP id f8mr5344303plb.244.1554370077864;
        Thu, 04 Apr 2019 02:27:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554370077; cv=none;
        d=google.com; s=arc-20160816;
        b=WCUtkB+ll69Ha/3h2XxFMejH2noOrB+3H+C0kXb6U1mVc2cJ7kKCpnm1orOyaSjBnC
         0W62XvwGgoiFsE+1s+U0v0kAupEKQnZYEMNToB0qBZtiWWB0CQje8bP1CbAf5SMBhyh3
         wZ8Cd/QeTqu7uUNRVRYY47DDK2SQjiLaRBmyaKdaUoMCabmid6hXygi3TnBcHy4geS3C
         RYkyqk3LZli1/R/lHeckvaWD0jTp3No7c4UNve5drEuo1qvWTY5FmKLWlr35u5C2Pbul
         a3yKyQsyL8AGfjTZoteOe5eqQFDQUoIhj2mnWrHY9CXa9CPEUkaMJUrYNYmdWfen7adZ
         Fw2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:to:from:dkim-signature;
        bh=5QJEwPl+CXdreFGjX7hUhAb/B83qjn99ySBy4TnWAbk=;
        b=svr2HqrXNc7k9oaPI7qmBISjxMFGIntMYaGjxbMbcBfnxEq9gVucMaWc22iDW6aZX0
         FT/2VHkd4XFz5UDfvW6Q/CVm72Sebk0L169foktsnSCu29t9lrcpqNh8vgvNPco/PNF9
         /l6PPFYcRL7Je6ufxuGscfVD1bhgLIL1z4UaxdSiuU7p5hT/935Vw0vRtPnQI/+P3/9u
         QnOb2dEWQi3BZtufx8YDuJgQoqtexxG+6Ks7if2ShVGvjbK1k7NXIOGNWdh2pU5GJwB3
         SPLWGLDHz57gg/xUxZ0P93ghTgyn8PiKp5BAgpEHl0b0CuJn25ZXI5zHb1wH7FtYfwFQ
         KcXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b="QXMBP+j/";
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.74 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-HK2-obe.outbound.protection.outlook.com (mail-eopbgr1300074.outbound.protection.outlook.com. [40.107.130.74])
        by mx.google.com with ESMTPS id 60si16697145plf.122.2019.04.04.02.27.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 02:27:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.74 as permitted sender) client-ip=40.107.130.74;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b="QXMBP+j/";
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.74 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5QJEwPl+CXdreFGjX7hUhAb/B83qjn99ySBy4TnWAbk=;
 b=QXMBP+j/dPNHXsW6tJYHvxmLuObvJoy8gLnpU2EPuy1hFWrXLeOyMGWxP4OB4GXI2MChry09zZxYA9vFVvv00FEOXAZGwOs9iZz0SEBM6IVSAO44ANcidS6DxJWvhdbZFgU5P0bbt6eSFKR5gewmvyJZ1ZXhEI2ShezhDF0JPmA=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB3608.apcprd02.prod.outlook.com (20.177.170.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.15; Thu, 4 Apr 2019 09:27:53 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1750.017; Thu, 4 Apr 2019
 09:27:53 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: How to calculate instruction executed for function
Thread-Topic: How to calculate instruction executed for function
Thread-Index: AQHU6igi0LAQURcEFkafVLmNd6QLn6YrvLoU
Date: Thu, 4 Apr 2019 09:27:53 +0000
Message-ID:
 <SG2PR02MB309878FDF524EAE5F61228B7E8500@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098EF270AE08CB19E96C5C4E8570@SG2PR02MB3098.apcprd02.prod.outlook.com>
In-Reply-To:
 <SG2PR02MB3098EF270AE08CB19E96C5C4E8570@SG2PR02MB3098.apcprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d1e2025e-e65e-4d08-1439-08d6b8dfd0c3
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SG2PR02MB3608;
x-ms-traffictypediagnostic: SG2PR02MB3608:
x-microsoft-antispam-prvs:
 <SG2PR02MB3608E4ADCC4CF947328DA1F2E8500@SG2PR02MB3608.apcprd02.prod.outlook.com>
x-forefront-prvs: 0997523C40
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(396003)(39850400004)(136003)(366004)(376002)(189003)(199004)(33656002)(186003)(26005)(6436002)(3846002)(2501003)(6116002)(476003)(446003)(105586002)(316002)(68736007)(106356001)(2906002)(11346002)(229853002)(53936002)(25786009)(110136005)(6246003)(305945005)(7736002)(97736004)(74316002)(99286004)(5024004)(486006)(5660300002)(44832011)(66574012)(52536014)(478600001)(14454004)(7696005)(8936002)(8676002)(102836004)(76176011)(53546011)(78486014)(6506007)(71190400001)(86362001)(55016002)(9686003)(71200400001)(55236004)(81166006)(81156014)(14444005)(256004)(66066001)(586874002);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB3608;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 tRiJbYgaqEl8TEz0/uORLDPaQ2dWghbagmdfWJcv/694uhTNFCz+5bUQlh++zPhsOjwBUUfUc5LSNENYAnxwTkbiaFCzw2KE7gnuW2te51gTe/c3oisn9fhQF+VgmL+oXgJbwyOLkEuXwe2+06W1rHD5c1AAdy3O0n56Fy9C4CKuRlda0+kD6s2joNanEt72P94fqwjTOtN0cUJERtH4Qgp+Ladwan1N5qnk8EmO+/jhl/AjTNKenX72EbjvgbvUNdzpJNW+Yz0WixxiP3wGMVTs58soZtvTLz3qhTXgKIqtuWA3WquyiVdueozcTFbOpoXdhtQeTKIGIrtVnsQW6fsxLqF/9B7HO59uHsrzxJvsXQJ62Mo5M3pI9xbMD7FtCrmXtDrjTl1ZLI+0MuNx2oZjQ2YK5FLkdPO7y/mJv/M=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d1e2025e-e65e-4d08-1439-08d6b8dfd0c3
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Apr 2019 09:27:53.7355
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB3608
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


________________________________________
From: Pankaj Suryawanshi
Sent: 03 April 2019 19:50
To: linux-mm@kvack.org; linux-kernel@vger.kernel.org
Subject: How to calculate instruction executed for function

Hello,

How to calculate instruction executed for function ?

For eg.

I need to calculate instruction executed for CMA_ALLOC function.
How many instruction executed for cma_alloc ?


CMA_ALLOC :

        for 1 cma_alloc success call there will around 75 instruction is ex=
ecuted, excluding jump, mutex,error case and debug info instruction.

        below are mandatory jump calls that are required for successful all=
ocations.

        cma_bitmap_aligned_mask
        cma_bitmap_aligned_offset
        cma_bitmap_maxno
        cma_bitmap_pages_to_bits
        bitmap_find_next_zero_area_off -> find_next_zero_bit -> find_next_b=
it
        bitmap_set
        alloc_contig_range -> start_isolate_page_range
        __alloc_contig_migrate_range -> isolate_migratepages_range -> recla=
im_clean_pages_from_list -> shrink_page_list -> migrate_pages


        So lets say

        cma_bitmap_aligned_mask  =3D 1 instrs
        cma_bitmap_aligned_offset =3D 1 instrs
        cma_bitmap_maxno                  =3D 1 instrs
        cma_bitmap_pages_to_bits  =3D 1 instrs

        bitmap_find_next_zero_area_off -> find_next_zero_bit -> find_next_b=
it =3D 3 instrs
        bitmap_set  =3D 1 instrs
        alloc_contig_range -> start_isolate_page_range =3D

                                has_unmovable_pages =3D 1 instrs
                                get_pfnblock_flags_mask =3D 1 instrs
                                set_pageblock_migratetype =3D 1 instrs
                                move_freepages_block =3D 1 instrn
                                __mod_zone_page_state =3D 1 instrs store in=
fo in vmstat
                                unset_migratetype_isolate =3D 1 instrs

        __alloc_contig_migrate_range -> isolate_migratepages_range -> recla=
im_clean_pages_from_list -> shrink_page_list -> migrate_pages


        isolate_migratepages_range =3D 3 instrs
        reclaim_clean_pages_from_list =3D 2 instrs
        migrate_pages =3D 1 instrs

        --------------------------------------------------------------
        Total =3D around 20 instrs per page

        20 ns per page on 1ghz processor is minimum excluding any overheads=
 like mutex, variables, failure/error case,debug/prints.

I roughly calculated this.
Is it Correct ?


Any help would be appreciated.

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

