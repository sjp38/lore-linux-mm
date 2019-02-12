Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17AB4C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:58:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B67F72075B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:58:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="Z1seC5fL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B67F72075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 519DD8E0003; Tue, 12 Feb 2019 09:58:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C95D8E0001; Tue, 12 Feb 2019 09:58:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B8138E0003; Tue, 12 Feb 2019 09:58:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D27478E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:58:39 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x47so1157722eda.8
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:58:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=sSzNBd6he1x0YLWmjimbeNK6bLjfvQApUUxCTyON9Fk=;
        b=IImlADeGjMFfLO1yJhzMedpmnr0BR0ihrSJzK18yet6XNOhiCAO7y/UZPDNaBQBFsb
         MHYRGi3dR87jyB/T6ZvqVdjHmhJ6jgBu1L2z+EZKoXmqMUpp8RJZDMKgaVTnESctFlkC
         KKFY5XSRK9XV8tgAMfrKSLxRSq2q5M3QdhG+FEAiyP3sBkNj/SVn7CI5Wsw0HGNKQLGL
         E9a/396+EGaD7FQtDLhb+s/TzBK/8EQrUsP4s9eU/oZqfHQ/V6hv16c/FNXc8T6JyjmF
         W9tskwkUIhTwXjJkYToq9IENLAh7k9KqM6gwFyfOsnVlkLSBVhuSpGpkfvPACAShip0E
         Gi9w==
X-Gm-Message-State: AHQUAuYvorEis0KwC2WkgR0OydhBAiffdOmMR8ocfWiR/PHW8MOMK0NH
	zslOaAKmXexigesm8y5se3JThePfG0zS4reRnNE4PkHb+UmtTYrYqvUFfBp59zFVQL7UbyhQ16a
	BxRUhm0E5GsBgCbguWCGYHme+njRGcHPWi+uBXXDufy8yWN8Gz0HYLTERHFN8js0qxg==
X-Received: by 2002:a50:e3cb:: with SMTP id c11mr3517499edm.80.1549983519396;
        Tue, 12 Feb 2019 06:58:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbaLIDBQX7PK/FVm8SGuOY3ztmHbG6/pWlWVRDi8G4a10KBfnuAWnr3ZHzuK/N8mnOqS2DJ
X-Received: by 2002:a50:e3cb:: with SMTP id c11mr3517451edm.80.1549983518455;
        Tue, 12 Feb 2019 06:58:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549983518; cv=none;
        d=google.com; s=arc-20160816;
        b=PhBm04viIvvV9vLocUUfqupmFIIt+hXVTHl/B8teI53fp6GN37AxRIR/cYLUVq00j/
         d0mlRfvovEGqQom99dzB3wA9uZ6u7eWk4hQlxhqejqyLpdpRzui78TyDOrIEDUobzZsB
         gWStcwKUbG6voTfFfOXdJCD9swqkeUuJzuKeqGb3qVjyRXUlAHvpoOWuv0wbUfWZLEx1
         5OBaIpUlGNhYpy5pZ0z6mNyrMGBeZYRjLBBCkMycypodu7qOXNsBAyz5qSfhxiOPPHNZ
         6Scz1ybRkJXPOHVZP6M9Qjd187j+h2MIi+4Z7JT13TyuJ8KJL4rttQNeXD+OqxgQtWhl
         +AOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=sSzNBd6he1x0YLWmjimbeNK6bLjfvQApUUxCTyON9Fk=;
        b=mwnXvAycnxO7LnBm9wgl1yxlM9I0bmOiJJujAoDXkjhiuI1GAj4gtWMnkdbNShL0Xc
         iMHt2DcYzZxFwdh67wn0cycq6Ht951aPNobb/+7Tx3NtYPla9HRL82v1Fk7sbcQltUKD
         yfwEHzw3Ulr3ljknPK+cw4J8Njg12B0MUEsCo1k1gK5IGAXTsL+/ww3DVnYi2evanaJ9
         QZE/cA3w7ctmUluKb0gZ617fl2VnX0Qqod+Wj/ymP7pV0z3BuomFlog4U07S7JZYbhn1
         8fxyFDwhvXACvwiCE8pdbGiU8gITKyV7TcLxAVHBmps58bIvLmRNGpVXE4SGO5E++ucx
         0Mfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=Z1seC5fL;
       spf=pass (google.com: domain of tariqt@mellanox.com designates 40.107.2.52 as permitted sender) smtp.mailfrom=tariqt@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20052.outbound.protection.outlook.com. [40.107.2.52])
        by mx.google.com with ESMTPS id s18si5745507eju.94.2019.02.12.06.58.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 06:58:38 -0800 (PST)
