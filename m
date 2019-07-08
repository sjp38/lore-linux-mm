Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AADAFC606C5
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:32:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F9D7216FD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:32:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="D4QnriIZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F9D7216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06AC18E0029; Mon,  8 Jul 2019 13:32:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0416F8E0027; Mon,  8 Jul 2019 13:32:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4B918E0029; Mon,  8 Jul 2019 13:32:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9307B8E0027
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 13:32:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so11855611edv.16
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 10:32:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=CyRZoytxL5GxI8Nuxt8XuYqlyWChhgVpZkttH29Bvqo=;
        b=SKHMVtPtU6+3AGkDuJuPCvr3xTJeL019PYykB60KxcLLpq/FYZvfbj+eY/7qASf+X3
         XipeKEjye+XgrZCifxt85W5W67tXjq52ZnyaV+EK7NnOxtWAa4dUAKNgOPCr/qHL7+tU
         SG4/ddYI88S/lOnBMUFBivoQc+ao0zG9k8ODxPNbQVcyRa7KdZG1E+1rOGQDlyzqgp2V
         s0MMrHPq9UqJJqWxn5L01kj4gH0HtTSFI36pJG/Oxmw0Y5JoQxRE2O/lgThpxykiaitG
         crx93KMR286MGQKMs3w14bewPUBrN9KRctw/g+HFHplEGfy20SN6YqSomKem6prJ54nb
         jJDQ==
X-Gm-Message-State: APjAAAWuIGWZTRa1BQ6jbkRneUQ6PiIeQF94mc5IUHRzuHOs4+CuU9zv
	rfgGJJbqZ0T/uaniDW3JVfAvBFrJIiW35pUem4mIsz3UVPoQIB3/Ltw2Ua9uQAoG1zBShPnOAax
	jOqTCn8AkyF1NO6pSMvDy85xfCm6nSH8cly1zkwx7sZhXrEh7ZFioZgfs0eMerSI7uw==
X-Received: by 2002:a50:acc6:: with SMTP id x64mr21959330edc.100.1562607147110;
        Mon, 08 Jul 2019 10:32:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxD7BscqWv31IxiDr010yBxFjV6bFnucePuIsyaumLC3CeRnpjGAViYRosGmkhq1Xkxzdj2
X-Received: by 2002:a50:acc6:: with SMTP id x64mr21959283edc.100.1562607146482;
        Mon, 08 Jul 2019 10:32:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562607146; cv=none;
        d=google.com; s=arc-20160816;
        b=lEa2KJVUxfhUX5okHNgRnVjpPtFph+Juv6SkCxhfBdoF2V0Zrb/snjGV+bDTjXptUD
         i+1ObE0q6vxIk0OE6qQFbQS4wdzfUN93zAVCEUOCWNTg4Se5n1D4+yfDNS0t0Sk8qqxA
         Kmjm9RJnjjDe55pq3yveWrv5xB1YRr87dJUN4S4k/JUL2tlE50I/GABaDgLsGuZ0x7Y1
         OrJuqQeysQOIGKHgfsKRNNx5z09lI1x81WbKnd6uctst5pZCGOoP5cKLFjUat+L1uxs8
         /kcc6MqkOfLhGXLcFBivTT6xJkkN2RP8oGID+eAFyc6SAwP9XbdANN8IcDH+xxivFrv7
         vSkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=CyRZoytxL5GxI8Nuxt8XuYqlyWChhgVpZkttH29Bvqo=;
        b=dAOyJYxSSjB731lkgCzUeMHNMkzkrUoMHkJUncDhE2werbjSiFS2Vkrzd8Fma+yWVr
         5mOSO4LvfpV0YO+Pp46C/jI//ep7k44RywVFhseY4Qf1hxomSuFMqy2DEn6bP87h05I9
         6BU7DDK8XO3n7k19g6F/voKFof0IM+MhdPPOAeErBFItWYjQoSI4KQEWjH5gQUIduDSy
         LvJaupVZBCBAdnUtSTue380bnMApj3/61/J8pdjI0sOTfPdGSeoLZkqackfch4vsUeq+
         FA6PWx/izIhnYBMeTqUNyHeHftc8PdrmXxNmqEpY7UcviPbEzbCQLEZown6fu9Hk3h23
         8KOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=D4QnriIZ;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.50 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10050.outbound.protection.outlook.com. [40.107.1.50])
        by mx.google.com with ESMTPS id c45si8365925eda.303.2019.07.08.10.32.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Jul 2019 10:32:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.1.50 as permitted sender) client-ip=40.107.1.50;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=D4QnriIZ;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.50 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=CyRZoytxL5GxI8Nuxt8XuYqlyWChhgVpZkttH29Bvqo=;
 b=D4QnriIZp4nCkMSSM2oTOX28PMZcD/EM4rVQVZ1eL2yXyrf+EdxcjiPBRi6WuEX8r2u9lmg+NFOAcTriiU939Jer4mN8rDHc8bGgK3JN5NsLY4eaIiryDsHapvOXyN+VUHZcLA/agG2Z19YfRhT71+nGTx5C2n1X0ZwLgJ2JiyE=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6589.eurprd05.prod.outlook.com (20.179.25.212) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2052.18; Mon, 8 Jul 2019 17:32:24 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2052.020; Mon, 8 Jul 2019
 17:32:24 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Ralph Campbell <rcampbell@nvidia.com>
