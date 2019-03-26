Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1F03C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:12:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 892A920857
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:12:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="y9DBfgzJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 892A920857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 182256B0005; Tue, 26 Mar 2019 05:12:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12FB36B0006; Tue, 26 Mar 2019 05:12:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01EE96B0007; Tue, 26 Mar 2019 05:12:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B8D136B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:12:40 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id h15so11517587pfj.22
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:12:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=cvbt4JeyhvN08obWAs4i4mWWkT0isD328Q6xa3GbbKc=;
        b=WpRg0YMJ+U8E92NzwoSOP0SealCM0lhMTb1nudD5Y24qkaeWEWD2b4Mz7x6Y5kg85t
         kk8A1cqdnuobz4z0QNIGwjthY9btvMovSXwsozrwEovX/3q5ypjmeNl46mavEfQOrYm+
         D5ebX8z1upEOmQaMExCtLryvyui5dlXT5C9JnM30TMJvUq0GBAExLJbBJgIUIhyMGRqO
         XNdkrtvVUio1pRC/uLUkK7nf577mfkzrOUu1DbWG6YNkUBQbyVMfFek5S/b+Zv736NfR
         Qn/g78A3u5MhMmdBs5y+fG17ujHtyZcaBXcM0xQP/DszN7+WiZ/GSzBB1TyFf64swSyj
         0LDA==
X-Gm-Message-State: APjAAAVuqvDDbBdl68Kvf2GUdcF2rfVmeyPmXk7BkomE/a2HVl1gYm2W
	fTrIeAfCTsA4gFrooVC7QwYBBxW33zJN+cTHIYgvNGwsWXVFiKn4L9ayewyYdHuMP30yaF7hKDE
	xN9yLLwqSoIYjQZGnLXJ8SQKcHrz7u/rhTU0TWgb9/m55gD8kPRbOzFvdCaW6R9aexA==
X-Received: by 2002:a63:af06:: with SMTP id w6mr27309821pge.338.1553591560383;
        Tue, 26 Mar 2019 02:12:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9pRlcHxSq0HrdPCDCYoqhxIs+MfUXClO/gXs1Qo9hakr8HgKkJJSVdgbddUqk6UAopMcW
