Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE806B0003
	for <linux-mm@kvack.org>; Sun, 20 May 2018 18:35:34 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x2-v6so8907602plv.0
        for <linux-mm@kvack.org>; Sun, 20 May 2018 15:35:34 -0700 (PDT)
Received: from esa6.hgst.iphmx.com (esa6.hgst.iphmx.com. [216.71.154.45])
        by mx.google.com with ESMTPS id q9-v6si9967220pgt.5.2018.05.20.15.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 15:35:33 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
Date: Sun, 20 May 2018 22:35:29 +0000
Message-ID: <b0aa2a8737b2d826fea58dc0bc113ddce50f018a.camel@wdc.com>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
	 <a26feed52ec6ed371b3d3b0567e31d1ff4fc31cb.camel@wdc.com>
	 <20180518090636.GA14738@kmo-pixel>
	 <8f62d8f870c6b66e90d3e7f57acee481acff57f5.camel@wdc.com>
	 <20180520221733.GA11495@kmo-pixel>
	 <bb4fd32d0baa6554615a7ec3b45cc2b89424328e.camel@wdc.com>
	 <20180520223116.GB11495@kmo-pixel>
In-Reply-To: <20180520223116.GB11495@kmo-pixel>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <EF5011A6CF2AF24FBEEEA7D497CE0A1D@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kent.overstreet@gmail.com" <kent.overstreet@gmail.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "axboe@kernel.dk" <axboe@kernel.dk>

T24gU3VuLCAyMDE4LTA1LTIwIGF0IDE4OjMxIC0wNDAwLCBLZW50IE92ZXJzdHJlZXQgd3JvdGU6
DQo+IE9uIFN1biwgTWF5IDIwLCAyMDE4IGF0IDEwOjE5OjEzUE0gKzAwMDAsIEJhcnQgVmFuIEFz
c2NoZSB3cm90ZToNCj4gPiBPbiBTdW4sIDIwMTgtMDUtMjAgYXQgMTg6MTcgLTA0MDAsIEtlbnQg
T3ZlcnN0cmVldCB3cm90ZToNCj4gPiA+IE9uIEZyaSwgTWF5IDE4LCAyMDE4IGF0IDAzOjEyOjI3
UE0gKzAwMDAsIEJhcnQgVmFuIEFzc2NoZSB3cm90ZToNCj4gPiA+ID4gT24gRnJpLCAyMDE4LTA1
LTE4IGF0IDA1OjA2IC0wNDAwLCBLZW50IE92ZXJzdHJlZXQgd3JvdGU6DQo+ID4gPiA+ID4gT24g
VGh1LCBNYXkgMTcsIDIwMTggYXQgMDg6NTQ6NTdQTSArMDAwMCwgQmFydCBWYW4gQXNzY2hlIHdy
b3RlOg0KPiA+ID4gPiA+ID4gV2l0aCBKZW5zJyBsYXRlc3QgZm9yLW5leHQgYnJhbmNoIEkgaGl0
IHRoZSBrZXJuZWwgd2FybmluZyBzaG93biBiZWxvdy4gQ2FuDQo+ID4gPiA+ID4gPiB5b3UgaGF2
ZSBhIGxvb2s/DQo+ID4gPiA+ID4gDQo+ID4gPiA+ID4gQW55IGhpbnRzIG9uIGhvdyB0byByZXBy
b2R1Y2UgaXQ/DQo+ID4gPiA+IA0KPiA+ID4gPiBTdXJlLiBUaGlzIGlzIGhvdyBJIHRyaWdnZXJl
ZCBpdDoNCj4gPiA+ID4gKiBDbG9uZSBodHRwczovL2dpdGh1Yi5jb20vYnZhbmFzc2NoZS9zcnAt
dGVzdC4NCj4gPiA+ID4gKiBGb2xsb3cgdGhlIGluc3RydWN0aW9ucyBpbiBSRUFETUUubWQuDQo+
ID4gPiA+ICogUnVuIHNycC10ZXN0L3J1bl90ZXN0cyAtYyAtciAxMA0KPiA+ID4gDQo+ID4gPiBD
YW4geW91IGJpc2VjdCBpdD8gSSBkb24ndCBoYXZlIGluZmluaWJhbmQgaGFyZHdhcmUgaGFuZHku
Li4NCj4gPiANCj4gPiBIZWxsbyBLZW50LA0KPiA+IA0KPiA+IEhhdmUgeW91IG5vdGljZWQgdGhh
dCB0aGUgdGVzdCBJIGRlc2NyaWJlZCB1c2VzIHRoZSByZG1hX3J4ZSBkcml2ZXIgYW5kIGhlbmNl
IHRoYXQNCj4gPiBubyBJbmZpbmlCYW5kIGhhcmR3YXJlIGlzIG5lZWRlZCB0byBydW4gdGhhdCB0
ZXN0Pw0KPiANCj4gTm8sIEknbSBub3QgdGVycmlibHkgZmFtaWxpYXIgd2l0aCBpbmZpbmliYW5k
IHN0dWZmLi4uLg0KPiANCj4gRG8geW91IGhhdmUgc29tZSBzb3J0IG9mIHNlbGYgY29udGFpbmVk
IHRlc3QvcWVtdSByZWNpcGU/IEkgd291bGQgcmVhbGx5IHJhdGhlcg0KPiBub3QgaGF2ZSB0byBm
aWd1cmUgb3V0IGhvdyB0byBjb25maWd1cmUgbXVsdGlwYXRoLCBhbmQgaW5maW5pYmFuZCwgYW5k
IEknbSBub3QNCj4gZXZlbiBzdXJlIHdoYXQgZWxzZSBpcyBuZWVkZWQgYmFzZWQgb24gdGhhdCBy
ZWFkbWUuLi4NCg0KSGVsbG8gS2VudCwNCg0KUGxlYXNlIGhhdmUgYW5vdGhlciBsb29rIGF0IHRo
ZSBzcnAtdGVzdCBSRUFETUUuIFRoZSBpbnN0cnVjdGlvbnMgaW4gdGhhdCBkb2N1bWVudA0KYXJl
IGVhc3kgdG8gZm9sbG93LiBObyBtdWx0aXBhdGggbm9yIGFueSBJbmZpbmlCYW5kIGtub3dsZWRn
ZSBpcyByZXF1aXJlZC4gVGhlIHRlc3QNCmV2ZW4gY2FuIGJlIHJ1biBpbiBhIHZpcnR1YWwgbWFj
aGluZSBpbiBjYXNlIHlvdSB3b3VsZCBiZSB3b3JyaWVkIGFib3V0IHBvdGVudGlhbA0KaW1wYWN0
IG9mIHRoZSB0ZXN0IG9uIHRoZSByZXN0IG9mIHRoZSBzeXN0ZW0uDQoNCkJhcnQuDQoNCg0K
