Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 668FFC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:52:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D04B5205F4
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:52:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=mit.edu header.i=@mit.edu header.b="XSA8jHS4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D04B5205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4223A8E00AD; Thu, 21 Feb 2019 13:52:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D29C8E00A9; Thu, 21 Feb 2019 13:52:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2745E8E00AD; Thu, 21 Feb 2019 13:52:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB7468E00A9
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:52:48 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id i4so19683152otf.3
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:52:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mail-followup-to:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=gJ1dTqfRFtTYc+hdkJXVtleFTwH8zvYWkeUm+hyQtoE=;
        b=tCFOxk9yXKizEGusbxImXo0Bqo6lzDZmrTNo5z4sES02Pf50KDameO4LHoEkxo+clZ
         sbbjQzvvtPg3eHQZgk/pKF6k/PqWerXZXt/OW4waVMevaKqCcqB9nltd7zGnqSZafJqN
         kaWU3seQTWimY44/PJn0VbyiZMpjhNtmkx1TxzsVUog/MJec2xEsxygSqKqAxgxkLNoE
         u0jqQIcYcLzqojY/be8c8bXvVxvU/Z2uuSyOXTEygXo1Rx40iTm0HkKU2foyFyZ5EFZs
         egxN0Dz8CNXAQRC6cbHddKURQktD54V2+s/sf7+1+GHI9SR7sfWuX3xg/8E9EXIE8QM7
         BGFQ==
X-Gm-Message-State: AHQUAuY1xCF1d7Almb7c1Dnh597krYm3LD72yuOR+UiWoxjNJNw1DnJk
	0xToNti/Y28Ri5H9IeEVgxaL0uduiD3mFwnK8wuU8bhWDkNQMec2x4408S6r2Ng3+uq+6DBOkjD
	vsdz5++yMpgL6cRKHgbx3sBDPJddr7t9wWc1wqOyOLjqB0IArPdRvFnVOjWlITLijSw==
X-Received: by 2002:a9d:6845:: with SMTP id c5mr15403251oto.350.1550775168552;
        Thu, 21 Feb 2019 10:52:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia+4eXvw3RjDAjLotmI+aFyyq1jWphBgFYZ8HmheaRzff4M7Znr2SxnczNlSi9U2QLa2aDW
X-Received: by 2002:a9d:6845:: with SMTP id c5mr15403195oto.350.1550775167461;
        Thu, 21 Feb 2019 10:52:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550775167; cv=none;
        d=google.com; s=arc-20160816;
        b=fDiGWsdnFqiyATScz5UeckZVv9O4oc96Im5kS1l3EhJVDpJNOQDRjEs2y78uegMQA7
         N36BilcEaGw4shWtnpuVScXlo5uqagH4G6av5AprLBMOMmrnLAiMSkczh9moK3d6E8j1
         etnPmSF4zgKu3wbOCHkp+78VkZLFVtDh2B1josU131Oq62Yuts6SpyYzcElGM02L0B5S
         GjncU9aiscwcQ/IUvpGRdFDABdEHHQSpIeX10LlbXRR1VAzh3DHhLzZd+TKLT2XSon1E
         v8p5NZDvDsUIPRQWcI64hJ0nnRoimCoYxyzb8ruH+/0DKLRQRLA9mMjV5/h2P0IiaPBK
         Q7sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:mail-followup-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gJ1dTqfRFtTYc+hdkJXVtleFTwH8zvYWkeUm+hyQtoE=;
        b=tfARvqv20HiNyXjknL8P2jNaB6PQ/ujbn9z2nnsoZJmnak1keHYQOFFFpAG9DkXxRD
         hyQCc6tOzWdi2mDEkiKRgl6PQuak7GkgFFF4OCNV9ei+OzEpaWl0fYnNlUkleomX5jWw
         SFWPVH4diPqKqnjROaLdpjRyF5MXogiZ9gfNEqzi8+dcNZ9x4ZXS6npaCs1QbbJxeAfi
         HPpj18o8lFMNAlXJbCdUw1iSJmNVkC3Dru7TEH+roLg0YoGdBynpXasFx20j/Gzbds1K
         flxQhhQUGvhkQ+LCXaMplboS5rmm1gMOArXZ0eKU9JUGLH/Lfc/Gtcymg+cMRM9Gcprh
         uBcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@mit.edu header.s=selector1 header.b=XSA8jHS4;
       spf=pass (google.com: domain of tytso@mit.edu designates 40.107.76.123 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-eopbgr760123.outbound.protection.outlook.com. [40.107.76.123])
        by mx.google.com with ESMTPS id w131si4724167oie.171.2019.02.21.10.52.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Feb 2019 10:52:47 -0800 (PST)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 40.107.76.123 as permitted sender) client-ip=40.107.76.123;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@mit.edu header.s=selector1 header.b=XSA8jHS4;
       spf=pass (google.com: domain of tytso@mit.edu designates 40.107.76.123 as permitted sender) smtp.mailfrom=tytso@mit.edu
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mit.edu; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=gJ1dTqfRFtTYc+hdkJXVtleFTwH8zvYWkeUm+hyQtoE=;
 b=XSA8jHS42sUiF7Tr0kpgGHVRaXghMsLVaWhnRInF0w96jgf8IWzm5pZIFWG7DsMnDKru9BIUBCTh8gD+SBfljwJe80wPyuNg9yRTjDd/+mpR0kjk6R76qVtRpUVWLRgZ/BeyjSP5xM2VmouhdCXITLOMr7Bd1clkhgFX6AohZ0w=