X-Received: by 2002:a63:af06:: with SMTP id w6mr27309766pge.338.1553591559578;
        Tue, 26 Mar 2019 02:12:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553591559; cv=none;
        d=google.com; s=arc-20160816;
        b=Z+S5gCZHQ0+kNqPY+6fAmJPJ92nmEXxVDSGwwLXJ6ww7/zXW3thGT99+U1hkM2TyGd
         UW/6vDq+cwoWvROdeWz78Pa7ted8wh/YhBXBLAd1/+Kuk01Ah+/ltOWVsG3NZZkVlz3g
         KNlSo5w5W7OB0Fue3z2Qkt01XygAvP52B3fBctWTT6eHFOYA0cXokyOAIQPbgWD/hdq7
         7DLa7UYVfx4SguhbtrSj6ULiazvMhvMRaJhRxoB2Nd8VYys7Zltgm8wjJCZg3nuyEDMU
         mwvXFOv6u7vrSdNObxIPEQSwToVL0hqhvxYSfMz58w+MXdwwwurpg9Isw3v9bfeSwGw3
         4IVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=cvbt4JeyhvN08obWAs4i4mWWkT0isD328Q6xa3GbbKc=;
        b=U4PyIvmwHk0b02gkqqGbkmHzU7cnWK4oCbtB9wBjWj57X7ORKFNTb/AKu0tmhQXbdp
         7izsrhzQPUzhF/TMUb5E194v0jOwKTo3ZDe8kJ41fzENk1HYrCVZaNZbWyTkg6CN4xQJ
         RgnAylwgUjTv8pzkU7injPplhvS2TVRLVXiqxf01UH42xyiShFUXrT5mttU5mjLYyg0k
         ni4a3K63hlv/O8nJikZESE0opeFhM+EQSOwdOHiu3q/5gYLkdyhEK0exSfAyY4RcDRjh
         slosksUxV9xMywlSwWSG9XyKYLQAMYhOA4av44lThcUOB8A1HzJ17ucTxQnPk/WS2Asz
         dLXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=y9DBfgzJ;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.47 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-HK2-obe.outbound.protection.outlook.com (mail-eopbgr1300047.outbound.protection.outlook.com. [40.107.130.47])
        by mx.google.com with ESMTPS id f2si15601856pgv.10.2019.03.26.02.12.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Mar 2019 02:12:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.47 as permitted sender) client-ip=40.107.130.47;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=y9DBfgzJ;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.47 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=cvbt4JeyhvN08obWAs4i4mWWkT0isD328Q6xa3GbbKc=;
 b=y9DBfgzJz6Pwfqwg9QlmakUbfPz6P2UyKYUmBrNfiBL8YHSuxDH3fc2jnMagNlFvoZP6gbbr31+Vk7ckWRP3nTc/RWaC1kHwBvKR0PyJeqTAzTE8MN7kUCNKMSHTSho/RNO0CrgeM6ni4kY+XJ4UTmSB0N0kICdKEIPfgMIdFyk=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB4249.apcprd02.prod.outlook.com (20.179.102.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.17; Tue, 26 Mar 2019 09:12:37 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1730.019; Tue, 26 Mar 2019
 09:12:37 +0000
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
 AQHU3WaYCAMWaFadm0e/0+hd2XPYGaYRGYZ/gAAG5oCAAAD82oAAAx4AgAABDq2AAAzwgIAC47DNgAmAbsCAABOgAIAAAlC/
Date: Tue, 26 Mar 2019 09:12:37 +0000
Message-ID:
 <SG2PR02MB30985379F554A2A49070C682E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
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
x-ms-office365-filtering-correlation-id: 13af1c99-1cc0-45f7-357c-08d6b1cb30cf
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB4249;
x-ms-traffictypediagnostic: SG2PR02MB4249:|SG2PR02MB4249:
x-microsoft-antispam-prvs:
 <SG2PR02MB4249AB2FA5CFD89C81F99C78E85F0@SG2PR02MB4249.apcprd02.prod.outlook.com>
x-forefront-prvs: 09888BC01D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(39850400004)(366004)(396003)(376002)(136003)(189003)(199004)(8936002)(52536014)(9686003)(476003)(74316002)(71200400001)(6116002)(105586002)(53936002)(54906003)(305945005)(6246003)(25786009)(55016002)(486006)(93886005)(316002)(33656002)(8676002)(5660300002)(11346002)(6506007)(7696005)(446003)(3846002)(6916009)(44832011)(68736007)(102836004)(53546011)(229853002)(55236004)(2906002)(14444005)(186003)(256004)(5024004)(106356001)(7736002)(76176011)(26005)(78486014)(81166006)(81156014)(14454004)(86362001)(6436002)(97736004)(66066001)(99286004)(66574012)(4326008)(478600001)(71190400001)(586874002);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB4249;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 SzgmBUwYo+hC81suPbbF++VIn3O+xzTEh/YBx4uWceI6otVc1pXLJ/GuaLt7h96VpjDm8cBN5pMZDgxcv2vAZssvFuRiI1Kzy7Z3AH/WH2Pp8nPQaB8pHenWmNQeElaJgBRRFfq7WE/4nTl+2/zvJS9KyUT22fuF1xFlJu0lYJ5wRE0N1Wqu0BIwhUXpaMuZXMotA2s+Ej+NCWfqkPyeGm1Dgn1ckhRCEHpIwruAoAyZVzAOhNy1mTpGU6QmDIejjgtO+NyTMlPleFi0lt7sD4DJcotMuy5UrBoKN2bCykk8JVVXG4hbP6POt2i7nbovbFzpWW48GmJd3BZt/5AYs+y6IivHnB4/cpo03ot+GMRy8eS1enakRkqUAM+jxFU3J9HPEwAMolhVHVg0ghNltLZNwZV9D+pQDYNRwenKKSg=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 13af1c99-1cc0-45f7-357c-08d6b1cb30cf
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Mar 2019 09:12:37.3106
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

I already fix the email client, dont know the reason for quoting.

On Tue 26-03-19 07:53:14, Pankaj Suryawanshi wrote:
> Is there anyone who is familiar with this?  Please Comment.

Not really. You are observing an unexpected behavior of the page reclaim
which hasn't changed for quite some time. So I find more probable that
your non-vanilla kernel is doing something unexpected. It would help if
you could track down how does the unevictable page get down to the
reclaim path. I assume this is a CMA page or something like that but
those shouldn't get to the reclaim path AFIR.

As i said earlier, the kernel i am using is vanilla kernel.

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

