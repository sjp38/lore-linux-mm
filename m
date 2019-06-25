Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76DE4C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 11:44:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF747213F2
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 11:44:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="P5BHz3Rm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF747213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B4136B0003; Tue, 25 Jun 2019 07:44:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43DC38E0003; Tue, 25 Jun 2019 07:44:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 290438E0002; Tue, 25 Jun 2019 07:44:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C95C66B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:44:32 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k15so25235125eda.6
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 04:44:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=u5g/kXs53cyAU/0l6biTfPEBGQO4pWzyaBiiFsCrnwQ=;
        b=WQjQJPSg8b3AaPyLhUEzXBI6LzoEXV0nuvIGXHMu8nW8xkFBcl7uTHX57rpTE+qQwh
         WpZL7uRrjuZxG1senCM+7fisM/FCDPPSL3EPkaDg5jhu20Xhr7BnZszdcDap2AjyXSUt
         ddQa27pMid9G7RVqq71upev7XNiiBYKrgbhJs0uBEUhkCkJpLyMu6f0JkX3ijEjYS6iU
         BfdzrdUPUw9AI88mONP9GE+LWXgzlSsZUg2uoqfgGHjjWNgtXrUCMJnSSFomCOjYXQnQ
         uGx88A2+ehIb5UYI0lemk75YkK+touUGGk9yiEavQnicBVNIZhc4RQMWt19VaMfuHQi5
         aWSw==
X-Gm-Message-State: APjAAAUirYRm6pJo6OXtejWjL3cPMeEEQjrlkyQe8IfgYiWU0qdL+eUD
	KwXVwXTEouh1v2h9F+lT2WTdGo6giyGBJgd1s+AikvyPKKE9V582Y3KiTp7RUGlts9YG1JGvvjH
	jTE7p0GVU9rc5mEF99W8fxczSG3JTnT9KHEMe3SB90AazK+m1aflp9pmYXHX8qt2RPg==
X-Received: by 2002:a17:906:4acc:: with SMTP id u12mr102468696ejt.41.1561463072098;
        Tue, 25 Jun 2019 04:44:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeroX37Y5fRl5I6GJWyvX7+gsK16ZZEK6MQlXAKLK3wboUA9Vnef6PJcvbF51pixV4SlZP
X-Received: by 2002:a17:906:4acc:: with SMTP id u12mr102468644ejt.41.1561463071293;
        Tue, 25 Jun 2019 04:44:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561463071; cv=none;
        d=google.com; s=arc-20160816;
        b=lwDOtAudQ1vHtWywOlHwXZDMUX6jjg8oju0Fu1at18Jrr7n4rNfxuVRcuTe30guPyH
         txnRPH8qEt4fxbHaPVKkedOi+8J6lF1Ul5G9hKwSBkd0Y4iur7OYjDbztFjz7wSUmJis
         f/8vlihuESRbmPJGhnftKYPwU+MWp33NhSYh19gPgqNuX7C0ddCNFIJ/RgXbDmD2uCox
         T3Y5wtn8p+FDhCBKneR0xR6kBAWv4LBu4nMPjcgRlTynATjCfS6JMjpgGi6OEXIoGUqi
         wC+v/LWXBpvVZMI0x1n9VFLf4b3x9yFLzBdrxy34PWuK9cNyfG36TrVEUQFdqe//5Zhr
         7IdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=u5g/kXs53cyAU/0l6biTfPEBGQO4pWzyaBiiFsCrnwQ=;
        b=QJod0UycmG59WC+WoMcegBP0cKlPhFlfxob6n7aIP+L5LPwMKujl1gX4qSlGfleQWC
         tQDMqgwaC/AU9yJsKB75QPbC1quEFDfCskCpizyxUXjcxGxzdUr8CM3J+eCvw4j1dW/U
         bhhov9f3mDrGaQEHoG0LWATpGnwHr5xZhlDNZgdZ84eb4H93hfyQdqo3NuoH3FQ6qC38
         Hx/Aqez5C1YGpGK39Kg+kl7je5FOBq4u4aijWrrzpJYTIIb28ZhJ/ZypzeoTtsPz6Yjm
         r7kEKbI4Svu5ZKF0aZiqjLsK6xoXQmUFsZPTOLHqKnSCREr5/DNC/bRCl2MdW0G+DdOD
         9lWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=P5BHz3Rm;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.0.84 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00084.outbound.protection.outlook.com. [40.107.0.84])
        by mx.google.com with ESMTPS id a6si160469ejr.357.2019.06.25.04.44.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 04:44:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.0.84 as permitted sender) client-ip=40.107.0.84;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=P5BHz3Rm;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.0.84 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=u5g/kXs53cyAU/0l6biTfPEBGQO4pWzyaBiiFsCrnwQ=;
 b=P5BHz3RmliJy0oSxBWbLono/6B0JZ4yTq07dKrkzyH4DvRzC+vmRuo7ABmDLYuzmqYGIBgNnOwUlJ6V9IMczIyKB3vaZiwSEfc/D54nWznYH6/jgYg9Wg4YL7dyQk9TOqxPHWDqccjKJ3LGRtUW2TQPLsgoWWADBUC01t4IHTRI=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6429.eurprd05.prod.outlook.com (20.179.27.208) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Tue, 25 Jun 2019 11:44:29 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2008.014; Tue, 25 Jun 2019
 11:44:28 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Thread-Topic: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Thread-Index: AQHVIcyVeqgMzBs0VkumwilsEzSkhqak+JsAgAcTLYCAAEdIAA==