Received: from MWHPR01CA0039.prod.exchangelabs.com (2603:10b6:300:101::25) by
 BN6PR01MB3281.prod.exchangelabs.com (2603:10b6:404:d8::22) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.19; Thu, 21 Feb 2019 18:52:43 +0000
Received: from DM3NAM03FT015.eop-NAM03.prod.protection.outlook.com
 (2a01:111:f400:7e49::203) by MWHPR01CA0039.outlook.office365.com
 (2603:10b6:300:101::25) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1643.15 via Frontend
 Transport; Thu, 21 Feb 2019 18:52:42 +0000
Authentication-Results: spf=pass (sender IP is 18.9.28.11)
 smtp.mailfrom=mit.edu; vger.kernel.org; dkim=none (message not signed)
 header.d=none;vger.kernel.org; dmarc=bestguesspass action=none
 header.from=mit.edu;
Received-SPF: Pass (protection.outlook.com: domain of mit.edu designates
 18.9.28.11 as permitted sender) receiver=protection.outlook.com;
 client-ip=18.9.28.11; helo=outgoing.mit.edu;
Received: from outgoing.mit.edu (18.9.28.11) by
 DM3NAM03FT015.mail.protection.outlook.com (10.152.82.195) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.20.1643.13 via Frontend Transport; Thu, 21 Feb 2019 18:52:42 +0000
Received: from callcc.thunk.org (guestnat-104-133-8-109.corp.google.com [104.133.8.109] (may be forged))
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x1LIqcF2004359
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 21 Feb 2019 13:52:40 -0500
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id 25B267A3F9E; Thu, 21 Feb 2019 13:52:38 -0500 (EST)
Date: Thu, 21 Feb 2019 13:52:38 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
To: Luis Chamberlain <mcgrof@kernel.org>
CC: James Bottomley <James.Bottomley@HansenPartnership.com>, Sasha Levin
	<sashal@kernel.org>, Greg KH <gregkh@linuxfoundation.org>, Amir Goldstein
	<amir73il@gmail.com>, Steve French <smfrench@gmail.com>,
	<lsf-pc@lists.linux-foundation.org>, linux-fsdevel
	<linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, LKML
	<linux-kernel@vger.kernel.org>
Subject: Re: [LSF/MM TOPIC] FS, MM, and stable trees
Message-ID: <20190221185238.GF10245@mit.edu>
Mail-Followup-To: "Theodore Y. Ts'o" <tytso@mit.edu>,
	Luis Chamberlain <mcgrof@kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Sasha Levin <sashal@kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Steve French <smfrench@gmail.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
References: <20190213073707.GA2875@kroah.com>
 <CAOQ4uxgQGCSbhppBfhHQmDDXS3TGmgB4m=Vp3nyyWTFiyv6z6g@mail.gmail.com>
 <20190213091803.GA2308@kroah.com>
 <20190213192512.GH69686@sasha-vm>
 <20190213195232.GA10047@kroah.com>
 <1550088875.2871.21.camel@HansenPartnership.com>
 <20190215015020.GJ69686@sasha-vm>
 <1550198902.2802.12.camel@HansenPartnership.com>
 <20190216182835.GF23000@mit.edu>
 <20190221153415.GL11489@garbanzo.do-not-panic.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20190221153415.GL11489@garbanzo.do-not-panic.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-EOPAttributedMessage: 0
