Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B785C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 12:35:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34E5F2075D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 12:35:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="VJSA8zVm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34E5F2075D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA6CC6B0005; Tue, 26 Mar 2019 08:35:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7D746B0006; Tue, 26 Mar 2019 08:35:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B44B86B0007; Tue, 26 Mar 2019 08:35:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 742896B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 08:35:29 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bh5so2058816plb.16
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:35:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=tmQFqqiXViPOV80Ke9PWdjdAXynGZQpBxqpD7XSKzzM=;
        b=I2u7nVATy4KLbDPJBmWFCIbux/xC/7AXyoFZ5h+OgVeK4FKYASeQF4uVo+FdneO5jq
         2a0dIoQ75kB9+sYvoTUeJLIF/tIbOvC+coCV1KpRLwQAr/SgXD8gkMa0gIKCymaWPvzo
         01AzpYKyZC9/XEZnUWeq+URUzboO+6HCwMfKGY6vZQ/VL4PbJ9WHR4wlxfVaQsznjtYq
         X6efCtnV51KsYmD0hotEuQub9agyh6qFx63RO48ctsEHZBJMsl+hbt0Ig+1ro4X9R3it
         9WXSofk6HDD6vxRuwIwGI+OxiNMK0tysC3SpDGgUiA2PiUhO3pd6Oev70wtNpkdGP8KF
         KnFg==
X-Gm-Message-State: APjAAAWLhg26gteJw13ovbv1BwQ6hO9I+5y3vkp5MjBEIdP2jBGH9ax0
	1WW6/Yhp7zB81anA2JkesxBN90+6+ZhqIuVHmaZqQNbFW7jPEkOdVyLk9tlqW0oPt1Hk5AtAFvc
	BWJ+Ko68x2XJTQTw1dLlTWoLikxskMLndKqcWz5EIJFb8ai3fIbWgfkB5pSNh6pLJPw==
X-Received: by 2002:a63:9246:: with SMTP id s6mr28984392pgn.316.1553603729108;
        Tue, 26 Mar 2019 05:35:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwimquSewiZTwYwqs8sGsIWl3cCE4W8U8vnVheM0FAJ8frJC7pVVG1oeWLVLD/mMMHfxNxY
X-Received: by 2002:a63:9246:: with SMTP id s6mr28984318pgn.316.1553603728244;
        Tue, 26 Mar 2019 05:35:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553603728; cv=none;
        d=google.com; s=arc-20160816;
        b=DPQMozsV9Ie4Fh7mT1gvB/5c8osvl/f9TPeX7AkvHM9aAAD2fWrYXY3y7dDrqX7WnJ
         rTnxQ8MZ/dOj7JX7nvUdW/lxfGnNmW9rccmtLKQhspI9lvy8Olb3u4c1EUSiiWkLNBaT
         Rp4Eos50/E9moOc061C9SpsFq9UlYowa3wvx4Le+wynCh7OFUwMTVR5olj6wWlK6Xr0w
         g15y7tjaqg0tQQbQWoxFEwHh9Z8zn5yz4BIEojl4ApKCp1mVSu7qYwbGEL+DY3Q9p19V
         EMnwStn3mUlUvUH00Y8Jss/Qnb70099tTSwtr4KuI0W8Z53ZL9Z5Ua9+H8K+Sun91EPo
         FCKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=tmQFqqiXViPOV80Ke9PWdjdAXynGZQpBxqpD7XSKzzM=;
        b=H+qzb2NzkTuUoGgl35ea5W2huAb6mrLR6gN7ode5FMMZEuEkZT6Fhw5av0cNyHpSS0
         h8vuNMgWybPSQOrE82S+XSSVe++P4Dvqhw6Y74bM4lTsRjnWy0KAGQ46+BX9ZebSlPJy
         7YzfTHsFcAwoqJxqV3rdeM5pYIMaNYyX2JD0j4J6xF9LJPZC7i1elaO9zUo8Lx5vGtWO
         wPaDwl90ZAvDCGWhsMqcEi9jl00CuXAKOCUERo02zS1H92/QnPwveMB7T/wbf/f5EArj
         l+Ud8WCRMJMY7Af9/klFkO0kZ0Dw0iIlGiY4QPi+0tfoZsaHoFw+pklpakO4iyg+Di6R
         w0xA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=VJSA8zVm;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.82 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-PU1-obe.outbound.protection.outlook.com (mail-eopbgr1320082.outbound.protection.outlook.com. [40.107.132.82])
        by mx.google.com with ESMTPS id t17si8300275pfe.250.2019.03.26.05.35.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 05:35:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.82 as permitted sender) client-ip=40.107.132.82;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=VJSA8zVm;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.82 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=tmQFqqiXViPOV80Ke9PWdjdAXynGZQpBxqpD7XSKzzM=;
 b=VJSA8zVmrBvLrSlta6LtRaWgjxuHZ/VG7FqqlFz8QU8PiSAidDNBVQR255Mefa+743q9tZhRIW8opKpWYxhL8PF1zZH1TX9Xclecv871xtNXQXpTYfovvEYx3oi8aFOi8AqzRGOGk3XPGFo9tt1QpUwJagKRYq5kuHEE5qnUtqE=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB3434.apcprd02.prod.outlook.com (20.177.80.204) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.18; Tue, 26 Mar 2019 12:35:25 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1730.019; Tue, 26 Mar 2019
 12:35:25 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: Matthew Wilcox <willy@infradead.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [External] Re: Print map for total physical and virtual memory
