Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 115DFC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:05:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A32C920821
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 18:05:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="MGvVSsNn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A32C920821
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 551538E00E7; Wed,  6 Feb 2019 13:05:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 501808E00E6; Wed,  6 Feb 2019 13:05:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F1DF8E00E7; Wed,  6 Feb 2019 13:05:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD3118E00E6
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 13:05:54 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id l45so3215993edb.1
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 10:05:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=skq5LH0IKhWW3GcTIgZ8fHXVayfNlZc0eFyAdFeAXLs=;
        b=C9exHc4ilQrM5nmU8UqNIlEhQE2sj3+yrCuThyMpGZuXSbYBc2YFgi5X7a3G4lUUXu
         ymQMnvdOZaW/saZRWQ1QKRIdqkaCVwvvqnc0KyT4tWmX5jlT9GbFyysGpMElkEOrTAlJ
         2jfqpXFoCDLH/Ey9SXX7NNpVACGhNNNjlDx/Eu22Z5f5PkBfEsFaEtPIBrnpvKIO4d9U
         zy37T6pX4GkfgNYNKTN7Ta+KzmwiSSIVNdP5z/ebv1uzaGuUFSQuYJLhd3pxWXwfA4u9
         6XIg7UrPorxLbBZkWgBX4cm0eFqa2mhCU/2LxQ9K+AEKTk+i9Apq5tSkiolhFbfRtQxd
         Zx+Q==
X-Gm-Message-State: AHQUAuaUdWanubllxenkyQ2rc/sMqf18VqeFHeOOAlx4ViDJnxz6TcC7
	QQGIYojXat2Ba1xT7qNO6ZrQQlp6KvhjINrZHeiqVyvYALLv7ZCuobN9+XzsP3dkWUzvXNlM/B5
	UvjMP/UkqadiVzBlFgpz1w90YNhKqadVPL0kNFyhejs+sf995Ska/8YqjcNcVSvvntg==
X-Received: by 2002:aa7:d9d6:: with SMTP id v22mr9022500eds.265.1549476354247;
        Wed, 06 Feb 2019 10:05:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZE+SDBcX5ZiOhStUdbKot0iAUksU/lyi3zJ62kpW6V24b0z8n43goEjivlT8aHUKZs0HM2
X-Received: by 2002:aa7:d9d6:: with SMTP id v22mr9022464eds.265.1549476353428;
        Wed, 06 Feb 2019 10:05:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549476353; cv=none;
        d=google.com; s=arc-20160816;
        b=AZkWIU+3pID01vk1e6TVpCAM9M8031d9YsQsOkYvfFMkM7g+F5fHd/F7CAIWfci4dt
         fR9t2VS4sK7UstabV2jBILTYqhA4Wil9h6tKH8MsJcRaA8BHvuQYbSghHw8yfHEWyCVG
         K/V2oQspqUD81M3gdoCqJEbtzvMiXRq3t2laNXGsFF1vurDC/p3IngbPEfQvRVTu+Hlm
         NaLtAp9j3/3Uxfwk7g7hhFxlcjyglW7AVykAPexVcejhJ9m2RokVrXuz/g9Sv2ohX4mZ
         FsJ0RdPvWT18B2lp4PGAohZ99f40eewJlCdTP81UyeirCFgxGarQ36wQR5uZaSYBmMOW
         nIQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=skq5LH0IKhWW3GcTIgZ8fHXVayfNlZc0eFyAdFeAXLs=;
        b=si49WDdPv0UhHVIT9OSvbCxuTIApSIn/vMjkxw4noB1qmghgFeLUTX6sBz5YCG9Egm
         CDJFIqfOav6AVNri7U3CxWCZz42V+aW4EiJE36B5K2f+PGwnxMGXxISMeofelRKt5erU
         xLPzBMe9I39nbpuENHxmNNHIMxXYB275SD4qoHNKAM8yFOrYyzVUmhWXIKNYON3JwGLY
         LchxgtqNXiI2Ib97OT6SXvZkUfrxQsV/la+Gw/0vj3FviAWj2BU5HoOTViva07ilzxsG
         /LIYJz4oqZiUzrTKweoX1XQ4wMnWHZZx/XyqIpQY4vURXnSS79wjhHiMIV1G+b4QVSgp
         5KYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=MGvVSsNn;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.70.55 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700055.outbound.protection.outlook.com. [40.107.70.55])
        by mx.google.com with ESMTPS id 4si1515267edh.154.2019.02.06.10.05.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 10:05:53 -0800 (PST)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.70.55 as permitted sender) client-ip=40.107.70.55;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=MGvVSsNn;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.70.55 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=skq5LH0IKhWW3GcTIgZ8fHXVayfNlZc0eFyAdFeAXLs=;
 b=MGvVSsNnYYJnnkA5Y/9o2PElXlz4k8uPbJBKXqgXOauQcjSQqojAPCbsTK4vYPUeZ7HNNUWaOTIuFJIwrucKyMewf90OAexZRAb/Cp9O/xdlWkHo1FTBlcxV5eHBgesCuZuRn9uzYCT8k0oAJR1g4wdxoHO8ix7x/zfqnC9FUn8=
Received: from BL0PR05MB4772.namprd05.prod.outlook.com (20.177.145.81) by
 BL0PR05MB5249.namprd05.prod.outlook.com (20.177.242.32) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.16; Wed, 6 Feb 2019 18:05:49 +0000
