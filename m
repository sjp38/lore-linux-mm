Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE8096B0003
	for <linux-mm@kvack.org>; Sun, 20 May 2018 19:10:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b25-v6so8130430pfn.10
        for <linux-mm@kvack.org>; Sun, 20 May 2018 16:10:59 -0700 (PDT)
Received: from esa2.hgst.iphmx.com (esa2.hgst.iphmx.com. [68.232.143.124])
        by mx.google.com with ESMTPS id u2-v6si9949564pgv.246.2018.05.20.16.10.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 16:10:58 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
Date: Sun, 20 May 2018 23:10:54 +0000
Message-ID: <f9fa245d2788081e68d2d6d9337256fd21283897.camel@wdc.com>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
	 <a26feed52ec6ed371b3d3b0567e31d1ff4fc31cb.camel@wdc.com>
	 <20180518090636.GA14738@kmo-pixel>
	 <8f62d8f870c6b66e90d3e7f57acee481acff57f5.camel@wdc.com>
	 <20180520221733.GA11495@kmo-pixel>
	 <bb4fd32d0baa6554615a7ec3b45cc2b89424328e.camel@wdc.com>
	 <20180520223116.GB11495@kmo-pixel>
	 <b0aa2a8737b2d826fea58dc0bc113ddce50f018a.camel@wdc.com>
	 <20180520230055.GD11495@kmo-pixel>
In-Reply-To: <20180520230055.GD11495@kmo-pixel>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <8C8959F83E50944CAA72E3305A7EE54F@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kent.overstreet@gmail.com" <kent.overstreet@gmail.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "axboe@kernel.dk" <axboe@kernel.dk>