CC: Christoph Hellwig <hch@lst.de>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: hmm_range_fault related fixes and legacy API removal v2
Thread-Topic: hmm_range_fault related fixes and legacy API removal v2
Thread-Index: AQHVMer7t/tGwC82LkyVSWCA9HbG9qa6qyIAgAZW04CAAABlAA==
Date: Mon, 8 Jul 2019 17:32:24 +0000
Message-ID: <20190708173219.GL23966@mellanox.com>
References: <20190703220214.28319-1-hch@lst.de>
 <20190704164236.GP3401@mellanox.com>
 <41dbb308-fc9e-d730-ffb0-6ce051dff1e1@nvidia.com>
In-Reply-To: <41dbb308-fc9e-d730-ffb0-6ce051dff1e1@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR04CA0026.namprd04.prod.outlook.com
 (2603:10b6:208:d4::39) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 06f06ac4-6250-447d-49b3-08d703ca3d01
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6589;
x-ms-traffictypediagnostic: VI1PR05MB6589:
x-microsoft-antispam-prvs:
 <VI1PR05MB65893AD6AA3A6095CC078DD2CFF60@VI1PR05MB6589.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 00922518D8
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(39860400002)(396003)(366004)(346002)(136003)(189003)(199004)(6916009)(8936002)(66556008)(2906002)(66476007)(66446008)(64756008)(66946007)(73956011)(305945005)(99286004)(81166006)(81156014)(8676002)(86362001)(102836004)(316002)(6436002)(54906003)(6246003)(36756003)(52116002)(256004)(71200400001)(71190400001)(6486002)(478600001)(14454004)(53546011)(68736007)(186003)(5660300002)(66574012)(476003)(6512007)(33656002)(11346002)(2616005)(6506007)(25786009)(26005)(386003)(66066001)(7736002)(76176011)(53936002)(486006)(4326008)(6116002)(1076003)(446003)(3846002)(229853002)(4744005);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6589;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 nY15vKNO4PNEEgep0hJ6zItN1FcRngQV6udYZyjYDpozrGLDU2uJLKpU0keTx/nEevhOBPj/hvaucyE4urOVb0RHPpgr2ma1NCYL7SbLmv67CmHEs2VXDZV29Hq0kI56JUBDc0nCsGHmevOXqmMKc2qVv25V9aSISiDyC0NRgxlidjKRpQeOgcWgP919clBsGOGQXD4+VKwVCvRlE6vB/fFiI2NdxRwqAdnPVzKZRf6+Sp0FS9gVbCio9cq6zjh7KBqS0fYd4XzYC84u+eziq5JTcxvqrunyUxw4qV5WP6+Q/IiOk4ndl7wR9u8YU3lYua0DsUP7yqWyxJUcLwzIpnwaRM7lFxgy+DzD/mDmG9BZTtcFPpMQGS5A/guKF2ExxGzAfUbQxe5q4dg+9zEsvC+Wuvfv29xC7iQkHNUYRh4=
Content-Type: text/plain; charset="utf-8"
Content-ID: <F61E600089470D4898FBE87BCA1D4B71@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 06f06ac4-6250-447d-49b3-08d703ca3d01
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Jul 2019 17:32:24.4372
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6589
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCBKdWwgMDgsIDIwMTkgYXQgMTA6MzA6NTVBTSAtMDcwMCwgUmFscGggQ2FtcGJlbGwg
d3JvdGU6DQo+IA0KPiBPbiA3LzQvMTkgOTo0MiBBTSwgSmFzb24gR3VudGhvcnBlIHdyb3RlOg0K
PiA+IE9uIFdlZCwgSnVsIDAzLCAyMDE5IGF0IDAzOjAyOjA4UE0gLTA3MDAsIENocmlzdG9waCBI
ZWxsd2lnIHdyb3RlOg0KPiA+ID4gSGkgSsOpcsO0bWUsIEJlbiBhbmQgSmFzb24sDQo+ID4gPiAN
Cj4gPiA+IGJlbG93IGlzIGEgc2VyaWVzIGFnYWluc3QgdGhlIGhtbSB0cmVlIHdoaWNoIGZpeGVz
IHVwIHRoZSBtbWFwX3NlbQ0KPiA+ID4gbG9ja2luZyBpbiBub3V2ZWF1IGFuZCB3aGlsZSBhdCBp
dCBhbHNvIHJlbW92ZXMgbGVmdG92ZXIgbGVnYWN5IEhNTSBBUElzDQo+ID4gPiBvbmx5IHVzZWQg
Ynkgbm91dmVhdS4NCj4gPiA+IA0KPiA+ID4gQ2hhbmdlcyBzaW5jZSB2MToNCj4gPiA+ICAgLSBk
b24ndCByZXR1cm4gdGhlIHZhbGlkIHN0YXRlIGZyb20gaG1tX3JhbmdlX3VucmVnaXN0ZXINCj4g
PiA+ICAgLSBhZGRpdGlvbmFsIG5vdXZlYXUgY2xlYW51cHMNCj4gPiANCj4gPiBSYWxwaCwgc2lu
Y2UgbW9zdCBvZiB0aGlzIGlzIG5vdXZlYXUgY291bGQgeW91IGNvbnRyaWJ1dGUgYQ0KPiA+IFRl
c3RlZC1ieT8gVGhhbmtzDQo+ID4gDQo+ID4gSmFzb24NCj4gPiANCj4gDQo+IEkgY2FuIHRlc3Qg
dGhpbmdzIGZhaXJseSBlYXNpbHkgYnV0IHdpdGggYWxsIHRoZSBkaWZmZXJlbnQgcGF0Y2hlcywN
Cj4gY29uZmxpY3RzLCBhbmQgcGVyc29uYWwgZ2l0IHRyZWVzLCBjYW4geW91IHNwZWNpZnkgdGhl
IGdpdCB0cmVlDQo+IGFuZCBicmFuY2ggd2l0aCBldmVyeXRoaW5nIGFwcGxpZWQgdGhhdCB5b3Ug
d2FudCBtZSB0byB0ZXN0Pw0KDQpUaGlzIHNlcmllcyB3aWxsIGJlIHB1c2hlZCB0byB0aGUgbmV4
dCBjeWNsZSwgc28gaWYgeW91IHRlc3QgdjUuMy1yYzENCisgdGhpcyBzZXJpZXMgeW91J2QgZ2V0
IHRoZSByaWdodCBjb3ZlcmFnZS4NCg0KVGhhbmtzLA0KSmFzb24NCg==