Thread-Topic: [External] Re: Print map for total physical and virtual memory
Thread-Index: AQHU46nCeD1YOwMRP0e9ea2iKxtjwaYdyRyAgAAQFrU=
Date: Tue, 26 Mar 2019 12:35:25 +0000
Message-ID:
 <SG2PR02MB3098B0C0CD27969FB7C9ECD7E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098F980E1EB299853AC46E6E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>,<20190326113657.GL10344@bombadil.infradead.org>
In-Reply-To: <20190326113657.GL10344@bombadil.infradead.org>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 16a4cc42-407d-4f65-475b-08d6b1e78565
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB3434;
x-ms-traffictypediagnostic: SG2PR02MB3434:|SG2PR02MB3434:
x-microsoft-antispam-prvs:
 <SG2PR02MB343456E4C14A8A34C8D1E308E85F0@SG2PR02MB3434.apcprd02.prod.outlook.com>
x-forefront-prvs: 09888BC01D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(366004)(39850400004)(396003)(136003)(346002)(189003)(199004)(3846002)(53546011)(78486014)(33656002)(76176011)(8676002)(55016002)(7736002)(102836004)(6506007)(55236004)(99286004)(81156014)(7696005)(66574012)(26005)(53936002)(81166006)(5660300002)(6246003)(6916009)(478600001)(305945005)(9686003)(6436002)(229853002)(14454004)(105586002)(106356001)(316002)(256004)(86362001)(14444005)(74316002)(4326008)(54906003)(5024004)(25786009)(71200400001)(446003)(486006)(11346002)(66066001)(68736007)(6116002)(44832011)(476003)(52536014)(2906002)(71190400001)(97736004)(8936002)(186003)(586874002);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB3434;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 9GG86l8FdnYCP6KDPqmpLcG+AMq2VQyNP8oF3ALobndaI+O4W03qE910o4hHT5DPNWBjCpTspWdtaNjgz0JAiS1Il9r4Bf6U3ZZgL6Jji+fBYCVaw4s5r4QcdIFf/Sv7WW39P7WhkHWIzAWnpc1EqWwEAnSlSIH5K7oMPdBGluCVJUn1Vv7hSBKfnmBgwWr2q8Kdk90x/w2mYKWJ14lKo0hkmhjZkzj71RBIVqwA26wiHwyWJsYKz2Fd7XuAtfsJsrMlWgdP1PGBxTI4tUuo3CS5xv8oXVouQxcgf0JdrJSsZ7ql9+a8WlKtaq9k0Cr+e6pC9n8QPOLUI0Rx90/5R66Y4hCPi1vQEK/20ytCj7GY8Q9Ai6Dc++e1cyYL4tV9zo0eaYFAZGlT0UkV8CKWGfF8Ak0BgILjoWP0U5idBrs=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 16a4cc42-407d-4f65-475b-08d6b1e78565
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Mar 2019 12:35:25.0470
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB3434
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000042, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


________________________________________
From: Matthew Wilcox <willy@infradead.org>
Sent: 26 March 2019 17:06
To: Pankaj Suryawanshi
Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org
Subject: [External] Re: Print map for total physical and virtual memory

CAUTION: This email originated from outside of the organization. Do not cli=
ck links or open attachments unless you recognize the sender and know the c=
ontent is safe.


On Tue, Mar 26, 2019 at 08:34:20AM +0000, Pankaj Suryawanshi wrote:
> Hello,
>
> 1. Is there any way to print whole physical and virtual memory map in ker=
nel/user space ?
>
> 2. Is there any way to print map of cma area reserved memory and movable =
pages of cma area.
>
> 3. Is there any way to know who pinned the pages from cma reserved area ?

You probably want tools/vm/page-types.c

Can you please elaborate about tools/vm/page-types.c ?
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