Date: Tue, 25 Jun 2019 11:44:28 +0000
Message-ID: <20190625114422.GA3118@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-19-hch@lst.de> <20190620192648.GI12083@dhcp22.suse.cz>
 <20190625072915.GD30350@lst.de>
In-Reply-To: <20190625072915.GD30350@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR16CA0020.namprd16.prod.outlook.com
 (2603:10b6:208:134::33) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [209.213.91.242]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 33e4dfbc-5b01-4b89-e89c-08d6f9627a81
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6429;
x-ms-traffictypediagnostic: VI1PR05MB6429:
x-microsoft-antispam-prvs:
 <VI1PR05MB6429E15F0940959724D7B61CCFE30@VI1PR05MB6429.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0079056367
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(39860400002)(366004)(346002)(136003)(396003)(199004)(189003)(2906002)(52116002)(54906003)(8676002)(53936002)(5660300002)(11346002)(81166006)(81156014)(68736007)(66446008)(66946007)(71200400001)(478600001)(305945005)(66476007)(3846002)(6116002)(14454004)(36756003)(73956011)(1076003)(256004)(71190400001)(446003)(76176011)(486006)(316002)(7416002)(6512007)(66556008)(7736002)(64756008)(33656002)(86362001)(4326008)(6246003)(476003)(186003)(2616005)(8936002)(102836004)(26005)(6486002)(66066001)(386003)(6506007)(6436002)(229853002)(6916009)(25786009)(99286004);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6429;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 KvSArAdb6oF3ia/u73x5Rm05QnQCPBHemQrCRtpJGi8yD5h29saYmk9PT1xbrEAZJ9dPKmR+komLg+x3ZVv13yfbRnfb/cwtQ6ECdT6g5lhognBgTrUp3dW/dJMkl647bq2tpjh/ons35mu7BhmlmYoqCkfNz5XAdd7veZBiiWMwA54isp3xfz1ynXyrTmeoXcyWM4WksZzPetHcj3BtpHWkCYpxcBA3Hx3W8PMYKy1DAIveWea2oz4yjrnhztNCOPDAGng0NdfI7wuv0SBA1iZ4bf6l/58enmEryLl4O/byyEqMPxpoI0P3xJt9UMgOCwm0Qt8WR9FftnHAdcP92IdBa4mKsSsvO9UGTWsWapNf8KPFJK+ZiYGjddLsEtodSeB8kv9lcKcF4R+hXZfuNErpQPQNV62z/y1X1PA7qis=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <9099450B868E3548B355AC3B0AFD1F5E@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 33e4dfbc-5b01-4b89-e89c-08d6f9627a81
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Jun 2019 11:44:28.8132
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6429
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 09:29:15AM +0200, Christoph Hellwig wrote:
> On Thu, Jun 20, 2019 at 09:26:48PM +0200, Michal Hocko wrote:
> > On Thu 13-06-19 11:43:21, Christoph Hellwig wrote:
> > > The code hasn't been used since it was added to the tree, and doesn't
> > > appear to actually be usable.  Mark it as BROKEN until either a user
> > > comes along or we finally give up on it.
> >=20
> > I would go even further and simply remove all the DEVICE_PUBLIC code.
>=20
> I looked into that as I now got the feedback twice.  It would
> create a conflict with another tree cleaning things up around the
> is_device_private defintion, but otherwise I'd be glad to just remove
> it.
>=20
> Jason, as this goes through your tree, do you mind the additional
> conflict?

Which tree and what does the resolution look like?

Also, I don't want to be making the decision if we should keep/remove
DEVICE_PUBLIC, so let's get an Ack from Andrew/etc?

My main reluctance is that I know there is HW out there that can do
coherent, and I want to believe they are coming with patches, just
too slowly. But I'd also rather those people defend themselves :P

Thanks,
Jason

