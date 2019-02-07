Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C404C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:12:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE08921904
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:12:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=raithlin.onmicrosoft.com header.i=@raithlin.onmicrosoft.com header.b="cLJKbULx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE08921904
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=raithlin.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61FC68E0050; Thu,  7 Feb 2019 12:12:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 602358E0002; Thu,  7 Feb 2019 12:12:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E2078E0050; Thu,  7 Feb 2019 12:12:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2761C8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 12:12:56 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id b192so6025593itb.0
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 09:12:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :user-agent:content-id:content-transfer-encoding:mime-version;
        bh=xhkX4kyquyhfAPut4hwfVsgQ6KPYouVvKuAcCGy6uVc=;
        b=BUumNwXt7hjAEQSiwwwBmk75ueHvp02FSYo75RQKTznoKbW2AXeiaAXiqFGHi5Tv7Z
         LusuKnn3lSoNLGYxCKc7r/2g9TeVXR4buRfiCve5PE6Fzvn+sUfCTYH94goO4g68jALw
         rcH0FcCi8A+SHP1wJ7pnpX9b6RYu3iGSvrW5hLF6H1ZIRyeoSeld3/KZ5WPYEtuO0Yjg
         d0xWmVOu78NVeZyoIV067ldK/oG5BX+rQGdKPtG/DGsoQMYIefrUW3epQQ7KwYj9SoMK
         ItYxmdXDqvoBDydtM79YjvPIzSry1b9EPvj+dKTMotLyTHGhF0wGapevIIX6CpIY83+L
         dWkQ==
X-Gm-Message-State: AHQUAuZvJ/iPTyYcoN3Lz/bXggKa6ozGRIlBjBNsjaIFt4qGMumS7FAf
	UUFBQIauSxdR5K+0HsQrCfZ/vRxdIEp03Op2Nmcq1LP2abvok6A9IilPx545AumKBDCniato3Eb
	R9tgSRdhCelnEujX3shlYvywi0iLqKIG/ft4kUtU7E8gNdsyK7GTJjlQ7Zn1vCJbbuQ==
X-Received: by 2002:a02:41c7:: with SMTP id n68mr9605570jad.61.1549559575834;
        Thu, 07 Feb 2019 09:12:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbCUOoDULK/MD4SyvkI2Q7DWNBBYBPpq9uMuGyzBparimIy9YzLWcZRzlO/zagZb2hdIpIs
X-Received: by 2002:a02:41c7:: with SMTP id n68mr9605499jad.61.1549559574813;
        Thu, 07 Feb 2019 09:12:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549559574; cv=none;
        d=google.com; s=arc-20160816;
        b=n68KTeWIBorx780hj+MDgmbQPabIALRxkfck1PdmdJWbi9clE8aXnyot+pGmpfj5xw
         hGeWBtU6oqLNaGc43HUksiFkpwYGZngjyDkkHCm7iPZTQAIJPY/p4LArx3GdThsEOBEU
         JfrXNw453W1JOuP+ArDZxz30QgjEThePTOY0B1nMXIu1jjLyaMfpHoniCgzinglBTjqy
         aqB2NrNHH1J/3uapDS8vLYKVORQLl/o1WkgLgYMZEsB+4XhKXiTXmVEl/gVj1/Gvjr6U
         8o3ZFrvHb6kXqkZNLBTTX/9X8FRqBuyQSIJYn3qVLcWbqkaP8j3NKshnEtxKcXn2ou1m
         vCZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=xhkX4kyquyhfAPut4hwfVsgQ6KPYouVvKuAcCGy6uVc=;
        b=pX7h8ra2evqf3Wo4fNGeGbDjNM5C/tz0V+9pJGk6G1XT4FKBmLBaBgVojl9/qzRiti
         /m7f6idVNOiuz+znXm+9H6nZQ8bbrV9LhOsML8yI4g/8lBL83t4L0eKQCZ5UoYfjgJDt
         3rE1ereuN8OCpNbnQ/y7IWe8VWgaikP0DLfyHBfHoKMhyKY7Ie/5+0fuhstLs1s6dj4w
         oFHo3OiOG9xpwGqlEmKdUzLnzkPFH8QhQrcba8fhrmzSW6gUzLzpxb22wh/TcKukU2XS
         zmyztOsxoRhvrb/AZQ5d06EjKDdNarMIwFSyAgrTrndY80bv2URidt0onO9JQsqwNL4x
         dNiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@raithlin.onmicrosoft.com header.s=selector1-raithlin-com header.b=cLJKbULx;
       spf=pass (google.com: domain of sbates@raithlin.com designates 40.107.66.106 as permitted sender) smtp.mailfrom=sbates@raithlin.com
