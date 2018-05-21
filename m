Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E81B6B0006
	for <linux-mm@kvack.org>; Mon, 21 May 2018 11:11:13 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id a14-v6so10195727plt.7
        for <linux-mm@kvack.org>; Mon, 21 May 2018 08:11:13 -0700 (PDT)
Received: from esa2.hgst.iphmx.com (esa2.hgst.iphmx.com. [68.232.143.124])
        by mx.google.com with ESMTPS id b34-v6si14474262pld.272.2018.05.21.08.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 08:11:11 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
Date: Mon, 21 May 2018 15:11:08 +0000
Message-ID: <d3fbfaa667f5ac64c1f230249e3333594cb4a128.camel@wdc.com>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
	 <a26feed52ec6ed371b3d3b0567e31d1ff4fc31cb.camel@wdc.com>
	 <20180518090636.GA14738@kmo-pixel>
	 <8f62d8f870c6b66e90d3e7f57acee481acff57f5.camel@wdc.com>
	 <20180520221733.GA11495@kmo-pixel>
	 <bb4fd32d0baa6554615a7ec3b45cc2b89424328e.camel@wdc.com>
	 <20180520223116.GB11495@kmo-pixel>
	 <b0aa2a8737b2d826fea58dc0bc113ddce50f018a.camel@wdc.com>
	 <20180520232139.GE11495@kmo-pixel>
	 <238bacfbc43245159c1586189a436efbb069306b.camel@wdc.com>
	 <20180520235853.GF11495@kmo-pixel>
In-Reply-To: <20180520235853.GF11495@kmo-pixel>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <02E95219DA71BB46BA28E21F4B376E38@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kent.overstreet@gmail.com" <kent.overstreet@gmail.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "axboe@kernel.dk" <axboe@kernel.dk>

T24gU3VuLCAyMDE4LTA1LTIwIGF0IDE5OjU4IC0wNDAwLCBLZW50IE92ZXJzdHJlZXQgd3JvdGU6
DQo+IE9uIFN1biwgTWF5IDIwLCAyMDE4IGF0IDExOjQwOjQ1UE0gKzAwMDAsIEJhcnQgVmFuIEFz
c2NoZSB3cm90ZToNCj4gPiBPbiBTdW4sIDIwMTgtMDUtMjAgYXQgMTk6MjEgLTA0MDAsIEtlbnQg
T3ZlcnN0cmVldCB3cm90ZToNCj4gPiA+IEkgcmVhbGx5IGhhdmUgYmV0dGVyIHRoaW5ncyB0byBk
byB0aGFuIGRlYnVnIHNvbWVvbmUgZWxzZSdzIHRlc3RzLi4uDQo+ID4gPiBbIC4uLiBdDQo+ID4g
PiAuLi9ydW5fdGVzdHM6IGxpbmUgNjU6IGNkOiAvbGliL21vZHVsZXMvNC4xNi4wKy9rZXJuZWwv
YmxvY2s6IE5vIHN1Y2ggZmlsZSBvciBkaXJlY3RvcnkNCj4gPiANCj4gPiBLZXJuZWwgdjQuMTYg
aXMgdG9vIG9sZCB0byBydW4gdGhlc2UgdGVzdHMuIFRoZSBzcnAtdGVzdCBzY3JpcHQgbmVlZHMg
dGhlDQo+ID4gZm9sbG93aW5nIGNvbW1pdCB0aGF0IHdlbnQgdXBzdHJlYW0gaW4ga2VybmVsIHY0
LjE3LXJjMToNCj4gPiANCj4gPiA2M2NmMWE5MDJjOWQgKCJJQi9zcnB0OiBBZGQgUkRNQS9DTSBz
dXBwb3J0IikNCj4gDQo+IFNhbWUgb3V0cHV0IG9uIEplbnMnIGZvci1uZXh0IGJyYW5jaC4NCg0K
T3RoZXJzIGhhdmUgYmVlbiBhYmxlIHRvIHJ1biB0aGUgc3JwLXRlc3Qgc29mdHdhcmUgd2l0aCB0
aGUgaW5zdHJ1Y3Rpb25zDQpwcm92aWRlZCBlYXJsaWVyIGluIHRoaXMgZS1tYWlsIHRocmVhZC4g
Q2FuIHlvdSBzaGFyZSB0aGUga2VybmVsIG1lc3NhZ2VzIGZyb20NCmFyb3VuZCB0aGUgdGltZSB0
aGUgdGVzdCB3YXMgcnVuIChkbWVzZywgL3Zhci9sb2cvbWVzc2FnZXMgb3IgL3Zhci9sb2cvc3lz
bG9nKT8NCg0KVGhhbmtzLA0KDQpCYXJ0Lg0KDQoNCg0KDQoNCg==