Received-SPF: pass (google.com: domain of tariqt@mellanox.com designates 40.107.2.52 as permitted sender) client-ip=40.107.2.52;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=Z1seC5fL;
       spf=pass (google.com: domain of tariqt@mellanox.com designates 40.107.2.52 as permitted sender) smtp.mailfrom=tariqt@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=sSzNBd6he1x0YLWmjimbeNK6bLjfvQApUUxCTyON9Fk=;
 b=Z1seC5fLTsuYFsoHE7DAFAIQece79niZJqotnZkcWabeb40XW3yUsCkgvzzDURjTsQUj1UcgLbPknfkbtzLTwkqDSIvqRqd8tyRgVgV+wFkIIkeJc5jhhML1Vzz8/wWXhjO5lmnS0iQ0H1Fa6nAwJqKAuAO5obrTGjNK4jVmMvg=
Received: from HE1PR05MB3257.eurprd05.prod.outlook.com (10.170.243.19) by
 HE1SPR01MB09.eurprd05.prod.outlook.com (52.133.7.26) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.21; Tue, 12 Feb 2019 14:58:34 +0000
Received: from HE1PR05MB3257.eurprd05.prod.outlook.com
 ([fe80::550a:a35e:2062:792a]) by HE1PR05MB3257.eurprd05.prod.outlook.com
 ([fe80::550a:a35e:2062:792a%7]) with mapi id 15.20.1601.023; Tue, 12 Feb 2019
 14:58:34 +0000
From: Tariq Toukan <tariqt@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>, Ilias Apalodimas
	<ilias.apalodimas@linaro.org>, Matthew Wilcox <willy@infradead.org>, David
 Miller <davem@davemloft.net>, "toke@redhat.com" <toke@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mgorman@techsingularity.net" <mgorman@techsingularity.net>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Thread-Topic: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Thread-Index:
 AQHUvvKPEpTQQqXqi0+ZzMx9yc3kKaXUb92AgAADlACAAGXpgIAAAm4AgAACaICABZPkAIAAanSAgAFFsACAABN6AIAAEz0A
Date: Tue, 12 Feb 2019 14:58:34 +0000
Message-ID: <8c12e15c-26b1-0028-e023-86bb62c7d60b@mellanox.com>
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
 <20190207150745.GW21860@bombadil.infradead.org>
 <20190207152034.GA3295@apalos>
 <20190207.132519.1698007650891404763.davem@davemloft.net>
 <20190207213400.GA21860@bombadil.infradead.org>
 <20190207214237.GA10676@Iliass-MBP.lan>
 <bfd83487-7073-18c8-6d89-e50fe9a83313@mellanox.com>
 <64f7af75-e6df-7abc-c4ce-82e6ca51fafe@gmail.com>
 <27e97aac-f25b-d46c-3e70-7d0d44f784b5@mellanox.com>
 <20190212144938.36dd45b4@carbon>