Received: from CAN01-QB1-obe.outbound.protection.outlook.com (mail-eopbgr660106.outbound.protection.outlook.com. [40.107.66.106])
        by mx.google.com with ESMTPS id k12si792794ioq.139.2019.02.07.09.12.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Feb 2019 09:12:54 -0800 (PST)
Received-SPF: pass (google.com: domain of sbates@raithlin.com designates 40.107.66.106 as permitted sender) client-ip=40.107.66.106;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@raithlin.onmicrosoft.com header.s=selector1-raithlin-com header.b=cLJKbULx;
       spf=pass (google.com: domain of sbates@raithlin.com designates 40.107.66.106 as permitted sender) smtp.mailfrom=sbates@raithlin.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=raithlin.onmicrosoft.com; s=selector1-raithlin-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xhkX4kyquyhfAPut4hwfVsgQ6KPYouVvKuAcCGy6uVc=;
 b=cLJKbULxmNaB2tSbn5gukDIHvXEQ6PAgBmuOAnlFxzMsxOyaLXlcclnIbLR37ZtMuFL61M7HHqLXs0UjMy0Wz3RGdOl3Q0H0UNJ+pWkcKDqvo6C/uATzDxId/naL41uTqVqdotGPsyW6hZnUhB7OlwSjKYBjnqoWMHidJhU4dzI=
