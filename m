Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E23686B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 11:15:45 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m190so296725pgm.4
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 08:15:45 -0700 (PDT)
Received: from esa5.hgst.iphmx.com (esa5.hgst.iphmx.com. [216.71.153.144])
        by mx.google.com with ESMTPS id g12-v6si516447plo.664.2018.04.09.08.15.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 08:15:45 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@wdc.com>
Subject: Re: Block layer use of __GFP flags
Date: Mon, 9 Apr 2018 15:15:42 +0000
Message-ID: <2d4016a71342f75009b8b6c967ee513702d677da.camel@wdc.com>
References: <20180408065425.GD16007@bombadil.infradead.org>
	 <aea2f6bcae3fe2b88e020d6a258706af1ce1a58b.camel@wdc.com>
	 <20180408190825.GC5704@bombadil.infradead.org>
	 <63d16891d115de25ac2776088571d7e90dab867a.camel@wdc.com>
	 <20180409085349.31b10550@pentland.suse.de>
	 <20180409082650.GA869@infradead.org>
In-Reply-To: <20180409082650.GA869@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <76637FC96B84AF45BDFA381669596079@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@infradead.org" <hch@infradead.org>, "hare@suse.de" <hare@suse.de>
Cc: "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "martin@lichtvoll.de" <martin@lichtvoll.de>, "oleksandr@natalenko.name" <oleksandr@natalenko.name>, "willy@infradead.org" <willy@infradead.org>, "axboe@kernel.dk" <axboe@kernel.dk>

T24gTW9uLCAyMDE4LTA0LTA5IGF0IDAxOjI2IC0wNzAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gT24gTW9uLCBBcHIgMDksIDIwMTggYXQgMDg6NTM6NDlBTSArMDIwMCwgSGFubmVzIFJl
aW5lY2tlIHdyb3RlOg0KPiA+IFdoeSBkb24ndCB5b3UgZm9sZCB0aGUgJ2ZsYWdzJyBhcmd1bWVu
dCBpbnRvIHRoZSAnZ2ZwX2ZsYWdzJywgYW5kIGRyb3ANCj4gPiB0aGUgJ2ZsYWdzJyBhcmd1bWVu
dCBjb21wbGV0ZWx5Pw0KPiA+IExvb2tzIGEgYml0IHBvaW50bGVzcyB0byBtZSwgaGF2aW5nIHR3
byBhcmd1bWVudHMgZGVub3RpbmcgYmFzaWNhbGx5DQo+ID4gdGhlIHNhbWUgLi4uDQo+IA0KPiBX
cm9uZyB3YXkgYXJvdW5kLiAgZ2ZwX2ZsYWdzIGRvZXNuJ3QgcmVhbGx5IG1ha2UgbXVjaCBzZW5z
ZSBpbiB0aGlzDQo+IGNvbnRleHQuICBXZSBqdXN0IHdhbnQgdGhlIHBsYWluIGZsYWdzIGFyZ3Vt
ZW50LCBpbmNsdWRpbmcgYSBub24tYmxvY2sNCj4gZmxhZyBmb3IgaXQuDQoNCkhlbGxvIENocmlz
dG9waCBhbmQgSGFubmVzLA0KDQpUb2RheSBzcGFyc2UgdmVyaWZpZXMgd2hldGhlciBvciBub3Qg
Z2ZwX3QgYW5kIGJsa19tcV9yZXFfdCBmbGFncyBhcmUgbm90DQptaXhlZCB3aXRoIG90aGVyIGZs
YWdzLiBDb21iaW5pbmcgdGhlc2UgdHdvIHR5cGVzIG9mIGZsYWdzIGludG8gYSBzaW5nbGUNCmJp
dCBwYXR0ZXJuIHdvdWxkIHJlcXVpcmUgc29tZSB1Z2x5IGNhc3RzIHRvIGF2b2lkIHRoYXQgc3Bh
cnNlIGNvbXBsYWlucw0KYWJvdXQgY29tYmluaW5nIHRoZXNlIGZsYWdzIGludG8gYSBzaW5nbGUg
Yml0IHBhdHRlcm4uDQoNCkJhcnQuDQoNCg0KDQo=
