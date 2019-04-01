Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A5E9C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 07:49:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3859213A2
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 07:49:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="UQowoQFx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3859213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51A7F6B0006; Mon,  1 Apr 2019 03:49:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CB816B0008; Mon,  1 Apr 2019 03:49:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 345FB6B000A; Mon,  1 Apr 2019 03:49:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E79B46B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 03:49:17 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i23so6668641pfa.0
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 00:49:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=YzDRcL5HGApuuS9OTyrFpea3LHxiQCjmBLdxl0rre0Q=;
        b=c+6St21UogcACxnfGtjOxIZ3+9+Pz1ZvFL1Cu8l504eQY7YDeOr7uX93yhuVt3ZdU5
         tHkp1Lg+ubHveZiRe46l9yUnnuTViK0qHPS9N5ksp3xnyOaXbRdsLVnQ5wE8k/A6Fy17
         lAI84CczatbcWwytostShSmJ8/6Nj1tQk7d/v2uSlC1YTodefcs7S4lrQFtZ0hqnypks
         uaS+aboa3mSE54xc/5NsilzT7y/33o5hxqJW5ka4vDi2soZoblSoe8QdTpFfo4CggWxf
         LFB6nL2UFOViKOXJ6TORoLu1f+WWcjUgkpU4ZjksrGHRGpypKFrosfBDOMG6Mc1yLK3U
         7pWg==
X-Gm-Message-State: APjAAAWM1bAjvHgGhuYlcdCcpYaAaC9wvyZtEAf46DPDHI961cpqs4t8
	Nc3t90tBclpMa90Mt7dnKOnfUfFdFYPSapSyfCMJ1vHL1GHLySi+EnbxJLLVLpatdfjtU07CItd
	5GrOF2JamUuWia0sSnY8aumyNo4Eo88WDjPUUoszotFjX8GyWWvtuWVGfLQhTM6CkNQ==
X-Received: by 2002:a17:902:2e01:: with SMTP id q1mr63740004plb.253.1554104957431;
        Mon, 01 Apr 2019 00:49:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXsXBsS3btjS8i0bxduYFH9On2QZ+pMr+6C4x1XA06/I/wcV9ZFlCIMPzNxRSqcC7eaNel
X-Received: by 2002:a17:902:2e01:: with SMTP id q1mr63739959plb.253.1554104956600;
        Mon, 01 Apr 2019 00:49:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554104956; cv=none;
        d=google.com; s=arc-20160816;
        b=gshb9oaHVFW5/ilvSVqwGFSYeJR0BkVGR3UDy1gYhesLhERPHa2Amo43ACbYL1mnnZ
         qCm5w+tDahrooyUqhEYPxsaP7QQabGCaRD+4ehiuAPuHJyFQ0vBNNtHjKznWI0sQ6NfQ
         Q0954sqaAmbI04LdKBCoCUbZNGZQVGxRSPEc90ehf7x68rBRaWjto8BnThhQ8yWaqZGO
         C3ZzR7522bCVipyXAPdhl7wFhh4knjbJeuh6WCvl9nHk8DeFz1LPNwsJBxkaqIXU2ozu
         KhRnYStvpcFWhlKjsmCd4NXyyd6W6KivnJnAQf3JqoGAVWYATj+m1quUZtkd27CUEtz1
         nPSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=YzDRcL5HGApuuS9OTyrFpea3LHxiQCjmBLdxl0rre0Q=;
        b=IrdmPNp0s0CeHy03w8flyd21PdVvvjmBmyxiVi+rP5mJdYVVtMZe7x9lOfVSTtd/uW
         H0DwD8C/2k5jAwz8SnG8bpzuS6Fd6fVl1T8FWKDqnEyyXuZkHnIu450ZmiskwVGtGpxX
         D5uaw2Qi74KpDXYwNdODibPOwvkWAvB8rXj05QSkM8+lBzt0l2rhItFj+R9DLUVBfarG
         HAwOjFll5gFjI2z0pGY5Me5ft4M+KQ9ePq5rkIjB3Hi2fAM6ionOK2ifAUWMfZWVXYMG
         wgCN2dlY6su6B1D1LCdpkjgxWEZA1VCLKd0qn3B98RqXoZ3KKsfwp9J/rgLTKowMA2y8
         HJkw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=UQowoQFx;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.40 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-HK2-obe.outbound.protection.outlook.com (mail-eopbgr1300040.outbound.protection.outlook.com. [40.107.130.40])
        by mx.google.com with ESMTPS id m18si8188385pgl.483.2019.04.01.00.49.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 00:49:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.40 as permitted sender) client-ip=40.107.130.40;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=UQowoQFx;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.130.40 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=YzDRcL5HGApuuS9OTyrFpea3LHxiQCjmBLdxl0rre0Q=;
 b=UQowoQFxNN21liy4W9yXqRiN8MAwdTA7wVTjyQ5X1OllOaIcSLRU0YX+GuhQ9DzZ2OUZcexN189yy/0kR/KJ8udJr/rtJrW7ec0hkb9fSWfVIGqq4Jq5czj46HmsZWWI7BvJz/1J55zoW9HQ3CXRMhdhsEnp+mLjJX/n1/ZNYUk=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB3372.apcprd02.prod.outlook.com (20.177.82.14) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1750.20; Mon, 1 Apr 2019 07:49:14 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1750.017; Mon, 1 Apr 2019
 07:49:14 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: Matthew Wilcox <willy@infradead.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [External] Re: Print map for total physical and virtual memory