Received: from YQXPR0101MB0728.CANPRD01.PROD.OUTLOOK.COM (52.132.75.145) by
 YQXPR0101MB1096.CANPRD01.PROD.OUTLOOK.COM (52.132.78.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.19; Thu, 7 Feb 2019 17:12:52 +0000
Received: from YQXPR0101MB0728.CANPRD01.PROD.OUTLOOK.COM
 ([fe80::3984:214:c472:b3d7]) by YQXPR0101MB0728.CANPRD01.PROD.OUTLOOK.COM
 ([fe80::3984:214:c472:b3d7%2]) with mapi id 15.20.1601.016; Thu, 7 Feb 2019
 17:12:52 +0000
From: "Stephen  Bates" <sbates@raithlin.com>
To: Jens Axboe <axboe@kernel.dk>, linux-fsdevel
	<linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	"linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, IDE/ATA
 development list <linux-ide@vger.kernel.org>, linux-scsi
	<linux-scsi@vger.kernel.org>, "linux-nvme@lists.infradead.org"
	<linux-nvme@lists.infradead.org>, Logan Gunthorpe <logang@deltatee.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"bpf@vger.kernel.org" <bpf@vger.kernel.org>, "ast@kernel.org"
	<ast@kernel.org>
Subject: [LSF/MM TOPIC] BPF for Block Devices
Thread-Topic: [LSF/MM TOPIC] BPF for Block Devices
Thread-Index: AQHUvwhboOvoMzJnxEqbA/z88fpLtw==
Date: Thu, 7 Feb 2019 17:12:52 +0000
Message-ID: <40D2EB06-6BF2-4233-9196-7A26AC43C64E@raithlin.com>
Accept-Language: en-CA, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Microsoft-MacOutlook/10.16.0.190203
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=sbates@raithlin.com; 
x-originating-ip: [70.65.250.31]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;YQXPR0101MB1096;6:ob6azazJQUOEsRZD3gVCXkxJoaGEQ4oaRr29iFRgd6B4ZOSU36ZYy2D9SXgqQwxYRKcPdbO0P2tlm7MsB0A4Mu8OA2tzZxRFlVJnURmhAVM2Mg00q5hHHe75te2PRbmsdEtS44fBXBQ89TuOaW9oAYrC6tz17sNMggQ5U3yVQ5Tdcto2xwp8sM8iiauN7R3hfMq2TFA5mPCAgpYULUv+AZNIlAwm8OdbbOEu9ftQ/GBOgDUIk0vycXxydXXEA8CzpBWwNmawFQ3ZVtc54gbMJ+Uprbe5MY6i9OLaAjcenoPoLkUlqBsb6h5+sPHiRSDl/LdMafRMe27pOuY7bN2B1n3dt3zgRrc6IHpXVM/bqng4q3CYFu0mr5Gzxfz5P0mXIVMYpHEoN6Cdr2gpWBXk8RejtQI97PtWKB+uAzs7YsNFZNUR3NvS3e7bGXwhMHY8oUF8xC5KJ7cQSRw1g036Uw==;5:fBzSAnsB9JER0Ld1ad0Jx85+NrMF1y415qL7qHvyNrbHbPngSB5/T/SmCH2N0I4vPIuDWtr629xsEm6V+NwShrLViYYXhcORRiuFRm6Ze1hJKZc0wYZ4uX2usWhtIGoOP5JGoQXVXm6WRyVVySRGmeE6kcKOaATi5YdHc+YwTXlgKX26x65GiuNLr9TwhvocVM7HmgFnCMv0LPuN/IUd7Q==;7:vwtk3Hf5BLBrleCgmILXEE0McusnAynS3HfL78URuvS9XeKJj5Ik0rmKSxAylIQYUcUqeXQHxFm5P+LPFx4qoYBr87Eqp/gN9QkvtM2rQl8B9NGVMzd8jlEyng2D/GvfAmlYTjM69MAGjXB0eBAhyA==
x-ms-office365-filtering-correlation-id: e627a5eb-b078-428f-a380-08d68d1f7e5b
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(7021145)(8989299)(4534185)(7022145)(4603075)(4627221)(201702281549075)(8990200)(7048125)(7024125)(7027125)(7023125)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:YQXPR0101MB1096;
x-ms-traffictypediagnostic: YQXPR0101MB1096:
x-microsoft-antispam-prvs:
 <YQXPR0101MB109684F0B1A4A96A46C95C29AA680@YQXPR0101MB1096.CANPRD01.PROD.OUTLOOK.COM>
x-forefront-prvs: 0941B96580
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(366004)(346002)(136003)(376002)(39830400003)(396003)(199004)(189003)(53754006)(8676002)(476003)(186003)(486006)(7416002)(6506007)(102836004)(110136005)(54906003)(81166006)(81156014)(2616005)(58126008)(26005)(7736002)(86362001)(6306002)(36756003)(99286004)(105586002)(316002)(305945005)(106356001)(256004)(14444005)(68736007)(14454004)(4326008)(3846002)(966005)(6116002)(25786009)(2906002)(83716004)(71200400001)(71190400001)(2501003)(33656002)(6512007)(82746002)(508600001)(66066001)(97736004)(8936002)(53936002)(6436002)(6486002);DIR:OUT;SFP:1102;SCL:1;SRVR:YQXPR0101MB1096;H:YQXPR0101MB0728.CANPRD01.PROD.OUTLOOK.COM;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: raithlin.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 MxvFc1fOz11+eyBeylzZK2apkhk30AJza2Zu79KJh2GEgyZW4/iJloqAQDFkETtEVbLol4H3uoyd9/lhTkHqFzA95Hd24vK8wkZgbx4OoSvwQUpns6Id3a/uLRpY5ZbF7yK+cnOUcAH7ZlTS8Q99t8h9uXsrwnCYInkd9jrpmDBmAMvv6cB2ZS/iyRrQVC5tU4Do4lcIawimvQdpw1skcRqzVuuqCxg6dN1QYKrPdoklnnOU8aVzRDDzEWWd7JKm93/Uz8JzdJdgeNUW8L5j+jyy/jaNwpUU6yWRLoOfFgALU/xBfkjFYB9gUT2tTUQUYH23mz37dgJ3sXEBGiV7lf9TRAkNwIclArS/x5mAe2cORSE8F+FVgBgNZZ9BP94VtmhJ7uoup2gNKAj2tvGSb1i9C5i8chGCCel+AKSfk8s=
Content-Type: text/plain; charset="utf-8"
Content-ID: <80AE72F32E8C7642AD78708C57CA9358@CANPRD01.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: raithlin.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e627a5eb-b078-428f-a380-08d68d1f7e5b
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Feb 2019 17:12:52.1490
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 18519031-7ff4-4cbb-bbcb-c3252d330f4b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: YQXPR0101MB1096
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgQWxsDQoNCj4gQSBCUEYgdHJhY2sgd2lsbCBqb2luIHRoZSBhbm51YWwgTFNGL01NIFN1bW1p
dCB0aGlzIHllYXIhIFBsZWFzZSByZWFkIHRoZSB1cGRhdGVkIGRlc2NyaXB0aW9uIGFuZCBDRlAg
aW5mb3JtYXRpb24gYmVsb3cuDQoNCldlbGwgaWYgd2UgYXJlIGFkZGluZyBCUEYgdG8gTFNGL01N
IEkgaGF2ZSB0byBzdWJtaXQgYSByZXF1ZXN0IHRvIGRpc2N1c3MgQlBGIGZvciBibG9jayBkZXZp
Y2VzIHBsZWFzZSENCg0KVGhlcmUgaGFzIGJlZW4gcXVpdGUgYSBiaXQgb2YgYWN0aXZpdHkgYXJv
dW5kIHRoZSBjb25jZXB0IG9mIENvbXB1dGF0aW9uYWwgU3RvcmFnZSBpbiB0aGUgcGFzdCAxMiBt
b250aHMuIFNOSUEgcmVjZW50bHkgZm9ybWVkIGEgVGVjaG5pY2FsIFdvcmtpbmcgR3JvdXAgKFRX
RykgYW5kIGl0IGlzIGV4cGVjdGVkIHRoYXQgdGhpcyBUV0cgd2lsbCBiZSBtYWtpbmcgcHJvcG9z
YWxzIHRvIHN0YW5kYXJkcyBsaWtlIE5WTSBFeHByZXNzIHRvIGFkZCBBUElzIGZvciBjb21wdXRh
dGlvbiBlbGVtZW50cyB0aGF0IHJlc2lkZSBvbiBvciBuZWFyIGJsb2NrIGRldmljZXMuDQoNCldo
aWxlIHNvbWUgb2YgdGhlc2UgQ29tcHV0YXRpb25hbCBTdG9yYWdlIGFjY2VsZXJhdG9ycyB3aWxs
IHByb3ZpZGUgZml4ZWQgZnVuY3Rpb25zIChlLmcuIGEgUkFJRCwgZW5jcnlwdGlvbiBvciBjb21w
cmVzc2lvbiksIG90aGVycyB3aWxsIGJlIG1vcmUgZmxleGlibGUuIFNvbWUgb2YgdGhlc2UgZmxl
eGlibGUgYWNjZWxlcmF0b3JzIHdpbGwgYmUgY2FwYWJsZSBvZiBydW5uaW5nIEJQRiBjb2RlIG9u
IHRoZW0gKHNvbWV0aGluZyB0aGF0IGNlcnRhaW4gTGludXggZHJpdmVycyBmb3IgU21hcnROSUNz
IHN1cHBvcnQgdG9kYXkgWzFdKS4gSSB3b3VsZCBsaWtlIHRvIGRpc2N1c3Mgd2hhdCBzdWNoIGEg
ZnJhbWV3b3JrIGNvdWxkIGxvb2sgbGlrZSBmb3IgdGhlIHN0b3JhZ2UgbGF5ZXIgYW5kIHRoZSBm
aWxlLXN5c3RlbSBsYXllci4gSSdkIGxpa2UgdG8gZGlzY3VzcyBob3cgZGV2aWNlcyBjb3VsZCBh
ZHZlcnRpc2UgdGhpcyBjYXBhYmlsaXR5IChhIHNwZWNpYWwgdHlwZSBvZiBOVk1lIG5hbWVzcGFj
ZSBvciBTQ1NJIExVTiBwZXJoYXBzPykgYW5kIGhvdyB0aGUgQlBGIGVuZ2luZSBjb3VsZCBiZSBw
cm9ncmFtbWVkIGFuZCB0aGVuIHVzZWQgYWdhaW5zdCBibG9jayBJTy4gSWRlYWxseSBJJ2QgbGlr
ZSB0byBkaXNjdXNzIGRvaW5nIHRoaXMgaW4gYSB2ZW5kb3ItbmV1dHJhbCB3YXkgYW5kIGRldmVs
b3AgaWRlYXMgSSBjYW4gdGFrZSBiYWNrIHRvIE5WTWUgYW5kIHRoZSBTTklBIFRXRyB0byBoZWxw
IHNoYXBlIGhvdyB0aGVzZSBzdGFuZGFyZCBldm9sdmUuDQoNClRvIHByb3ZpZGUgYW4gZXhhbXBs
ZSB1c2UtY2FzZSBvbmUgY291bGQgY29uc2lkZXIgYSBCUEYgY2FwYWJsZSBhY2NlbGVyYXRvciBi
ZWluZyB1c2VkIHRvIHBlcmZvcm0gYSBmaWx0ZXJpbmcgZnVuY3Rpb24gYW5kIHRoZW4gdXNpbmcg
cDJwZG1hIHRvIHNjYW4gZGF0YSBvbiBhIG51bWJlciBvZiBhZGphY2VudCBOVk1lIFNTRHMsIGZp
bHRlcmluZyBzYWlkIGRhdGEgYW5kIHRoZW4gb25seSBwcm92aWRpbmcgZmlsdGVyLW1hdGNoZWQg
TEJBcyB0byB0aGUgaG9zdC4gTWFueSBvdGhlciBwb3RlbnRpYWwgYXBwbGljYXRpb25zIGFwcGx5
LiANCg0KQWxzbywgSSBhbSBpbnRlcmVzdGVkIGluIHRoZSAiVGhlIGVuZCBvZiB0aGUgREFYIEV4
cGVyaW1lbnQiIHRvcGljIHByb3Bvc2VkIGJ5IERhbiBhbmQgdGhlICIgWm9uZWQgQmxvY2sgRGV2
aWNlcyIgZnJvbSBNYXRpYXMgYW5kIERhbWllbi4NCg0KQ2hlZXJzDQogDQpTdGVwaGVuDQoNClsx
XSBodHRwczovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC90b3J2YWxk
cy9saW51eC5naXQvdHJlZS9kcml2ZXJzL25ldC9ldGhlcm5ldC9uZXRyb25vbWUvbmZwL2JwZi9v
ZmZsb2FkLmM/aD12NS4wLXJjNQ0KIA0KICAgIA0KDQo=

