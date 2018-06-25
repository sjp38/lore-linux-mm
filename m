Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 659866B0003
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 10:56:33 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 39-v6so8353803ple.6
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 07:56:33 -0700 (PDT)
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com. [15.241.140.78])
        by mx.google.com with ESMTPS id d18-v6si11796317pgp.214.2018.06.25.07.56.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 07:56:31 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH v3 0/3] fix free pmd/pte page handlings on x86
Date: Mon, 25 Jun 2018 14:56:26 +0000
Message-ID: <1529938470.14039.134.camel@hpe.com>
References: <20180516233207.1580-1-toshi.kani@hpe.com>
	 <alpine.DEB.2.21.1806241516410.8650@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1806241516410.8650@nanos.tec.linutronix.de>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <4246762E255CE349A995678638C71999@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "Hocko, Michal" <MHocko@suse.com>

T24gU3VuLCAyMDE4LTA2LTI0IGF0IDE1OjE5ICswMjAwLCBUaG9tYXMgR2xlaXhuZXIgd3JvdGU6
DQo+IE9uIFdlZCwgMTYgTWF5IDIwMTgsIFRvc2hpIEthbmkgd3JvdGU6DQo+IA0KPiA+IFRoaXMg
c2VyaWVzIGZpeGVzIHR3byBpc3N1ZXMgaW4gdGhlIHg4NiBpb3JlbWFwIGZyZWUgcGFnZSBoYW5k
bGluZ3MNCj4gPiBmb3IgcHVkL3BtZCBtYXBwaW5ncy4NCj4gPiANCj4gPiBQYXRjaCAwMSBmaXhl
cyBCVUdfT04gb24geDg2LVBBRSByZXBvcnRlZCBieSBKb2VyZy4gIEl0IGRpc2FibGVzDQo+ID4g
dGhlIGZyZWUgcGFnZSBoYW5kbGluZyBvbiB4ODYtUEFFLg0KPiA+IA0KPiA+IFBhdGNoIDAyLTAz
IGZpeGVzIGEgcG9zc2libGUgaXNzdWUgd2l0aCBzcGVjdWxhdGlvbiB3aGljaCBjYW4gY2F1c2UN
Cj4gPiBzdGFsZSBwYWdlLWRpcmVjdG9yeSBjYWNoZS4NCj4gPiAgLSBQYXRjaCAwMiBpcyBmcm9t
IENoaW50YW4ncyB2OSAwMS8wNCBwYXRjaCBbMV0sIHdoaWNoIGFkZHMgYSBuZXcgYXJnDQo+ID4g
ICAgJ2FkZHInLCB3aXRoIG15IG1lcmdlIGNoYW5nZSB0byBwYXRjaCAwMS4NCj4gPiAgLSBQYXRj
aCAwMyBhZGRzIGEgVExCIHB1cmdlIChJTlZMUEcpIHRvIHB1cmdlIHBhZ2Utc3RydWN0dXJlIGNh
Y2hlcw0KPiA+ICAgIHRoYXQgbWF5IGJlIGNhY2hlZCBieSBzcGVjdWxhdGlvbi4gIFNlZSB0aGUg
cGF0Y2ggZGVzY3JpcHRpb25zIGZvcg0KPiA+ICAgIG1vcmUgZGV0YWwuDQo+IA0KPiBUb3NoaSwg
Sm9lcmcsIE1pY2hhbCENCg0KSGkgVGhvbWFzLA0KDQpUaGFua3MgZm9yIGNoZWNraW5nLiBJIHdh
cyBhYm91dCB0byBwaW5nIGFzIHdlbGwuDQoNCj4gSSdtIGZhaWxpbmcgdG8gZmluZCBhIGNvbmNs
dXNpb24gb2YgdGhpcyBkaXNjdXNzaW9uLiBDYW4gd2UgZmluYWxseSBtYWtlDQo+IHNvbWUgcHJv
Z3Jlc3Mgd2l0aCB0aGF0Pw0KDQpJIGhhdmUgbm90IGhlYXJkIGZyb20gSm9lcmcgc2luY2UgSSBs
YXN0IHJlcGxpZWQgdG8gaGlzIGNvbW1lbnRzIHRvDQpQYXRjaCAzLzMgLS0gSSBkaWQgbXkgYmVz
dCB0byBleHBsYWluIHRoYXQgdGhlcmUgd2FzIG5vIGlzc3VlIGluIHRoZQ0Kc2luZ2xlIHBhZ2Ug
YWxsb2NhdGlvbiBpbiBwdWRfZnJlZV9wbWRfcGFnZSgpLiAgRnJvbSBteSBwZXJzcGVjdGl2ZSwg
dGhlDQogdjMgc2VyaWVzIGlzIGdvb2QgdG8gZ28uDQoNCj4gQ2FuIHNvbWVvbmUgZ2l2ZSBtZSBh
IGhpbnQgd2hhdCB0byBwaWNrIHVwIHVyZ2VudGx5IHBsZWFzZT8NCg0KSSd2ZSBjb25maXJtZWQg
dGhhdCB0aGUgdjMgc2VyaWVzIHN0aWxsIGFwcGxpZXMgY2xlYXJseSB0byA0LjE4LXIyDQpsaW51
cy5naXQuDQoNClBhdGNoIDEvMywgdjMgDQpodHRwczovL3BhdGNod29yay5rZXJuZWwub3JnL3Bh
dGNoLzEwNDA1MDcxLw0KDQpQYXRjaCAyLzMsIHYzLVVQREFURQ0KaHR0cHM6Ly9wYXRjaHdvcmsu
a2VybmVsLm9yZy9wYXRjaC8xMDQwNzA2NS8NCg0Kbml0OiBzb3JyeSwgcGxlYXNlIGZpeCBteSBl
bWFpbCBhZGRyZXNzIGJlbG93Lg0KLSBbdG9zaGlAaHBlLmNvbTogbWVyZ2UgY2hhbmdlcywgcmV3
cml0ZSBwYXRjaCBkZXNjcmlwdGlvbl0NCisgW3Rvc2hpLmthbmlAaHBlLmNvbTogbWVyZ2UgY2hh
bmdlcywgcmV3cml0ZSBwYXRjaCBkZXNjcmlwdGlvbl0NCg0KUGF0Y2ggMy8zLCB2Mw0KaHR0cHM6
Ly9wYXRjaHdvcmsua2VybmVsLm9yZy9wYXRjaC8xMDQwNTA3My8NCg0KVGhhbmtzLA0KLVRvc2hp
DQo=