Thread-Topic: [External] Re: Print map for total physical and virtual memory
Thread-Index: AQHU46nCeD1YOwMRP0e9ea2iKxtjwaYdyRyAgAAQFrWAAAJjAIAEO9QagATeRQE=
Date: Mon, 1 Apr 2019 07:49:14 +0000
Message-ID:
 <SG2PR02MB3098608C52BFEA600BDD7DD7E8550@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098F980E1EB299853AC46E6E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190326113657.GL10344@bombadil.infradead.org>
 <SG2PR02MB3098B0C0CD27969FB7C9ECD7E85F0@SG2PR02MB3098.apcprd02.prod.outlook.com>,<20190326124304.GN10344@bombadil.infradead.org>,<SG2PR02MB3098156002F7CCC46078B57AE85A0@SG2PR02MB3098.apcprd02.prod.outlook.com>
In-Reply-To:
 <SG2PR02MB3098156002F7CCC46078B57AE85A0@SG2PR02MB3098.apcprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b6b2a6f9-2a74-4cdc-6148-08d6b676892a
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600139)(711020)(4605104)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB3372;
x-ms-traffictypediagnostic: SG2PR02MB3372:
x-microsoft-antispam-prvs:
 <SG2PR02MB33723B015B64A815A7BB4407E8550@SG2PR02MB3372.apcprd02.prod.outlook.com>
x-forefront-prvs: 0994F5E0C5
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(396003)(39840400004)(376002)(346002)(136003)(189003)(199004)(76176011)(33656002)(6436002)(14454004)(4326008)(25786009)(316002)(78486014)(54906003)(105586002)(6246003)(8936002)(8676002)(5660300002)(106356001)(74316002)(7736002)(68736007)(305945005)(6916009)(53936002)(7696005)(478600001)(99286004)(93886005)(97736004)(55016002)(52536014)(86362001)(81166006)(81156014)(6116002)(229853002)(71190400001)(71200400001)(186003)(3846002)(9686003)(66574012)(44832011)(476003)(486006)(256004)(14444005)(5024004)(446003)(11346002)(6506007)(53546011)(2906002)(66066001)(55236004)(102836004)(26005)(586874002)(98474002);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB3372;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 zl0/ULvVuidhS4fZZKlJtGB5xFxp+kRQXiiVdMwLgl1VXVERplEKVnmPMFT18vDwMvyf+HAwqDlFqt0Gz44WwoFumEUx73G7tBA8NNeKm14+QZZLuWze7zU13ekWqaQM2VhdVi/xzWWGIP9WPvC0xwGPV2GM5YrGdjsMUp1fX5zsX/hWmRhBX1J8bDTFU/kXf18glLUjAsVm870HYX7hF4F3G6FNrq9pzdGR6nIN1R+Clz1thc0KnDZbXUuzY+O/Mz2QzHEo54LYOSr4fQuyErJVhsyG4xl4RnNHpKGCZAe5U6UJbNE5K92lC55nGoPJhRBTnQ09Xnk+klKGzaS5SYvDWG3zh/zUi92rxQL5aGL2/0Px5VOs78BaFBvnI7q7nRXiJqbakVpsBKDn8Hec+I3IiJDFtyvnbRIzCb1X4+M=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b6b2a6f9-2a74-4cdc-6148-08d6b676892a
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Apr 2019 07:49:14.2725
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB3372
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


________________________________________
From: Pankaj Suryawanshi
Sent: 29 March 2019 10:52
To: Matthew Wilcox
Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org
Subject: Re: [External] Re: Print map for total physical and virtual memory


________________________________________
From: Matthew Wilcox <willy@infradead.org>
Sent: 26 March 2019 18:13
To: Pankaj Suryawanshi
Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org
Subject: Re: [External] Re: Print map for total physical and virtual memory

On Tue, Mar 26, 2019 at 12:35:25PM +0000, Pankaj Suryawanshi wrote:
> From: Matthew Wilcox <willy@infradead.org>
> Sent: 26 March 2019 17:06
> To: Pankaj Suryawanshi
> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org
> Subject: [External] Re: Print map for total physical and virtual memory
>
> CAUTION: This email originated from outside of the organization. Do not c=
lick links or open attachments unless you recognize the sender and know the=
 content is safe.

... you should probably use gmail or something.  Whatever broken email
system your employer provides makes it really hard for you to participate
in any meaningful way.

Okay i will use gmail.

> Can you please elaborate about tools/vm/page-types.c ?

cd tools/vm/
make
sudo ./page-types

If that doesn't do exactly what you need, you can use the source code to
make a program which does.

Is there any other way to print only cma area pages ? because i am interest=
ed for cma area pages only.

Thanks Matthew.
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

