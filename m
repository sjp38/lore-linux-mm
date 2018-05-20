Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A05596B0003
	for <linux-mm@kvack.org>; Sun, 20 May 2018 19:40:49 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 89-v6so8852449plb.18
        for <linux-mm@kvack.org>; Sun, 20 May 2018 16:40:49 -0700 (PDT)
Received: from esa3.hgst.iphmx.com (esa3.hgst.iphmx.com. [216.71.153.141])
        by mx.google.com with ESMTPS id f17-v6si1712460pgt.243.2018.05.20.16.40.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 16:40:48 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
Date: Sun, 20 May 2018 23:40:45 +0000
Message-ID: <238bacfbc43245159c1586189a436efbb069306b.camel@wdc.com>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
	 <a26feed52ec6ed371b3d3b0567e31d1ff4fc31cb.camel@wdc.com>
	 <20180518090636.GA14738@kmo-pixel>
	 <8f62d8f870c6b66e90d3e7f57acee481acff57f5.camel@wdc.com>
	 <20180520221733.GA11495@kmo-pixel>
	 <bb4fd32d0baa6554615a7ec3b45cc2b89424328e.camel@wdc.com>
	 <20180520223116.GB11495@kmo-pixel>
	 <b0aa2a8737b2d826fea58dc0bc113ddce50f018a.camel@wdc.com>
	 <20180520232139.GE11495@kmo-pixel>
In-Reply-To: <20180520232139.GE11495@kmo-pixel>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <9BBC200AF993E04D9BC9734E2B816F86@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kent.overstreet@gmail.com" <kent.overstreet@gmail.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "axboe@kernel.dk" <axboe@kernel.dk>

T24gU3VuLCAyMDE4LTA1LTIwIGF0IDE5OjIxIC0wNDAwLCBLZW50IE92ZXJzdHJlZXQgd3JvdGU6
DQo+IEkgcmVhbGx5IGhhdmUgYmV0dGVyIHRoaW5ncyB0byBkbyB0aGFuIGRlYnVnIHNvbWVvbmUg
ZWxzZSdzIHRlc3RzLi4uDQo+IFsgLi4uIF0NCj4gLi4vcnVuX3Rlc3RzOiBsaW5lIDY1OiBjZDog
L2xpYi9tb2R1bGVzLzQuMTYuMCsva2VybmVsL2Jsb2NrOiBObyBzdWNoIGZpbGUgb3IgZGlyZWN0
b3J5DQoNCktlcm5lbCB2NC4xNiBpcyB0b28gb2xkIHRvIHJ1biB0aGVzZSB0ZXN0cy4gVGhlIHNy
cC10ZXN0IHNjcmlwdCBuZWVkcyB0aGUNCmZvbGxvd2luZyBjb21taXQgdGhhdCB3ZW50IHVwc3Ry
ZWFtIGluIGtlcm5lbCB2NC4xNy1yYzE6DQoNCjYzY2YxYTkwMmM5ZCAoIklCL3NycHQ6IEFkZCBS
RE1BL0NNIHN1cHBvcnQiKQ0KDQpCYXJ0Lg0KDQoNCg==