Received: from BL0PR05MB4772.namprd05.prod.outlook.com
 ([fe80::52e:b645:417c:a4cf]) by BL0PR05MB4772.namprd05.prod.outlook.com
 ([fe80::52e:b645:417c:a4cf%5]) with mapi id 15.20.1601.016; Wed, 6 Feb 2019
 18:05:49 +0000
From: Nadav Amit <namit@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann
	<arnd@arndb.de>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Julien Freche <jfreche@vmware.com>, Jason
 Wang <jasowang@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
Subject: Re: [PATCH 0/6] vmw_balloon: 64-bit limit support, compaction,
 shrinker
Thread-Topic: [PATCH 0/6] vmw_balloon: 64-bit limit support, compaction,
 shrinker
Thread-Index: AQHUvkStvw9NM/JPVUmV7bK1hNU336XTEKMA
Date: Wed, 6 Feb 2019 18:05:49 +0000
Message-ID: <CE790CFD-40E2-4651-A544-17C1311C5F8C@vmware.com>
References: <20190206051336.2425-1-namit@vmware.com>
 <20190206124926-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190206124926-mutt-send-email-mst@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [208.91.2.1]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;BL0PR05MB5249;20:uUPh2nYgrRDKXZnXj7Fnrm/tc4JAyKQYSez2sGJZujwmbc2fFzAUHX5vypSBYQvbmlN3xMJeeSp/8v2PT5y3UVH+jg+xPj8TCCmfYOp5IErchM2K0fwJ4ivWevcI2MlPgQAbEaLEu2iCYfjitnypp0PH9P4g9byQk3wwtQbFbFM=
x-ms-office365-filtering-correlation-id: c9c38247-89c8-45e9-fade-08d68c5db9ce
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:BL0PR05MB5249;
x-ms-traffictypediagnostic: BL0PR05MB5249:
x-microsoft-antispam-prvs:
 <BL0PR05MB5249C951B33E803EDA5B2B73D06F0@BL0PR05MB5249.namprd05.prod.outlook.com>
x-forefront-prvs: 0940A19703
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(396003)(366004)(376002)(39860400002)(346002)(189003)(199004)(6436002)(97736004)(36756003)(106356001)(6486002)(66066001)(14454004)(256004)(316002)(4326008)(105586002)(486006)(446003)(14444005)(54906003)(6506007)(53546011)(102836004)(68736007)(26005)(186003)(6246003)(99286004)(86362001)(3846002)(71200400001)(82746002)(476003)(11346002)(8676002)(81166006)(2616005)(6116002)(6512007)(83716004)(7736002)(33656002)(6916009)(305945005)(76176011)(53936002)(229853002)(25786009)(4744005)(71190400001)(478600001)(81156014)(2906002)(8936002);DIR:OUT;SFP:1101;SCL:1;SRVR:BL0PR05MB5249;H:BL0PR05MB4772.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 SMRtLJGx1XAyhn34wTQMcbPrk8yWJbpymVDZwPkbJZDP1b5KlVq6bpGN5aE+MuGvaAkd3Ukrlrw9yxCpuQcP/rXBNK98N32dupoMyGo19oS8r70/ubi9gLD5lpdp3uS20lItOopnH2L/lu1miUPSA3Jq56iYnE6aUgPAttFLAt0S3ps1VbEOk0VhZjFSxYv0Y7XQzAfo1uHaxjW1lwrCag9yjyCFqPMaw9IOXyW6Kf82Q+tKYJxaLoKIbjn5gguGFeJiHxTLXHk5s61yO3/K57ELG1605H2lB/oCbICDy1MMrPxtfn2KVkvoG5LMeyoeHaDA4okGgM7IkFP+zsKz70TZt9jFTwtViauRfScFjtN1PRFgPeTXzB6mkPEXooT8sKLbPrw9DaWgRc5a5mjCRdJxvlbeDmF/geshk9naFt4=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <0CE6823711E6D844A289499B414298C1@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c9c38247-89c8-45e9-fade-08d68c5db9ce
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Feb 2019 18:05:49.5709
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BL0PR05MB5249
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Feb 6, 2019, at 9:52 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>=20
> On Tue, Feb 05, 2019 at 09:13:30PM -0800, Nadav Amit wrote:
>> Various enhancements for VMware balloon, some of which are remainder
>> from a previous patch-set.
>>=20
>> Patch 1: Aumps the version number, following recent changes
>> Patch 2: Adds support for 64-bit memory limit
>> Patches 3-4: Support for compaction
>> Patch 5: Support for memory shrinker - disabled by default
>> Patch 6: Split refused pages to improve performance
>>=20
>> Since the 3rd patch requires Michael Tsirkin ack, which has not arrived
>> in the last couple of times the patch was sent, please consider applying
>> patches 1-2 for 5.1.
>>=20
>> Cc: "Michael S. Tsirkin" <mst@redhat.com>
>> Cc: Jason Wang <jasowang@redhat.com>
>> Cc: linux-mm@kvack.org
>> Cc: virtualization@lists.linux-foundation.org
>=20
>=20
> I don't seem to have got anything except patch 0 either directly
> or through virtualization@lists.linux-foundation.org
> Could you bounce the relevant patches there?

Sorry for that. I will resend.