T24gU3VuLCAyMDE4LTA1LTIwIGF0IDE5OjAwIC0wNDAwLCBLZW50IE92ZXJzdHJlZXQgd3JvdGU6
DQo+IE9uIFN1biwgTWF5IDIwLCAyMDE4IGF0IDEwOjM1OjI5UE0gKzAwMDAsIEJhcnQgVmFuIEFz
c2NoZSB3cm90ZToNCj4gPiBPbiBTdW4sIDIwMTgtMDUtMjAgYXQgMTg6MzEgLTA0MDAsIEtlbnQg
T3ZlcnN0cmVldCB3cm90ZToNCj4gPiA+IE9uIFN1biwgTWF5IDIwLCAyMDE4IGF0IDEwOjE5OjEz
UE0gKzAwMDAsIEJhcnQgVmFuIEFzc2NoZSB3cm90ZToNCj4gPiA+ID4gT24gU3VuLCAyMDE4LTA1
LTIwIGF0IDE4OjE3IC0wNDAwLCBLZW50IE92ZXJzdHJlZXQgd3JvdGU6DQo+ID4gPiA+ID4gT24g
RnJpLCBNYXkgMTgsIDIwMTggYXQgMDM6MTI6MjdQTSArMDAwMCwgQmFydCBWYW4gQXNzY2hlIHdy
b3RlOg0KPiA+ID4gPiA+ID4gT24gRnJpLCAyMDE4LTA1LTE4IGF0IDA1OjA2IC0wNDAwLCBLZW50
IE92ZXJzdHJlZXQgd3JvdGU6DQo+ID4gPiA+ID4gPiA+IE9uIFRodSwgTWF5IDE3LCAyMDE4IGF0
IDA4OjU0OjU3UE0gKzAwMDAsIEJhcnQgVmFuIEFzc2NoZSB3cm90ZToNCj4gPiA+ID4gPiA+ID4g
PiBXaXRoIEplbnMnIGxhdGVzdCBmb3ItbmV4dCBicmFuY2ggSSBoaXQgdGhlIGtlcm5lbCB3YXJu
aW5nIHNob3duIGJlbG93LiBDYW4NCj4gPiA+ID4gPiA+ID4gPiB5b3UgaGF2ZSBhIGxvb2s/DQo+
ID4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+ID4gPiBBbnkgaGludHMgb24gaG93IHRvIHJlcHJvZHVj
ZSBpdD8NCj4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+ID4gU3VyZS4gVGhpcyBpcyBob3cgSSB0cmln
Z2VyZWQgaXQ6DQo+ID4gPiA+ID4gPiAqIENsb25lIGh0dHBzOi8vZ2l0aHViLmNvbS9idmFuYXNz
Y2hlL3NycC10ZXN0Lg0KPiA+ID4gPiA+ID4gKiBGb2xsb3cgdGhlIGluc3RydWN0aW9ucyBpbiBS
RUFETUUubWQuDQo+ID4gPiA+ID4gPiAqIFJ1biBzcnAtdGVzdC9ydW5fdGVzdHMgLWMgLXIgMTAN
Cj4gPiA+ID4gPiANCj4gPiA+ID4gPiBDYW4geW91IGJpc2VjdCBpdD8gSSBkb24ndCBoYXZlIGlu
ZmluaWJhbmQgaGFyZHdhcmUgaGFuZHkuLi4NCj4gPiA+ID4gDQo+ID4gPiA+IEhlbGxvIEtlbnQs
DQo+ID4gPiA+IA0KPiA+ID4gPiBIYXZlIHlvdSBub3RpY2VkIHRoYXQgdGhlIHRlc3QgSSBkZXNj
cmliZWQgdXNlcyB0aGUgcmRtYV9yeGUgZHJpdmVyIGFuZCBoZW5jZSB0aGF0DQo+ID4gPiA+IG5v
IEluZmluaUJhbmQgaGFyZHdhcmUgaXMgbmVlZGVkIHRvIHJ1biB0aGF0IHRlc3Q/DQo+ID4gPiAN
Cj4gPiA+IE5vLCBJJ20gbm90IHRlcnJpYmx5IGZhbWlsaWFyIHdpdGggaW5maW5pYmFuZCBzdHVm
Zi4uLi4NCj4gPiA+IA0KPiA+ID4gRG8geW91IGhhdmUgc29tZSBzb3J0IG9mIHNlbGYgY29udGFp
bmVkIHRlc3QvcWVtdSByZWNpcGU/IEkgd291bGQgcmVhbGx5IHJhdGhlcg0KPiA+ID4gbm90IGhh
dmUgdG8gZmlndXJlIG91dCBob3cgdG8gY29uZmlndXJlIG11bHRpcGF0aCwgYW5kIGluZmluaWJh
bmQsIGFuZCBJJ20gbm90DQo+ID4gPiBldmVuIHN1cmUgd2hhdCBlbHNlIGlzIG5lZWRlZCBiYXNl
ZCBvbiB0aGF0IHJlYWRtZS4uLg0KPiA+IA0KPiA+IFBsZWFzZSBoYXZlIGFub3RoZXIgbG9vayBh
dCB0aGUgc3JwLXRlc3QgUkVBRE1FLiBUaGUgaW5zdHJ1Y3Rpb25zIGluIHRoYXQgZG9jdW1lbnQN
Cj4gPiBhcmUgZWFzeSB0byBmb2xsb3cuIE5vIG11bHRpcGF0aCBub3IgYW55IEluZmluaUJhbmQg
a25vd2xlZGdlIGlzIHJlcXVpcmVkLiBUaGUgdGVzdA0KPiA+IGV2ZW4gY2FuIGJlIHJ1biBpbiBh
IHZpcnR1YWwgbWFjaGluZSBpbiBjYXNlIHlvdSB3b3VsZCBiZSB3b3JyaWVkIGFib3V0IHBvdGVu
dGlhbA0KPiA+IGltcGFjdCBvZiB0aGUgdGVzdCBvbiB0aGUgcmVzdCBvZiB0aGUgc3lzdGVtLg0K
PiANCj4gWW91ciByZWFkbWUgcmVmZXJzIHRvIGtlcm5lbCBjb25maWcgb3B0aW9ucyB0aGF0IGRv
bid0IGV2ZW4gZXhpc3QgaW4gdGhlIGN1cnJlbnQNCj4ga2VybmVsDQoNClRoYXQncyBwcm9iYWJs
eSBhIG1pc3VuZGVyc3RhbmRpbmcgb2YgeW91ciBzaWRlLiBGcm9tIGEgcXVpY2sgbG9vayBpdCBz
ZWVtcyBsaWtlIGFsbA0KY29uZmlnIHN5bWJvbHMgbWVudGlvbmVkIGluIHRoZSBzcnAtdGVzdCBS
RUFETUUubWQgZXhpc3QgaW4ga2VybmVsIHY0LjE3LXJjNi4gVGhlDQpmb2xsb3dpbmcgY29tbWFu
ZCBkb2VzIG5vdCByZXBvcnQgYW55IG5vbi1leGlzdGluZyBLY29uZmlnIHN5bWJvbHM6DQoNCiQg
Y2QgbGludXgta2VybmVsDQokIHNlZCAtbiAncy9eXCogQ09ORklHXy8vcCcgfi9zb2Z0d2FyZS9p
bmZpbmliYW5kL3NycC10ZXN0L1JFQURNRS5tZCB8DQogIHdoaWxlIHJlYWQgZjsgZG8geyBnaXQg
Z3JlcCAtbHcgIiRmIiB8IGdyZXAgLXEgS2NvbmZpZzsgfSB8fCBlY2hvICRmOyBkb25lDQoNCkJh
cnQuDQoNCg0KDQo=
