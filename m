Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52517C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:16:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7D582084B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:16:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="vtKla7/v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7D582084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 799A56B0005; Tue, 26 Mar 2019 05:16:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 721BE6B0006; Tue, 26 Mar 2019 05:16:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59AF86B0007; Tue, 26 Mar 2019 05:16:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1162D6B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:16:15 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o4so11420948pgl.6
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:16:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=D88G+Vh5U3UtxzazzAqekvx4X29mAS8ojsGLDNKgfT8=;
        b=runGNsEnWMhVU8rUyfWk63OeJD7/4NSakzx06JeY2R9Ojv6Zrqvc0OPdbvdVAirvBg
         WclEI22yAPTVvspr/Ha4ENwwiGHOVZMNuvjguG+REqbj0tQZ1IAFE33PGqKcUYYIsg/i
         bvvF6Dej75yOmzxBlX+NXqdZ1c+Lf5BoGQlYV4cH/UEfu5zZWEKhryGrwFjJFJ+C90rw
         b7yJrQq8azid1UtVpHLEFalV1NcI5xj9xMONHb3rb5B3GJK8D4GgZzd6tE+ytuDzjHuE
         GjDfzFBoYj0tH4ZSCdJErCBu4OZVOaYyq66yygpii+fHcuqQZo1kcAFJxJdtVdGsEyGu
         LPGQ==
X-Gm-Message-State: APjAAAXkdFQIyeMZNDvodbixAuoHuitXJK9gyKlJ2Q2Lebver1o1n3H6
	slePMm7wkFBFYUitv0jzzinAf7REUZHBYBHWQxcYvEPTw9GMNVB8s6K3Qw2jdKnbMyLnNwztxhL
	8J22F6eyF+s9gngeFCbZKN66GOa2bSD6xC0C+hjY6HewaJSAIk+R/7V7dgpZan6Y9NA==
X-Received: by 2002:a17:902:b20e:: with SMTP id t14mr29522366plr.97.1553591774674;
        Tue, 26 Mar 2019 02:16:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVbWmZEbjrXz7EyaOe9wbuuO8Uxd9AOjNdOxPAf/kkuGWGEnGtKXM791B0SXLkGPW1i/Ex