In-Reply-To: <20190212144938.36dd45b4@carbon>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: LNXP265CA0018.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:5e::30) To HE1PR05MB3257.eurprd05.prod.outlook.com
 (2603:10a6:7:35::19)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=tariqt@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [193.47.165.251]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;HE1SPR01MB09;6:lsOKb9WrwTJXnHWnt1SCOBtEDsKfeXXC4to5qUjVIixy8DFXx8r4dzwV4WZcxUhSCSw7gse1KtJXqE/Hogok2+CwkgRHy+xKG5m4sPYgt99vNZCtuHkmHMSGDhzhjt2lEvD7d3dVfWqiV5RhBRcGWSqRFcYGFWpaWlY+ENW37Q27UbTXc7UqtjuOqdNSQZ4N8kwXoRcYm0mriZQXEOdOF7VxpwATgVr0avY2mCg60XbHIxeqJqTvxrVIJhA5A+pp550hSCtDouVDR6Y8k24cHLD1D3mztPenH+cAcdHoldahxV730LGoQCQFjJL2MlKP+DUAlKkk5YcltQhcbB5xsnRIt2LMg62jHCGdyDQZ8Ya2srb92ElVAjst2fM4L5Lmb1qlBp0MKG0mzPzZNwBxcGLlNbeyLkvgfo4CLAUa5VczyBAro6JhxJt2SjMrko7DLp8K4JiTHDxnvpplPaKOvQ==;5:4OzmagM19crZfj4CVHXGOuk0++x3rHjnWKFpAhgq9BcfWqyhUXm9XO+bJnwEpzvANpuaG5zJ6rM9qNt9yBIVoT9Nb4L1ialw/jwjDP4I2ULDWh3cFpYXQvpSAfnaoOYiO3KrlwYID4sUgaoMhRjD9M/qTqNupy8hbWJbosav6qFde9OUdjHzIL/2tCj9fEDNZNXcjmxp/rZeT5SR+3f+fA==;7:tGdaWiHe5aS+nDcjFov01LtqNNoxTjKwQMbxttmt1yH99uXhZJ6NvMzC/hamBm+/kGvHSUSTc2NhWJulB5N96H3KDcHCaR7e1BmdupdlEICQu39fDQ+BCuIpbKDm3pMe99vJFqzs2FNbvwnlJo3ATw==
x-ms-office365-filtering-correlation-id: c344df8b-cbb0-443c-6a9d-08d690fa8f5e
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:HE1SPR01MB09;
x-ms-traffictypediagnostic: HE1SPR01MB09:
x-microsoft-antispam-prvs:
 <HE1SPR01MB097DA6771287BD3EB26A2CAE650@HE1SPR01MB09.eurprd05.prod.outlook.com>