X-Forefront-Antispam-Report:
	CIP:18.9.28.11;IPV:CAL;SCL:-1;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10019020)(39860400002)(136003)(346002)(376002)(396003)(2980300002)(189003)(199004)(86362001)(50466002)(93886005)(14444005)(33656002)(54906003)(336012)(75432002)(5024004)(36756003)(8746002)(42186006)(356004)(246002)(36906005)(47776003)(8936002)(106002)(2616005)(126002)(486006)(58126008)(52956003)(316002)(446003)(11346002)(305945005)(46406003)(1076003)(8676002)(186003)(476003)(26005)(786003)(23726003)(6916009)(2906002)(88552002)(90966002)(7416002)(478600001)(26826003)(6266002)(5660300002)(4326008)(76176011)(6246003)(103686004)(97756001)(229853002)(106466001)(18370500001)(42866002);DIR:OUT;SFP:1102;SCL:1;SRVR:BN6PR01MB3281;H:outgoing.mit.edu;FPR:;SPF:Pass;LANG:en;PTR:outgoing-auth-1.mit.edu;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 377d23b0-da3a-453a-a18e-08d6982dc2c8
X-Microsoft-Antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(4608103)(4709054)(2017052603328)(7153060);SRVR:BN6PR01MB3281;
X-MS-TrafficTypeDiagnostic: BN6PR01MB3281:
X-LD-Processed: 64afd9ba-0ecf-4acf-bc36-935f6235ba8b,ExtAddr
X-Microsoft-Exchange-Diagnostics:
	1;BN6PR01MB3281;20:Kp6Q7eILZDuQfc9cuiH5l4dAhEn7GzRQlcvNnfkD3st+bePFnLG9xz4CGPXhbXqekDGpI+6M7N5d2ftsNHcSjieDpVd5t/+GqIkQCXYSIiBhRfe3FrTC4iVaC4ul2CYsMGlb9r0em1TlNeRbp6vq2Z2IbsD9fxyuAUQvnt1dbuNniW5ZHeK7bphta0XEJB1kYMi6evg1tp+8WsgZ6zOwxypsm9arkcciagUPPLYtl46kGrIBVwqwg68B5WPOk1m2EjJfTogWMNEwmwLTPnD/zbD8/ss3urDBI7ioQ11V7CIVB5IehSyn9XtGKgjACmGf7FY1CXMcpJwRK3TRyStjyvK/6yQWZGl+957sCwN0nq9ffLLSnN8u+xZ+ZHLlcjmxrhno3l5ZNJcaU/qK2+QaJIo0Ts8Tp1s8xBUbi5ev6gZJrMT5+5b6qAeER30lED/XHWG62+UVgEsHlK6NHjDs5BD2PtbaGJ9pviboX6jy/Drh5cVKy/nP3Dg2giCKyx4QS0FctJyRIwEse6h8rRcfGmTNHxbtblQW/aDTNKfZvbc/eU4OIcB/wqlv7kMRdQgkZCDlxTEPEd9GlkTLrL5C7p8vn8uDatPBhr16kavJ+cc=
X-Microsoft-Antispam-PRVS:
	<BN6PR01MB32818F3CD6837B23ACF0FEC1B57E0@BN6PR01MB3281.prod.exchangelabs.com>