X-Received: by 2002:a17:902:b20e:: with SMTP id t14mr29522321plr.97.1553591774053;
        Tue, 26 Mar 2019 02:16:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553591774; cv=none;
        d=google.com; s=arc-20160816;
        b=cEOlSQOkjuSHN1ZdK1gmHtRoSUACan6Aeown26I+tX6ggZwut05B70JzF1XJ14n2rd
         lW9GPjBLtxSFio2BcwMQMjLsmoePQmcWUJAVyZfPtIL2ZRV+UZ6NVWn8lXZjamuP9p6n
         ILxdDrsgGDRoDcqQRI21qTwyqVLK/y0zca+ueHgtDVhrmkCRp9uEG3bgkBbkqWGBfPHj
         OlXS7UvwymPXIzWlyB6hIh6Rl2+0EjfGQ60etHvRcCciswUlDtM/XaGgzte5OxN0t9+y
         0+RDKZ5I5d7cgtGzjKFA0ASAPVLG/1hS8ixQ/EynoornAlM//OBUueUQL1E0OO/pdAvn
         uTDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=D88G+Vh5U3UtxzazzAqekvx4X29mAS8ojsGLDNKgfT8=;
        b=XidTt4NBPW6G1NYMb8XEPIfvXiVc8InPu+b/92m286I/Am9CcAxpkCb+p3f/6nbYH+
         PWTmpO5ZGLUWhvHmMh/nk8HoWsa61e3ZAYGbEpGerJ3gCh2FnjtdXr9E90c4pYn3po4a
         YmkfTJG1xLR9J/LNy+5lG/5gbl0U6m2ze55s3lXNEQBr/lzddh/Mt3od4GL2AbiIT/lC
         Azykrtm8NV2hONnfF8MhbTKeRGX57A9RT6y87jCiZjpnC0Fvovs1vI9wZnxdaHEfjhqi
         uXXvmlZdAXVWK3YpNIuAOIIIi5CpeAyxPFx2FlxBKNNm8pY1W+ZUpfRZ+RZ1DbGzNQ3i
         rdBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b="vtKla7/v";
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.48 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-HK2-obe.outbound.protection.outlook.com (mail-eopbgr1300048.outbound.protection.outlook.com. [40.107.130.48])
        by mx.google.com with ESMTPS id r190si5236691pfc.14.2019.03.26.02.16.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:16:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.48 as permitted sender) client-ip=40.107.130.48;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b="vtKla7/v";
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.48 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=D88G+Vh5U3UtxzazzAqekvx4X29mAS8ojsGLDNKgfT8=;
 b=vtKla7/v3LR4Tgykdc1KFn6myJ2HwI2yMXTPeicaVrUICtB/RmvflByRxc7qZYVZhG2wMcX6Z2Ut4Nk8H0y/9VSrXVpzaBIMweFtfuAQYI0U5rVE/QULi4mL7yDw0pjF8HVB7yaKymmT9mISQRVtKz4yJeyoXKzegOLk+57On4Y=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB4249.apcprd02.prod.outlook.com (20.179.102.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.17; Tue, 26 Mar 2019 09:16:12 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1730.019; Tue, 26 Mar 2019
 09:16:12 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: Michal Hocko <mhocko@kernel.org>
CC: Kirill Tkhai <ktkhai@virtuozzo.com>, Vlastimil Babka <vbabka@suse.cz>,
	"aneesh.kumar@linux.ibm.com" <aneesh.kumar@linux.ibm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"minchan@kernel.org" <minchan@kernel.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "khandual@linux.vnet.ibm.com"
	<khandual@linux.vnet.ibm.com>
Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
Thread-Topic: [External] Re: vmscan: Reclaim unevictable pages
Thread-Index:
 AQHU3WaYCAMWaFadm0e/0+hd2XPYGaYRGYZ/gAAG5oCAAAD82oAAAx4AgAABDq2AAAzwgIAC47DNgAmAbsCAABOgAIAAA15X
Date: Tue, 26 Mar 2019 09:16:11 +0000
Message-ID:
 <SG2PR02MB3098FAEA335228CFB56F1668E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098E6F2C4BAEB56AE071EDCE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <0b86dbca-cbc9-3b43-e3b9-8876bcc24f22@suse.cz>
 <SG2PR02MB309841EA4764E675D4649139E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <56862fc0-3e4b-8d1e-ae15-0df32bf5e4c0@virtuozzo.com>
 <SG2PR02MB3098EEAF291BFD72F4163936E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <4c05dda3-9fdf-e357-75ed-6ee3f25c9e52@virtuozzo.com>
 <SG2PR02MB309869FC3A436C71B50FA57BE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <09b6ee71-0007-7f1d-ac80-7e05421e4ec6@virtuozzo.com>
 <SG2PR02MB309864258DBE630AD3AD2E10E8410@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB309824F3FCD9B0D1DF689390E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>,<20190326090142.GH28406@dhcp22.suse.cz>
In-Reply-To: <20190326090142.GH28406@dhcp22.suse.cz>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d0efc8f5-9ce2-41a8-65b8-08d6b1cbb0b2
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB4249;
x-ms-traffictypediagnostic: SG2PR02MB4249:|SG2PR02MB4249:
x-microsoft-antispam-prvs:
 <SG2PR02MB4249BC2A7F5436F80FD23863E85F0@SG2PR02MB4249.apcprd02.prod.outlook.com>
x-forefront-prvs: 09888BC01D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(39850400004)(366004)(396003)(376002)(136003)(189003)(199004)(8936002)(52536014)(9686003)(476003)(74316002)(71200400001)(6116002)(105586002)(53936002)(54906003)(305945005)(6246003)(25786009)(55016002)(486006)(93886005)(316002)(33656002)(8676002)(5660300002)(11346002)(6506007)(7696005)(446003)(3846002)(6916009)(44832011)(68736007)(102836004)(53546011)(229853002)(55236004)(2906002)(14444005)(186003)(256004)(5024004)(106356001)(7736002)(76176011)(26005)(78486014)(81166006)(81156014)(14454004)(86362001)(6436002)(97736004)(66066001)(99286004)(66574012)(4326008)(478600001)(71190400001)(586874002);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB4249;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 14gN9kp6Yz+7tFHuZSR99p9ClLUkIKrz2aMS1hw63XQd/c45+hOK31pobFsGftdBQ3cVie0ENPVZsJfTk46LQAujdxDBq9muwPSrRfCq/xFD7kG3QXAkZRCh4rkJk67I3ekuEehJaOVbPknNcbY6da2Ak6Eq7zoatGuWG7Aieb143/zsa9W0LEhJuyZ+NqsdvV0sBE7XklAXr1R4RMX3MuRm4WUkuQr6PRCjmpmBNHc1vcMx3l9w5q0JZ9GXi0kFVX3KnYsQkp7+evJgJJbz8jlEr9rlbwGDhmaC5HJvPoJX3G3s1f+VyftA2SnXzul637IyulLFqAf6duNBtLf8AFvb2wINbG/zWnmaC682lstnZuYSZgUPTaVuk3Fa/m8BtkgaDfId48g3ce4dRj4nQz2IiTwZRBlZlxbjcwWx3Zw=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d0efc8f5-9ce2-41a8-65b8-08d6b1cbb0b2
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Mar 2019 09:16:11.8621
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB4249
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


________________________________________
From: Michal Hocko <mhocko@kernel.org>
Sent: 26 March 2019 14:31
To: Pankaj Suryawanshi
Cc: Kirill Tkhai; Vlastimil Babka; aneesh.kumar@linux.ibm.com; linux-kernel=
@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org; khandual@linux.vn=
et.ibm.com
Subject: Re: [External] Re: vmscan: Reclaim unevictable pages

[You were asked to use a reasonable quoting several times. This is
really annoying because it turns the email thread into a complete mess]

[Already fix the email client, but dont know the reason for quoting Maybe a=
ccount issue.]

On Tue 26-03-19 07:53:14, Pankaj Suryawanshi wrote:
> Is there anyone who is familiar with this?  Please Comment.

Not really. You are observing an unexpected behavior of the page reclaim
which hasn't changed for quite some time. So I find more probable that
your non-vanilla kernel is doing something unexpected. It would help if
you could track down how does the unevictable page get down to the
reclaim path. I assume this is a CMA page or something like that but
those shouldn't get to the reclaim path AFIR.

As i said earlier, i am using vanilla kernel 4.14.65.
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