x-forefront-prvs: 0946DC87A1
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(39860400002)(136003)(396003)(366004)(346002)(189003)(199004)(478600001)(8676002)(36756003)(97736004)(76176011)(8936002)(68736007)(81166006)(81156014)(14444005)(6246003)(25786009)(256004)(4326008)(6486002)(2906002)(71200400001)(71190400001)(66066001)(53936002)(3846002)(6116002)(6436002)(6916009)(2616005)(446003)(316002)(11346002)(476003)(14454004)(6512007)(106356001)(7736002)(105586002)(31686004)(93886005)(305945005)(54906003)(186003)(52116002)(102836004)(86362001)(229853002)(6506007)(31696002)(26005)(99286004)(53546011)(386003)(486006);DIR:OUT;SFP:1101;SCL:1;SRVR:HE1SPR01MB09;H:HE1PR05MB3257.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 sdfZLreImod4TDYeIZPaY2kl4/JJ81gv0D2s06X7XsmQA+jFY+CNNlZAEC3B3sVIhTAU/4LkAQb06GOgb+HhTHkg/on6V60HVhXwibnJ8HQeEMZZrock6MWhPd67jyYLTbHHATdFQ5DOEE+AcExmHni9XqIgUSokQDDh0ZoL8Ga7p2iQvDrRt0t/NmSkmpHBlmHVnn4hU9i/Nb1bUNDqcY6ofrpO1d0dZgzuQFOkb++Tb/8wmPBW8rYITmJ//gSJ2Alr0TfASIJp6XHv0iYlLMVDaWtk1GjUS/PVSo3fCAg3j+PKPnugHPgXi2WIT6jfPGW73S0UwEDtxUzwM+pPUCuCbulAWfMm+XWaKOZYuBgwnbmENbOW3I425bvEsHOMyZwcpTSTXZUD7O60+Ff6n8aUT14nvQa1y7+lAUIlfx8=
Content-Type: text/plain; charset="utf-8"
Content-ID: <7BDA101BF2E2014EA319746820BC1251@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c344df8b-cbb0-443c-6a9d-08d690fa8f5e
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Feb 2019 14:58:32.9349
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: HE1SPR01MB09
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCk9uIDIvMTIvMjAxOSAzOjQ5IFBNLCBKZXNwZXIgRGFuZ2FhcmQgQnJvdWVyIHdyb3RlOg0K
PiBPbiBUdWUsIDEyIEZlYiAyMDE5IDEyOjM5OjU5ICswMDAwDQo+IFRhcmlxIFRvdWthbiA8dGFy
aXF0QG1lbGxhbm94LmNvbT4gd3JvdGU6DQo+IA0KPj4gT24gMi8xMS8yMDE5IDc6MTQgUE0sIEVy
aWMgRHVtYXpldCB3cm90ZToNCj4+Pg0KPj4+IE9uIDAyLzExLzIwMTkgMTI6NTMgQU0sIFRhcmlx
IFRvdWthbiB3cm90ZToNCj4+Pj4gICANCj4+PiAgICANCj4+Pj4gSGksDQo+Pj4+DQo+Pj4+IEl0
J3MgZ3JlYXQgdG8gdXNlIHRoZSBzdHJ1Y3QgcGFnZSB0byBzdG9yZSBpdHMgZG1hIG1hcHBpbmcs
IGJ1dCBJIGFtDQo+Pj4+IHdvcnJpZWQgYWJvdXQgZXh0ZW5zaWJpbGl0eS4NCj4+Pj4gcGFnZV9w
b29sIGlzIGV2b2x2aW5nLCBhbmQgaXQgd291bGQgbmVlZCBzZXZlcmFsIG1vcmUgcGVyLXBhZ2Ug
ZmllbGRzLg0KPj4+PiBPbmUgb2YgdGhlbSB3b3VsZCBiZSBwYWdlcmVmX2JpYXMsIGEgcGxhbm5l
ZCBvcHRpbWl6YXRpb24gdG8gcmVkdWNlIHRoZQ0KPj4+PiBudW1iZXIgb2YgdGhlIGNvc3RseSBh
dG9taWMgcGFnZXJlZiBvcGVyYXRpb25zIChhbmQgcmVwbGFjZSBleGlzdGluZw0KPj4+PiBjb2Rl
IGluIHNldmVyYWwgZHJpdmVycykuDQo+Pj4+ICAgDQo+Pj4NCj4+PiBCdXQgdGhlIHBvaW50IGFi
b3V0IHBhZ2VyZWZfYmlhcyBpcyB0byBwbGFjZSBpdCBpbiBhIGRpZmZlcmVudA0KPj4+IGNhY2hl
IGxpbmUgdGhhbiAic3RydWN0IHBhZ2UiDQo+IA0KPiBZZXMsIGV4YWN0bHkuDQo+IA0KPiANCj4+
PiBUaGUgbWFqb3IgY29zdCBpcyBoYXZpbmcgYSBjYWNoZSBsaW5lIGJvdW5jaW5nIGJldHdlZW4g
cHJvZHVjZXIgYW5kDQo+Pj4gY29uc3VtZXIuDQo+Pg0KPj4gcGFnZXJlZl9iaWFzIGlzIG1lYW50
IHRvIGJlIGRpcnRpZWQgb25seSBieSB0aGUgcGFnZSByZXF1ZXN0ZXIsIGkuZS4gdGhlDQo+PiBO
SUMgZHJpdmVyIC8gcGFnZV9wb29sLg0KPj4gQWxsIG90aGVyIGNvbXBvbmVudHMgKGJhc2ljYWxs
eSwgU0tCIHJlbGVhc2UgZmxvdyAvIHB1dF9wYWdlKSBzaG91bGQNCj4+IGNvbnRpbnVlIHdvcmtp
bmcgd2l0aCB0aGUgYXRvbWljIHBhZ2VfcmVmY250LCBhbmQgbm90IGRpcnR5IHRoZQ0KPj4gcGFn
ZXJlZl9iaWFzLg0KPj4NCj4+IEhvd2V2ZXIsIHdoYXQgYm90aGVycyBtZSBtb3JlIGlzIGFub3Ro
ZXIgaXNzdWUuDQo+PiBUaGUgb3B0aW1pemF0aW9uIGRvZXNuJ3QgY2xlYW5seSBjb21iaW5lIHdp
dGggdGhlIG5ldyBwYWdlX3Bvb2wNCj4+IGRpcmVjdGlvbiBmb3IgbWFpbnRhaW5pbmcgYSBxdWV1
ZSBmb3IgImF2YWlsYWJsZSIgcGFnZXMsIGFzIHRoZSBwdXRfcGFnZQ0KPj4gZmxvdyB3b3VsZCBu
ZWVkIHRvIHJlYWQgcGFnZXJlZl9iaWFzLCBhc3luY2hyb25vdXNseSwgYW5kIGFjdCBhY2NvcmRp
bmdseS4NCj4+DQo+PiBUaGUgc3VnZ2VzdGVkIGhvb2sgaW4gcHV0X3BhZ2UgKHRvIGNhdGNoIHRo
ZSAyIC0+IDEgImJpYXNlZCByZWZjbnQiDQo+PiB0cmFuc2l0aW9uKSBjYXVzZXMgYSBwcm9ibGVt
IHRvIHRoZSB0cmFkaXRpb25hbCBwYWdlcmVmX2JpYXMgaWRlYSwgYXMgaXQNCj4+IGltcGxpZXMg
YSBuZXcgcG9pbnQgaW4gd2hpY2ggdGhlIHBhZ2VyZWZfYmlhcyBmaWVsZCBpcyByZWFkDQo+PiAq
YXN5bmNocm9ub3VzbHkqLiBUaGlzIHdvdWxkIHJpc2sgbWlzc2luZyB0aGUgdGhpcyBjcml0aWNh
bCAyIC0+IDENCj4+IHRyYW5zaXRpb24hIFVubGVzcyBwYWdlcmVmX2JpYXMgaXMgYXRvbWljLi4u
DQo+IA0KPiBJIHdhbnQgdG8gc3RvcCB5b3UgaGVyZS4uLg0KPiANCj4gSXQgc2VlbXMgdG8gbWUg
dGhhdCB5b3UgYXJlIHRyeWluZyB0byBzaG9laG9ybiBpbiBhIHJlZmNvdW50DQo+IG9wdGltaXph
dGlvbiBpbnRvIHBhZ2VfcG9vbC4gIFRoZSBwYWdlX3Bvb2wgaXMgb3B0aW1pemVkIGZvciB0aGUg
WERQDQo+IGNhc2Ugb2Ygb25lLWZyYW1lLXBlci1wYWdlLCB3aGVyZSB3ZSBjYW4gYXZvaWQgY2hh
bmdpbmcgdGhlIHJlZmNvdW50LA0KPiBhbmQgdHJhZGVvZmYgbWVtb3J5IHVzYWdlIGZvciBzcGVl
ZC4gIEl0IGlzIGNvbXBhdGlibGUgd2l0aCB0aGUgZWxldmF0ZWQNCj4gcmVmY291bnQgdXNhZ2Us
IGJ1dCB0aGF0IGlzIG5vdCB0aGUgb3B0aW1pemF0aW9uIHRhcmdldC4NCj4gDQo+IElmIHRoZSBj
YXNlIHlvdSBhcmUgb3B0aW1pemluZyBmb3IgaXMgInBhY2tpbmciIG1vcmUgZnJhbWVzIGluIGEg
cGFnZSwNCj4gdGhlbiB0aGUgcGFnZV9wb29sIG1pZ2h0IGJlIHRoZSB3cm9uZyBjaG9pY2UuICBU
byBtZSBpdCB3b3VsZCBtYWtlIG1vcmUNCj4gc2Vuc2UgdG8gY3JlYXRlIGFub3RoZXIgZW51bSB4
ZHBfbWVtX3R5cGUsIHRoYXQgZ2VuZXJhbGl6ZSB0aGUNCj4gcGFnZXJlZl9iaWFzIHRyaWNrcyBh
bHNvIHVzZWQgYnkgc29tZSBkcml2ZXJzLg0KPiANCg0KSGkgSmVzcGVyLA0KDQpXZSBzaGFyZSB0
aGUgc2FtZSBpbnRlcmVzdCwgSSB0cmllZCB0byBjb21iaW5lIHRoZSBwYWdlcmVmX2JpYXMgDQpv
cHRpbWl6YXRpb24gb24gdG9wIG9mIHRoZSBwdXRfcGFnZSBob29rLCBidXQgdHVybnMgb3V0IGl0
IGRvZXNuJ3QgZml0LiANClRoYXQncyBhbGwuDQoNCk9mIGNvdXJzZSwgSSBhbSBhd2FyZSBvZiB0
aGUgZmFjdCB0aGF0IHBhZ2VfcG9vbCBpcyBvcHRpbWl6ZWQgZm9yIFhEUCANCnVzZSBjYXNlcy4g
QnV0LCBhcyBkcml2ZXJzIHByZWZlciBhIHNpbmdsZSBmbG93IGZvciB0aGVpciANCnBhZ2UtYWxs
b2NhdGlvbiBtYW5hZ2VtZW50LCByYXRoZXIgdGhhbiBoYXZpbmcgc2V2ZXJhbCBhbGxvY2F0aW9u
L2ZyZWUgDQptZXRob2RzIGRlcGVuZGluZyBvbiB3aGV0aGVyIFhEUCBwcm9ncmFtIGlzIGxvYWRl
ZCBvciBub3QsIHRoZSANCnBlcmZvcm1hbmNlIGZvciBub24tWERQIGZsb3cgYWxzbyBtYXR0ZXJz
Lg0KSSBrbm93IHlvdSdyZSBub3QgaWdub3JpbmcgdGhpcywgdGhlIGZhY3QgdGhhdCB5b3UncmUg
YWRkaW5nIA0KY29tcGF0aWJpbGl0eSBmb3IgdGhlIGVsZXZhdGVkIHJlZmNvdW50IHVzYWdlIGlz
IGEga2V5IHN0ZXAgaW4gdGhpcyANCmRpcmVjdGlvbi4NCg0KQW5vdGhlciBrZXkgYmVuZWZpdCBv
ZiBwYWdlX3Bvb2wgaXMgcHJvdmlkaW5nIGEgbmV0ZGV2LW9wdGltaXplZCBBUEkgDQp0aGF0IGNh
biByZXBsYWNlIHRoZSBwYWdlIGFsbG9jYXRpb24gLyBkbWEgbWFwcGluZyBsb2dpYyBvZiB0aGUg
DQpkaWZmZXJlbnQgZHJpdmVycywgYW5kIHRha2UgaXQgaW50byBvbmUgY29tbW9uIHNoYXJlZCB1
bml0Lg0KVGhpcyBoZWxwcyByZW1vdmUgbWFueSBMT0NzIGZyb20gZHJpdmVycywgc2lnbmlmaWNh
bnRseSBpbXByb3ZlcyANCm1vZHVsYXJpdHksIGFuZCBlYXNlcyB0aGUgc3VwcG9ydCBvZiBuZXcg
b3B0aW1pemF0aW9ucy4NCkJ5IGltcHJvdmluZyB0aGUgZ2VuZXJhbCBub24tWERQIGZsb3cgKHBh
Y2tpbmcgc2V2ZXJhbCBwYWNrZXRzIGluIGEgDQpwYWdlKSB5b3UgZW5jb3VyYWdlIG1vcmUgYW5k
IG1vcmUgZHJpdmVycyB0byBkbyB0aGUgdHJhbnNpdGlvbi4NCg0KV2UgYWxsIGxvb2sgdG8gZnVy
dGhlciBpbXByb3ZlIHRoZSBwYWdlLXBvb2wgcGVyZm9ybWFuY2UuIFRoZSANCnBhZ2VyZWZfYmlh
cyBpZGVhIGRvZXMgbm90IGZpdCwgdGhhdCdzIGZpbmUuDQpXZSBjYW4gc3RpbGwgaW50cm9kdWNl
IGFuIEFQSSBmb3IgYnVsayBwYWdlLWFsbG9jYXRpb24sIGl0IHdpbGwgaW1wcm92ZSANCmJvdGgg
WERQIGFuZCBub24tWERQIGZsb3dzLg0KDQpSZWdhcmRzLA0KVGFyaXENCg==