X-Forefront-PRVS: 09555FB1AD
X-Microsoft-Exchange-Diagnostics:
	=?us-ascii?Q?1;BN6PR01MB3281;23:syWX1yXQMMENtimTe7VUG+9vvUSH/nHYdz4VgCsnH?=
 =?us-ascii?Q?MYOYk8zYqJzKSxhE0byjqCaQSRUGdUgBE2wqwRCdWbw5T8PyN6Y/QRHZ9s0l?=
 =?us-ascii?Q?UzH5TIN0sA7bEEWvgMaVRn29hE8wYasaPsrHEgIsYEaHph8GBmYcOt/3PEF8?=
 =?us-ascii?Q?gtMa2I4vaVHxDohwUSKc98sk4WOegLcgkwpworarEmalR8TYLY1Tv2KFZ3eX?=
 =?us-ascii?Q?6q+h/d3c/uAepAILueK0kcoxvhExdXwAtFZB5oM1868JVyA+Hnvp/pgKfE1v?=
 =?us-ascii?Q?7ScmokIAeqVDIctRSdQyWjNV7xVm22AkeRpjhdmZRlj8CQHSQJzyU9OJuoxk?=
 =?us-ascii?Q?Y7yxOg1yodhW6OrAnHjlk6/Fib+2inzh4RyAvUSpXm0nFZ2wrhZ4F8bKGcah?=
 =?us-ascii?Q?gBe0hth3wNesJFi/7+Yhh3L/48XSRgP4ycKZbmIt5Y4TIwx9lY7Xz0IHHwGk?=
 =?us-ascii?Q?HEhh1d3OfyPUdjmCuX/Hra6HPq07sT7mFSDW6hQwFO+gPznf7YZCeLN4jTK4?=
 =?us-ascii?Q?CjPndAAbH4k0YhteyGZ+w31Pq09UbTL7FSRKXNM7hMwlNd84ju4LimhLaoKF?=
 =?us-ascii?Q?AQr6MPpkG3FfQa9iyN0WElcN/kNF3FD8v0jBk7jaCzP2Lvb+8oabpyFkqGzJ?=
 =?us-ascii?Q?l2i0v+HGp/FRap6UiQ4qbYzCbLlkvxlbLIK50mqyEB66oHklalX9DiwMXIhO?=
 =?us-ascii?Q?vySSDMdOpWsFgYA0THM0ODrufgIQaPvDRWRdw8o1+np9knyDunrzdT6voMrE?=
 =?us-ascii?Q?mILaOez4lBMZcxO9Ggt2dA5GTe3AMQwutwCLSzNBGNDdqiCYNABSOP3JOM2i?=
 =?us-ascii?Q?R3weMUIcGWYuWQDcMCLMF1AcD5MBz4YTfvHL91c0LCoeT9bAb/h2Mj3zUWPn?=
 =?us-ascii?Q?ldKAHWD/J92LXMH4P7KYof1Vg4/1MfcOBdrx24JOZ4I3FCaL6MKZ/+8Z0Z2S?=
 =?us-ascii?Q?s4FtZdwbz+IPGw71y2BAbCinU7mmmOe/V4m8hazTFHxEjxdIhMheeykTDiQe?=
 =?us-ascii?Q?ioM7DVEpBPvpjM+S5nNoImEGbCHNC42k80urv8Oiu+5SSdeCjlijQRuTQG8N?=
 =?us-ascii?Q?RFkAuqJ//PrdVJTvszZOvsBoy1qkn3kdk54Ck3qjKyW+c0/R8bAQ4kf4LzU2?=
 =?us-ascii?Q?2TGygartrV79UdnX3enwb8WfGNZ70gI9rT3HXK+EnxfXNKZ+rIS/dODMl2RP?=
 =?us-ascii?Q?ljQOJ8koOshnRRtjwBz30m/5BkfrfoiVhIfHZs5WuN4qBLAa5bVCvSVMFi1c?=
 =?us-ascii?Q?sDOjAqP1qOGxmYo+z6dOz/t0OwHCMRqk32yxEzlDr0Dam+w7gm6wUzUJmzeg?=
 =?us-ascii?Q?jJxROAX2JhZhJLkIHV0WSyTdPRUkxE8DN+iKd92oPad?=
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	sz4gfWwZzrokR3S9l9md+o52ulAnuAwinjhPzgv7C0m2QVNI6mOyGLcoUlqQ4TiYjTpWErrv3iVrNkGcR9C5gxCaRHfdVNCY2FMRE8SMd/GrdnqzY3gy+lsRCkmliH19wrryCFUH0J4jDghEGSB2C0A+vS00kt13DU/ZmpGlatKX07O7RCR22jTlHTFfqUqINdphhgj66At7D1FKOdOKxV/2Sa4OmbV1DM7D3dV8SasWragFS9N4gw1JKyeBf156XLDxW8PeHYDPKIurn47XofxZysJThzZjuRUxwudFj6fXK/VgnE5ypVVEUxigCORMmvy73tfgN6eMRIoADknR8wbBn2lCxsa6W1HndfjkqYkmIZsdP/p3M6gc3cz/p3iwKbJgixa56QNReqEC+PJnr2VPmnayuVY1GRQ4DqoY/yI=
X-OriginatorOrg: mit.edu
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 21 Feb 2019 18:52:42.0686
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 377d23b0-da3a-453a-a18e-08d6982dc2c8
X-MS-Exchange-CrossTenant-Id: 64afd9ba-0ecf-4acf-bc36-935f6235ba8b
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=64afd9ba-0ecf-4acf-bc36-935f6235ba8b;Ip=[18.9.28.11];Helo=[outgoing.mit.edu]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR01MB3281
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 07:34:15AM -0800, Luis Chamberlain wrote:
> On Sat, Feb 16, 2019 at 01:28:35PM -0500, Theodore Y. Ts'o wrote:
> > The block/*, loop/* and scsi/* tests in blktests do seem to be in
> > pretty good shape.  The nvme, nvmeof, and srp tests are *definitely*
> > not as mature.
>=20
> Can you say more about this later part. What would you like to see more
> of for nvme tests for instance?
>=20
> It sounds like a productive session would include tracking our:
>=20
>   a) sour spots
>   b) who's already working on these
>   c) gather volutneers for these sour spots

I complained on another LSF/MM topic thread, but there are a lot of
failures where it's not clear whether it's because I guessed
incorrectly about which version of nvme-cli I should be using (debian
stable and head of nvme-cli both are apparently wrong answers), or
kernel bugs or kernel misconfiguration issues on my side.

Current nvme/* failures that I'm still seeing are attached below.

	       		     	       - Ted

nvme/012 (run mkfs and data verification fio job on NVMeOF block device-bac=
ked ns) [failed]
    runtime  ...  100.265s
    something found in dmesg:
    [ 1857.188083] run blktests nvme/012 at 2019-02-12 01:11:33
    [ 1857.437322] nvmet: adding nsid 1 to subsystem blktests-subsystem-1
    [ 1857.456187] nvmet: creating controller 1 for subsystem blktests-subs=
ystem-1 for NQN nqn.2014-08.org.nvmexpress:uuid:78dc695a-2c99-4841-968d-c2c=
16a49a02a.
    [ 1857.458162] nvme nvme0: ANA group 1: optimized.
    [ 1857.458257] nvme nvme0: creating 2 I/O queues.
    [ 1857.460893] nvme nvme0: new ctrl: "blktests-subsystem-1"
   =20
    [ 1857.720666] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
    [ 1857.726308] WARNING: possible recursive locking detected
    [ 1857.731784] 5.0.0-rc3-xfstests-00014-g1236f7d60242 #843 Not tainted
    ...
    (See '/results/nodev/nvme/012.dmesg' for the entire message)
nvme/013 (run mkfs and data verification fio job on NVMeOF file-backed ns) =
[failed]
    runtime  ...  32.634s
    --- tests/nvme/013.out	2019-02-11 18:57:39.000000000 -0500
    +++ /results/nodev/nvme/013.out.bad	2019-02-12 01:13:46.708757206 -0500
    @@ -1,5 +1,9 @@
     Running nvme/013
     91fdba0d-f87b-4c25-b80f-db7be1418b9e
     uuid.91fdba0d-f87b-4c25-b80f-db7be1418b9e
    +fio: io_u error on file /mnt/blktests///verify.0.0: Input/output error=
: write offset=3D329326592, buflen=3D4096
    +fio: io_u error on file /mnt/blktests///verify.0.0: Input/output error=
: write offset=3D467435520, buflen=3D4096
    +fio exited with status 0
    +4;fio-3.2;verify;0;5;0;0;0;0;0;0;0.000000;0.000000;0;0;0.000000;0.0000=
00;1.000000%=3D0;5.000000%=3D0;10.000000%=3D0;20.000000%=3D0;30.000000%=3D0=
;40.000000%=3D0;50.000000%=3D0;60.000000%=3D0;70.000000%=3D0;80.000000%=3D0=
;90.000000%=3D0;95.000000%=3D0;99.000000%=3D0;99.500000%=3D0;99.900000%=3D0=
;99.950000%=3D0;99.990000%=3D0;0%=3D0;0%=3D0;0%=3D0;0;0;0.000000;0.000000;0=
;0;0.000000%;0.000000;0.000000;192672;6182;1546;31166;4;9044;63.332763;57.9=
79218;482;29948;10268.332290;1421.459893;1.000000%=3D4145;5.000000%=3D9109;=
10.000000%=3D9502;20.000000%=3D9764;30.000000%=3D10027;40.000000%=3D10289;5=
0.000000%=3D10420;60.000000%=3D10551;70.000000%=3D10682;80.000000%=3D10682;=
90.000000%=3D10944;95.000000%=3D11206;99.000000%=3D13172;99.500000%=3D16318=
;99.900000%=3D24510;99.950000%=3D27394;99.990000%=3D29229;0%=3D0;0%=3D0;0%=
=3D0;507;30005;10331.973087;1421.131712;6040;8232;100.000000%;6189.741935;2=
67.091495;0;0;0;0;0;0;0.000000;0.000000;0;0;0.000000;0.000000;1.000000%=3D0=
;5.000000%=3D0;10.000000%=3D0;20.000000%=3D0;30.000000%=3D0;40.000000%=3D0;=
50.000000%=3D0;60.000000%=3D0;70.000000%=3D0;80.000000%=3D0;90.000000%=3D0;=
95.000000%=3D0;99.000000%=3D0;99.500000%=3D0;99.900000%=3D0;99.950000%=3D0;=
99.990000%=3D0;0%=3D0;0%=3D0;0%=3D0;0;0;0.000000;0.000000;0;0;0.000000%;0.0=
00000;0.000000;3.991657%;6.484839%;91142;0;1024;0.1%;0.1%;0.1%;0.1%;100.0%;=
0.0%;0.0%;0.00%;0.00%;0.00%;0.00%;0.00%;0.00%;0.00%;0.01%;0.20%;0.34%;0.25%=
;0.19%;27.86%;70.89%;0.23%;0.00%;0.00%;0.00%;0.00%;0.00%;0.00%;0.00%;nvme0n=
1;0;0;0;0;0;0;0;0.00%
    ...
    (Run 'diff -u tests/nvme/013.out /results/nodev/nvme/013.out.bad' to se=
e the entire diff)
nvme/015 (unit test for NVMe flush for file backed ns)       [failed]
    runtime  ...  8.914s
    --- tests/nvme/015.out	2019-02-11 18:57:39.000000000 -0500
    +++ /results/nodev/nvme/015.out.bad	2019-02-12 01:14:05.429328259 -0500
    @@ -1,6 +1,6 @@
     Running nvme/015
     91fdba0d-f87b-4c25-b80f-db7be1418b9e
     uuid.91fdba0d-f87b-4c25-b80f-db7be1418b9e
    -NVMe Flush: success
    +NVME IO command error:INTERNAL: The command was not completed successf=
ully due to an internal error(6006)
     NQN:blktests-subsystem-1 disconnected 1 controller(s)
     Test complete
nvme/016 (create/delete many NVMeOF block device-backed ns and test discove=
ry)
    runtime  ...
nvme/016 (create/delete many NVMeOF block device-backed ns and test discove=
ry) [failed]
    runtime  ...  23.576s
    --- tests/nvme/016.out	2019-02-11 18:57:39.000000000 -0500
    +++ /results/nodev/nvme/016.out.bad	2019-02-12 01:14:29.173378854 -0500
    @@ -1,11 +1,11 @@
     Running nvme/016
    =20
    -Discovery Log Number of Records 1, Generation counter 1
    +Discovery Log Number of Records 1, Generation counter 5
     =3D=3D=3D=3D=3DDiscovery Log Entry 0=3D=3D=3D=3D=3D=3D
     trtype:  loop
     adrfam:  pci
    ...
    (Run 'diff -u tests/nvme/016.out /results/nodev/nvme/016.out.bad' to se=
e the entire diff)
nvme/017 (create/delete many file-ns and test discovery)   =20
    runtime  ...
nvme/017 (create/delete many file-ns and test discovery)     [failed]
    runtime  ...  23.592s
    --- tests/nvme/017.out	2019-02-11 18:57:39.000000000 -0500
    +++ /results/nodev/nvme/017.out.bad	2019-02-12 01:14:52.880762691 -0500
    @@ -1,11 +1,11 @@
     Running nvme/017
    =20
    -Discovery Log Number of Records 1, Generation counter 1
    +Discovery Log Number of Records 1, Generation counter 2
     =3D=3D=3D=3D=3DDiscovery Log Entry 0=3D=3D=3D=3D=3D=3D
     trtype:  loop
     adrfam:  pci
    ...
    (Run 'diff -u tests/nvme/017.out /results/nodev/nvme/017.out.bad' to se=
e the entire diff)

